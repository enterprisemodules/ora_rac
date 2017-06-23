class ora_rac::requirements
{
  include ::ora_rac::params

  # TODO make variable
  file {'/u01':
    ensure => directory,
    mode   => '0775',
    owner  => 'oracle',
    group  => 'oinstall',
  }
  # Oracle Base
  file { '/u01/oracle':
    ensure => directory,
    mode   => '0775',
    owner  => 'oracle',
    group  => 'oinstall',
  }
  # Grid Base
  file { '/u01/grid':
    ensure => directory,
    mode   => '0775',
    owner  => 'grid',
    group  => 'oinstall',
  }

  contain ::ora_rac::os
  contain ::ora_rac::disk_config
  contain ::ora_rac::hosts
  contain ::ora_rac::os_users
  contain ::ora_rac::authenticated_nodes
  contain ::ora_rac::swapspace
  contain ::ora_rac::iptables
  contain ::ora_rac::asm_drivers
  contain ::ora_rac::install

  Class['::ora_rac::os']
  -> Class['::ora_rac::hosts']
  -> Class['::ora_rac::os_users']
  -> Class['::ora_rac::authenticated_nodes']
  -> Class['::ora_rac::swapspace']
  -> Class['::ora_rac::iptables']
  -> Class['::ora_rac::asm_drivers']
  -> Class['::ora_rac::install']
}
