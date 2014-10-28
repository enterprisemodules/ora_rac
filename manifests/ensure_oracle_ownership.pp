# == Class: ora_rac::ensure_oracle_ownership
#
# This class makes sure all the directories fro oracle_base to oracle_home
# exist and are owned by the oracle user and oracle_install group.
#
# === Parameters
#
#  none
#
# === Variables
#
#   $oracle_base
#   $oracle_home
#   $oracle_user
#   $install_group
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::ensure_oracle_ownership inherits ora_rac::params{
  require ora_rac::settings

  exec{"change ownership ${ora_rac::settings::oracle_base}":
    command   => "/bin/chown ${ora_rac::settings::oracle_user}:${ora_rac::settings::install_group} ${ora_rac::settings::oracle_base}"
  }

  $difference  = regsubst($ora_rac::settings::oracle_home,$ora_rac::settings::oracle_base,'')
  $directories = split($difference,'/')
  $non_empty_directories = $directories.filter |$element| { $element != ''}

  $non_empty_directories.reduce($ora_rac::settings::oracle_base) |$base_path, $relative_path| {
    $path = "${base_path}/${relative_path}"
    exec{"create directory ${path}": # is a hack. Somehow Oracle
      command  => "/bin/mkdir ${path}",
      onlyif   => "/usr/bin/test ! -d ${path}",
    } ->
    exec{"set_ownership ${path}": # is a hack. Somehow Oracle
      command  => "/bin/chown  ${ora_rac::settings::oracle_user}:${ora_rac::settings::install_group} ${path}",
    }
    $path
  }
}

