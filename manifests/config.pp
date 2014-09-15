# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
class ora_rac::config inherits ora_rac::params
{

  $devices = [
    '/dev/sda',
    '/dev/sdb',
    '/dev/sdc',
    '/dev/sdd',
    '/dev/sde',
    '/dev/sdf',
    '/dev/sdg',
    ]

  partition_table{$devices:
    ensure  => 'gpt',
  }

  $partitions = $devices.map |$d| {"${d}:1"}

  partition{$partitions:
    ensure     => present,
    part_name  => 'primary',
    start      => '17.4kB',
    end        => '4096MB',
    require    => Partition_table[$devices],
  }

  ora_rac::asm_disk{'/dev/sda1':
    volume  => 'CRSVOL1',
    require => Partition[$partitions],
  }

  ora_rac::asm_disk{'/dev/sdb1':
    volume  => 'CRSVOL2',
    require => Partition[$partitions],
  }

  ora_rac::asm_disk{'/dev/sdc1':
    volume  => 'CRSVOL3',
    require => Partition[$partitions],
  }

  ora_rac::asm_disk{'/dev/sdd1':
    volume  => 'REDOVOL1',
    require => Partition[$partitions],
  }

  ora_rac::asm_disk{'/dev/sde1':
    volume  => 'REDOVOL2',
    require => Partition[$partitions],
  }

  ora_rac::asm_disk{'/dev/sdf1':
    volume  => 'DATAVOL1',
    require => Partition[$partitions],
  }

  ora_rac::asm_disk{'/dev/sdg1':
    volume  => 'DATAVOL2',
    require => Partition[$partitions],
  }

}