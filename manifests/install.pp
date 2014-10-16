# == Class: ora_rac::install
#
# This class ensures installation of RPM's needed for the
# Oracle database product.
#
# === Parameters
#
# None
#
# === Variables
#
# === Authors
#
# Bert Hajee hajee@moretIA.com
#
#
class ora_rac::install
{
  $packages = [
    'binutils',
    'compat-libstdc++-33',
    'elfutils-libelf',
    'elfutils-libelf-devel',
    'gcc',
    'gcc-c++',
    'glibc',
    'glibc-common',
    'glibc-devel',
    'glibc-headers',
    'ksh',
    'libaio',
    'libaio-devel',
    'libgcc',
    'libstdc++',
    'libstdc++-devel',
    'make',
    'sysstat',
    'unixODBC',
    'unixODBC-devel',
    'coreutils',
    'compat-libcap1',
    ]

  package{$packages:
    ensure    => 'installed',
  }

} # end ora_rac::install
