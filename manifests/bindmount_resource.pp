# @summary Create a bindmount (generally of Lustre) on a directory
#
# Assumes that we are bindmounting from a mount or sub-directory of
# a mount.
#
# @param opts
#   Mount options. MUST include 'bind'. (Optional.)
#
# @param src_mountpoint
#   The mount point of the source we are bindmounting from.
#
# @param src_path
#   The location we are bindmounting from (either same as
#   src_mountpoint or a sub-directory).
#
# @example
#   profile_lustre::bindmount_resource { '/scratch':
#     #opts           => "defaults,bind,noauto,nosuid,nodev,ro"
#     src_mountpoint => "/mnt/mount",
#     src_path       => "/mnt/mount/scratch",
#   }
#
define profile_lustre::bindmount_resource (
  String           $src_mountpoint,
  String           $src_path,
  Optional[String] $opts = 'defaults,bind,noauto,nodev,nosuid',
) {

  # Resource defaults
  Mount {
    ensure => mounted,
    fstype => 'none',
  }
  File {
    ensure => directory,
  }

  # Ensure parents of target dir exist, if needed (excluding / )
  $dirparts = reject( split( $name, '/' ), '^$' )
  $numparts = size( $dirparts )
  if ( $numparts > 1 ) {
    each( Integer[2,$numparts] ) |$i| {
      ensure_resource(
        'file',
        reduce( Integer[2,$i], $name ) |$memo, $val| { dirname( $memo ) },
        { 'ensure' => 'directory' }
      )
    }
  }

  # Ensure target directory exists
  file { $name: }

  # Add bind option if not already included
  if ( $opts =~ /bind/ ) {
    $mount_opts = $opts
  } else {
    $mount_opts = join( split( $opts, ',' ) + 'bind', ',' )
  }

  # Define the mount point
  mount { $name:
    device  => $src_path,
    options => $mount_opts,
    require => [
      File[ $name ],
      Mount[ $src_mountpoint ],
    ],
  }

}
