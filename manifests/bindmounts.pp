# @summary Create bindmounts (generally of Lustre) on a directory
#
# @param map
#   mapping of (Lustre) filesystems to bindmounts
#
#   Example hiera parameter:
# ```
#   profile_lustre::bindmounts::map:
#     /scratch:
#       #opts: "defaults,nosuid,nodev,ro"
#       src_mountpoint: "/mnt/mount"
#       src_path: "/mnt/mount/scratch"
# ```
#
# @example
#   include profile_lustre::bindmounts
class profile_lustre::bindmounts (
  Optional[ Hash ] $map = undef,
) {

  if $map {
    $map.each | $k, $v | {
      profile_lustre::bindmount_resource { $k: * => $v }
    }
  }

}
