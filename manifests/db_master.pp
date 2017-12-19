# == Class: ::ora_rac::db_master
#
# This class installes the master database node. A master database node is
# the first machine to be installed. All db_server machines (see class ::ora_rac::db_server)
# take their configuration of this master node.
#
# === Parameters
#
# Check ::ora_rac::params for all the parameters
#
# === Variables
#
# Check ::ora_rac::params for all the variables
#
# === Authors
#
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::db_master(
  String[1,8] $db_name                    = $::ora_rac::params::db_name,
  String[1]   $domain_name                = $::ora_rac::params::domain_name,
  Array[Stdlib::Compat::Ip_address]
              $scan_adresses              = $::ora_rac::params::scan_adresses,
  Hash        $db_machines                = $::ora_rac::params::db_machines,
  Optional[String[1]]
              $init_ora_content           = $::ora_rac::params::init_ora_content,
  Array[String[1]]
              $public_network_interfaces  = $::ora_rac::params::public_network_interfaces,
  Array[String[1]]
              $private_network_interfaces = $::ora_rac::params::private_network_interfaces,
  Array[String[1]]
              $unused_network_interfaces  = $::ora_rac::params::unused_network_interfaces,
  String[1]   $cluster_name               = $::ora_rac::params::cluster_name,             # name of the cluster
  String[1]   $password                   = $::ora_rac::params::password,
  String[1]   $scan_name                  = $::ora_rac::params::scan_name,
  Integer     $scan_port                  = $::ora_rac::params::scan_port,
  String[1]   $crs_disk_group_name        = $::ora_rac::params::crs_disk_group_name,
  String[1]   $crs_disk                   = $::ora_rac::params::crs_disk,
  String[1]   $data_disk_group_name       = $::ora_rac::params::data_disk_group_name,
  Enum['NORMAL','EXTERNAL', 'HIGH']
              $disk_redundancy            = $::ora_rac::params::disk_redundancy,
  Array[Hash] $config_scripts             = $::ora_rac::params::config_scripts,
  Optional[Boolean]
              $configure_afd              = $::ora_rac::params::configure_afd
) inherits ::ora_rac::params {

  require ::ora_rac::settings

  $database_definition = lookup({name          => 'ora_rac::internal::database_definition',
                                 value_type    => Hash,
                                 merge         => {strategy => 'deep', merge_hash_arrays => true},
                                 default_value => {}})

  if $::operatingsystemmajrelease == '6' {
    #
    # Replace cvu_config CV_ASSUME_DISTID=OEL4 for V_ASSUME_DISTID=OEL6
    #
    file{"${::ora_rac::settings::oracle_home}/cv/admin/cvu_config":
      ensure  => 'file',
      owner   => $::ora_rac::settings::oracle_user,
      group   => $::ora_rac::settings::install_group,
      source  => 'puppet:///modules/ora_rac/cvu_config',
      require => Ora_install::Installdb[$::ora_rac::settings::_oracle_file],
      before  => Ora_database[$db_name],
    }

    file{"${::ora_rac::settings::grid_home}/cv/admin/cvu_config":
      ensure  => 'file',
      owner   => $::ora_rac::settings::grid_user,
      group   => $::ora_rac::settings::install_group,
      source  => 'puppet:///modules/ora_rac/cvu_config',
      require => Ora_install::Installasm[$::ora_rac::settings::_grid_file],
      before  => Ora_database[$db_name],
    }
  }

  # Create all ASM disks before staring the ASM installation
  Ora_rac::Asm_disk<||> -> Ora_install::Installasm<||>

  ora_install::installasm{ $::ora_rac::settings::_grid_file:
    version                   => $::ora_rac::settings::version,
    file                      => $::ora_rac::settings::_grid_file,
    grid_type                 => 'CRS_CONFIG',
    grid_base                 => $::ora_rac::settings::grid_base,
    grid_home                 => $::ora_rac::settings::grid_home,
    ora_inventory_dir         => $::ora_rac::settings::ora_inventory_dir,
    user                      => $::ora_rac::settings::grid_user,
    group                     => $::ora_rac::settings::grid_group,
    group_install             => $::ora_rac::settings::install_group,
    group_oper                => $::ora_rac::settings::grid_oper_group,
    group_asm                 => $::ora_rac::settings::grid_admin_group,
    disk_discovery_string     => $::ora_rac::params::disk_discovery_string,
    asm_diskgroup             => $crs_disk_group_name,
    disks                     => $crs_disk,
    disk_redundancy           => $disk_redundancy,
    disk_au_size              => '4',
    disks_failgroup_names     => "${crs_disk},",
    configure_afd             => $configure_afd,
    puppet_download_mnt_point => $::ora_rac::settings::puppet_download_mnt_point,
    download_dir              => $::ora_rac::settings::download_dir,
    temp_dir                  => $::ora_rac::settings::temp_dir,
    zip_extract               => $::ora_rac::settings::zip_extract,
    cluster_name              => $cluster_name,
    scan_name                 => $scan_name,
    scan_port                 => $scan_port,
    cluster_nodes             => case $::ora_rac::settings::version {
                                   '11.2.0.4', '12.1.0.2': {
                                     "${::hostname}:${::hostname}-vip"
                                   }
                                   '12.2.0.1': {
                                     "${::hostname}:${::hostname}-vip:HUB"
                                   }
                                 },
    network_interface_list    => $::ora_rac::params::nw_interface_list,
    storage_option            => case $::ora_rac::settings::version {
                                   '11.2.0.4': {
                                     'ASM_STORAGE'
                                   }
                                   '12.1.0.2': {
                                     'LOCAL_ASM_STORAGE'
                                   }
                                   '12.2.0.1': {
                                     'FLEX_ASM_STORAGE'
                                   }
                                 },
  }

  -> ora_setting { '+ASM1':
    oracle_home => $::ora_rac::settings::grid_home,
    syspriv     => 'sysasm',
  }

  if ( $::ora_rac::params::configure_afd ) {
    create_resources('ora_rac::afd_label', $::ora_rac::settings::afd_disks)
  }

  ora_setting { "${db_name}1":
    oracle_home => $::ora_rac::settings::oracle_home,
    default     => true,
    require     => Ora_setting['+ASM1'],
  }

  -> ora_install::installdb{ $::ora_rac::settings::_oracle_file:
    version                   => $::ora_rac::settings::version,
    file                      => $::ora_rac::settings::_oracle_file,
    user                      => $::ora_rac::settings::oracle_user,
    group                     => $::ora_rac::settings::dba_group,
    group_oper                => $::ora_rac::settings::oper_group,
    group_install             => $::ora_rac::settings::install_group,
    ora_inventory_dir         => $::ora_rac::settings::ora_inventory_dir,
    database_type             => 'EE',
    oracle_base               => $::ora_rac::settings::oracle_base,
    oracle_home               => $::ora_rac::settings::oracle_home,
    puppet_download_mnt_point => $::ora_rac::settings::puppet_download_mnt_point,
    download_dir              => $::ora_rac::settings::download_dir,
    temp_dir                  => $::ora_rac::settings::temp_dir,
    cluster_nodes             => $::hostname,
    require                   => Ora_install::Installasm[$::ora_rac::settings::_grid_file],
    before                    => Ora_database[$db_name],
  }

  -> ::ora_rac::oratab_entry{"${db_name}1":
    home    => $::ora_rac::settings::oracle_home,
    start   => 'N',
    comment => 'Added by puppet',
    require => Ora_database[$db_name],
  }

  $full_database_definition = merge($database_definition, {config_scripts => $config_scripts})
  ensure_resource(ora_database, $db_name, $full_database_definition)

  exec{'register_diskgroups':
    refreshonly => true,
    user        => $::ora_rac::settings::oracle_user,
    environment => ["ORACLE_SID=${db_name}1", 'ORAENV_ASK=NO', "ORACLE_HOME=${::ora_rac::settings::oracle_home}"],
    command     => "${::ora_rac::settings::grid_home}/bin/srvctl modify database -d ${db_name} -a ${::ora_rac::settings::disk_group_names.join(',')}",
    logoutput   => on_failure,
    require     => Ora_rac::Oratab_entry["${db_name}1"],
    subscribe   => Ora_database[$db_name],
  }

  $::ora_rac::params::cluster_nodes.each | $index, $instance| {
    $instance_number  = $index + 1
    $thread           = $instance_number
    $instance_name    = "${db_name}${instance_number}"

    if ($instance_number > 1) { # Not a master node

      ::ora_rac::ora_instance{$instance_name:
        on                => $::ora_rac::params::master_instance,
        number            => $instance_number,
        thread            => $thread,
        datafile          => $::ora_rac::settings::data_file_destination,
        undo_initial_size => $::ora_rac::settings::undo_initial_size,
        undo_next         => $::ora_rac::settings::undo_next,
        undo_autoextend   => $::ora_rac::settings::undo_autoextend,
        undo_max_size     => $::ora_rac::settings::undo_max_size,
        require           => Ora_rac::Oratab_entry["${db_name}1"],
      }
    }
  }

}
