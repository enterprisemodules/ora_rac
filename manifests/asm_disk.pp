# == Class: ora_rac::asm_disk
#
# === Parameters
#
# name      device name
# voldume   asm volume name
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
#
define ora_rac::asm_disk( $volume)
{

  exec{"/usr/sbin/oracleasm createdisk ${volume} ${name}":
    unless    => "/usr/sbin/oracleasm querydisk -v ${name}",
    logoutput => true,
    require   => Service['oracleasm'],
  }


}