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

  #
  # Because we need a little bit more space in the tmpfs then is specified by memory_max_target, we
  # check the specified value and normalize it to a byte value and add 10% to it
  #
  #
  $extra_percentage = 1.1
  $memory_value = inline_template("<%= @memory_max_target.scan(/^([0-9]+) *([K|k|M|m|G|g|T|t]) ?$/).flatten[0] -%>")
  $memory_unit  = inline_template("<%= @memory_max_target.scan(/^([0-9]+) *([K|k|M|m|G|g|T|t]) ?$/).flatten[1] -%>")
  case($memory_unit) {
    'K', 'k': { $memory_size = floor($memory_value * 1024 * $extra_percentage) }
    'M', 'm': { $memory_size = floor($memory_value * 1024 * 1024 * $extra_percentage) }
    'G', 'g': { $memory_size = floor($memory_value * 1024 * 1024 * 1024 * $extra_percentage) }
    'T', 't': { $memory_size = floor($memory_value * 1024 * 1024 * 1024 * 1024 * $extra_percentage) }
  }

  augeas {'ensure_tmpfs_size':
    context => '/files/etc/fstab',
    changes => [
      "ins opt after *[spec = 'tmpfs'][file = '/dev/shm']/opt[last()]",
      "set *[spec = 'tmpfs']/opt[last()] size",
      "set *[spec = 'tmpfs']/opt[last()]/value ${memory_size}",
    ],
    onlyif  => "match *[spec='tmpfs'][file = '/dev/shm']/opt[. = 'size'] size == 0",
  }

  exec {'remount_tmpfs':
    command => '/bin/mount -o remount /dev/shm',
    onlyif  => "/usr/bin/test -z $(/bin/mount | /bin/grep /dev/shm | /bin/grep -o size=${memory_size})",
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
