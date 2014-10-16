# == Class: ora_rac::sysctl
#
# set all required sysctl paramaters for a RAC node
#
# === Parameters
#
#  none
#
# === Variables
#
# none
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::sysctl inherits ora_rac::params
{
  # TODO: Fix the devices
  #   'title'   => 'net.ipv4.conf.eth2.rp_filter',
  #   'comment' => '# Disable rp_filtering on interconnects',
  #   'setting' => 'net.ipv4.conf.eth2.rp_filter = 2',
  # },
  # {
  #   'title'   => 'net.ipv4.conf.eth3.rp_filter',
  #   'comment' => '# Disable rp_filtering on interconnects',
  #   'setting' => 'net.ipv4.conf.eth3.rp_filter = 2',
  # },
  # {
  #   'title'   => 'net.ipv4.conf.bond0/103.rp_filter',
  #   'comment' => '# Disable rp_filtering on interconnects',
  #   'setting' => 'net.ipv4.conf.bond0/103.rp_filter = 1',
  # },
  # Sysctl{ permanent => 'yes'}

  sysctl {'net.ipv4.ip_local_port_range':
    ensure  => 'present',
    value   => '9000 65500',
    comment => 'TODO: Add comment',
  }

  sysctl {'kernel.shmall':
    ensure  => 'present',
    value   => '65536000',
    comment => 'TODO: Add comment',
  }

  sysctl {'kernel.shmmax':
    ensure  => 'present',
    value   => '4294967296',
    comment => 'TODO: Add comment',
  }

  sysctl {'kernel.msgmni':
    ensure  => 'present',
    value   => '2878',
    comment => 'TODO: Add comment',
  }

  sysctl {'kernel.sem':
    ensure  => 'present',
    value   => '2510 356420 2510 142',
    comment => 'TODO: Add comment',
  }

  sysctl { 'kernel.shmmni':
    ensure  => 'present',
    value   => '4096',
    comment => 'TODO: Add comment',
  }

  sysctl {'fs.file-max':
    ensure  => 'present',
    value   => '6815744',
    comment => 'TODO: Add comment',
  }

  sysctl {'fs.aio-max-nr':
    ensure  => 'present',
    value   => '1572864',
    comment => 'TODO: Add comment',
  }

  sysctl {'net.core.rmem_default':
    ensure  => 'present',
    value   => '262144',
    comment => 'TODO: Add comment',
  }

  sysctl {'net.core.rmem_max':
    ensure  => 'present',
    value   => '4194304',
    comment => 'TODO: Add comment',
  }

  sysctl {'net.core.wmem_default':
    ensure  =>  'present',
    value   => '262144',
    comment => 'TODO: Add comment',
  }

  sysctl {'net.core.wmem_max':
    ensure  => 'present',
    value   => '1048576',
    comment => 'TODO: Add comment',
  }

  # TODO: Checkout why
  # sysctl {'sunrpc.tcp_slot_table_entries':
  #   ensure  => 'present',
  #   value   => '128',
  #   comment => 'TODO: Add comment',
  # }

  sysctl {'vm.max_map_count':
    ensure  => 'present',
    value   => '100000',
    comment => 'TODO: Add comment',
  }
}