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
  $sysctl_params = hiera('ora_rac::sysctl_params')
  create_resources('sysctl', $sysctl_params)

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
}