# == Class: ora_rac::user_equivalence
#
# Create user equavalance for oracle user. This means registering public and private ssh keys so a user
# on node 1 can access like homeself on node 2
#
# === Parameters
# name  - User name
# nodes - Nodes where equivalance should work
#
# === Variables
#
# none
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
define ora_rac::user_equivalence(
  $nodes = ['localhost'],
)
{
  #
  # Validate input
  #
  assert_type(Array[String[1]], $nodes)   |$e, $a| { fail "nodes is ${a}, expected an array of non empty strings"}
  assert_type(String[1], $name)           |$e, $a| { fail "name is ${a}, expect a non empty string"}

  include ssh

  file{"/home/${name}/.ssh":
    ensure  => 'directory',
    mode    => '0700',
    owner   => $name,
    require => User[$name],
  }


  file{"/home/${name}/.ssh/id_rsa":
    ensure  => 'file',
    source  => "puppet:///modules/ora_rac/${name}.key",
    require => File["/home/${name}/.ssh"],
  }

  #
  # For the specfied user, disable StrictHostKeyChecking for all nodes in the cluster
  #
  #
  file{"/home/${name}/.ssh/config":
    ensure  => 'file',
    mode    => '0700',
    owner   => $name,
    content => template('ora_rac/ssh_config.erb'),
    require => File["/home/${name}/.ssh"],
  }

}