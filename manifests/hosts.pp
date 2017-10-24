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
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::hosts inherits ora_rac::params
{

  host{'localhost':
    ip           => '127.0.0.1',
    host_aliases => [
      'localhost.localdomain',
      'localhost4',
      'localhost4.localdomain4',
    ],
  }

  $::ora_rac::params::db_machines.each | $host, $information| {
    #
    # Set the public IP hostname
    #
    $ip     = $information['ip']
    unless ( defined(Host["${host}.${::domain}"]) ) {
      host{"${host}.${::domain}":
        host_aliases => $host,
        ip           => $ip,
      }
    }

    #
    # Set the private IP hostname
    #
    $priv   = $information['priv']
    unless ( defined(Host["${host}-priv.${::domain}"]) ) {
      host{"${host}-priv.${::domain}":
        host_aliases => "${host}-priv",
        ip           => $priv,
      }
    }

    #
    # Set the virtual private IP hostname
    #
    $vip    = $information['vip']
    unless ( defined(Host["${host}-vip.${::domain}"]) ) {
      host{"${host}-vip.${::domain}":
        host_aliases => "${host}-vip",
        ip           => $vip,
      }
    }
  }

  #
  # Register SCAN name in hostfile
  #
  if $::ora_rac::params::scan_name_in_hostfile {
    unless ( defined(Host["${::ora_rac::params::scan_name}.${::domain}"]) ) {
      host{"${::ora_rac::params::scan_name}.${::domain}":
        ensure       => present,
        host_aliases => $::ora_rac::params::scan_name,
        ip           => $::ora_rac::params::scan_adresses,
      }
    }
  } else {
    unless ( defined(Host["${::ora_rac::params::scan_name}.${::domain}"]) ) {
      host{"${::ora_rac::params::scan_name}.${::domain}":
        ensure       => absent,
        host_aliases => $::ora_rac::params::scan_name,
        ip           => $::ora_rac::params::scan_adresses,
      }
      notice('SCAN name not defined in hostfile by puppet. Be sure it is in the DNS')
    }
  }
}
