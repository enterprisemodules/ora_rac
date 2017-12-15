# == Class: ora_rac::authenticated_nodes
#
# Manage the authenticated nodes for grid and oracle users
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::authenticated_nodes (
  Hash $keys = {},
) inherits ora_rac::params {
  require ::ora_rac::settings

  create_resources('ssh_authorized_key', $keys)

  ora_rac::user_equivalence{$::ora_rac::settings::oracle_user:
    nodes       => $::ora_rac::params::cluster_nodes,
    private_key => $::ora_rac::params::oracle_private_key,
  }

  ora_rac::user_equivalence{$::ora_rac::settings::grid_user:
    nodes       => $::ora_rac::params::cluster_nodes,
    private_key => $::ora_rac::params::grid_private_key,
  }
}
