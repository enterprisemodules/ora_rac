class ora_rac::set_ownership inherits ora_rac::params {

  exec{"set_ownership ${oracle_base}":
    command  => "/bin/chown  ${oracle_user}:${install_group} ${oracle_base}",
  }

  $difference  = regsubst($oracle_home,$oracle_base,'')
  $directories = split($difference,'/')
  $non_empty_directories = $directories.filter |$element| { $element != ''}
  $selected_directories = delete_at($non_empty_directories, size($non_empty_directories) - 1)

  $selected_directories.reduce($oracle_base) |$base_path, $relative_path| {
    $path = "${base_path}/${relative_path}"
    exec{"set_ownership ${path}": # is a hack. Somehow Oracle
      command  => "/bin/chown  ${oracle_user}:${install_group} ${path}",
      before   => Oradb::Installdb[$file],
      require  => Oradb::Installasm[$file],
    }
    $path
  }

}
