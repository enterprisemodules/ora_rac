# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
define ora_rac::user_equivalence(
  $nodes = ['localhost'],
)
{
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

  $nodes.each |$node|{
    exec{"authorize_node_${node}_for_${name}":
    user    => $name,
    command => "/usr/bin/scp -o StrictHostKeyChecking=no x ${name}@${node}:~",
    unless  => "/bin/grep ${node}, /home/${name}/.ssh/known_hosts",
    returns => [0,1],
    require => File["/home/${name}/.ssh/id_rsa"],
    }
  }

}
