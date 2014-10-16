# == Class: ora_rac::os
#
# This class takes care of installing and configuring the OS
# layer as a prerequisite for creating the DB generic
# instance.
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::os (
  $etc_profile    = '/etc/profile',
  $config_limits  = '/etc/security/limits.conf',
) inherits ora_rac::params {

  augeas {'ensure_tmpfs_size':
    context => '/files/etc/fstab',
    changes => [
      "ins opt after *[spec = 'tmpfs'][file = '/dev/shm']/opt[last()]",
      "set *[spec = 'tmpfs']/opt[last()] size",
      "set *[spec = 'tmpfs']/opt[last()]/value ${orashm}m",
    ],
    onlyif  => "match *[spec='tmpfs'][file = '/dev/shm']/opt[. = 'size'] size == 0",
  }

  exec {'remount_tmpfs':
    command => '/bin/mount -o remount /dev/shm',
    onlyif  => "/usr/bin/test -z $(/bin/mount | /bin/grep /dev/shm | /bin/grep -o size=${orashm}m)",
    require => Augeas['ensure_tmpfs_size'],
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

  user{ $oracle_user:
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
    nodes => $ora_rac::params::cluster_nodes,
  }

  file {"/home/${$oracle_user}/.bash_profile":
    ensure  => file,
    owner   => $oracle_user,
    group   => $dba_group,
    mode    => '0644',
    source  => 'puppet:///modules/ora_rac/bash_profile',
    require => User[$oracle_user],
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
    nodes => $ora_rac::params::cluster_nodes,
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


} # end ora_rac::os
