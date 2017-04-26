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
class ora_rac::params(
  $db_name,
  $scan_adresses,
  $domain_name,
  $db_machines,
  $oracle_private_key,
  $grid_private_key,
  $init_ora_content           = template('ora_rac/init.ora.erb'),
  $public_network_interfaces  = ['eth1'],
  $private_network_interfaces = ['eth2'],
  $unused_network_interfaces  = [],
  $cluster_name               = 'cluster',
  $password                   = 'manager123',
  $scan_name                  = 'scan',
  $scan_port                  = 1521,
  $scan_name_in_hostfile      = true,
  $crs_disk_group_name        = 'CRS',
  $crs_disk                   = 'ORCL:CRSVOL1,ORCL:CRSVOL2,ORCL:CRSVOL3',
  $data_disk_group_name       = 'DATA',
  $disk_discovery_string      =  '',
  $disk_redundancy            = 'NORMAL',
  $config_scripts             = [],
  $virtual_services           = {},
# 
# This is a small hack to get a size in Mb without further subclassing. 
# 
  $memory_target              = join([floor( $::memorysize_mb/ 2), 'M'], ''),  # Default is half of the reported memory size
  $memory_max_target          = join([floor( $::memorysize_mb/ 2), 'M'], ''),  # Default is half of the reported memory size
  $shared_memory_size         = undef,
)
{
  #
  # Validate input
  #
  #validate_re($::puppetversion, '^[2,3,4].[6-9]\..*$', 'Ora_Rac required Pupet version 2.6 or higher')
  assert_type(String[1,8], $db_name)              |$e, $a| { fail "dbname is ${a}, but must be between 1 and 8 character length string" }
  assert_type(Array, $scan_adresses)              |$e, $a| { fail "scan_addresses is ${a}, but must be an array of IP adresses" }
  assert_type(String[1], $domain_name)            |$e, $a| { fail "domain_name is ${a}, but must be a non empty string"}
  assert_type(Hash, $db_machines)                 |$e, $a| { fail "db_machines is ${a}, but should be a Hash of machines"}
  assert_type(String[1], $oracle_private_key)     |$e, $a| { fail "oracle_private_key is ${a}, but should be a non empty string"}
  assert_type(String[1], $grid_private_key)       |$e, $a| { fail "grid_private_key is ${a}, but should be a non empty string"}
  assert_type(String[1], $init_ora_content)       |$e, $a| { fail "init_ora_content is ${a}, but must be a non empty string"}
  assert_type(Array, $public_network_interfaces)  |$e, $a| { fail " is a ${a}, but must be an array of interfaces"}
  assert_type(Array, $private_network_interfaces) |$e, $a| { fail " is a ${a}, but must be an array of interfaces"}
  assert_type(Array, $unused_network_interfaces)  |$e, $a| { fail " is a ${a}, but must be an array of interfaces"}
  assert_type(String[1], $cluster_name)           |$e, $a| { fail "cluster_name is ${a}, but should be a non empty string"}
  assert_type(String[1], $password)               |$e, $a| { fail "password is ${a}, but should be a non empty string"}
  assert_type(String[1], $scan_name)              |$e, $a| { fail "scan_name is ${a}, but should be a non empty string"}
  assert_type(Integer, $scan_port)                |$e, $a| { fail "scan_port is ${a}, but should be an integer number"}
  assert_type(String[1], $crs_disk_group_name)    |$e, $a| { fail "crs_disk_group_name is ${a}, but should be a non empty string"}
  assert_type(String[1], $crs_disk)               |$e, $a| { fail "crs_disk is ${a}, but should be a non empty string"}
  assert_type(String[1], $data_disk_group_name)   |$e, $a| { fail "data_disk_group_name is ${a}, but should be a non empty string"}
  assert_type(String[0], $disk_discovery_string)  |$e, $a| { fail "disk_discovery_string is ${a}, but should be a string"}
  assert_type(Enum['NORMAL','EXTERNAL', 'HIGH'], $disk_redundancy)
                                                  |$e, $a| { fail "disk_redundancy is ${a}, but should be either EXTERNAL or NORMAL"}
  $size_pattern = '^[0-9]*[k|K|m|M|g|G|t|T]?$'
  assert_type(Pattern[$size_pattern], $memory_target)
                                                   | $e, $a | { fail "memory_target ${a}, but should be a valid size. (e.g. 10G, 10M or another number."}
  assert_type(Pattern[$size_pattern], $memory_max_target)
                                                   | $e, $a | { fail "memory_max_target ${a}, but should be a valid size. (e.g. 10G, 10M or another number."}

  $virtual_services.each | $key, $value| {
    # lint:ignore:variable_scope
    assert_type(Hash[Enum['ip', 'interface_number', 'fwmark', 'send_program', 'scheduler', 'protocol', 'port', 'url', 'servers'], Data], $value) | $e, $a | { fail "${key} is ${a}, but should be a valid hash that should contains following keys: [ip, interface_number, fwmark, send_program, scheduler, protocol, port, url, servers]."}

    if has_key($value, 'ip') {
      assert_type(Pattern[$ipaddress_pattern], $value[ip])        | $e, $a | { fail "virtual_services::${key}::ip is ${a}, but should be a valid IP address."}
    } else {
      fail "virtual_services::${key} has no ip"
    }
  }

  assert_type(Array[Hash], $config_scripts)   |$e, $a| {
   fail "config_scripts is ${a}, but should be a an array of Hashes describing the config scripts."
  }
  assert_type(String[0], $memory_target)  |$e, $a| { fail "memory_target is ${a}, but should be a string"}

  #
  # Build the string needed by oracle grid installer
  #
  # The value should be a comma separated strings where each string is as shown
  # below:
  #
  # InterfaceName:SubnetAddress:InterfaceType
  # where InterfaceType can be either "1", "2", or "3"
  # (1 indicates public, 2 indicates private, and 3 indicates the interface is
  # not used)
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

  $_private_list = $private_network_interfaces.reduce('') | $list, $interface| {
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
}
