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
class ora_rac::interfaces(){

  #
  # Borrow the db_machines parameter from ora_rac::params
  #
  $db_machines = hiera('ora_rac::params::db_machines')
  #
  # Calculate the private ip adress of the current node
  #
  $private_ipaddress = $db_machines.reduce('') | $memo, $node| {
    if ($node[0] == $::hostname) {
      $node[1]['priv']
    } else {
      $memo
    }
  }

  #
  # After we added the network adapter eth2, the facts are not yet updated. We
  # need the network fact set for the rac options so we use a hack of setting
  # a toplevel variable
  #
  # First calculate the network adress
  #
  unless $::network_eth2 {
    $netmask        = '255.255.255.0'
    $mask_length    = netmask_to_masklen($netmask)
    $network        = cidr_to_network("${private_ipaddress}/${mask_length}")
    set_variable('::','network_eth2', $network )
  }
  network_config { 'eth2':
    ensure    => 'present',
    family    => 'inet',
    method    => 'static',
    onboot    => true,
    hotplug   => true,
    ipaddress => $private_ipaddress,
    netmask   => $netmask,
    options   => {},
  } ~>

  service{'network':
    ensure  => 'running',
  }

}