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

  require ora_rac::params
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

  group {$oracledb_group:
    ensure     => present,
    gid        => $oracledb_gid,
  }

  group {$dba_group:
    ensure     => present,
    gid        => $dba_gid,
  }

  group {$osdba_group:
    ensure     => present,
    gid        => $osdba_gid,
  }

  group {$asm_group:
    ensure     => present,
    gid        => $asm_gid,
  }

  group {$oper_group:
    ensure     => present,
    gid        => $oper_gid,
  }

  group {$asm_oper_group:
    ensure     => present,
    gid        => $asm_oper_gid,
  }

  user {$oracledb_user:
    ensure     => present,
    comment    => 'Oracle user',
    gid        => $oracledb_gid,
    groups     => [
                    $dba_group,
                    $osdba_group,
                    $asm_group,
                    $oper_group
                  ],
    uid        => $oracledb_uid,
    shell      => '/bin/bash',
    home       => "/home/${oracledb_user}",
    managehome => true,
    require    => Group[
                    $oracledb_group,
                    $dba_group,
                    $osdba_group,
                    $asm_group,
                    $oper_group
                  ],
  }


  ora_rac::user_equivalence{$oracledb_user:
    nodes => $ora_rac::params::all_nodes,
  }

  file {"/home/${$oracledb_user}/.bash_profile":
    ensure    => file,
    owner     => $oracledb_user,
    group     => $osdba_group,
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/bash_profile',
    require   => User[$oracledb_user],
  }


  user {$grid_user:
    ensure     => present,
    comment    => 'Oracle Grid user',
    gid        => $oracledb_gid,
    groups     => [
                    $dba_group,
                    $osdba_group,
                    $asm_group,
                    $asm_oper_group
                  ],
    uid        => $grid_uid,
    shell      => '/bin/bash',
    home       => "/home/${grid_user}",
    managehome => true,
    require    => Group[
                    $oracledb_group,
                    $dba_group,
                    $osdba_group,
                    $asm_group,
                    $asm_oper_group
                  ],
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


  exec { "create swap file":
    command => "/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=8192",
    creates => "/var/swap.1",
  }

  exec { "attach swap file":
    command => "/sbin/mkswap /var/swap.1 && /sbin/swapon /var/swap.1",
    require => Exec["create swap file"],
    unless => "/sbin/swapon -s | grep /var/swap.1",
  }

  #add swap file entry to fstab
  exec {"add swapfile entry to fstab":
    command => "/bin/echo >>/etc/fstab /var/swap.1 swap swap defaults 0 0",
    require => Exec["attach swap file"],
    user => root,
    unless => "/bin/grep '^/var/swap.1' /etc/fstab 2>/dev/null",
  }

  firewall { '10 DB listner':
    port   => 1521,
    proto  => tcp,
    action => accept,
  }
  firewall { '20 DB gridcontrol':
    port   => 3872,
    proto  => tcp,
    action => accept,
  }
  firewall {'30 DB multicast':
    pkttype   => 'multicast',
    action    => accept,
  }

} # end ora_rac::os
