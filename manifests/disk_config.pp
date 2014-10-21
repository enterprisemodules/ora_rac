# == Class: ora_rac::disk_config
#
# The purpose of this class is to configure the basic storage requirements
# for RAC. It creates the partitions and formats them according to needs. This
# is just an example class for getting it running in Vagrant. You need to make
# your own config class..
#
# === Parameters
#
#   none
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::disk_config inherits ora_rac::params
{
  $asm_disks = hiera('ora_rac::disk_config::asm_disks')
  create_resources('ora_rac::asm_disk', $asm_disks)
}