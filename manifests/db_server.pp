# == Class: ora_rac::db_server
#
# This class installs a second or third or... RAC node. It clone's all information
# from the db_master node and add's the node to the RAC cluster
#
# === Parameters
#
# Check ora_rac::params for all the parameters
#
# === Variables
#
# Check ora_rac::params for all the variables
#
# === Authors
#
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::db_server(
  Hash $db_machines                = $::ora_rac::params::db_machines,
) inherits ::ora_rac::params {
  case $::ora_rac::settings::version {
    '11.2.0.4', '12.1.0.2': {
      $cluster_new_node_roles=""
    }
    '12.2.0.1': {
      $cluster_new_node_roles="\"CLUSTER_NEW_NODE_ROLES={HUB}\""
    }
  }

  exec{'add_grid_node':
    timeout => 0,
    user    => $::ora_rac::settings::grid_user,
    command => "/usr/bin/ssh ${ora_rac::settings::grid_user}@${::ora_rac::params::master_node} \"${ora_rac::settings::grid_home}/\"${ora_rac::settings::add_node_path} \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\" ${cluster_new_node_roles}",
    creates => "${ora_rac::settings::grid_home}/root.sh",
  }

  -> exec{'register_grid_node':
    timeout => 0,
    user    => 'root',
    creates => "${ora_rac::settings::grid_base}/${::hostname}",
    returns => [0,25],
    command => "/bin/sh ${ora_rac::settings::ora_inventory_dir}/oraInventory/orainstRoot.sh;/bin/sh ${ora_rac::settings::grid_home}/root.sh",
  }


  $difference  = regsubst($::ora_rac::settings::oracle_home,$::ora_rac::settings::oracle_base,'')
  $directories = split($difference,'/')
  $non_empty_directories = $directories.filter |$element| { $element != ''}

  $non_empty_directories.reduce($::ora_rac::settings::oracle_base) |$base_path, $relative_path| {
    $path = "${base_path}/${relative_path}"
    file{ $path:
      ensure  => 'directory',
      owner   => $::ora_rac::settings::oracle_user,
      group   => $::ora_rac::settings::install_group,
      before  => Exec['add_oracle_node'],
      require => Exec['register_grid_node'],
    }
    $path
  }

  exec{'add_oracle_node':
    timeout   => 0,
    user      => $::ora_rac::settings::grid_user,
    command   => "/usr/bin/ssh ${ora_rac::settings::oracle_user}@${ora_rac::params::master_node} \"${ora_rac::settings::oracle_home}/\"${ora_rac::settings::add_node_path} \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\" ${cluster_new_node_roles}",
    logoutput => on_failure,
    creates   => "${ora_rac::settings::oracle_home}/root.sh",
    require   => Exec['register_grid_node'],
  }

  ~> exec{'register_oracle_node':
    refreshonly => true,
    timeout     => 0,
    user        => 'root',
    command     => "/bin/sh ${ora_rac::settings::ora_inventory_dir}/oraInventory/orainstRoot.sh;/bin/sh ${ora_rac::settings::oracle_home}/root.sh",
    logoutput   => on_failure,
  }

  -> ora_rac::oratab_entry{$::ora_rac::params::current_instance:
    home    => $::ora_rac::settings::oracle_home,
    start   => 'N',
    comment => 'Added by puppet',
  }

  -> exec{'add_instance':
    user        => $::ora_rac::settings::oracle_user,
    environment => ["ORACLE_SID=${::ora_rac::params::current_instance}", 'ORAENV_ASK=NO', "ORACLE_HOME=${::ora_rac::settings::oracle_home}"],
    command     => "${ora_rac::settings::oracle_home}/bin/srvctl add instance -d ${::ora_rac::params::db_name} -i ${::ora_rac::params::current_instance} -n ${::hostname}",
    unless      => "${ora_rac::settings::oracle_home}/bin/srvctl status instance -d ${::ora_rac::params::db_name} -i ${::ora_rac::params::current_instance}",
    logoutput   => on_failure,
  }

  ~> exec{'chmod_oracle':
    refreshonly => true,
    command     => "/bin/chown ${::ora_rac::settings::oracle_user} ${::ora_rac::settings::oracle_base}",
  }

  -> exec{'start_instance':
    user        => $::ora_rac::settings::oracle_user,
    environment => ["ORACLE_SID=${::ora_rac::params::current_instance}", 'ORAENV_ASK=NO',"ORACLE_HOME=${::ora_rac::settings::oracle_home}"],
    command     => "${::ora_rac::settings::oracle_home}/bin/srvctl start instance -d ${::ora_rac::params::db_name} -i ${::ora_rac::params::current_instance}",
    onlyif      => "${::ora_rac::settings::oracle_home}/bin/srvctl status instance -d ${::ora_rac::params::db_name} -i ${::ora_rac::params::current_instance} | grep not",
    logoutput   => on_failure,
  }

  $current_asm_instance = $::ora_rac::params::current_instance[-1,1]

  ora_setting { "+ASM${current_asm_instance}":
    oracle_home => $::ora_rac::settings::grid_home,
    syspriv     => 'sysasm',
  }

  ora_setting { $::ora_rac::params::current_instance:
    oracle_home => $::ora_rac::settings::oracle_home,
    default     => true,
  }
}
