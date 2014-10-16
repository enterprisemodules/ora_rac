# == Class: ora_rac::base
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
class ora_rac::base inherits ora_rac::params {

  if $::operatingsystemmajrelease == 5 {

    package {'oracleasm-support':
      ensure   => 'installed',
      provider => 'rpm',
      source   => "${puppet_download_mnt_point}/oracleasm-support-2.1.8-1.el5.x86_64.rpm",
    }->

    package {$asm_package:
      ensure   => 'installed',
      source   => "${puppet_download_mnt_point}/${asm_package_name}",
      provider => 'rpm',
    } ->

    package {'oracleasmlib':
      ensure   => 'installed',
      source   => "${puppet_download_mnt_point}/oracleasmlib-2.0.4-1.el5.x86_64.rpm",
      provider => 'rpm',
    }

  } else {
    $packages = [
      'kmod-oracleasm',
      'oracleasm-support',
    ]
    yumrepo{'oracle':
      baseurl  => "http://public-yum.oracle.com/repo/OracleLinux/OL6/latest/$architecture",
      descr   => 'Oracle repo',
      gpgcheck => 0,
      enabled => 1,
    } ->
    package{$packages:
      ensure => 'installed',
    }

    package {'oracleasmlib':
      ensure   => 'installed',
      source   => "${puppet_download_mnt_point}/oracleasmlib-2.0.4-1.el6.x86_64.rpm",
      provider => 'rpm',
    }


  }

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