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
# Copyright 2014 Bert Hajee
#
class ora_rac::params(
  $db_name,
  $scan_adresses,
  $domain_name,
  $db_machines,
  $public_network_interfaces  = ['eth1'],
  $private_network_interfaces = ['eth2'],
  $unused_network_interfaces  = [],
  $cluster_name               = 'cluster',
  $version                    = '11.2.0.4',
  $file                       = 'p13390677_112040_Linux-x86-64',   # For backwards compatibility
  $grid_file                  =  $file,
  $oracle_file                =  $file,
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

  $password                   = 'manager123',
  $scan_name                  = 'scan',
  $scan_port                  = 1521,
  $crs_disk_group_name        = 'CRS',
  $data_disk_group_name       = 'DATA',
  $disk_redundancy            = 'NORMAL',
)
{

  $_version_array       = split($version,'[.]')
  $db_major_version     = $_version_array[0]
  $db_minor_version     = $_version_array[1]
  $db_version           = "${db_major_version}.${db_minor_version}"


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

  $_public_list = $public_network_interfaces.reduce('') | $list, $interface | {
    $network = getvar("::network_${interface}")
    unless $network { fail "network for interface ${interface} not defined"}
    if $list == ''{
        "${interface}:${network}:1"
      } else {
        "${list},${interface}:${network}:1"
      }
  }

  $_private_list = $private_network_interfaces.reduce('') | $list, $interface | {
    $network = getvar("::network_${interface}")
    unless $network { fail "network for interface ${interface} not defined"}
    if $list == ''{
        "${interface}:${network}:2"
      } else {
        "${list},${interface}:${network}:2"
      }
  }

  $_unused_list = $unused_network_interfaces.reduce('') | $list, $interface | {
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

  $master_instance      = "${db_name}1"

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

  $public_ip_addresses  = $db_machines.map | $list, $node | { $node['ip'] }
  $private_ip_addresses = $db_machines.map | $list, $node | { $node['priv'] }
  $vip_ip_addresses     = $db_machines.map | $list, $node | { $node['vip'] }
  $all_ip_addresses     = $public_ip_addresses + $private_ip_addresses + $vip_ip_addresses

  $cluster_vip_names    = suffix($cluster_nodes, '-vip')
  $all_nodes            = concat($cluster_nodes, $cluster_vip_names)
}
