# == Class: ora_rac::asm_disk
#
# === Parameters
#
# name      partition name if the form /dev/sda:1
# name    asm name name
# start     start of the partition
# end       end of the partition
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
#
define ora_rac::asm_disk(
  $raw_device,
  $start    = '0%'  ,
  $end      = '100%',
)
{
  $_device_array    = split($raw_device,'[:]')
  $device_name      = $_device_array[0]
  $partition_number = $_device_array[1]
  $device           = "${device_name}${partition_number}"

  partition_table{$device_name:
    ensure  => 'gpt',
  }->

  partition{$raw_device:
    ensure    => 'present',
    part_name => 'primary',
    start     => $start,
    end       => $end,
  }->

  exec{"/usr/sbin/oracleasm createdisk ${name} ${device}":
    unless    => "/usr/sbin/oracleasm querydisk -v ${device}",
    logoutput => true,
    require   => Service['oracleasm'],
  }

}