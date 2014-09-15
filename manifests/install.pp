# == Class: rac::install
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
# Allard Berends <allard.berends@prorail.nl>
#
# === Copyright
#
# Copyright 2013 Allard Berends
#
# === Design
#
# In this class, only software channels may be subscribed to
# and only RPM's may be installed. No other side effects are
# allowed.
# The list of required RPM's to install for the Oracle DB
# comes from the oracle-validated RPM, obtained from
# http://public-yum.oracle.com/repo/OracleLinux/OL5/8/base/x86_64
# bc
# compat-libstdc++
# elfutils-libelf-devel
# gcc
# gcc.i386
# gcc-c++
# gdbm
# glibc
# glibc-common
# glibc-devel
# glibc-headers
# irqbalance
# ksh
# libaio
# libaio-devel
# libgcc
# libICE
# libSM
# libstdc++
# libstdc++-devel
# libXp
# libXt
# libXtst
# make
# smartmontools
# unixODBC64-devel
# unixODBC-devel
# unixODBC-libs
# xorg-x11-utils
# xorg-x11-xinit
#
# Note that not all of the above RPM's show up in the actual
# list. Some are installed via dependencies, others are not
# needed.
#
class rac::install (
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
} # end rac::install
