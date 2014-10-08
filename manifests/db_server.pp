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
  $version                    = $ora_rac::params::version,                  # Oracle version to install
  $oracle_base                = $ora_rac::params::oracle_base,              # Base for Oracle
  $grid_base                  = $ora_rac::params::grid_base,                # Base for grid
  $oracle_home                = $ora_rac::params::oracle_home,              # Oracle home
  $grid_home                  = $ora_rac::params::grid_home,                # Grid home
  $ora_inventory_dir          = $ora_rac::params::ora_inventory_dir,
  $oracle_user                = $ora_rac::params::oracle_user,
  $oracle_user_id             = $ora_rac::params::oracle_user_id,
  $grid_user                  = $ora_rac::params::grid_user,
  $grid_user_id               = $ora_rac::params::grid_user_id,
  $dba_group                  = $ora_rac::params::dba_group,
  $dba_group_id               = $ora_rac::params::dba_group_id,
  $grid_group                 = $ora_rac::params::grid_group,
  $grid_group_id              = $ora_rac::params::grid_group_id,
  $install_group              = $ora_rac::params::install_group,
  $install_group_id           = $ora_rac::params::group_install_id,
  $grid_oper_group            = $ora_rac::params::grid_oper_group,
  $grid_oper_group_id         = $ora_rac::params::grid_oper_group_id,
  $grid_admin_group           = $ora_rac::params::grid_admin_group,
  $grid_admin_group_id        = $ora_rac::params::grid_admin_group_id,
) inherits ora_rac::params {


  exec{'add_grid_node':
    timeout => 0,
    user    => $grid_user,
    command => "/usr/bin/ssh ${grid_user}@${master_node} \"${grid_home}/\"${add_node_path} \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\"",
    creates => "${grid_home}/root.sh",
  } ->

  exec{'register_grid_node':
    timeout => 0,
    user    => 'root',
    creates => "${grid_base}/grid/${::hostname}",
    command => "/bin/sh ${ora_inventory_dir}/oraInventory/orainstRoot.sh;/bin/sh ${grid_home}/root.sh",
  }


  $difference  = regsubst($oracle_home,$oracle_base,'')
  $directories = split($difference,'/')
  $non_empty_directories = $directories.filter |$element| { $element != ''}

  $non_empty_directories.reduce($oracle_base) |$base_path, $relative_path| {
    $path = "${base_path}/${relative_path}"
    file{ $path:
      ensure  => 'directory',
      owner   => $oracle_user,
      group   => $install_group,
      before  => Exec['add_oracle_node'],
      require => Exec['register_grid_node'],
    }
    $path
  }


  exec{'add_oracle_node':
    timeout   => 0,
    user      => $grid_user,
    command   => "/usr/bin/ssh ${oracle_user}@${master_node} \"${oracle_home}/\"${add_node_path} \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\"",
    logoutput => on_failure,
    creates   => "${oracle_home}/root.sh",
    require   => [
      Exec['register_grid_node']
    ]
  }->


  exec{'register_oracle_node':
    timeout   => 0,
    user      => 'root',
    # creates   => $oracle_home,
    command   => "/bin/sh ${ora_inventory_dir}/oraInventory/orainstRoot.sh;/bin/sh ${oracle_home}/root.sh",
    logoutput => on_failure,
  }->

  class{'ora_rac::ensure_oracle_ownership':} ->

  ora_rac::oratab_entry{$current_instance:
    home    => $oracle_home,
    start   => 'N',
    comment => 'Added by puppet',
  } ->


  exec{'add_instance':
    user        => $oracle_user,
    environment => ["ORACLE_SID=${current_instance}", "ORAENV_ASK=NO", "ORACLE_HOME=${oracle_home}"],
    command     => "${oracle_home}/bin/srvctl add instance -d ${db_name} -i ${current_instance} -n ${::hostname}",
    unless      => "${oracle_home}/bin/srvctl status instance -d ${db_name} -i ${current_instance}",
    logoutput   => on_failure,
  } ->

  exec{'start_instance':
    user        => $oracle_user,
    environment => ["ORACLE_SID=${current_instance}", "ORAENV_ASK=NO","ORACLE_HOME=/opt/oracle/app/${version}/db_1"],
    command     => "${oracle_home}/bin/srvctl start instance -d ${db_name} -i ${current_instance}",
    onlyif      => "${oracle_home}/bin/srvctl status instance -d ${db_name} -i ${current_instance} | grep not",
    logoutput   => on_failure,
  }

}
