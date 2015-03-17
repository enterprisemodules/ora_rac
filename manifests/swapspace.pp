# == Class: ora_rac::swapspace
#
# Create temporary swapspace for Oracle.
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
class ora_rac::swapspace(
  $size = floor($::memorysize_mb * 2),
)
{
  exec{'oracle_temporary_swapspace':
    timeout => 0,
    command => "/bin/dd if=/dev/zero of=/tmp/ora_tmp_swap.1 bs=1M count=${size}; /bin/chmod 0600 /tmp/ora_tmp_swap.1; /sbin/mkswap /tmp/ora_tmp_swap.1; /sbin/swapon /tmp/ora_tmp_swap.1",
    onlyif  => '/usr/bin/test ! -f /tmp/ora_tmp_swap.1',
  }
}
