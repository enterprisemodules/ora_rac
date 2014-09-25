# == Class: ora_rac::os
#
# This class takes care of installing and configuring the OS
# layer as a prerequisite for creating the DB generic
# instance.
#
# === Parameters
#
# *iptables_lines*
#   Array of hashes of iptables entries
#
# *sysctl_lines*
#   Array of hashes of sysctl entries
#
# === Variables
#
# === Authors
#
# Allard Berends <allard.berends@prorail.nl>
#
# === Copyright
#
# Copyright 2013 Allard Berends
#
# ==== Design
#
# To make the generic Oracle database installation possible,
# we need to conduct the following steps:
# * adapt /etc/fstab
# * create Oracle groups and accounts
# * set /etc/security/limits.conf
# * set /etc/sysconfig/iptables
# * set /etc/sysctl.conf
#
class ora_rac::os (
  $etc_profile    = '/etc/profile',
  $config_limits  = '/etc/security/limits.conf',
) inherits ora_rac::params {
  # TODO: Fix the devices 
  #   'title'   => 'net.ipv4.conf.eth2.rp_filter',
  #   'comment' => '# Disable rp_filtering on interconnects',
  #   'setting' => 'net.ipv4.conf.eth2.rp_filter = 2',
  # },
  # {
  #   'title'   => 'net.ipv4.conf.eth3.rp_filter',
  #   'comment' => '# Disable rp_filtering on interconnects',
  #   'setting' => 'net.ipv4.conf.eth3.rp_filter = 2',
  # },
  # {
  #   'title'   => 'net.ipv4.conf.bond0/103.rp_filter',
  #   'comment' => '# Disable rp_filtering on interconnects',
  #   'setting' => 'net.ipv4.conf.bond0/103.rp_filter = 1',
  # },
  # Sysctl{ permanent => 'yes'}

  sysctl {'net.ipv4.ip_local_port_range':
    ensure    => 'present',
    value     => '9000 65500',
    comment   => 'TODO: Add comment',
  }

  sysctl {'kernel.shmall':
    ensure    => 'present',
    value     => '65536000',
    comment   => 'TODO: Add comment',
  }

  sysctl {'kernel.shmmax':
    ensure    => 'present',
    value     => '4294967296',
    comment   => 'TODO: Add comment',
  }

  sysctl {'kernel.msgmni':
    ensure    => 'present',
    value     => '2878',
    comment   => 'TODO: Add comment',
  }

  sysctl {'kernel.sem':
    ensure    => 'present',
    value     => '2510 356420 2510 142',
    comment   => 'TODO: Add comment',
  }

  sysctl { 'kernel.shmmni':
    ensure    => 'present',
    value     => '4096',
    comment   => 'TODO: Add comment',
  }

  sysctl {'fs.file-max':
    ensure    => 'present',
    value     => '6815744',
    comment   => 'TODO: Add comment',
  }

  sysctl {'fs.aio-max-nr':
    ensure    => 'present',
    value     => '1572864',
    comment   => 'TODO: Add comment',
  }

  sysctl {'net.core.rmem_default':
    ensure    => 'present',
    value     => '262144',
    comment   => 'TODO: Add comment',
  }

  sysctl {'net.core.rmem_max':
    ensure    => 'present',
    value     => '4194304',
    comment   => 'TODO: Add comment',
  }

 sysctl {'net.core.wmem_default':
    ensure    => 'present',
    value     => '262144',
    comment   => 'TODO: Add comment',
  }

  sysctl {'net.core.wmem_max':
    ensure    => 'present',
    value     => '1048576',
    comment   => 'TODO: Add comment',
  }

  sysctl {'sunrpc.tcp_slot_table_entries':
    ensure    => 'present',
    value     => '128',
    comment   => 'TODO: Add comment',
  }

  sysctl {'vm.max_map_count':
    ensure    => 'present',
    value     => '100000',
    comment   => 'TODO: Add comment',
  }

  augeas {'ensure_tmpfs_size':
    context    => '/files/etc/fstab',
    changes    => [
      "ins opt after *[spec = 'tmpfs'][file = '/dev/shm']/opt[last()]",
      "set *[spec = 'tmpfs']/opt[last()] size",
      "set *[spec = 'tmpfs']/opt[last()]/value ${orashm}m",
    ],
    onlyif     => "match *[spec='tmpfs'][file = '/dev/shm']/opt[. = 'size'] size == 0",
  }

  exec {'remount_tmpfs':
    command    => '/bin/mount -o remount /dev/shm',
    onlyif     => "/usr/bin/test -z $(/bin/mount | /bin/grep /dev/shm | /bin/grep -o size=${orashm}m)",
    require    => Augeas['ensure_tmpfs_size'],
  }


  ['install','dba','oper', 'grid','grid_oper', 'grid_admin'].each |$group| {
    $variable_name  = "${group}_group"
    $group_name     = getvar($variable_name)
    $group_id_name  = "${variable_name}_id"
    $gid            = getvar($group_id_name)
    group {$group_name:
      ensure => 'present',
      gid    => $gid,
    }
  }

  user {$oracle_user:
    ensure     => present,
    comment    => 'Oracle user',
    gid        => $install_group_id,
    groups     => [
                    $dba_group,
                    $grid_group,
                    $oper_group,
                  ],
    uid        => $install_group_id,
    shell      => '/bin/bash',
    home       => "/home/${oracle_user}",
    managehome => true,
    require    => Group[$dba_group, $oper_group, $install_group],
  }


  ora_rac::user_equivalence{$oracle_user:
    nodes => $ora_rac::params::all_nodes,
  }

  file {"/home/${$oracle_user}/.bash_profile":
    ensure    => file,
    owner     => $oracle_user,
    group     => $dba_group,
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/bash_profile',
    require   => User[$oracledb_user],
  }


  user {$grid_user:
    ensure     => present,
    comment    => 'Oracle Grid user',
    gid        => $install_group_id,
    groups     => [
                    $dba_group,
                    $grid_group,
                    $grid_admin_group,
                    $grid_oper_group,
                  ],
    uid        => $grid_uid,
    shell      => '/bin/bash',
    home       => "/home/${grid_user}",
    managehome => true,
    require    => Group[$install_group,$dba_group, $grid_group, $grid_admin_group, $grid_oper_group],
  }

  file {"/home/${grid_user}/.bash_profile":
    ensure    => file,
    owner     => $grid_user,
    group     => $asm_group,
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/bash_profile',
    require   => User[$grid_user],
  }

  ora_rac::user_equivalence{$grid_user:
    nodes => $ora_rac::params::all_nodes,
  }

  file {$config_limits:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/limits'
  }

  file {$etc_profile:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/etc_profile'
  }

  class{'ora_rac::swapspace':}

  $all_ip_addresses.each |$ipadress| {
    firewall{"200 RAC communication for ${ipadress}":
      chain   => 'RH-Firewall-1-INPUT',
      source  => $ipadress,
      action  => 'accept',
    }
  }

  firewall { '200 DB listner':
    chain   => 'RH-Firewall-1-INPUT',
    port   => 1521,
    proto  => tcp,
    action => 'accept',
  }
  firewall { '200 DB gridcontrol':
    chain   => 'RH-Firewall-1-INPUT',
    port   => 3872,
    proto  => tcp,
    action => 'accept',
  }

  firewall { '200 RAC Multicast':
    chain   => 'RH-Firewall-1-INPUT',
    pkttype => 'multicast',
    action => 'accept',
  }


  $private_interfaces.each | $interface| {
    firewall {'200 Oracle Cluster Interconnect':
      chain   => 'RH-Firewall-1-INPUT',
      proto   => 'all',
      iniface => $interface,
      action  => 'accept',
    }    
  }



} # end ora_rac::os
