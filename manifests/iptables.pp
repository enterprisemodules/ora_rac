class ora_rac::iptables inherits ora_rac::params
{
  $input_chain = hiera('ora_rac::internal::iptables::input_chain')

  assert_type(String[1], $input_chain)  |$e, $a| { fail "input_chain is ${a}, expected a non empty string"}

  $all_ip_addresses.each |$ipadress| {
    firewall{"200 RAC communication for ${ipadress}":
      chain   => $input_chain,
      source  => $ipadress,
      action  => 'accept',
    }
  }

  firewall { '200 DB listner':
    chain   => $input_chain,
    port   => 1521,
    proto  => tcp,
    action => 'accept',
  }
  firewall { '200 DB gridcontrol':
    chain   => $input_chain,
    port   => 3872,
    proto  => tcp,
    action => 'accept',
  }


  $private_network_interfaces.each | $interface| {
    firewall {"200 Oracle Cluster Interconnect on interface ${interface}":
      chain   => $input_chain,
      proto   => 'all',
      iniface => $interface,
      action  => 'accept',
    }
  }


}