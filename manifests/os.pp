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
class ora_rac::os inherits ora_rac::params {

  require ora_rac::settings

  $orashm = floor( ($::memorysize_mb * 1024 * 1024) / 2 )

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
    $variable_name  = "ora_rac::settings::${group}_group"
    $group_name     = getvar($variable_name)
    $group_id_name  = "${variable_name}_id"
    $gid            = getvar($group_id_name)
    group {$group_name:
      ensure => 'present',
      gid    => $gid,
    }
  }

  user{ $ora_rac::settings::oracle_user:
    ensure     => present,
    comment    => 'Oracle user',
    gid        => $ora_rac::settings::install_group_id,
    groups     => [
                    $ora_rac::settings::dba_group,
                    $ora_rac::settings::grid_group,
                    $ora_rac::settings::oper_group,
                  ],
    uid        => $ora_rac::settings::install_group_id,
    shell      => '/bin/bash',
    home       => "/home/${ora_rac::settings::oracle_user}",
    managehome => true,
    require    => Group[$ora_rac::settings::dba_group, $ora_rac::settings::oper_group, $ora_rac::settings::install_group],
  }

  ora_rac::user_equivalence{$ora_rac::settings::oracle_user:
    nodes => $ora_rac::params::cluster_nodes,
  }

  file {"/home/${$ora_rac::settings::oracle_user}/.bash_profile":
    ensure  => file,
    owner   => $ora_rac::settings::oracle_user,
    group   => $ora_rac::settings::dba_group,
    mode    => '0644',
    source  => 'puppet:///modules/ora_rac/bash_profile',
    require => User[$ora_rac::settings::oracle_user],
  }

  user {$ora_rac::settings::grid_user:
    ensure     => present,
    comment    => 'Oracle Grid user',
    gid        => $ora_rac::settings::install_group_id,
    groups     => [
                    $ora_rac::settings::dba_group,
                    $ora_rac::settings::grid_group,
                    $ora_rac::settings::grid_admin_group,
                    $ora_rac::settings::grid_oper_group,
                  ],
    uid        => $ora_rac::settings::grid_uid,
    shell      => '/bin/bash',
    home       => "/home/${ora_rac::settings::grid_user}",
    managehome => true,
    require    => Group[$ora_rac::settings::install_group,$ora_rac::settings::dba_group, $ora_rac::settings::grid_group, $ora_rac::settings::grid_admin_group, $ora_rac::settings::grid_oper_group],
  }

  file {"/home/${ora_rac::settings::grid_user}/.bash_profile":
    ensure    => file,
    owner     => $ora_rac::settings::grid_user,
    group     => $ora_rac::settings::asm_group,
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/bash_profile',
    require   => User[$ora_rac::settings::grid_user],
  }

  ora_rac::user_equivalence{$ora_rac::settings::grid_user:
    nodes => $ora_rac::params::cluster_nodes,
  }

  file {'/etc/security/limits.conf':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/limits'
  }

  file {'/etc/profile':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/etc_profile'
  }


} # end ora_rac::os
