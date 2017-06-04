# == Class: ora_rac::internal
#
# read all internal variables from the internal hiera data
# These paramaters are the ones that can be OS specific
# and should NOT be overridden by user supplied hiera data
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <bert.hajee@enterprisemodules.com>
#
class ora_rac::internal(
  Hash $yumrepos,
  Hash $packages,
  Hash $asm_packages,
)
{}
