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
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
# lint:ignore:inherits_across_namespaces lint:ignore:class_inherits_from_params_class
class ora_rac::os (
  Hash $sysctl = lookup('ora_rac::internal::sysctl_params', Hash),
  Hash $limits = lookup('ora_rac::internal::limits', Hash, undef, {}),
)inherits ora_rac::params {
# lint:endignore
  require ::ora_rac::settings
  #
  # If shared memory is not defined, we memory_target and memory_max_target to
  # calculate it.
  #

  #
  # Because we need a little bit more space in the tmpfs then is specified by memory_max_target, we
  # check the specified value and normalize it to a byte value and add 10% to it
  #
  #
  if $::ora_rac::params::shared_memory_size {
    $mem_size = $ora_rac::params::shared_memory_size
    $calculate_size = false
  } else {
    $mem_size = $memory_max_target
    $calculate_size = true
  }
  $extra_percentage = 1.1
  $memory_value = inline_template("<%= @mem_size.scan(/^([0-9]+) *([K|k|M|m|G|g|T|t]) ?$/).flatten[0] -%>")
  $memory_unit  = inline_template("<%= @mem_size.scan(/^([0-9]+) *([K|k|M|m|G|g|T|t]) ?$/).flatten[1] -%>")
  case($memory_unit) {
    'K', 'k': { if ( $calculate_size ) {
                  $memory_size = floor($memory_value * 1024 * $extra_percentage)
                  $memory_size_k = $memory_size * 1024
                } else {
                  $memory_size = $mem_size
                  $memory_size_k = $memory_value
                }
              }
    'M', 'm': { if ( $calculate_size ) {
                  $memory_size = floor($memory_value * 1024 * 1024 * $extra_percentage)
                  $memory_size_k = $memory_size * 1024
                } else {
                  $memory_size = $mem_size
                  $memory_size_k = $memory_value * 1024
                }
              }
              #{ $calculated_memory_size = floor($memory_value * 1024 * 1024 * $extra_percentage) }
    'G', 'g': { if ( $calculate_size ) {
                  $memory_size = floor($memory_value * 1024 * 1024 * 1024 * $extra_percentage)
                  $memory_size_k = $memory_size * 1024
                } else {
                  $memory_size = $mem_size
                  $memory_size_k = $memory_value * 1024 * 1024
                }
              }
              # { $calculated_memory_size = floor($memory_value * 1024 * 1024 * 1024 * $extra_percentage) }
    'T', 't': { if ( $calculate_size ) {
                  $memory_size = floor($memory_value * 1024 * 1024 * 1024 * 1024 * $extra_percentage)
                  $memory_size_k = $memory_size * 1024
                } else {
                  $memory_size = $mem_size
                  $memory_size_k = $memory_value * 1024 * 1024 * 1024
                }
              }
              # { $calculated_memory_size = floor($memory_value * 1024 * 1024 * 1024 * 1024 * $extra_percentage) }
    default:  { fail 'Unkown unit for memory_max_target'}
  }

  $limits_defaults = {
    ensure  => 'present',
    user    => "@${::ora_rac::settings::install_group}",
  }

  $default_limits = {
    'oracle_nofile' => {
      'limit_type' => 'nofile',
      'hard'       => '65536',
      'soft'       => '65536',
    },
    'oracle_nproc' => {
      'limit_type' => 'nproc',
      'hard'       => '16384',
      'soft'       => '16384',
    },
  }



  create_resources('limits::limits', $default_limits, $limits_defaults)
  create_resources('limits::limits', $limits, $limits_defaults)
  create_resources('sysctl', $sysctl)

  augeas {'ensure_tmpfs_size':
    context => '/files/etc/fstab',
    changes => [
      "set 01/spec tmpfs",
      "set 01/file /dev/shm",
      "set 01/vfstype tmpfs",
      "set 01/opt size",
      "set 01/opt/value ${memory_size}",
      "set 01/dump 0",
      "set 01/passno 0",
      # "ins opt after *[spec = 'tmpfs'][file = '/dev/shm']/opt[last()]",
      # "set *[spec = 'tmpfs']/opt[last()] size",
      # "set *[spec = 'tmpfs']/opt[last()]/value ${memory_size}",
    ],
    onlyif  => "match *[spec='tmpfs'][file = '/dev/shm']/opt[. = 'size'] size == 0",
  }

  exec {'remount_/dev/shm':
    command => '/bin/mount -o remount /dev/shm',
    onlyif  => "/usr/bin/test -z $(/bin/mount | /bin/grep /dev/shm | /bin/egrep -o \"size=${memory_size}|size=${memory_size_k}\")",
    require => Augeas['ensure_tmpfs_size'],
  }

  file {'/etc/profile':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ora_rac/etc_profile',
  }

} # end ora_rac::os
