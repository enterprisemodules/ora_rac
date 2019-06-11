# == Class: ora_rac::asm_disk
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
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
#
define ora_rac::asm_disk(
  Ora_rac::RawDevice         $raw_device,
  Optional[Easy_type::Size]  $start      = undef,
  Optional[Easy_type::Size]  $end        = undef,
  Enum['gpt','msdos']        $table_type = 'msdos',
)
{
  include ora_rac::params
  #
  # Manipulation and translation of parameters
  #
  $_device_array    = split($raw_device,'[:]')
  $device_name      = $_device_array[0]
  $partition_number = $_device_array[1]
  $mapped_device    = regsubst($device_name,'\/dev\/mapper\/.*', '') != $device_name
  #
  #
  # Mapped devices use the 'p1' and 'p2' extensions for partitions
  #
  if $mapped_device {
    $device         = "${device_name}p${partition_number}"
  } else {
    $device         = "${device_name}${partition_number}"
  }

  partition_table { $device_name:
    ensure  => $table_type,
  }

  -> partition { $raw_device:
    ensure    => 'present',
    part_type => 'primary',
    start     => $start,
    end       => $end,
  }

  if $ora_rac::params::configure_asmlib {
    exec { "/usr/sbin/oracleasm createdisk ${name} ${device}":
      unless  => "/bin/bash -c \"while [ ! -e /dev/${device} ]; do sleep 1 ;done\";/usr/sbin/oracleasm querydisk -v ${device}",
      require => [
        Service['oracleasm'],
        Partition[$raw_device],
      ]
    }
  }
}
