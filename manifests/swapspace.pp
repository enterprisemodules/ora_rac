# == Class: ora_rac::swapspace
#
# Create swapspace for Oracle. This is probably only needed for Vagrant boxes
# REAL nodes should define their own swapspace.
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
class ora_rac::swapspace
{
  exec { "create swap file":
    command => "/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=8192",
    creates => "/var/swap.1",
  }

  exec { "attach swap file":
    command => "/sbin/mkswap /var/swap.1 && /sbin/swapon /var/swap.1",
    require => Exec["create swap file"],
    unless => "/sbin/swapon -s | grep /var/swap.1",
  }

  #add swap file entry to fstab
  exec {"add swapfile entry to fstab":
    command => "/bin/echo >>/etc/fstab /var/swap.1 swap swap defaults 0 0",
    require => Exec["attach swap file"],
    user => root,
    unless => "/bin/grep '^/var/swap.1' /etc/fstab 2>/dev/null",
  }

}