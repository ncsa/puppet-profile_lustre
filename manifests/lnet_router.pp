# @summary Manage Lustre for an LNet router
#
# Manage Lustre for an LNet router
#
# @example
#   include profile_lustre::lnet_router
class profile_lustre::lnet_router {

  include ::profile_lustre::firewall
  include ::profile_lustre::install
  include ::profile_lustre::module
  include ::profile_lustre::service
  include ::profile_lustre::telegraf::lnet_router_stats
  include ::profile_lustre::tuning

  Class['::profile_lustre::module'] -> Class['::profile_lustre::tuning']

}
