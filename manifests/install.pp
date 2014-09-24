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
# === Copyright
#
# Copyright 2014 Bert Hajee
#
# === Design
#
#
class ora_rac::install (
  $packages        = [
      'binutils',
      # 'compat-libcap1',
      'compat-libstdc++-33',
      'compat-libstdc++-33.x86_64',
      'pdksh',
      'gcc',
      'gcc-c++',
      'glibc',
      'glibc-devel',
      'ksh',
      'libgcc',
      'libstdc++',
      'libstdc++-devel',
      'libaio',
      'libaio-devel',
      'make',
      'sysstat',
      'compat-libstdc++-33.i386',
      # 'glibc.i386',
      'glibc-devel.i386',
      'libgcc.i386',
      'libstdc++.i386',
      'libstdc++-devel.i386',
      'libaio.i386',
      'libaio-devel.i386',
      'nfs-utils',
      # 'xclock',
      # 'xauth',
      # 'xdpyinfo',
      'screen',
      'nscd',
      'elfutils',
      'elfutils-libs',
      'elfutils-libelf',
      'elfutils-libelf-devel',
  ],
) {


  package {$packages:
    ensure    => 'installed',
  }

  unless defined(Package['libstdc++.x86_64']){
      package{'libstdc++.x86_64': 
      ensure    => 'installed',
    }
  }
} # end ora_rac::install
