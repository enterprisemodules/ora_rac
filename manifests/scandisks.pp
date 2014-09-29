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
class ora_rac::scandisks
{
  exec{'/usr/sbin/oracleasm scandisks':
    unless    => "/usr/sbin/oracleasm querydisk -v ${name}",
    logoutput => on_failure,
    require   => Service['oracleasm'],
  }
}