# == Class: ora_rac::params
#
# Read's the instance variables to be used for this application
# This class is ment to be inherited
#
# === Parameters
#
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
# === Copyright
#
# Copyright 2014 ProRail
#
class ora_rac::params
{
  $instance_name        = hiera('instance_name')
  $domain_name          = hiera('domain_name')
  $oracle_version       = hiera('oracle_version')
  #
  # Read these next values from the product yaml
  #
  $private_ipaddress    = hiera('ora_rac::params::private_ipaddress')
  $oracledb_group       = hiera('ora_rac::params::oracle_group',     'oinstall')
  $oracledb_gid         = hiera('ora_rac::params::oracle_gid',        7000)
  $oracledb_user        = hiera('ora_rac::params::oracle_user',      'oracle')
  $oracledb_uid         = hiera('ora_rac::params::oracle_uid',        7000,)
  $oper_group           = hiera('ora_rac::params::oper_group',        'oper')
  $oper_gid             = hiera('ora_rac::params::oper_gid',          7004)
  $grid_user            = hiera('ora_rac::params::grid_user',         'grid')
  $grid_uid             = hiera('ora_rac::params::grid_uid',          7001)
  $dba_group            = hiera('ora_rac::params::dba_group',         'dba')
  $dba_gid              = hiera('ora_rac::params::dba_gid',           7001)
  $osdba_group          = hiera('ora_rac::params::osdba_group',       'asmdba')
  $osdba_gid            = hiera('ora_rac::params::osdba_group',       7002,)
  $asm_group            = hiera('ora_rac::params::asm_group',         'asmadmin')
  $asm_gid              = hiera('ora_rac::params::asm_gid',           7003)
  $asm_oper_group       = hiera('ora_rac::params::asm_oper_group',    'asmoper')
  $asm_oper_gid         = hiera('ora_rac::params::asm_oper_gid',      7005)
  $db_password          = hiera("ora_rac::param::password",          'Prorail123')
  $db_version           = hiera("ora_rac::params::version",           "11.2.0.4")
  $grid_version         = hiera("ora_rac::params::version",           "11.2.0.4")
  #
  # RAC
  #
  $scan_name            = hiera('ora_rac::params::scan_name')
  $scan_port            = hiera('ora_rac::params::scan_port',         1521)
  $scan_adresses        = hiera('ora_rac::params::scan_adresses')
  $cluster_name         = hiera('ora_rac::params::cluster_name')

  $crs_disk_group_name  = hiera('ora_rac::params::crs_disk_group_name','CRS')
  $data_disk_group_name = hiera('ora_rac::params::data_disk_group_name','DATA')



  $public_interfaces    = hiera('ora_rac::params::public_network_interfaces')
  $private_interfaces   = hiera('ora_rac::params::private_network_interfaces')
  $unused_interfaces    = hiera('ora_rac::params::unused_network_interfaces')

  #
  # Build the string needed by oracle grid installer
  #
  # The value should be a comma separated strings where each string is as shown below
  # InterfaceName:SubnetAddress:InterfaceType
  # where InterfaceType can be either "1", "2", or "3"
  # (1 indicates public, 2 indicates private, and 3 indicates the interface is not used)
  #
  # For example: eth0:140.87.24.0:1,eth1:10.2.1.0:2,eth2:140.87.52.0:3
  #

  $_public_list = $public_interfaces.reduce('') | $list, $interface | {
    $network = getvar("::network_${interface}")
    unless $network { fail "network for interface ${interface} not defined"}
    if $list == ''{
        "${interface}:${network}:1"
      } else {
        "${list},${interface}:${network}:1"
      }
  }

  $_private_list = $private_interfaces.reduce('') | $list, $interface | {
    $network = getvar("::network_${interface}")
    unless $network { fail "network for interface ${interface} not defined"}
    if $list == ''{
        "${interface}:${network}:2"
      } else {
        "${list},${interface}:${network}:2"
      }
  }

  $_unused_list = $unused_interfaces.reduce('') | $list, $interface | {
    $network = getvar("::network_${interface}")
    unless $network { fail "network for interface ${interface} not defined"}
    if $list == ''{
        "${interface}:${network}:3"
      } else {
        "${list},${interface}:${network}:3"
      }
  }

  $nw_interface_list     = join([$_public_list,$_private_list,$_unused_list],',')
  #
  # The names for the asm base packages
  #
  $asm_package          = hiera("ora_rac::params::asm_package",      "oracleasm-${::kernelrelease}")
  $asm_package_name     = hiera("ora_rac::params::asm_package_name", "${asm_package}-2.0.5-1.el5.x86_64.rpm")
  #
  # Deduct variables from known information
  #
  $env_prefix           = sprintf('%.1s',$::environment)
  $db_name              = upcase("${env_prefix}${instance_name}")
  $machine_domain       = $domain_name


  $master_instance      = "${db_name}1"
  $db_machines          = hiera('ora_rac::params::machines')

  $cluster_nodes        = sort(keys($db_machines))

  $master_node          = $cluster_nodes[0]
  #
  # Calculate the current instance by looping through the cluster_nodes
  #
  $current_instance = $cluster_nodes.reduce(1) | $instance, $node| {
    if ($node == $::hostname) { 
      "${db_name}${instance}"
    } else {
      if is_numeric($instance) {$instance + 1}
    }
  }

  $cluster_vip_names    = suffix($cluster_nodes, '-vip')
  $all_nodes            = concat($cluster_nodes, $cluster_vip_names)
}
