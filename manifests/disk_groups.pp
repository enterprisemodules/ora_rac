# == Class: ora_rac::disk_groups
#
# This class creates all required disk groups on ASM. At the end of the class, the
# requirements with other classes is described. This takes care of any depencies
#
# === Parameters
#
# Check ora_rac::params for all the parameters
#
# === Variables
#
# Check ora_rac::params for all the variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::disk_groups inherits ora_rac::params
{
  require ora_rac::settings

  $defaults = {
    ensure        => 'present',
    compat_asm    => $ora_rac::settings::db_version,
    compat_rdbms  => $ora_rac::settings::db_version,
  }
  create_resources('ora_asm_diskgroup', $ora_rac::settings::asm_disk_groups, $defaults)
  #
  # Define all required relations
  #
  Oradb::Installasm<||> -> Ora_asm_diskgroup<||> -> Oradb::Installdb<||>
  Ora_rac::Asm_disk<||> -> Ora_asm_diskgroup<||> -> Ora_asm_volume<||> 
}