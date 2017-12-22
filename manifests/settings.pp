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
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::settings(
  Hash                  $asm_disk_groups,
  Hash                  $asm_disks                  = lookup(::ora_rac::settings::asm_disks, Hash, 'hash', {}),
  Hash                  $afd_disks                  = lookup(::ora_rac::settings::afd_disks, Hash, 'hash', {}),
  Stdlib::Absolutepath  $oracle_base                = '/opt/oracle',
  Stdlib::Absolutepath  $grid_base                  = '/opt/oracle/grid',
  Stdlib::Absolutepath  $oracle_home                = '/opt/oracle/app/11.2.0.4/db_1',
  Stdlib::Absolutepath  $grid_home                  = '/opt/oracle/app/11.2.0.4/grid',
  Stdlib::Absolutepath  $ora_inventory_dir          = '/opt/oracle',
  String[1]             $puppet_download_mnt_point  = '/opt/software',
  Stdlib::Absolutepath  $download_dir               = '/install',
  Stdlib::Absolutepath  $temp_dir                   = '/tmp',
  Boolean               $zip_extract                = true,
  String[1]             $oracle_user                = 'oracle',
  Integer               $oracle_user_id             = 7000,
  Optional[String]      $oracle_user_password       = undef,
  String[1]             $grid_user                  = 'grid',
  Integer               $grid_user_id               =  7001,
  Optional[String]      $grid_user_password         = undef,
  String[1]             $install_group              = 'oinstall',
  String[1]             $dba_group                  = 'dba',
  String[1]             $oper_group                 = 'oper',
  String[1]             $grid_group                 = 'asmdba',
  String[1]             $grid_oper_group            = 'asmoper',
  String[1]             $grid_admin_group           = 'asmadmin',
  Integer               $install_group_id           = 7000,
  Integer               $dba_group_id               = 7001,
  Integer               $oper_group_id              = 7002,
  Integer               $grid_group_id              = 7003,
  Integer               $grid_oper_group_id         = 7004,
  Integer               $grid_admin_group_id        = 7005,
  Pattern[/^\d+\.\d+\.\d+\.\d+$/]
                        $version                    = '11.2.0.4',
  String                $file                       = 'p13390677_112040_Linux-x86-64',   # For backwards compatibility
  Optional[String]      $grid_file                  = undef,
  Optional[String]      $oracle_file                = undef,
  String[1]             $character_set              = 'AL32UTF8',
  String[1]             $national_character_set     = 'UTF8',
  String[1]             $database_type              = 'MULTIPURPOSE',
  String[1]             $data_file_destination      = '+DATA',
  String[1]             $recovery_area_destination  = '+RECO',
  Easy_type::Size       $undo_initial_size          = '200M',
  Easy_type::Size       $undo_next                  = '100M',
  Enum['on','off']      $undo_autoextend            = 'ON',
  String                $undo_max_size              = 'unlimited',
  String                $asm_disk_group             = 'DATA',     # TODO: Check the difference
)
{
  $_version_array       = split($version,'[.]')
  $db_major_version     = $_version_array[0]
  $db_minor_version     = $_version_array[1]
  $db_version           = "${db_major_version}.${db_minor_version}"

  if $db_major_version == '12' {
    $add_node_path ='/addnode/addnode.sh -silent -ignorePrereq'
  } else {
    $add_node_path = '/oui/bin/addNode.sh -ignorePrereq'
  }

  if $oracle_file == undef and $file != undef {
    $_oracle_file = $file
  } else {
    $_oracle_file = $oracle_file
  }

  unless $_oracle_file {
    fail( 'You must specify either the file or an oracle_file for db_master')
  }

  if $grid_file == undef and $file != undef {
    $_grid_basic_file = $file
  } else {
    $_grid_basic_file = $grid_file
  }
  unless $_grid_basic_file {
    fail( 'You must specify either the file or a grid_file for db_master')
  }

  if $db_major_version == '12' {
    $_grid_file = $_grid_basic_file
  } else {
    $_grid_file = "${_grid_basic_file}_3of7"
  }
  #
  # Extract the diskgroup names from the datastructure. We need this
  #
  $disk_group_names = $asm_disk_groups.keys.map |$d| {$d.split('@')[0]}
}
