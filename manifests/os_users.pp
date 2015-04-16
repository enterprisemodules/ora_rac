# == Class: ora_rac::os_users
#
# This class takes care of creating the required ora_rac users ands groups
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::os_users inherits ora_rac::params {

  require ora_rac::settings

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
    uid        => $ora_rac::settings::oracle_user_id,
    shell      => '/bin/bash',
    home       => "/home/${ora_rac::settings::oracle_user}",
    managehome => true,
    require    => Group[$ora_rac::settings::dba_group, $ora_rac::settings::oper_group, $ora_rac::settings::install_group],
  } ->

  ora_rac::user_equivalence{$ora_rac::settings::oracle_user:
    nodes       => $ora_rac::params::cluster_nodes,
    private_key => $ora_rac::params::oracle_private_key,
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
  } ->

  ora_rac::user_equivalence{$ora_rac::settings::grid_user:
    nodes       => $ora_rac::params::cluster_nodes,
    private_key => $ora_rac::params::grid_private_key,
  }

  file {"/home/${ora_rac::settings::grid_user}/.bash_profile":
    ensure    => file,
    owner     => $ora_rac::settings::grid_user,
    group     => $ora_rac::settings::asm_group,
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/bash_profile',
    require   => User[$ora_rac::settings::grid_user],
  }
}

