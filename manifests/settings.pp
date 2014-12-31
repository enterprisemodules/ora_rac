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
  $oracle_home                = '/opt/oracle/app/11.2.0.4/db_1',
  $grid_home                  = '/opt/oracle/app/11.2.0.4/grid',
  $grid_base                  = '/opt/oracle',
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
  $recovery_area_destination  = '+DATA',
  $asm_disk_group             = 'DATA', # TODO: Check the difference
  $asm_disk_groups,
  $asm_disks,
)
{
  $valid_id_re      = '^/d+$'
  $valid_version_re = '^\d+\.\d+\.\d+\.\d+$'
  #
  # Validate input
  #
  assert_type(String[1], $oracle_base)              |$e, $a| { fail "oracle_base is ${a}, but expected a non empty string"}
  assert_type(String[1], $grid_base)                |$e, $a| { fail "grid_base is ${a}, but expected a non empty string"}
  validate_absolute_path($oracle_home)
  validate_absolute_path($grid_home)
  validate_absolute_path($ora_inventory_dir)
  validate_absolute_path($puppet_download_mnt_point)
  validate_absolute_path($download_dir)
  assert_type(Boolean, $zip_extract)                |$e, $a| { fail "zip_extract is ${a}, but expected boolean"}
  assert_type(Boolean, $remote_file)                |$e, $a| { fail "remote_file is ${a}, but expected a boolean"}
  assert_type(String[1], $oracle_user)              |$e, $a| { fail "oracle_user is ${a}, but expected a non empty string"}
  assert_type(Integer, $oracle_user_id)             |$e, $a| { fail "oracle_user_id is ${a}, but expected an integer"}
  assert_type(String[1], $grid_user)                |$e, $a| { fail "grid_user is ${a}, but expected a non empty string"}
  assert_type(Integer, $grid_user_id)               |$e, $a| { fail "grid_user_id is ${a}, but expected an integer"}
  assert_type(String[1], $install_group)            |$e, $a| { fail "install_group is ${a}, but expected a non empty string"}
  assert_type(String[1], $dba_group)                |$e, $a| { fail "dba_group is ${a}, but expected a non empty string"}
  assert_type(String[1], $oper_group)               |$e, $a| { fail "oper_group is ${a}, but expected a non empty string"}
  assert_type(String[1], $grid_group)               |$e, $a| { fail "grid_group is ${a}, but expected a non empty string"}
  assert_type(String[1], $grid_oper_group)          |$e, $a| { fail "grid_oper_group is ${a}, but expected a non empty string"}
  assert_type(String[1], $grid_admin_group)         |$e, $a| { fail "grid_admin_group is ${a}, but expected a non empty string"}
  assert_type(Integer,$install_group_id)            |$e, $a| { fail "install_group_id is ${a}, but expected an integer"}
  assert_type(Integer,$dba_group_id)                |$e, $a| { fail "dba_group_id is ${a}, but expected an integer"}
  assert_type(Integer,$oper_group_id)               |$e, $a| { fail "oper_group_id is ${a}, but expected an integer"}
  assert_type(Integer,$grid_group_id)               |$e, $a| { fail "grid_group_id is ${a}, but expected an integer"}
  assert_type(Integer,$grid_oper_group_id)          |$e, $a| { fail "grid_oper_group_id is ${a}, but expected an integer"}
  assert_type(Integer,$grid_admin_group_id)         |$e, $a| { fail "grid_admin_group_id is ${a}, but expected an integer"}
  validate_re($version, $valid_version_re, "grid_base is ${a}, but expected a non empty string")
  assert_type(String[1], $file)                     |$e, $a| { fail "grid_file is ${a}, but expected a non empty string"}
  assert_type(String, $grid_file)                   |$e, $a| { fail "grid_file is ${a}, but expected a string"}
  assert_type(String, $oracle_file)                 |$e, $a| { fail "oracle_file is ${a}, but expected a string"}
  assert_type(Variant[String,Undef], $opatch)       |$e, $a| { fail "opatch is ${a}, but expected a string or undefined"}
  assert_type(String[1], $character_set)            |$e, $a| { fail "character_set is ${a}, but expected a non empty string"}
  assert_type(String[1], $national_character_set)   |$e, $a| { fail "grid_base is ${a}, but expected a non empty string"}
  assert_type(String[1], $database_type)            |$e, $a| { fail "database_type is ${a}, but expected a non empty string"}
  assert_type(String[1],$data_file_destination)     |$e, $a| { fail "data_file_destination is ${a}, but expected a non empty string"}
  assert_type(String[1],$recovery_area_destination) |$e, $a| { fail "gridrecovery_area_destination_base is ${a}, but expected a non empty string"}
  assert_type(String[1],$asm_disk_group)            |$e, $a| { fail "asm_disk_group is ${a}, but expected a non empty string"}
  assert_type(Hash, $asm_disk_groups)               |$e, $a| { fail "asm_disk_groups is ${a}, but expected a Hash"}
  assert_type(Hash, $asm_disks)                     |$e, $a| { fail "asm_disks is ${a}, but expected a Hash"}

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
    fail( 'You must specify either the file or a grid_file for db_master')
  }

  if $db_major_version == 12 {
    $_grid_file = $_grid_basic_file
  } else {
    $_grid_file = "${_grid_basic_file}_3of7"
  }

}
