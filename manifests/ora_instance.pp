# == Class: ora_rac::ora_instance
#
# Do all the stuff needed to register a new oracle inntance in a running (single node)
# RAC cluster
#
#
# === Parameters
#
# name    - The instance name
# on      - The oracle instance (probably the master instance) on which to run the sql commands
# number  - The instance number
# thread  - The instancd thread
#
# === Variables
#
#  none
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
define ora_rac::ora_instance(
  $on,
  $number,
  $thread,
  $datafile,
  $undo_initial_size,
  $undo_next,
  $undo_autoextend,
  $undo_max_size,
){
  #
  # Validate the inputs
  #
  assert_type(String[1], $on)  |$e, $a| { 
    fail "on is ${a}, but expected a non empty string"
  }
  assert_type(Integer, $number)|$e, $a| {
    fail "number is ${a}, but expected an integer"
  }
  assert_type(Integer, $thread) |$e, $a| {
   fail "thread is ${a}, but expected an integer"
 }
  assert_type(String[1], $undo_initial_size) |$e, $a| {
   fail "undo_initial_size is ${a}, but expected a non empty string"
 }
  assert_type(String[1], $undo_next) |$e, $a| {
   fail "undo_next is ${a}, but expected a non empty string"
 }
  assert_type(String[1], $undo_max_size) |$e, $a| {
    fail "undo_max_size is ${a}, but expected a non empty string"
  }
  assert_type(String[1], $datafile) |$e, $a| {
    fail "datafile is ${a}, but expected a non empty string"
  }
  assert_type(Enum['on','off'], $undo_autoextend) |$e, $a| {
    fail "undo_autoextend is ${a}, but expected a value ON or OFF"
  }

  ora_tablespace{"UNDOTBS${number}@${on}":
    contents    => 'undo',
    datafile    => $datafile,
    size        => $undo_initial_size,
    autoextend  => $undo_autoextend,
    next        => $undo_next,
    max_size    => $undo_max_size,
  }

  ora_init_param{"SPFILE/instance_number:${name}@${on}":
    ensure => present,
    value  => $number,
  }

  ora_init_param{"SPFILE/instance_name:${name}@${on}":
    ensure => present,
    value  => $name,
  }

  ora_init_param{"SPFILE/thread:${name}@${on}":
    ensure => present,
    value  => $thread,
  }

  ora_init_param{"SPFILE/undo_tablespace:${name}@${on}":
    ensure  => present,
    value   => "UNDOTBS${number}",
    require => Ora_tablespace["UNDOTBS${number}@${on}"],
  }

  file{"/tmp/add_logfiles_${thread}.sql":
    ensure  => 'present',
    content => template('ora_rac/add_logfiles.sql.erb'),
  }

  ora_exec{"@/tmp/add_logfiles_${thread}.sql@${on}":
    unless    => "select * from v\$log where THREAD#=${thread}",
    require   => [
      File["/tmp/add_logfiles_${thread}.sql"],
    ]
  }

  ora_thread{"${thread}@${on}":
    ensure  => 'enabled',
    require   => [
      Ora_init_param["SPFILE/undo_tablespace:${name}@${on}"],
      Ora_exec["@/tmp/add_logfiles_${thread}.sql@${on}"],
      ]
  }

}

