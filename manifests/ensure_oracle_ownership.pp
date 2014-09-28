class ora_rac::ensure_oracle_ownership inherits ora_rac::params{
  exec{"change ownership ${oracle_base}":
    command   => "/bin/chown ${oracle_user}:${install_group} ${oracle_base}"
  }

  $difference  = regsubst($oracle_home,$oracle_base,'')
  $directories = split($difference,'/')
  $non_empty_directories = $directories.filter |$element| { $element != ''}

  $non_empty_directories.reduce($oracle_base) |$base_path, $relative_path| {
    $path = "${base_path}/${relative_path}"
    exec{"create directory ${path}": # is a hack. Somehow Oracle
      command  => "/bin/mkdir ${path}",
      onlyif   => "/usr/bin/test ! -d ${path}",
    } ->
    exec{"set_ownership ${path}": # is a hack. Somehow Oracle
      command  => "/bin/chown  ${oracle_user}:${install_group} ${path}",
    }
    $path
  }
}

