# == Class: ora_rac::asm_drivers
#
# Install the base ASM packges and ocnfigure the ASM driver and service for 
# Linux
#
# === Parameters
#
#     None
#
# === Variables
#
# $asm_package_name - Use this to change the package to install. This package
#                     is OS release specific
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::asm_drivers inherits ora_rac::params {

  $yumrepos = hiera('ora_rac::yumrepos')
  $packages = hiera('ora_rac::asm_drivers::packages')

  create_resources('yumrepo', $yumrepos)
  create_resources('package', $packages)

  file{'/etc/sysconfig/oracleasm-_dev_oracleasm':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0775',
    content => template('ora_rac/oracleasm.erb'),
  }

  file{'/etc/sysconfig/oracleasm':
    ensure  => link,
    target  => '/etc/sysconfig/oracleasm-_dev_oracleasm',
    require => File['/etc/sysconfig/oracleasm-_dev_oracleasm'],
  }

  service{'oracleasm':
    ensure    => 'running',
    subscribe => File['/etc/sysconfig/oracleasm'],
    require   => Package['oracleasm-support'],
  }

}