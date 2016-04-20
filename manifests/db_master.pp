# == Class: ora_rac::db_master
#
# This class installes the master database node. A master database node is
# the first machine to be installed. All db_server machines (see class ora_rac::db_server)
# take their configuration of this master node.
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
class ora_rac::db_master(
  $db_name                    = $ora_rac::params::db_name,
  $domain_name                = $ora_rac::params::domain_name,
  $scan_adresses              = $ora_rac::params::scan_adresses,
  $db_machines                = $ora_rac::params::db_machines,
  $init_ora_content           = $ora_rac::params::init_ora_content,
  $public_network_interfaces  = $ora_rac::params::public_network_interfaces,
  $private_network_interfaces = $ora_rac::params::private_network_interfaces,
  $unused_network_interfaces  = $ora_rac::params::unused_network_interfaces,
  $cluster_name               = $ora_rac::params::cluster_name,             # name of the cluster
  $password                   = $ora_rac::params::password,
  $scan_name                  = $ora_rac::params::scan_name,
  $scan_port                  = $ora_rac::params::scan_port,
  $crs_disk_group_name        = $ora_rac::params::crs_disk_group_name,
  $crs_disk                   = $ora_rac::params::crs_disk,
  $data_disk_group_name       = $ora_rac::params::data_disk_group_name,
  $disk_redundancy            = $ora_rac::params::disk_redundancy,
  $config_scripts             = $ora_rac::params::config_scripts,
) inherits ora_rac::params {

  #
  # Validation of parameters
  #
  assert_type(String[1,8], $db_name) |$e, $a| {
    fail "dbname is ${a}, but must be between 1 and 8 character length string"
  }
  assert_type(Array, $scan_adresses) |$e, $a| {
    fail "scan_addresses is ${a}, but must be an array of IP adresses" 
  }
  assert_type(String[1], $domain_name) |$e, $a| {
    fail "domain_name is ${a}, but must be a non empty string"
  }
  assert_type(Hash, $db_machines) |$e, $a| {
    fail "db_machines is ${a}, but should be a Hash of machines"
  }

  assert_type(String[1], $init_ora_content) |$e, $a| {
    fail "init_ora_content is ${a}, but must be a non empty string"
  }
  assert_type(Array, $public_network_interfaces) |$e, $a| {
    fail "public_network_interfaces is a ${a}, but must be an array of interfaces"
  }
  assert_type(Array, $private_network_interfaces) |$e, $a| {
    fail "private_network_interfaces is a ${a}, but must be an array of interfaces"
  }
  assert_type(Array, $unused_network_interfaces) |$e, $a| {
    fail "unused_network_interfaces is a ${a}, but must be an array of interfaces"
  }
  assert_type(String[1], $cluster_name) |$e, $a| {
   fail "cluster_name is ${a}, but should be a non empty string"
  }
  assert_type(String[1], $password) |$e, $a| {
   fail "password is ${a}, but should be a non empty string"
  }
  assert_type(String[1], $scan_name) |$e, $a| {
   fail "scan_name is ${a}, but should be a non empty string"
  }
  assert_type(Integer, $scan_port) |$e, $a| {
   fail "scan_port is ${a}, but should be an integer number"
  }
  assert_type(String[1], $crs_disk_group_name) |$e, $a| {
   fail "crs_disk_group_name is ${a}, but should be a non empty string"
  }
  assert_type(String[1], $crs_disk)  |$e, $a| {
   fail "crs_disk is ${a}, but should be a non empty string"
  }
  assert_type(String[1], $data_disk_group_name)   |$e, $a| {
   fail "data_disk_group_name is ${a}, but should be a non empty string"
  }
  assert_type(Enum['NORMAL','EXTERNAL', 'HIGH'], $disk_redundancy)
  assert_type(Array[Hash], $config_scripts)   |$e, $a| {
   fail "config_scripts is ${a}, but should be a an array of Hashes describing the config scripts."
  }


  require ora_rac::settings

  $database_definition = hiera('ora_rac::internal::database_definition')

  if $::operatingsystemmajrelease == 6 {
    #
    # Replace cvu_config CV_ASSUME_DISTID=OEL4 for V_ASSUME_DISTID=OEL6
    #
    file{"${ora_rac::settings::oracle_home}/cv/admin/cvu_config":
      ensure  => 'file',
      owner   => $ora_rac::settings::oracle_user,
      group   => $ora_rac::settings::install_group,
      source  => 'puppet:///modules/ora_rac/cvu_config',
      require => Oradb::Installdb[$ora_rac::settings::_oracle_file],
      before  => Ora_database[$db_name],
    }

    file{"${ora_rac::settings::grid_home}/cv/admin/cvu_config":
      ensure  => 'file',
      owner   => $ora_rac::settings::grid_user,
      group   => $ora_rac::settings::install_group,
      source  => 'puppet:///modules/ora_rac/cvu_config',
      require => Oradb::Installasm[$ora_rac::settings::_grid_file],
      before  => Ora_database[$db_name],
    }
  }

  # Create all ASM disks before staring the ASM installation
  Ora_rac::Asm_disk<||> -> Oradb::Installasm<||> 

  oradb::installasm{ $ora_rac::settings::_grid_file:
    version                   => $ora_rac::settings::version,
    file                      => $ora_rac::settings::_grid_file,
    grid_type                 => 'CRS_CONFIG',
    grid_base                 => $ora_rac::settings::grid_base,
    grid_home                 => $ora_rac::settings::grid_home,
    ora_inventory_dir         => $ora_rac::settings::ora_inventory_dir,
    user                      => $ora_rac::settings::grid_user,
    group                     => $ora_rac::settings::grid_group,
    group_install             => $ora_rac::settings::install_group,
    group_oper                => $ora_rac::settings::grid_oper_group,
    group_asm                 => $ora_rac::settings::grid_admin_group,
    disk_discovery_string     => $ora_rac::params::disk_discovery_string,
    asm_diskgroup             => $crs_disk_group_name,
    disks                     => $crs_disk,
    disk_redundancy           => $disk_redundancy,
    puppet_download_mnt_point => $ora_rac::settings::puppet_download_mnt_point,
    download_dir              => $ora_rac::settings::download_dir,
    zip_extract               => $ora_rac::settings::zip_extract,
    remote_file               => $ora_rac::settings::remote_file, #false,
    cluster_name              => $cluster_name,
    scan_name                 => $scan_name,
    scan_port                 => $scan_port,
    cluster_nodes             => "${::hostname}:${::hostname}-vip",
    network_interface_list    => $ora_rac::params::nw_interface_list,
    storage_option            => 'ASM_STORAGE',
  } ->

  oradb::installdb{ $ora_rac::settings::_oracle_file:
    version                   => $ora_rac::settings::version,
    file                      => $ora_rac::settings::_oracle_file,
    user                      => $ora_rac::settings::oracle_user,
    group                     => $ora_rac::settings::dba_group,
    group_oper                => $ora_rac::settings::oper_group,
    group_install             => $ora_rac::settings::install_group,
    ora_inventory_dir         => $ora_rac::settings::ora_inventory_dir,
    database_type             => 'EE',
    oracle_base               => $ora_rac::settings::oracle_base,
    oracle_home               => $ora_rac::settings::oracle_home,
    puppet_download_mnt_point => $ora_rac::settings::puppet_download_mnt_point,
    download_dir              => $ora_rac::settings::download_dir,
    cluster_nodes             => $::hostname,
    remote_file               => $ora_rac::settings::remote_file,
    require                   => Oradb::Installasm[$ora_rac::settings::_grid_file],
    before                    => Ora_database[$db_name],
  }

  $full_database_definition = merge($database_definition, {config_scripts => $config_scripts})
  ensure_resource(ora_database, $db_name, $full_database_definition)

  ora_rac::oratab_entry{"${db_name}1":
    home    => $ora_rac::settings::oracle_home,
    start   => 'N',
    comment => 'Added by puppet',
    require => Ora_database[$db_name],
  }->

  exec{'register_diskgroups':
    refreshonly   => true,
    user          => $ora_rac::settings::oracle_user,
    environment   => ["ORACLE_SID=${db_name}1", "ORAENV_ASK=NO", "ORACLE_HOME=${ora_rac::settings::oracle_home}"],
    command       => "${ora_rac::settings::grid_home}/bin/srvctl modify database -d ${db_name} -a ${ora_rac::settings::disk_group_names.join(',')}",
    logoutput     => on_failure,
    subscribe     => Ora_database[$db_name],
  }

  $cluster_nodes.each | $index, $instance| {
    $instance_number  = $index + 1
    $thread           = $instance_number
    $instance_name    = "${db_name}${instance_number}"

    if ($instance_number > 1) { # Not a master node

      ora_rac::ora_instance{$instance_name:
        on                 => $master_instance,
        number             => $instance_number,
        thread             => $thread,
        datafile           => $ora_rac::settings::data_file_destination,
        undo_initial_size  => $ora_rac::settings::undo_initial_size,
        undo_next          => $ora_rac::settings::undo_next,
        undo_autoextend    => $ora_rac::settings::undo_autoextend,
        undo_max_size      => $ora_rac::settings::undo_max_size,
        require => [
          Ora_rac::Oratab_entry["${db_name}1"],
        ]
      }
    }
  }

}