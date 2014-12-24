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
class ora_rac::scandisks
{
  assert_type(String[1], $name)   |$e, $a| {fail "name is ${a}, expected a non empty string"}

  exec{'/usr/sbin/oracleasm scandisks':
    unless    => "/usr/sbin/oracleasm querydisk -v ${name}",
    logoutput => on_failure,
    require   => Service['oracleasm'],
  }
}