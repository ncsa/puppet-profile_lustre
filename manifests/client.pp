# @summary Manage Lustre for a client machine
#
# Manage Lustre for a client machine
#
# @example
#   include profile_lustre::client
class profile_lustre::client {

  include ::profile_lustre::bindmounts
  include ::profile_lustre::firewall
  include ::profile_lustre::install
  include ::profile_lustre::module
  include ::profile_lustre::nativemounts
  include ::profile_lustre::service
  include ::profile_lustre::telegraf::lustre_client_health
  include ::profile_lustre::tuning

  Class['::profile_lustre::nativemounts'] -> Class['::profile_lustre::tuning']

}
