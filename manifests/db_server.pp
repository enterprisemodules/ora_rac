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
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::db_server(
  $db_machines                = $ora_rac::params::db_machines,
) inherits ora_rac::params {
  assert_type(Hash, $db_machines)                 |$e, $a| { fail "db_machines is ${a}, but should be a Hash of machines"}


  #
  # Validate parameters
  #
  validate_hash($db_machines)

  exec{'add_grid_node':
    timeout     => 0,
    user        => $ora_rac::settings::grid_user,
    command     => "/usr/bin/ssh ${ora_rac::settings::grid_user}@${master_node} \"${ora_rac::settings::grid_home}/\"${ora_rac::settings::add_node_path} \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\"",
    creates     => "${ora_rac::settings::grid_home}/root.sh",
  } ->

  exec{'register_grid_node':
    timeout     => 0,
    user        => 'root',
    creates     => "${ora_rac::settings::grid_base}/${::hostname}",
    returns     => [0,25],
    command     => "/bin/sh ${ora_rac::settings::ora_inventory_dir}/oraInventory/orainstRoot.sh;/bin/sh ${ora_rac::settings::grid_home}/root.sh",
  }


  $difference  = regsubst($ora_rac::settings::oracle_home,$ora_rac::settings::oracle_base,'')
  $directories = split($difference,'/')
  $non_empty_directories = $directories.filter |$element| { $element != ''}

  $non_empty_directories.reduce($ora_rac::settings::oracle_base) |$base_path, $relative_path| {
    $path = "${base_path}/${relative_path}"
    file{ $path:
      ensure    => 'directory',
      owner     => $ora_rac::settings::oracle_user,
      group     => $ora_rac::settings::install_group,
      before    => Exec['add_oracle_node'],
      require   => Exec['register_grid_node'],
    }
    $path
  }


  exec{'add_oracle_node':
    timeout     => 0,
    user        => $ora_rac::settings::grid_user,
    command     => "/usr/bin/ssh ${ora_rac::settings::oracle_user}@${master_node} \"${ora_rac::settings::oracle_home}/\"${ora_rac::settings::add_node_path} \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\"",
    logoutput   => on_failure,
    creates     => "${ora_rac::settings::oracle_home}/root.sh",
    require     => [
      Exec['register_grid_node']
    ]
  }~>

  exec{'register_oracle_node':
    refreshonly => true,
    timeout     => 0,
    user        => 'root',
    command     => "/bin/sh ${ora_rac::settings::ora_inventory_dir}/oraInventory/orainstRoot.sh;/bin/sh ${ora_rac::settings::oracle_home}/root.sh",
    logoutput   => on_failure,
  }->

  ora_rac::oratab_entry{$current_instance:
    home      => $ora_rac::settings::oracle_home,
    start     => 'N',
    comment   => 'Added by puppet',
  } ->

  exec{'add_instance':
    user          => $ora_rac::settings::oracle_user,
    environment   => ["ORACLE_SID=${current_instance}", "ORAENV_ASK=NO", "ORACLE_HOME=${ora_rac::settings::oracle_home}"],
    command       => "${ora_rac::settings::oracle_home}/bin/srvctl add instance -d ${db_name} -i ${current_instance} -n ${::hostname}",
    unless        => "${ora_rac::settings::oracle_home}/bin/srvctl status instance -d ${db_name} -i ${current_instance}",
    logoutput     => on_failure,
  } ~>

  exec{'chmod_oracle':
    refreshonly => true,
    command     => "/bin/chown ${ora_rac::settings::oracle_user} ${ora_rac::settings::oracle_base}"
  } ->

  exec{'start_instance':
    user          => $ora_rac::settings::oracle_user,
    environment   => ["ORACLE_SID=${current_instance}", "ORAENV_ASK=NO","ORACLE_HOME=/opt/oracle/app/${ora_rac::settings::version}/db_1"],
    command       => "${ora_rac::settings::oracle_home}/bin/srvctl start instance -d ${db_name} -i ${current_instance}",
    onlyif        => "${ora_rac::settings::oracle_home}/bin/srvctl status instance -d ${db_name} -i ${current_instance} | grep not",
    logoutput     => on_failure,
  }

}
