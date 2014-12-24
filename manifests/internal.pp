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
  assert_type(Hash, $yumrepos )          |$e, $a| { fail "yumrepos is ${a}, expected a Hash"}
  assert_type(Hash, $packages )          |$e, $a| { fail "packages is ${a}, expected a Hash"}
  assert_type(Hash, $asm_packages )      |$e, $a| { fail "asm_packages is ${a}, expected a Hash"}
  
}