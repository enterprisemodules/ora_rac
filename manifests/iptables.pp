#
# Create the correct Firewall rules for the RAC nodes
#
class ora_rac::iptables inherits ora_rac::params
{
  $input_chain = lookup('ora_rac::internal::iptables::input_chain', String[1])

  $ora_rac::params::all_ip_addresses.each |$ipadress| {
    firewall{"200 RAC communication for ${ipadress}":
      chain  => $input_chain,
      source => $ipadress,
      action => 'accept',
    }
  }

  firewall { '200 DB listner':
    chain  => $input_chain,
    dport  => 1521,
    proto  => tcp,
    action => 'accept',
  }
  firewall { '200 DB gridcontrol':
    chain  => $input_chain,
    dport  => 3872,
    proto  => tcp,
    action => 'accept',
  }

  $ora_rac::params::private_network_interfaces.each | $interface| {
    firewall {"200 Oracle Cluster Interconnect on interface ${interface}":
      chain   => $input_chain,
      proto   => 'all',
      iniface => $interface,
      action  => 'accept',
    }
  }


}
