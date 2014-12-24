# == Class: ora_rac::oratab_entry
#
# register an instance in /etc/oratab
#
# === Parameters
#
# home    - Oracle home directory
# start   - Start on autostart
# comment - Comment in the oratab
#
# === Variables
#
#  None
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
define ora_rac::oratab_entry(
  $home,
  $start,
  $comment = '',
){
  #
  # Validate the inputs
  #
  assert_type(String[1], $home)              |$e, $a| { fail "home is ${a}, but should be a non empty string"}
  assert_type(String, $comment)              |$e, $a| { fail "comment is ${a}, but should be a string"}
  assert_type(Enum['Y','y','N','n'], $start) |$e, $a| { fail "start is ${a}, but should be Y of N case insensive"}
 
  $sid = $name

  exec{"add_${sid}_to_oratab":
    command => "/bin/echo '${sid}:${home}:${start}   # ${comment}' >> /etc/oratab",
    unless  => "/bin/grep ${sid}:${home}: /etc/oratab",
  }
}

