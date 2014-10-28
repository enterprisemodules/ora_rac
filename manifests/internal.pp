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
# Bert Hajee <hajee@moretIA.com>
#
class ora_rac::internal(
  $yumrepos,
  $packages,
  $asm_packages,
)
{
  
}