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
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::params(
  String[1]         $db_name,
  Array[String[1]]
                    $scan_adresses,
  String[1]         $domain_name,
  Hash              $db_machines,
  String[1]         $oracle_private_key,
  String[1]         $grid_private_key,
  Optional[String[1]]
                    $init_ora_content           = undef,
  Array[String[1]]  $public_network_interfaces  = ['eth1'],
  Array[String[1]]  $private_network_interfaces = ['eth2'],
  Array[String[1]]  $unused_network_interfaces  = [],
  String            $scan_exclude               = 'sd',
  String[1]         $cluster_name               = 'cluster',
  String[1]         $password                   = 'manager123',
  String[1]         $scan_name                  = 'scan',
  Integer           $scan_port                  = 1521,
  Boolean           $scan_name_in_hostfile      = true,
  String[1]         $crs_disk_group_name        = 'CRS',
  String[1]         $crs_disk                   = 'ORCL:CRSVOL1,ORCL:CRSVOL2,ORCL:CRSVOL3',
  String[1]         $data_disk_group_name       = 'DATA',
  String            $disk_discovery_string      =  '',
  Enum['NORMAL','EXTERNAL', 'HIGH']
                    $disk_redundancy            = 'NORMAL',
  Array[Hash]       $config_scripts             = [],
  Hash              $virtual_services           = {},
  Easy_type::Size   $memory_target              = join([floor( $::memorysize_mb/ 2), 'M'], ''),  # Default is half of the reported memory size
  Easy_type::Size   $memory_max_target          = join([floor( $::memorysize_mb/ 2), 'M'], ''),  # Default is half of the reported memory size
  Optional[Easy_type::Size]
                    $shared_memory_size         = undef,
  Optional[Boolean] $configure_afd              = false,
)
{
  require ::ora_rac::settings

  $virtual_services.each | $key, $value| {
    # lint:ignore:variable_scope
    assert_type(Hash[Enum['ip', 'interface_number', 'fwmark', 'send_program', 'scheduler', 'protocol', 'port', 'url', 'servers'], Data], $value) | $e, $a | { fail "${key} is ${a}, but should be a valid hash that should contains following keys: [ip, interface_number, fwmark, send_program, scheduler, protocol, port, url, servers]."}

    if has_key($value, 'ip') {
      # assert_type(Stdlib::Compat::Ip_address, $value[ip])        | $e, $a | { fail "virtual_services::${key}::ip is ${a}, but should be a valid IP address."}
      unless validate_legacy(String, 'is_ip_address', $value[ip]) { fail "virtual_services::${key}::ip is ${a}, but should be a valid IP address." }
    } else {
      fail "virtual_services::${key} has no ip"
    }
  }
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
  # In oracle 12.2 two more interface types have been introduced, namely
  # 4) ASM and 5) ASM & private. And it is mandatory to define at least one interface
  # for ASM. So instead of 2 we should use 5 here.
  case $::ora_rac::settings::version {
    '11.2.0.4', '12.1.0.2': {
      $priv_int_type = 2
    }
    '12.2.0.1': {
      $priv_int_type = 5
    }
  }

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
        "${interface}:${network}:$priv_int_type"
      } else {
        "${list},${interface}:${network}:$priv_int_type"
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

  $nw_interface_list     = join([$_unused_list,$_public_list,$_private_list],',')
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
      $instance_integer = assert_type(Integer, $instance) |$expected, $actual| { 0 }
      if ( $instance_integer > 0 ) { $instance + 1 }
    }
  }

  $public_ip_addresses  = $db_machines.map | $list, $node | { $node['ip'] }
  $private_ip_addresses = $db_machines.map | $list, $node | { $node['priv'] }
  $vip_ip_addresses     = $db_machines.map | $list, $node | { $node['vip'] }
  $all_ip_addresses     = $public_ip_addresses + $private_ip_addresses + $vip_ip_addresses
  $cluster_vip_names    = suffix($cluster_nodes, '-vip')
}
