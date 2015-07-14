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
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::authenticated_nodes inherits ora_rac::params {
  require ora_rac::settings

  ora_rac::user_equivalence{$ora_rac::settings::oracle_user:
    nodes       => $ora_rac::params::cluster_nodes,
    private_key => $ora_rac::params::oracle_private_key,
  }

  ora_rac::user_equivalence{$ora_rac::settings::grid_user:
    nodes       => $ora_rac::params::cluster_nodes,
    private_key => $ora_rac::params::grid_private_key,
  }
}
