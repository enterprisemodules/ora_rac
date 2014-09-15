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
class ora_rac::db_master inherits ora_rac::params {
  contain ora_rac::hosts
  contain ora_rac::os
  contain ora_rac::base
  contain ora_rac::install
  contain ora_rac::config
  contain obtain::ora_files

  $dirs = [
    '/opt/oracle',
    '/opt/stage/tmp',
    '/opt/oracle/app',
    "/opt/oracle/app/${grid_version}",
  ]

  file {$dirs:
    ensure    => directory,
    owner     => $oracledb_user,
    group     => $oracledb_group,
    mode      => '0775',
  }

  oradb::installasm{ '11.2_linux-x64':
    version                => $grid_version,
    file                   => 'p13390677_112040_Linux-x86-64_3of7.zip',
    gridType               => 'CRS_CONFIG',
    gridBase               => '/opt/oracle/grid',
    gridHome               => "/opt/oracle/app/${grid_version}/grid",
    oraInventoryDir        => '/opt/oracle',
    user                   => $grid_user,
    group                  => $osdba_group,
    group_install          => $oracledb_group,
    group_oper             => $asm_oper_group,
    group_asm              => $asm_group,
    asm_diskgroup          => $data_disk_group_name,
    disks                  => "ORCL:CRSVOL1,ORCL:CRSVOL2,ORCL:CRSVOL3",
    disk_redundancy        => 'NORMAL',
    puppetDownloadMntPoint => '/opt/stage',
    remoteFile             => false,
    cluster_name           => $cluster_name,
    scan_name              => $scan_name,
    scan_port              => $scan_port,
    cluster_nodes          => "${::hostname}:${::hostname}-vip",
    network_interface_list => $nw_interface_list,
    storage_option         => 'ASM_STORAGE',
    require                => [
        Class['ora_rac::config'],
        Class['ora_rac::hosts'],
        File[$dirs],
        Class['obtain::ora_files'],
      ]
  }

  file{"/opt/stage/tmp/create_disk_groups.sh":,
    ensure    => file,
    owner     => $oracledb_user,
    group     => $oracledb_group,
    content   => template('ora_rac/create_disk_groups.sh.erb'),
    mode      => '0775',
  }

  exec {'create_disk_groups':
    timeout   => 0, # This might take a long time
    command   => "/bin/su - ${grid_user} -c \"/opt/stage/tmp/create_disk_groups.sh\"",
    logoutput => on_failure,
    require   => [
      Oradb::Installasm['11.2_linux-x64'],
      File["/opt/stage/tmp/create_disk_groups.sh"],
    ]
  }

  exec{'set_ownership': # is a hack. Somehow Oracle 
    command   => "/bin/chown ${oracledb_user}:${oracledb_group} /opt/oracle /opt/oracle/app /opt/oracle/app/${db_version}",
    require   => Oradb::Installasm['11.2_linux-x64'],
  }

  oradb::installdb{ '112040_Linux-x86-64':
    version                => "${db_version}",
    file                   => 'p13390677_112040_Linux-x86-64',
    databaseType           => 'EE',
    oracleBase             => '/opt/oracle',
    oracleHome             => "/opt/oracle/app/${db_version}/db_1",
    puppetDownloadMntPoint => '/opt/stage',
    cluster_nodes          => "${::hostname}",
    remoteFile             => false,
    require                => [
        Exec['set_ownership'],
         # Exec['create_disk_groups'],
      ]
  }

  oradb::database{ $db_name:
    oracleBase              => '/opt/oracle',
    oracleHome              => "/opt/oracle/app/${db_version}/db_1",
    version                 => '11.2',
    user                    => $oracledb_user,
    group                   => $oracledb_group,
    downloadDir             => '/install',
    action                  => 'create',
    dbName                  => $db_name,
    dbDomain                => $domain_name,
    sysPassword             => $db_password,
    systemPassword          => $db_password,
    dataFileDestination     => "+DATA",
    storageType             => 'ASM',
    characterSet            => "AL32UTF8",
    nationalCharacterSet    => "UTF8",
    initParams              => "open_cursors=1000,processes=600,job_queue_processes=4",
    sampleSchema            => 'FALSE',
    databaseType            => "MULTIPURPOSE",
    emConfiguration         => "NONE",
    asmDiskgroup            => 'DATA',
    require                 => Oradb::Installdb['112040_Linux-x86-64'],
    cluster_nodes           => "${::hostname}",
  }

  
  $cluster_nodes.each | $index, $instance| {

    $instance_number  = $index + 1
    $thread           = $instance_number
    $instance_name    = "${db_name}${instance_number}"

    ora_rac::oratab_entry{$instance_name:
      home      => "/opt/oracle/app/${db_version}/db_1",
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