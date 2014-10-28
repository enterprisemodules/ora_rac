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
# ora_rac::internal::packages - Hash of packages to install
#
# === Authors
#
# Bert Hajee hajee@moretIA.com
#
#
class ora_rac::install
{
  require ora_rac::internal
  create_resources('package', $ora_rac::internal::packages)
} # end ora_rac::install
