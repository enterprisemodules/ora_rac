# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moiretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
class rac::base inherits rac::params {


  package {'oracleasm-support':
    ensure    => 'installed',
    provider  => 'rpm',
    source    => '/vagrant/software/oracleasm-support-2.1.8-1.el5.x86_64.rpm',
  }

  package {$asm_package:
    ensure    => 'installed',
    source    => "/vagrant/software/$asm_package_name",
    provider  => 'rpm',
    require   => Package['oracleasm-support'],
  }

  package {'oracleasmlib':
    ensure    => 'installed',
    source    => '/vagrant/software/oracleasmlib-2.0.4-1.el5.x86_64.rpm',
    provider  => 'rpm',
    require   => Package[$asm_package],
  }


  file{'/etc/sysconfig/oracleasm-_dev_oracleasm':
    ensure    => file,
    owner     => root,
    group     => root,
    mode      => '0775',
    content   => template('rac/oracleasm.erb'),
  }

  file{'/etc/sysconfig/oracleasm':
    ensure    => link,
    target    => '/etc/sysconfig/oracleasm-_dev_oracleasm',
    require   => File['/etc/sysconfig/oracleasm-_dev_oracleasm'],
  }

  service{'oracleasm':
    ensure  => 'running',
    subscribe => File['/etc/sysconfig/oracleasm'],
    require   => Package['oracleasm-support'],
  }

}