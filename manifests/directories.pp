# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moiretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
class rac::directories inherits rac::params {
  $dirs1 = [
    # '/etc/prorail',
    # "/etc/prorail/${db_name}",
    # '/mnt/fra',
    # '/mnt/orabackup',
    # '/mnt/oradata',
    "/opt/stage",
    "/opt/stage/${db_name}",
    "/opt/stage/${db_name}/etc",
    "/opt/stage/${db_name}/extract",
    "/opt/stage/${db_name}/extract/database",
    "/opt/stage/${db_name}/extract/database/response",
    "/opt/stage/${db_name}/log",
    "/opt/stage/${db_name}/tmp",
  ]

  $dirs2 = [
    '/opt/oracle',
    # '/opt/oracle/app',
    # "/opt/oracle/app/${grid_version}",
    # "/opt/oracle/app/${grid_version}/OraGrid_1",
    # '/opt/oracle/grid',
    # '/opt/oracle/11.2.0',
    # '/opt/oracle/11.2.0/grid',
  ]

  file {$dirs1:
    ensure    => directory,
    owner     => $oracledb_user,
    group     => $oracledb_group,
    mode      => '0775',
  }

  file {$dirs2:
    ensure    => directory,
    owner     => $oracledb_user,
    group     => $oracledb_group,
    mode      => '0775',
  }

  file {'/opt/oracle/oraInventory':
    ensure    => directory,
    owner     => $grid_user,
    group     => $oracledb_group,
    mode      => '0770',
  }

} # end  ora_dirs