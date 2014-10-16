class ora_rac::iptables inherits ora_rac::params
{
  $all_ip_addresses.each |$ipadress| {
    firewall{"200 RAC communication for ${ipadress}":
      chain   => $fw::input_chain,
      source  => $ipadress,
      action  => 'accept',
    }
  }

  firewall { '200 DB listner':
    chain   => $fw::input_chain,
    port   => 1521,
    proto  => tcp,
    action => 'accept',
  }
  firewall { '200 DB gridcontrol':
    chain   => $fw::input_chain,
    port   => 3872,
    proto  => tcp,
    action => 'accept',
  }

  firewall { '200 RAC Multicast':
    chain   => $fw::input_chain,
    pkttype => 'multicast',
    action => 'accept',
  }

  $private_network_interfaces.each | $interface| {
    firewall {'200 Oracle Cluster Interconnect':
      chain   => $fw::input_chain,
      proto   => 'all',
      iniface => $interface,
      action  => 'accept',
    }
  }


}