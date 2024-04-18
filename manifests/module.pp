# @summary Configure LNet & Lustre kernel modules
# This Puppet class primarily uses [Dynamic LNet Configuration](https://wiki.lustre.org/Dynamic_LNet_Configuration_and_lnetctl)
# by importing from an lnet.conf. Where necessary it uses [Static LNet Configuration](https://wiki.lustre.org/Static_LNet_Configuration),
# in particular for driver-level configurations, which are placed in a lustre.conf.
#
# @param driver_config_client
#   Hash to configure driver options (in lustre.conf) for Lustre clients
#
#   Syntax:
#     driver:
#       key: value
#
#   E.g.:
#     ksocklnd:
#       skip_mr_route_setup: 1
#
# @param driver_config_router
#   Hash to configure driver options (in lustre.conf) for LNet routers
#
#   Syntax:
#     driver:
#       key: value
#
#   E.g.:
#     ksocklnd:
#       skip_mr_route_setup: 1
#
# @param global_lnet_configs
#   Hash for "global" configs for LNet (in lnet.conf, "global:" section) with String values. E.g.:
#     numa_range: "0"
#     max_intf: "200"
#
# @param is_lnet_router
#   Is the node an LNet router or not? Enables routing (via lnet.conf).
#
# @param lnet_conf_file
#   Full path to lnet.conf file, e.g. "/etc/lnet.conf"
#
# @param lnet_trigger_file
#   Full path to LNet trigger file (if this file is NOT present,
#   Puppet will attempt to (re)configure Lnet).
#
# @param local_networks
#   Hash of data to configure local NIDs on the host (via lnet.conf, "net:" section), in this form:
#     <LOCAL_LNET_1>:
#                   interfaces:    Array of Strings
#                                  - formerly a String named "interface:"
#                                  - interfaces for this LNet
#       (optional): tunables:      Hash of params with String values
#                                  - these are general tunables for this LNet
#       (optional): lnd_tunables:  Hash of params with String values
#                                  - these are LND (Lustre Network Driver) tunables specific to this LNet
#       (optional): CPT:           String
#                                  - specify the CPU Partition Table for this LNet
#     ...
#   E.g.:
#     tcp0:
#       interfaces: ["eth1"]
#       lnd_tunables:
#         conns_per_peer: "1"
#       tunables:
#         peer_timeout: "240"
#       CPT: "[0,1]"
#     o2ib1:
#       interfaces:
#         - "ib0"
#         - "ib1"
#
# @param modprobe_lustre_conf_file
#   Full path to lustre.conf file, e.g. "/etc/modprobe.d/lustre.conf".
#
# @param router_buffers
#   Hash of buffer sizes for LNet routers (via lnet.conf, "buffers:" section), usually of this form:
#     tiny: 2048
#     small: 16384
#     large: 1024
#
# @param routes
#   (fka remote_networks) Hash of data to configure routes to reach remote networks,
#   (via lnet.conf, "route:" section) in this form:
#     <REMOTE_LNET_A>:
#                  router_ips: "IP_or_IP_list" (IPs for gateways)
#                  - formerly a String called "router_IPs", now an Array
#                  - range shorthand (e.g., *.[30-31]) no longer allowed
#                  router_net: "LND_for_router(s)" (LNDs for gateways)
#       (optional) params: Hash with String values for additional parameters
#                  - any additional parameters for these routes (to this remote LNet)
#     ...
#   E.g.:
#     o2ib0:
#       router_ips:
#         - "172.28.16.30"
#         - "172.28.16.31"
#       router_net: "tcp0"
#       params:
#         hops: "-1"
#
# @example
#   include profile_lustre::module
#
class profile_lustre::module (
  Hash    $driver_config_client,
  Hash    $driver_config_router,
  Hash    $global_lnet_configs,
  Boolean $is_lnet_router,
  String  $lnet_conf_file,
  String  $lnet_trigger_file,
  Hash    $local_networks,
  String  $modprobe_lustre_conf_file,
  Hash    $router_buffers,
  Hash    $routes,
) {
  # determine which template to use to build lustre.conf file
  if $is_lnet_router {
    # use template for LNet routers
    $modprobe_lustre_conf_template = 'profile_lustre/lustre.conf.lnet.epp'
  } else {
    # use template for clients
    $modprobe_lustre_conf_template = 'profile_lustre/lustre.conf.client.epp'
  }

  # BUILD /etc/modprobe.d/lustre.conf FILE
  file { $modprobe_lustre_conf_file:
    ensure  => file,
    content => epp( $modprobe_lustre_conf_template ),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
  }

  # BUILD /etc/lnet.conf FILE
  file { $lnet_conf_file:
    ensure  => file,
    content => epp( 'profile_lustre/lnet.conf.epp' ),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
  }

  # CONFIGURE LNET

  ## when LNet is (re)configured, write a trigger file containing the last reboot time
  $configure_lustre_command = "umount -a -t lustre && lustre_rmmod && \
    modprobe lnet && lnetctl lnet configure && lnetctl import ${lnet_conf_file} && \
    echo 'If this file is deleted or contains an older system boot time Puppet will unmount Lustre and reconfigure LNet' > ${lnet_trigger_file} && \
    uptime -s >> ${lnet_trigger_file}"

  ## configure LNet, but only if the trigger file is missing or has a different last reboot time
  exec { 'configure_lustre':
    command => $configure_lustre_command,
    unless  => "egrep -q \"$(uptime -s)\" ${lnet_trigger_file}",
    path    => ['/usr/bin', '/usr/sbin', '/sbin'],
    require => [
      File[$modprobe_lustre_conf_file],
      File[$lnet_conf_file],
      Package[$profile_lustre::install::required_pkgs],
    ],
  }

  unless $is_lnet_router {
    exec { 'modprobe_lustre':
      command   => 'modprobe lustre',
      unless    => 'lsmod | grep lustre',
      path      => ['/usr/bin', '/usr/sbin', '/sbin'],
      subscribe => Exec['configure_lustre'],
      require   => [
        File[$modprobe_lustre_conf_file],
        Package[$profile_lustre::install::required_pkgs],
      ],
    }
  }
}
