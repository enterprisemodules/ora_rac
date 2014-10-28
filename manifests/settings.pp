# == Class: ora_rac::settings
#
# This class contains some of the global settings to be used by the oracle RAC 
# instalation
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::settings(
  $oracle_base                = '/opt/oracle',
  $grid_base                  = '/opt/oracle/grid',
  $oracle_home                = '/opt/oracle/app/11.2.0.4/db_1',
  $grid_home                  = '/opt/oracle/app/11.2.0.4/grid',
  $ora_inventory_dir          = '/opt/oracle',
  $puppet_download_mnt_point  = '/opt/software',
  $download_dir               = '/install',
  $zip_extract                = true,
  $remote_file                = false,
  $oracle_user                = 'oracle',
  $oracle_user_id             = 7000,
  $grid_user                  = 'grid',
  $grid_user_id               =  7001,
  $install_group              = 'oinstall',
  $dba_group                  = 'dba',
  $oper_group                 = 'oper',
  $grid_group                 = 'asmdba',
  $grid_oper_group            = 'asmoper',
  $grid_admin_group           = 'asmadmin',
  $install_group_id           = 7000,
  $dba_group_id               = 7001,
  $oper_group_id              = 7002,
  $grid_group_id              = 7003,
  $grid_oper_group_id         = 7004,
  $grid_admin_group_id        = 7005,
  $version                    = '11.2.0.4',
  $file                       = 'p13390677_112040_Linux-x86-64',   # For backwards compatibility
  $grid_file                  = undef,
  $oracle_file                = undef,
  $character_set              = 'AL32UTF8',
  $national_character_set     = 'UTF8',
  $database_type              = 'MULTIPURPOSE',
  $data_file_destination      = '+DATA',
  $asm_disk_groups            = 'DATA', # TODO: Check the difference
  $asm_disk_groups,
  $asm_disks,
)
{

  $_version_array       = split($version,'[.]')
  $db_major_version     = $_version_array[0]
  $db_minor_version     = $_version_array[1]
  $db_version           = "${db_major_version}.${db_minor_version}"

  if $db_major_version == 12 {
    $add_node_path ='/addnode/addnode.sh -silent -ignorePrereq'
  } else {
    $add_node_path = '/oui/bin/addNode.sh'
  }

  if $oracle_file == undef and $file != undef {
    $_oracle_file = $file
  } else {
    $_oracle_file = $oracle_file
  }

  unless $_oracle_file {
    fail( 'You mest specify either the file or an oracle_file for db_master')
  }

  if $grid_file == undef and $file != undef {
    $_grid_basic_file = $file
  } else {
    $_grid_basic_file = $grid_file
  }
  unless $_grid_basic_file {
    fail( 'You mest specify either the file or a grid_file for db_master')
  }

  if $db_major_version == 12 {
    $_grid_file = $_grid_basic_file
  } else {
    $_grid_file = "${_grid_basic_file}_3of7"
  }

}
