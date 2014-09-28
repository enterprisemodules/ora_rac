# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
class ora_rac::db_master(
  $db_name                    = $ora_rac::params::db_name,
  $domain_name                = $ora_rac::params::domain_name,
  $scan_adresses              = $ora_rac::params::scan_adresses,
  $db_machines                = $ora_rac::params::db_machines,
  $public_network_interfaces  = $ora_rac::params::public_network_interfaces,
  $private_network_interfaces = $ora_rac::params::private_network_interfaces,
  $unused_network_interfaces  = $ora_rac::params::unused_network_interfaces,
  $cluster_name               = $ora_rac::params::cluster_name,             # name of the cluster
  $version                    = $ora_rac::params::version,                  # Oracle version to install
  $file                       = $ora_rac::params::file,                     # file names base of installation files
  $grid_file                  = $ora_rac::params::grid_file,                # file names base of installation files
  $oracle_file                = $ora_rac::params::oracle_file,              # file names base of installation files
  $oracle_base                = $ora_rac::params::oracle_base,              # Base for Oracle
  $grid_base                  = $ora_rac::params::grid_base,                # Base for grid
  $oracle_home                = $ora_rac::params::oracle_home,              # Oracle home
  $grid_home                  = $ora_rac::params::grid_home,                # Grid home
  $ora_inventory_dir          = $ora_rac::params::ora_inventory_dir,
  $puppet_download_mnt_point  = $ora_rac::params::puppet_download_mnt_point,
  $zip_extract                = $ora_rac::params::zip_extract,
  $remote_file                = $ora_rac::params::remote_file,
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
  $password                   = $ora_rac::params::password,
  $scan_name                  = $ora_rac::params::scan_name,
  $scan_port                  = $ora_rac::params::scan_port,
  $crs_disk_group_name        = $ora_rac::params::crs_disk_group_name,
  $data_disk_group_name       = $ora_rac::params::data_disk_group_name,
  $disk_redundancy            = $ora_rac::params::disk_redundancy,
  ) inherits ora_rac::params {


  oradb::installasm{ $_grid_file:
    version                => $version,
    file                   => "${_grid_file}",
    gridType               => 'CRS_CONFIG',
    gridBase               => $grid_base,
    gridHome               => $grid_home,
    oraInventoryDir        => $ora_inventory_dir,
    user                   => $grid_user,
    group                  => $grid_group,
    group_install          => $install_group,
    group_oper             => $grid_oper_group,
    group_asm              => $grid_admin_group,
    asm_diskgroup          => $data_disk_group_name,
    disks                  => "ORCL:CRSVOL1,ORCL:CRSVOL2,ORCL:CRSVOL3",
    disk_redundancy        => 'NORMAL',
    puppetDownloadMntPoint => $puppet_download_mnt_point,
    downloadDir            => $download_dir,
    zipExtract             => $zip_extract,
    remoteFile             => $remote_file, #false,
    cluster_name           => $cluster_name,
    scan_name              => $scan_name,
    scan_port              => $scan_port,
    cluster_nodes          => "${::hostname}:${::hostname}-vip",
    network_interface_list => $ora_rac::params::nw_interface_list,
    storage_option         => 'ASM_STORAGE',
  } ~>

  file{"${download_dir}/create_disk_groups.sh":,
    ensure    => file,
    owner     => $oracle_user,
    group     => $install_group,
    content   => template('ora_rac/create_disk_groups.sh.erb'),
    mode      => '0775',
  } ~>

  exec {'create_disk_groups':
    timeout   => 0, # This might take a long time
    user      => $grid_user,
    command   => "/bin/sh ${$download_dir}/create_disk_groups.sh",
    logoutput => on_failure,
    require   => File["${$download_dir}/create_disk_groups.sh"],
  } ->

  class{'ora_rac::ensure_oracle_ownership':} ->

  oradb::installdb{ $_oracle_file:
    version                => $version,
    file                   => $_oracle_file,
    user                   => $oracle_user,
    group                  => $dba_group,
    group_oper             => $oper_group,
    group_install          => $install_group,
    oraInventoryDir        => $ora_inventory_dir,
    databaseType           => 'EE',
    oracleBase             => $oracle_base,
    createUser             => false,
    oracleHome             => $oracle_home,
    puppetDownloadMntPoint => $puppet_download_mnt_point,
    downloadDir            => $download_dir,
    cluster_nodes          => "${::hostname}",
    remoteFile             => $remote_file,
    require                => Oradb::Installasm[$_grid_file],
  } ->

  oradb::database{ $db_name:
    oracleBase              => $oracle_base,
    oracleHome              => $oracle_home,
    version                 => $db_version,
    user                    => $oracle_user,
    group                   => $dba_group,
    downloadDir             => $download_dir,
    action                  => 'create',
    dbName                  => $db_name,
    dbDomain                => $domain_name,
    sysPassword             => $db_password,
    systemPassword          => $db_password,
    dataFileDestination     => "+DATA",
    storageType             => 'ASM',
    characterSet            => "AL32UTF8",
    nationalCharacterSet    => "UTF8",
    initParams              => 'open_cursors=1000,processes=600,job_queue_processes=4',
    sampleSchema            => 'FALSE',
    databaseType            => "MULTIPURPOSE",
    emConfiguration         => "NONE",
    asmDiskgroup            => 'DATA',
    cluster_nodes           => "${::hostname}",
  }

  $cluster_nodes.each | $index, $instance| {


    $instance_number  = $index + 1
    $thread           = $instance_number
    $instance_name    = "${db_name}${instance_number}"

    ora_rac::oratab_entry{$instance_name:
      home      => $oracle_home,
      start     => 'N',
      comment   => 'Added by puppet',
      require   => Oradb::Database[$db_name],
    }

    if ($instance_number > 1) { # Not a master node

      ora_rac::ora_instance{$instance_name:
        on        => $master_instance,
        number    => $instance_number,
        thread    => $thread,
        require   => [
          Ora_rac::Oratab_entry[$instance_name],
          Ora_rac::Oratab_entry[$master_instance],
        ]
      }
    }
  }
}