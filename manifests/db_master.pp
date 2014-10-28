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
  $init_params                = $ora_rac::params::init_params,
  $public_network_interfaces  = $ora_rac::params::public_network_interfaces,
  $private_network_interfaces = $ora_rac::params::private_network_interfaces,
  $unused_network_interfaces  = $ora_rac::params::unused_network_interfaces,
  $cluster_name               = $ora_rac::params::cluster_name,             # name of the cluster
  $password                   = $ora_rac::params::password,
  $scan_name                  = $ora_rac::params::scan_name,
  $scan_port                  = $ora_rac::params::scan_port,
  $crs_disk_group_name        = $ora_rac::params::crs_disk_group_name,
  $data_disk_group_name       = $ora_rac::params::data_disk_group_name,
  $disk_redundancy            = $ora_rac::params::disk_redundancy,
) inherits ora_rac::params {

  require ora_rac::settings

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
      before  => Oradb::Database[$db_name],
    }

    file{"${ora_rac::settings::grid_home}/cv/admin/cvu_config":
      ensure  => 'file',
      owner   => $ora_rac::settings::grid_user,
      group   => $ora_rac::settings::install_group,
      source  => 'puppet:///modules/ora_rac/cvu_config',
      require => Oradb::Installasm[$ora_rac::settings::_grid_file],
      before  => Oradb::Database[$db_name],
    }
  }

  oradb::installasm{ $ora_rac::settings::_grid_file:
    version                => $ora_rac::settings::version,
    file                   => $ora_rac::settings::_grid_file,
    gridType               => 'CRS_CONFIG',
    gridBase               => $ora_rac::settings::grid_base,
    gridHome               => $ora_rac::settings::grid_home,
    oraInventoryDir        => $ora_rac::settings::ora_inventory_dir,
    user                   => $ora_rac::settings::grid_user,
    group                  => $ora_rac::settings::grid_group,
    group_install          => $ora_rac::settings::install_group,
    group_oper             => $ora_rac::settings::grid_oper_group,
    group_asm              => $ora_rac::settings::grid_admin_group,
    asm_diskgroup          => $crs_disk_group_name,
    disks                  => 'ORCL:CRSVOL1,ORCL:CRSVOL2,ORCL:CRSVOL3',
    disk_redundancy        => 'NORMAL',
    puppetDownloadMntPoint => $ora_rac::settings::puppet_download_mnt_point,
    downloadDir            => $ora_rac::settings::download_dir,
    zipExtract             => $ora_rac::settings::zip_extract,
    remoteFile             => $ora_rac::settings::remote_file, #false,
    cluster_name           => $cluster_name,
    scan_name              => $scan_name,
    scan_port              => $scan_port,
    cluster_nodes          => "${::hostname}:${::hostname}-vip",
    network_interface_list => $ora_rac::params::nw_interface_list,
    storage_option         => 'ASM_STORAGE',
  } ~>

  class{'ora_rac::ensure_oracle_ownership':} ->

  oradb::installdb{ $ora_rac::settings::_oracle_file:
    version                => $ora_rac::settings::version,
    file                   => $ora_rac::settings::_oracle_file,
    user                   => $ora_rac::settings::oracle_user,
    group                  => $ora_rac::settings::dba_group,
    group_oper             => $ora_rac::settings::oper_group,
    group_install          => $ora_rac::settings::install_group,
    oraInventoryDir        => $ora_rac::settings::ora_inventory_dir,
    databaseType           => 'EE',
    oracleBase             => $ora_rac::settings::oracle_base,
    createUser             => false,
    oracleHome             => $ora_rac::settings::oracle_home,
    puppetDownloadMntPoint => $ora_rac::settings::puppet_download_mnt_point,
    downloadDir            => $ora_rac::settings::download_dir,
    cluster_nodes          => $::hostname,
    remoteFile             => $ora_rac::settings::remote_file,
    require                => Oradb::Installasm[$ora_rac::settings::_grid_file],
  } ->

  oradb::database{ $db_name:
    oracleBase           => $ora_rac::settings::oracle_base,
    oracleHome           => $ora_rac::settings::oracle_home,
    version              => $ora_rac::settings::db_version,
    user                 => $ora_rac::settings::oracle_user,
    group                => $ora_rac::settings::dba_group,
    downloadDir          => $ora_rac::settings::download_dir,
    action               => 'create',
    dbName               => $db_name,
    dbDomain             => $domain_name,
    sysPassword          => $db_password,
    systemPassword       => $db_password,
    dataFileDestination  => $ora_rac::settings::data_file_destination,
    storageType          => 'ASM',
    characterSet         => $ora_rac::settings::character_set,
    nationalCharacterSet => $ora_rac::settings::national_character_set,
    initParams           => $init_params,
    sampleSchema         => 'FALSE',
    databaseType         => $ora_rac::settings::database_type,
    emConfiguration      => 'NONE',
    asmDiskgroup         => $ora_rac::settings::asm_disk_group,
    cluster_nodes        => $::hostname,
  }

  $cluster_nodes.each | $index, $instance| {


    $instance_number  = $index + 1
    $thread           = $instance_number
    $instance_name    = "${db_name}${instance_number}"

    ora_rac::oratab_entry{$instance_name:
      home    => $ora_rac::settings::oracle_home,
      start   => 'N',
      comment => 'Added by puppet',
      require => Oradb::Database[$db_name],
    }

    if ($instance_number > 1) { # Not a master node

      ora_rac::ora_instance{$instance_name:
        on      => $master_instance,
        number  => $instance_number,
        thread  => $thread,
        require => [
          Ora_rac::Oratab_entry[$instance_name],
          Ora_rac::Oratab_entry[$master_instance],
        ]
      }
    }
  }
}