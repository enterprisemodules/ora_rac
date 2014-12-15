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
  $init_params                = 'open_cursors=1000,processes=600,job_queue_processes=4',
  $public_network_interfaces  = ['eth1'],
  $private_network_interfaces = ['eth2'],
  $unused_network_interfaces  = [],
  $cluster_name               = 'cluster',
  $password                   = 'manager123',
  $scan_name                  = 'scan',
  $scan_port                  = 1521,
  $crs_disk_group_name        = 'CRS',
  $crs_disk                   = 'ORCL:CRSVOL1,ORCL:CRSVOL2,ORCL:CRSVOL3',
  $data_disk_group_name       = 'DATA',
  $disk_redundancy            = 'NORMAL',
)
{
  validate_re($::puppetversion, '^[2,3,4].[6-9]\..*$', 'Ora_Rac required Pupet version 2.6 or higher')
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
