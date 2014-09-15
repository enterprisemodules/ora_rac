# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moiretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
class rac::db_server inherits rac::params {
  contain rac::hosts
  contain rac::os
  contain rac::install
  contain rac::directories
  contain rac::base
  contain rac::scandisks


  exec{'add_grid_node':
    timeout     => 0,
    user        => 'grid',
    command     => "/usr/bin/ssh grid@${master_node} \"/opt/oracle/app/${grid_version}/grid/\"oui/bin/./addNode.sh \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\"",
    logoutput   => on_failure,
    creates     => "/opt/oracle/app/${grid_version}/grid/root.sh",
    require     => [
      Class['rac::base'],
      Class['rac::scandisks'],
    ]
  }

  exec{'register_grid_node':
    timeout     => 0,
    user        => 'root',
    creates     => "/opt/oracle/grid/db1",
    command     => "/bin/sh /opt/oracle/oraInventory/orainstRoot.sh;/bin/sh /opt/oracle/app/${grid_version}/grid/root.sh",
    logoutput   => on_failure,
    require     => Exec['add_grid_node'],
  }

  exec{'set_ownership_2': # is a hack. Somehow Oracle 
    command   => "/bin/chown ${oracledb_user}:${oracledb_group} /opt/oracle /opt/oracle/app /opt/oracle/app/${grid_version}",
    before    => Exec['add_oracle_node'],
    require   => Exec['register_grid_node'],
  }

  exec{'add_oracle_node':
    timeout     => 0,
    user        => 'grid',
    command     => "/usr/bin/ssh oracle@${master_node} \"/opt/oracle/app/${db_version}/db_1/\"oui/bin/./addNode.sh \"CLUSTER_NEW_NODES={${::hostname}}\" \"CLUSTER_NEW_VIRTUAL_HOSTNAMES={${::hostname}-vip}\"",
    logoutput   => on_failure,
    creates     => "/opt/oracle/app/${db_version}/db_1/root.sh",
    require     => [
      Exec['register_grid_node']
    ]
  }

  exec{'register_oracle_node':
    timeout     => 0,
    user        => 'root',
    creates     => "/opt/oracle/app/${db_version}/db_1",
    command     => "/bin/sh /opt/oracle/oraInventory/orainstRoot.sh;/bin/sh /opt/oracle/app/${db_version}/db_1/root.sh",
    logoutput   => on_failure,
    require     => Exec['add_oracle_node'],
  }

  rac::oratab_entry{$current_instance:
    home      => "/opt/oracle/app/${db_version}/db_1",
    start     => 'N',
    comment   => 'Added by puppet',
    require   => Exec['register_oracle_node'],
  }    


  exec{'add_instance':
    user          => 'oracle',
    environment   => ["ORACLE_SID=${current_instance}", "ORAENV_ASK=NO", "ORACLE_HOME=/opt/oracle/app/${db_version}/db_1"],
    command       => "/opt/oracle/app/${db_version}/db_1/bin/srvctl add instance -d ${db_name} -i ${current_instance} -n ${::hostname}",
    unless        => "/opt/oracle/app/${db_version}/db_1/bin/srvctl status instance -d ${db_name} -i ${current_instance}",
    logoutput     => on_failure,
    require       => Rac::Oratab_entry[$current_instance],
  }

  exec{'start_instance':
    user          => 'oracle',
    environment   => ["ORACLE_SID=${current_instance}", "ORAENV_ASK=NO","ORACLE_HOME=/opt/oracle/app/${version}/db_1"],
    command       => "/opt/oracle/app/${db_version}/db_1/bin/srvctl start instance -d ${db_name} -i ${current_instance}",
    onlyif        => "/opt/oracle/app/${db_version}/db_1/bin/srvctl status instance -d ${db_name} -i ${current_instance} | grep not",
    logoutput     => on_failure,
    require       => Exec['add_instance']
  }

}
