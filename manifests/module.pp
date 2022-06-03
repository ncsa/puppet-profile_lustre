# @summary Configure and build lnet & lustre kernel modules
#
# @param is_lnet_router
#   Is the node an LNet router or not?
#
# @param lnet_conf_file
#   Full path to lnet.conf file, e.g. "/etc/lnet.conf"
#
# @param lnet_trigger_file
#   Full path to LNet trigger file (if this file is NOT present,
#   Puppet will (re)configure Lnet).
#
# @param local_networks
#   Hash of data to configure local NIDs on the host, in this form:
#     <LOCAL_LND_1>:
#       interface: "<ifc for LOCAL_LND_1>"
#     ...
#   E.g.:
#     tcp0:
#       interface: "eth1"
#     o2ib1:
#       interface: "ib0"
#
# @param modprobe_lustre_conf_file
#   Full path to modprobe lustre.conf file, e.g. "/etc/modprobe.d/lustre.conf"
#
# @param remote_networks
#   Hash of data to configure routes to reach emote networks, in this form:
#     <REMOTE_LND_A>:
#       router_IPs: "IP_or_IP_list" (in format suitable for lustre.conf)
#       router_net: "LND_for_router(s)"
#     ...
#   E.g.:
#     o2ib0:
#       router_IPs: "172.28.16.[30-31]"
#       router_net: "tcp0"
#
# @example
#   include profile_lustre::module
#
class profile_lustre::module (
  Boolean $is_lnet_router,
  String  $lnet_conf_file,
  String  $lnet_trigger_file,
  Hash    $local_networks,
  String  $modprobe_lustre_conf_file,
  Hash    $remote_networks,
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

  # CONFIGURE LNET
  $configure_lustre_command = "modprobe lnet && lnetctl lnet configure --all && \
    lnetctl export --backup > ${lnet_conf_file} && \
    echo 'If this file is deleted Puppet will reconfigure LNet' > ${lnet_trigger_file}"
  exec { 'configure_lustre':
    command => $configure_lustre_command,
    creates => $lnet_trigger_file,
    unless  => "test -f ${lnet_trigger_file}",
    path    => ['/usr/bin', '/usr/sbin', '/sbin'],
    require => [
      Package[ $profile_lustre::install::required_pkgs ],
    ],
  }

  unless $is_lnet_router {
    exec { 'modprobe_lustre':
      command   => 'modprobe lustre',
      unless    => 'lsmod | grep lustre',
      path      => ['/usr/bin', '/usr/sbin', '/sbin'],
      subscribe => Exec['configure_lustre'],
      require   => [
        Package[ $profile_lustre::install::required_pkgs ],
      ],
    }
  }

}
