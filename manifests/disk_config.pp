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
  require ora_rac::settings
  create_resources('ora_rac::asm_disk', $ora_rac::settings::asm_disks)
}