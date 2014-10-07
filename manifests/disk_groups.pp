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
  asm_diskgroup {'+ASM1/REDO':
    ensure          => 'present',
    redundancy_type => 'normal',
    compat_asm      => '11.2.0.0.0',
    compat_rdbms    => '11.2.0.0.0',
    failgroups      => {
      'CONTROLLER1' => { 'diskname' => 'REDOVOL1', 'path' => 'ORCL:REDOVOL1'},
      'CONTROLLER2' => { 'diskname' => 'REDOVOL2', 'path' => 'ORCL:REDOVOL2'},
    }
  }

  asm_diskgroup {"+ASM1/${data_disk_group_name}":
    ensure          => 'present',
    redundancy_type => 'normal',
    compat_asm      => '11.2.0.0.0',
    compat_rdbms    => '11.2.0.0.0',
    failgroups      => {
      'CONTROLLER1' => { 'diskname' => 'DATAVOL1', 'path' => 'ORCL:DATAVOL1'},
      'CONTROLLER2' => { 'diskname' => 'DATAVOL2', 'path' => 'ORCL:DATAVOL2'},
    }
  }
  #
  # Define all required relations
  #
  Class[Ora_rac::Config] -> Asm_diskgroup<||>
  Oradb::Installasm<||> -> Asm_diskgroup<||>
  Asm_diskgroup<||> -> Oradb::Installdb<||>
  Asm_diskgroup<||> -> Oradb::Database<||>
}