# == Class: ora_rac::hosts
#
# This class defines all host names needed for an Oracle RCA cluster
# It deducts its information from the db_machines parameter. For every node, it creates
#  - a `node`-priv for the private address
#  - a `node`-vip for the vip address
#  - a `node` for the public address
#
# It also creates a name for the scan adress. Oracle recomends you  put this
# in the DNS.
#
# === Parameters
#
#   none
#
# === Variables
#
# $db_machines
# $scan_name
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::hosts inherits ora_rac::params
{

  host{'localhost':
    ip           => '127.0.0.1',
    host_aliases => [
      'localhost.localdomain',
      'localhost4',
      'localhost4.localdomain4'
    ],
  }

  $db_machines.each | $host, $information| {
    #
    # Set the public IP hostname
    #
    $ip     = $information['ip']
    host{"${host}.${::domain}":
      host_aliases => $host,
      ip           => $ip,
    }

    #
    # Set the private IP hostname
    #
    $priv   = $information['priv']
    host{"${host}-priv.${::domain}":
      host_aliases => "${host}-priv",
      ip           => $priv,
    }

    #
    # Set the virtual private IP hostname
    #
    $vip    = $information['vip']
    host{"${host}-vip.${::domain}":
      host_aliases => "${host}-vip",
      ip           => $vip,
    }
  }

  #
  # Set the virtual private IP hostname
  #
  if $scan_name {
    host{"${scan_name}.${::domain}":
      host_aliases => $scan_name,
      ip           => $scan_adresses,
    }
  } else {
    notice('Scan name not defined by puppet.Be sure it is in the DNS')
  }
}