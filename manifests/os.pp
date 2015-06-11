# == Class: ora_rac::os
#
# This class takes care of installing and configuring the OS
# layer as a prerequisite for creating the DB generic
# instance.
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::os inherits ora_rac::params {

  require ora_rac::settings

  $orashm = floor( (($::memorysize_mb) * 0.6 ))

  augeas {'ensure_tmpfs_size':
    context => '/files/etc/fstab',
    changes => [
      "ins opt after *[spec = 'tmpfs'][file = '/dev/shm']/opt[last()]",
      "set *[spec = 'tmpfs']/opt[last()] size",
      "set *[spec = 'tmpfs']/opt[last()]/value ${orashm}m",
    ],
    onlyif  => "match *[spec='tmpfs'][file = '/dev/shm']/opt[. = 'size'] size == 0",
  }

  exec {'remount_tmpfs':
    command => '/bin/mount -o remount /dev/shm',
    onlyif  => "/usr/bin/test -z $(/bin/mount | /bin/grep /dev/shm | /bin/grep -o size=${orashm}m)",
    require => Augeas['ensure_tmpfs_size'],
  }


  file {'/etc/security/limits.conf':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/limits'
  }

  file {'/etc/profile':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ora_rac/etc_profile'
  }


} # end ora_rac::os
