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
  #
  # Validation
  #
  assert_type(String[1],$raw_device)      |$e, $a| { fail "raw_device is ${a}, but must be a non empty string"}
  validate_re($raw_device, '.*\:.*')    # You must specify a device with a partition number
  validate_re($start,'\d.*\S?[%|k|K|m|M|g|G][b|B]?')
  validate_re($end,'\d.*\S?[%|k|K|m|M|g|G][b|B]?')

  #
  # Manipulation and translation of parameters
  #
  $_device_array    = split($raw_device,'[:]')
  $device_name      = $_device_array[0]
  $partition_number = $_device_array[1]
  $device           = "${device_name}${partition_number}"

  #
  #
  #

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
    require   => Service['oracleasm'],
  }

}