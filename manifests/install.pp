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
  $packages = hiera('ora_rac::install::packages')
  create_resources('package', $packages)
} # end ora_rac::install
