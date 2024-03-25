# @summary Configure and build lnet & lustre kernel modules
#
# @param driver_config_client
#   Hash to configure options in lustre.conf for clients
#
#   Syntax:
#     driver:
#       key: value
#
#   E.g.:
#     ksocklnd:
#       skip_mr_route_setup: 1
#     lnet:
#       dead_router_check_interval: 60
#
# @param driver_config_router
#   Hash to configure options in lustre.conf for routers
#
#   Syntax:
#     driver:
#       key: value
#
#   E.g.:
#     ksocklnd:
#       skip_mr_route_setup: 1
#     lnet:
#       dead_router_check_interval: 60
#
# @param global_lnet_configs
#   Hash for "global" configs for lnet with string values. E.g.:
#     numa_range: "0"
#     max_intf: "200"
#
# @param is_lnet_router
#   Is the node an LNet router or not?
#
# @param lnet_conf_file
#   Full path to lnet.conf file, e.g. "/etc/lnet.conf"
#
# @param lnet_trigger_file
#   Full path to LNet trigger file (if this file is NOT present,
#   Puppet will attempt to (re)configure Lnet).
#
# @param local_networks
#   Hash of data to configure local NIDs on the host, in this form:
#     <LOCAL_LNET_1>:
#                   interfaces:    array of strings
#       (optional): tunables:      hash of params with string values
#       (optional): lnd_tunables:  hash of params with string values
#       (optional): CPT:           string
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
#   Hash of buffer sizes for LNet routers, usually of this form:
#     tiny: 2048
#     small: 16384
#     large: 1024
#
# @param routes
#   (fka remote_networks) Hash of data to configure routes to reach remote networks,
#   in this form:
#     <REMOTE_LNET_A>:
#                  router_ips: "IP_or_IP_list" (in format suitable for lustre.conf)
#                  router_net: "LND_for_router(s)"
#       (optional) params: hash with string values for additional parameters
#     ...
#   E.g.:
#     o2ib0:
#       router_ips: "172.28.16.[30-31]"
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
  $configure_lustre_command = "modprobe lnet && lnetctl lnet configure && \
    lnetctl import ${lnet_conf_file} && \
    echo 'If this file is deleted Puppet will reconfigure LNet' > ${lnet_trigger_file}"
  exec { 'configure_lustre':
    command => $configure_lustre_command,
    creates => $lnet_trigger_file,
    unless  => "test -f ${lnet_trigger_file}",
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
