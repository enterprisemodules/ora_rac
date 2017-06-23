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
# ora_rac::internal::yumrepos
# ora_rac::internal::asm_packages
#
# === Authors
#
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::asm_drivers inherits ora_rac::params {

  require ::ora_rac::internal
  require ::ora_rac::settings

  create_resources('yumrepo', $::ora_rac::internal::yumrepos)
  create_resources('package', $::ora_rac::internal::asm_packages)

  $grid_user  = $::ora_rac::settings::grid_user
  $grid_group = $::ora_rac::settings::grid_group

  $scan_exclude = $::ora_rac::params::scan_exclude
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
