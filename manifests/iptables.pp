class ora_rac::iptables inherits ora_rac::params
{
  $input_chain = hiera('ora_rac::iptables::input_chain')

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

  firewall { '200 RAC Multicast':
    chain   => $input_chain,
    pkttype => 'multicast',
    action => 'accept',
  }

  $private_network_interfaces.each | $interface| {
    firewall {'200 Oracle Cluster Interconnect':
      chain   => $input_chain,
      proto   => 'all',
      iniface => $interface,
      action  => 'accept',
    }
  }


}