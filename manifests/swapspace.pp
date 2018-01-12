#
# $size - The size of the swapspace in mb. If no value specified the following calculation will be used:
#         if    $::memorysize_mb < 2048 --> ceiling(($::memorysize_mb * 1.5) - $::swapsize_mb)
#         elsif $::memorysize_mb < 8192 --> ceiling($::memorysize_mb - $::swapsize_mb)
#         else  ceiling($::memorysize_mb *0.75 - $::swapsize_mb)
#
class ora_rac::swapspace(
  $size = undef,
) {
  if $size != undef {
    $swapfile_size = ceiling($size - $::swapsize_mb)
  } else {
    if $::memorysize_mb <= 2048 {
      $swapfile_size = ceiling(($::memorysize_mb * 1.5) - $::swapsize_mb)
    } elsif $::memorysize_mb <= 8192 {
      $swapfile_size = ceiling($::memorysize_mb - $::swapsize_mb)
    } else {
      $swapfile_size = ceiling(($::memorysize_mb * 0.75) - $::swapsize_mb)
    }
  }

  if $swapfile_size > 0 {
    swap_file::files { 'swap_file':
      swapfilesize => "${swapfile_size} MB",
      swapfile     => '/mnt/swapfile',
      add_mount    => true,
    }
  }
}
