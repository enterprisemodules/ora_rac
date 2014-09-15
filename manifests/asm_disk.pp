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
define ora_rac::asm_disk( $volume)
{

  exec{"/usr/sbin/oracleasm createdisk ${volume} ${name}":
    unless    => "/usr/sbin/oracleasm querydisk -v ${name}",
    logoutput => true,
    require   => Service['oracleasm'],
  }
}