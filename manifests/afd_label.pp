# == Class: ora_rac::afd_label
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
define ora_rac::afd_label(
  String[1]                  $raw_device,
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
  #
  #
  # Mapped devices use the 'p1' and 'p2' extensions for partitions
  #
  if ( $partition_number != '0' ) {
    if $mapped_device {
      $device         = "${device_name}p${partition_number}"
    } else {
      $device         = "${device_name}${partition_number}"
    }
  } else {
    $device = $device_name
  }

  if ( $udev_name ) {
    $afddisk = $udev_name
  } else {
    $afddisk = $device
  }

  exec { "add afd label ${name} to device ${afddisk}":
    command     => "${::ora_rac::settings::grid_home}/bin/asmcmd afd_label ${name} ${afddisk}",
    environment => ["ORACLE_HOME=${::ora_rac::settings::grid_home}"],
    user        => $::ora_rac::settings::grid_user,
    path        => "/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:${::ora_rac::settings::grid_home}/bin",
    unless      => "${::ora_rac::settings::grid_home}/bin/asmcmd afd_lslbl ${afddisk} | grep '^${name} .* ${afddisk}$'",
    require     => [
      Partition_table[$device_name],
      Ora_install::Installasm[$::ora_rac::settings::_grid_file],
    ],
  }
}
