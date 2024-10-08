# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`profile_lustre::bindmounts`](#profile_lustre--bindmounts): Create bindmounts (generally of Lustre) on a directory
* [`profile_lustre::client`](#profile_lustre--client): Manage Lustre for a client machine
* [`profile_lustre::client::tuning`](#profile_lustre--client--tuning): Apply Lustre client tuning parameters using lctl.
* [`profile_lustre::firewall`](#profile_lustre--firewall): A short summary of the purpose of this class
* [`profile_lustre::install`](#profile_lustre--install): Install Lustre client
* [`profile_lustre::lnet_router`](#profile_lustre--lnet_router): Manage Lustre for an LNet router
* [`profile_lustre::module`](#profile_lustre--module): Configure LNet & Lustre kernel modules
* [`profile_lustre::nativemounts`](#profile_lustre--nativemounts): Mount Lustre filesystems on the client
* [`profile_lustre::service`](#profile_lustre--service): Configure the lnet service
* [`profile_lustre::telegraf::lnet_router_stats`](#profile_lustre--telegraf--lnet_router_stats): Telegraf LNET router stats
* [`profile_lustre::telegraf::lustre_client_health`](#profile_lustre--telegraf--lustre_client_health): Telegraf Lustre client health checks

### Defined types

* [`profile_lustre::bindmount_resource`](#profile_lustre--bindmount_resource): Create a bindmount (generally of Lustre) on a directory
* [`profile_lustre::nativemount_resource`](#profile_lustre--nativemount_resource): Mount Lustre filesystem on a directory

## Classes

### <a name="profile_lustre--bindmounts"></a>`profile_lustre::bindmounts`

```
  profile_lustre::bindmounts::map:
    /scratch:
      #opts: "defaults,nosuid,nodev,ro"
      src_mountpoint: "/mnt/mount"
      src_path: "/mnt/mount/scratch"
```

#### Examples

##### 

```puppet
include profile_lustre::bindmounts
```

#### Parameters

The following parameters are available in the `profile_lustre::bindmounts` class:

* [`map`](#-profile_lustre--bindmounts--map)

##### <a name="-profile_lustre--bindmounts--map"></a>`map`

Data type: `Optional[Hash]`

mapping of (Lustre) filesystems to bindmounts

Example hiera parameter:

Default value: `undef`

### <a name="profile_lustre--client"></a>`profile_lustre::client`

Manage Lustre for a client machine

#### Examples

##### 

```puppet
include profile_lustre::client
```

### <a name="profile_lustre--client--tuning"></a>`profile_lustre::client::tuning`

Apply Lustre client tuning parameters using lctl.

#### Examples

##### 

```puppet
include profile_lustre::client::tuning
```

#### Parameters

The following parameters are available in the `profile_lustre::client::tuning` class:

* [`params`](#-profile_lustre--client--tuning--params)

##### <a name="-profile_lustre--client--tuning--params"></a>`params`

Data type: `Hash`

Hash of Lustre client tuning parameters:
  "<key1>": "<value1>"
  "<key2>": "<value2">
Note: Keys may contain * as a wildcard. E.g.:
  "osc.*.max_pages_per_rpc": "4096"

### <a name="profile_lustre--firewall"></a>`profile_lustre::firewall`

A short summary of the purpose of this class

#### Examples

##### 

```puppet
include profile_lustre::firewall
```

#### Parameters

The following parameters are available in the `profile_lustre::firewall` class:

* [`dports`](#-profile_lustre--firewall--dports)
* [`proto`](#-profile_lustre--firewall--proto)
* [`sources`](#-profile_lustre--firewall--sources)

##### <a name="-profile_lustre--firewall--dports"></a>`dports`

Data type: `Array[Integer]`

Destination ports that need to be open for the lustre service

##### <a name="-profile_lustre--firewall--proto"></a>`proto`

Data type: `String`

Protocol that needs to be open for the lustre service

##### <a name="-profile_lustre--firewall--sources"></a>`sources`

Data type: `Array[String]`

CIDR sources that need to be open for the lustre service.
This should include all of the Lustre servers and any LNET routers.
It may also need to other lustre client peers (need confirmation about this).

### <a name="profile_lustre--install"></a>`profile_lustre::install`

Install Lustre client

#### Examples

##### 

```puppet
include profile_lustre::install
```

#### Parameters

The following parameters are available in the `profile_lustre::install` class:

* [`required_pkgs`](#-profile_lustre--install--required_pkgs)
* [`yumrepo`](#-profile_lustre--install--yumrepo)

##### <a name="-profile_lustre--install--required_pkgs"></a>`required_pkgs`

Data type: `Array[String]`

Packages that need to be installed for Lustre mounts to work.

##### <a name="-profile_lustre--install--yumrepo"></a>`yumrepo`

Data type: `Hash`

Hash of yumrepo resource for lustre yum repository

### <a name="profile_lustre--lnet_router"></a>`profile_lustre::lnet_router`

Manage Lustre for an LNet router

#### Examples

##### 

```puppet
include profile_lustre::lnet_router
```

### <a name="profile_lustre--module"></a>`profile_lustre::module`

This Puppet class primarily uses [Dynamic LNet Configuration](https://wiki.lustre.org/Dynamic_LNet_Configuration_and_lnetctl)
by importing from an lnet.conf. Where necessary it uses [Static LNet Configuration](https://wiki.lustre.org/Static_LNet_Configuration),
in particular for driver-level configurations, which are placed in a lustre.conf.

#### Examples

##### 

```puppet
include profile_lustre::module
```

#### Parameters

The following parameters are available in the `profile_lustre::module` class:

* [`driver_config_client`](#-profile_lustre--module--driver_config_client)
* [`driver_config_router`](#-profile_lustre--module--driver_config_router)
* [`global_lnet_configs`](#-profile_lustre--module--global_lnet_configs)
* [`is_lnet_router`](#-profile_lustre--module--is_lnet_router)
* [`lnet_conf_file`](#-profile_lustre--module--lnet_conf_file)
* [`lnet_trigger_file`](#-profile_lustre--module--lnet_trigger_file)
* [`local_networks`](#-profile_lustre--module--local_networks)
* [`modprobe_lustre_conf_file`](#-profile_lustre--module--modprobe_lustre_conf_file)
* [`router_buffers`](#-profile_lustre--module--router_buffers)
* [`routes`](#-profile_lustre--module--routes)

##### <a name="-profile_lustre--module--driver_config_client"></a>`driver_config_client`

Data type: `Hash`

Hash to configure driver options (in lustre.conf) for Lustre clients

Syntax:
  driver:
    key: value

E.g.:
  ksocklnd:
    skip_mr_route_setup: 1

##### <a name="-profile_lustre--module--driver_config_router"></a>`driver_config_router`

Data type: `Hash`

Hash to configure driver options (in lustre.conf) for LNet routers

Syntax:
  driver:
    key: value

E.g.:
  ksocklnd:
    skip_mr_route_setup: 1

##### <a name="-profile_lustre--module--global_lnet_configs"></a>`global_lnet_configs`

Data type: `Hash`

Hash for "global" configs for LNet (in lnet.conf, "global:" section) with String values. E.g.:
  numa_range: "0"
  max_intf: "200"

##### <a name="-profile_lustre--module--is_lnet_router"></a>`is_lnet_router`

Data type: `Boolean`

Is the node an LNet router or not? Enables routing (via lnet.conf).

##### <a name="-profile_lustre--module--lnet_conf_file"></a>`lnet_conf_file`

Data type: `String`

Full path to lnet.conf file, e.g. "/etc/lnet.conf"

##### <a name="-profile_lustre--module--lnet_trigger_file"></a>`lnet_trigger_file`

Data type: `String`

Full path to LNet trigger file (if this file is NOT present,
Puppet will attempt to (re)configure Lnet).

##### <a name="-profile_lustre--module--local_networks"></a>`local_networks`

Data type: `Hash`

Hash of data to configure local NIDs on the host (via lnet.conf, "net:" section), in this form:
  <LOCAL_LNET_1>:
                interfaces:    Array of Strings
                               - formerly a String named "interface:"
                               - interfaces for this LNet
    (optional): tunables:      Hash of params with String values
                               - these are general tunables for this LNet
    (optional): lnd_tunables:  Hash of params with String values
                               - these are LND (Lustre Network Driver) tunables specific to this LNet
    (optional): CPT:           String
                               - specify the CPU Partition Table for this LNet
  ...
E.g.:
  tcp0:
    interfaces: ["eth1"]
    lnd_tunables:
      conns_per_peer: "1"
    tunables:
      peer_timeout: "240"
    CPT: "[0,1]"
  o2ib1:
    interfaces:
      - "ib0"
      - "ib1"

##### <a name="-profile_lustre--module--modprobe_lustre_conf_file"></a>`modprobe_lustre_conf_file`

Data type: `String`

Full path to lustre.conf file, e.g. "/etc/modprobe.d/lustre.conf".

##### <a name="-profile_lustre--module--router_buffers"></a>`router_buffers`

Data type: `Hash`

Hash of buffer sizes for LNet routers (via lnet.conf, "buffers:" section), usually of this form:
  tiny: 2048
  small: 16384
  large: 1024

##### <a name="-profile_lustre--module--routes"></a>`routes`

Data type: `Hash`

(fka remote_networks) Hash of data to configure routes to reach remote networks,
(via lnet.conf, "route:" section) in this form:
  <REMOTE_LNET_A>:
               router_ips: "IP_or_IP_list" (IPs for gateways)
               - formerly a String called "router_IPs", now an Array
               - range shorthand (e.g., *.[30-31]) no longer allowed
               router_net: "LND_for_router(s)" (LNDs for gateways)
    (optional) params: Hash with String values for additional parameters
               - any additional parameters for these routes (to this remote LNet)
  ...
E.g.:
  o2ib0:
    router_ips:
      - "172.28.16.30"
      - "172.28.16.31"
    router_net: "tcp0"
    params:
      hops: "-1"

### <a name="profile_lustre--nativemounts"></a>`profile_lustre::nativemounts`

```
  profile_lustre::nativemounts::map:
    /mnt/mount:
      src: "lustre-server1.local@o2ib,lustre-server2.local@o2ib:/filesystem"
      #opts: "defaults,nosuid,ro"  ## ??
```

#### Examples

##### 

```puppet
include profile_lustre::nativemounts
```

#### Parameters

The following parameters are available in the `profile_lustre::nativemounts` class:

* [`map`](#-profile_lustre--nativemounts--map)

##### <a name="-profile_lustre--nativemounts--map"></a>`map`

Data type: `Optional[Hash]`

mapping of Lustre filesystems to local mount points

Example hiera parameter:

Default value: `undef`

### <a name="profile_lustre--service"></a>`profile_lustre::service`

Configure the lnet service

#### Examples

##### 

```puppet
include profile_lustre::service
```

#### Parameters

The following parameters are available in the `profile_lustre::service` class:

* [`lnet_service_enabled`](#-profile_lustre--service--lnet_service_enabled)
* [`lnet_service_name`](#-profile_lustre--service--lnet_service_name)
* [`lnet_service_running`](#-profile_lustre--service--lnet_service_running)

##### <a name="-profile_lustre--service--lnet_service_enabled"></a>`lnet_service_enabled`

Data type: `Boolean`

Boolean to determine if the lnet service is enabled

##### <a name="-profile_lustre--service--lnet_service_name"></a>`lnet_service_name`

Data type: `String`

String of the name of the lnet service

##### <a name="-profile_lustre--service--lnet_service_running"></a>`lnet_service_running`

Data type: `Boolean`

Boolean to determine if the lnet service is ensured running

### <a name="profile_lustre--telegraf--lnet_router_stats"></a>`profile_lustre::telegraf::lnet_router_stats`

Telegraf LNET router stats

#### Examples

##### 

```puppet
include profile_lustre::telegraf::lnet_router_stats
```

#### Parameters

The following parameters are available in the `profile_lustre::telegraf::lnet_router_stats` class:

* [`enabled`](#-profile_lustre--telegraf--lnet_router_stats--enabled)
* [`script_cfg`](#-profile_lustre--telegraf--lnet_router_stats--script_cfg)
* [`sudo_cfg`](#-profile_lustre--telegraf--lnet_router_stats--sudo_cfg)
* [`telegraf_cfg`](#-profile_lustre--telegraf--lnet_router_stats--telegraf_cfg)

##### <a name="-profile_lustre--telegraf--lnet_router_stats--enabled"></a>`enabled`

Data type: `Boolean`

Enable or disable this health check

##### <a name="-profile_lustre--telegraf--lnet_router_stats--script_cfg"></a>`script_cfg`

Data type: `Hash`

Hash that controls the values for the script config file. See data/common.yaml for examples

##### <a name="-profile_lustre--telegraf--lnet_router_stats--sudo_cfg"></a>`sudo_cfg`

Data type: `String`

String setting sudo config for this lustre check

##### <a name="-profile_lustre--telegraf--lnet_router_stats--telegraf_cfg"></a>`telegraf_cfg`

Data type: `Hash`

Hash of key:value pairs passed to telegraf::input as options

### <a name="profile_lustre--telegraf--lustre_client_health"></a>`profile_lustre::telegraf::lustre_client_health`

Telegraf Lustre client health checks

#### Examples

##### 

```puppet
include profile_lustre::telegraf::lustre_client_health
```

#### Parameters

The following parameters are available in the `profile_lustre::telegraf::lustre_client_health` class:

* [`enabled`](#-profile_lustre--telegraf--lustre_client_health--enabled)
* [`script_cfg`](#-profile_lustre--telegraf--lustre_client_health--script_cfg)
* [`telegraf_cfg`](#-profile_lustre--telegraf--lustre_client_health--telegraf_cfg)
* [`telegraf_lustre_client_check`](#-profile_lustre--telegraf--lustre_client_health--telegraf_lustre_client_check)
* [`sudo_cfg`](#-profile_lustre--telegraf--lustre_client_health--sudo_cfg)

##### <a name="-profile_lustre--telegraf--lustre_client_health--enabled"></a>`enabled`

Data type: `Boolean`

Enable or disable this health check

##### <a name="-profile_lustre--telegraf--lustre_client_health--script_cfg"></a>`script_cfg`

Data type: `Hash`

Hash that controls the values for the script config file. See data/common.yaml for examples

##### <a name="-profile_lustre--telegraf--lustre_client_health--telegraf_cfg"></a>`telegraf_cfg`

Data type: `Hash`

Hash of key:value pairs passed to telegraf::input as options

##### <a name="-profile_lustre--telegraf--lustre_client_health--telegraf_lustre_client_check"></a>`telegraf_lustre_client_check`

Ensure that a sudoers entry is created for telegraf to run lctl

##### <a name="-profile_lustre--telegraf--lustre_client_health--sudo_cfg"></a>`sudo_cfg`

Data type: `String`



## Defined types

### <a name="profile_lustre--bindmount_resource"></a>`profile_lustre::bindmount_resource`

Assumes that we are bindmounting from a mount or sub-directory of
a mount.

#### Examples

##### 

```puppet
profile_lustre::bindmount_resource { '/scratch':
  #opts           => "defaults,bind,noauto,nosuid,nodev,ro"
  src_mountpoint => "/mnt/mount",
  src_path       => "/mnt/mount/scratch",
}
```

#### Parameters

The following parameters are available in the `profile_lustre::bindmount_resource` defined type:

* [`opts`](#-profile_lustre--bindmount_resource--opts)
* [`src_mountpoint`](#-profile_lustre--bindmount_resource--src_mountpoint)
* [`src_path`](#-profile_lustre--bindmount_resource--src_path)

##### <a name="-profile_lustre--bindmount_resource--opts"></a>`opts`

Data type: `Optional[String]`

Mount options. MUST include 'bind'. (Optional.)

Default value: `'defaults,bind,noauto,nodev,nosuid'`

##### <a name="-profile_lustre--bindmount_resource--src_mountpoint"></a>`src_mountpoint`

Data type: `String`

The mount point of the source we are bindmounting from.

##### <a name="-profile_lustre--bindmount_resource--src_path"></a>`src_path`

Data type: `String`

The location we are bindmounting from (either same as
src_mountpoint or a sub-directory).

### <a name="profile_lustre--nativemount_resource"></a>`profile_lustre::nativemount_resource`

Mount Lustre filesystem on a directory

#### Examples

##### 

```puppet
profile_lustre::nativemount_resource { '/mnt/mount':
  src => 'lustre-server1.local@o2ib,lustre-server2.local@o2ib:/filesystem',
  #opts => 'defaults,nosuid,ro'  ## ??
}
```

#### Parameters

The following parameters are available in the `profile_lustre::nativemount_resource` defined type:

* [`opts`](#-profile_lustre--nativemount_resource--opts)
* [`src`](#-profile_lustre--nativemount_resource--src)

##### <a name="-profile_lustre--nativemount_resource--opts"></a>`opts`

Data type: `Optional[String]`

(Optional) mount options.

Default value: `'defaults,nodev,nosuid'`

##### <a name="-profile_lustre--nativemount_resource--src"></a>`src`

Data type: `String`

Lustre source for the mount (includes hostnames/IPs of Lustre servers
along with source filesystem/path.

