# == Class: ora_rac::afd_disk
#
# === Parameters
#
# name      partition name if the form /dev/sda:1
# name      asm name name
# start     start of the partition. If not specified or undef, it will default to the
#           first available sector on the disk.
# end       end of the partition. If not specfied or undef, it will default to the last
#           available block on the disk. Therefore filling the whole disk.
#
# === Variables
#
# === Authors
#
# Remy van Berkum <remy.van.berkum@enterprisemodules.com>
#
#
define ora_rac::afd_disk(
  Ora_rac::RawDevice         $raw_device,
  Optional[String[1]]        $udev_name   = undef,
  Optional[Easy_type::Size]  $start       = undef,
  Optional[Easy_type::Size]  $end         = undef,
  Enum['gpt','msdos']        $table_type  = 'msdos',
)
{
  #
  # Manipulation and translation of parameters
  #
  $_device_array    = split($raw_device,'[:]')
  $device_name      = $_device_array[0]
  if ( $_device_array.length > 1 ) {
    $partition_number = $_device_array[1]
  } else {
    $partition_number = '0'
  }
  $mapped_device    = regsubst($device_name,'\/dev\/mapper\/.*', '') != $device_name
  sleep { "until_${device_name}_available":
    bedtime       => '120',                                     # how long to sleep for
    wakeupfor     => "/usr/bin/test -b ${device_name}",         # an optional test, run in a shell
    dozetime      => '5',                                       # dozetime for the test interval, defaults to 10s
    failontimeout => true,                                      # whether to fail the resource if the test times out
    refreshonly   => false,
  }

  partition_table { $device_name:
    ensure  => $table_type,
  }

  if ( $partition_number != '0' ) {
    partition { $raw_device:
      ensure    => 'present',
      part_type => 'primary',
      start     => $start,
      end       => $end,
      require   => Partition_table[$device_name],
    }
  }
}
