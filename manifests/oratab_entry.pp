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
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
define ora_rac::oratab_entry(
  String[1]             $home,
  Enum['Y','y','N','n'] $start,
  String                $comment = '',
){
  $sid = $name

  exec{"add_${sid}_to_oratab":
    command => "/bin/echo '${sid}:${home}:${start}   # ${comment}' >> /etc/oratab",
    unless  => "/bin/grep ${sid}:${home}: /etc/oratab",
  }
}
