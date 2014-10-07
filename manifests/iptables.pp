class ora_rac::iptables inherits ora_rac::params
{
  $all_ip_addresses.each |$ipadress| {
    firewall{"200 RAC communication for ${ipadress}":
      chain   => 'RH-Firewall-1-INPUT',
      source  => $ipadress,
      action  => 'accept',
    }
  }

  firewall { '200 DB listner':
    chain   => 'RH-Firewall-1-INPUT',
    port   => 1521,
    proto  => tcp,
    action => 'accept',
  }
  firewall { '200 DB gridcontrol':
    chain   => 'RH-Firewall-1-INPUT',
    port   => 3872,
    proto  => tcp,
    action => 'accept',
  }

  firewall { '200 RAC Multicast':
    chain   => 'RH-Firewall-1-INPUT',
    pkttype => 'multicast',
    action => 'accept',
  }


  $private_interfaces.each | $interface| {
    firewall {'200 Oracle Cluster Interconnect':
      chain   => 'RH-Firewall-1-INPUT',
      proto   => 'all',
      iniface => $interface,
      action  => 'accept',
    }
  }


}