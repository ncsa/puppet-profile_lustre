# profile_lustre

![pdk-validate](https://github.com/ncsa/puppet-profile_lustre/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_lustre/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - install and configure Lustre for LNet router or client


## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This puppet profile customizes a host to install and configure Lustre for an LNet router or client.


## Setup

Include profile_lustre in a puppet profile file:
```
include ::profile_lustre::client
```
or:
```
include ::profile_lustre::lnet_router
```


## Usage

### Recent changes

:warning: WARNING: v3.0.0 of this module introduces changes to names and structuring of some parameters:
- changed:
  - `profile_lustre::module::local_networks`
  - `profile_lustre::module::routes` (fka 'remote_networks')
- added:
  - `profile_lustre::module::global_lnet_configs`
  - `profile_lustre::module::router_buffers`

Please see the following for more information:
- example below
- code or [REFERENCE.md](REFERENCE.md)

:warning: WARNING: This module has a safeguard against accidentally reconfiguring LNet on a system that
is in production. See [Reconfiguring LNet](#reconfiguring-lnet) for more information.

### LNet parameters and configuration methods

LNet configuration is applied by the `puppet_lustre::module` class. This class primarily relies on
[Dynamic LNet Configuration](https://wiki.lustre.org/Dynamic_LNet_Configuration_and_lnetctl),
using `lnetctl` to import from a YAML-formatted lnet.conf file. Where necessary, it also uses
[Static LNet Configuration](https://wiki.lustre.org/Static_LNet_Configuration), in particular for driver-level
configurations, which are placed in a lustre.conf file and processed earlier, when the lnet kernel module is loaded.

To get an idea of the configuration options possible via lnet.conf, you can run the following on a node that is
already configured (or see such example output in Lustre docs):
```bash
lnetctl export --backup
```
The sections of the lnet.conf file are populated according to the following parameters:
|lnet.conf section|profile_lustre::module parameter(s)|
|---|---|
|net|local_networks|
|route|routes|
|routing|is_lnet_router|
|buffers|router_buffers|
|peer|N/A|
|global|global_lnet_configs|

Configuration via lustre.conf are limited to driver-level configuration, e.g.:
```
options ko2iblnd ...
options ksocklnd ...
```
(See `profile_lustre::module::driver_config*` parameters.)

### Typical usage

The following parameters likely need to be set for any deployment:

```yaml
profile_lustre::firewall::sources:
  - "lustre-server1.local"
  - "lustre-server2.local"

profile_lustre::install::yumrepo:
  lustre:
    baseurl: "https://downloads.whamcloud.com/public/lustre/latest-release/el$releasever/client"
    descr: "lustre-client Repository el $releasever - Whamcloud"
    enabled: 1
    #gpgcheck: 1
    #gpgkey: "https://..."

# example only:
profile_lustre::module::local_networks:
  tcp0:
    ## fka (String) "interface"
    interfaces:  ## now an Array
      - "eth1"
  o2ib1:
    interfaces:
      - "ib0"
profile_lustre::module::routes:  ## fka "remote_networks"
  o2ib:
    ## fka "router_IPs"
    router_ips:  ## ranges like *.[30-31] no longer permitted; list each IP as an Array member
      - "172.28.16.30"
      - "172.28.16.31"
    router_net: "tcp0"

profile_lustre::nativemounts::map:
  /mnt/mount1:
    # mounting Lustre from 2 single-rail servers; single-rail servers are
    # typical for smaller, cluster-local Lustre deployments; separate
    # single-rail servers using ':'
    src: "lustre-server1.local@o2ib1:lustre-server2.local@o2ib1:/filesystem"
    opts: "defaults,nodev,nosuid"
  /mnt/mount2:
    # mounting Lustre from 2 dual-rail servers; dual-rail servers are
    # more typical for larger Lustre deployments (e.g., center-wide shared
    # filesystems); separate each server using ':' and both NIDs (IP@net)
    # for each server using ','
    src: "lustre-server-a1.local@o2ib,lustre-server-a2.local@o2ib:lustre-server-b1.local@o2ib,lustre-server-b2.local@o2ib:/filesystem"
    opts: "defaults,nodev,nosuid"
```

Bindmounts are discouraged; use (sub-directory) native mounts instead.

However, to include bindmounts you would include parameters like this:

```
profile_lustre::bindmounts::map:
  /scratch:
    opts: "defaults,nodev,nosuid"
    src_mountpoint: "/mnt/mount"
    src_path: "/mnt/mount/scratch"
...
```

Tunings can be applied like this:

```
profile_lustre::tuning::params:
  "osc.*.max_pages_per_rpc": "4096"
  "osc.*.max_rpcs_in_flight": "16"
  "osc.*.max_dirty_mb": "512"
  "osc.*.checksums": "0"
...
```

### Reconfiguring LNet

This profile includes a safeguard against accidently trying to reconfigure LNet in a production setting. There is
a "trigger" file, `/etc/lnet.trigger` by default, that is created when Puppet configures LNet for the first
time. Once it is present, Puppet will NOT try to reconfigure LNet even if changes are made to lnet.conf or
lustre.conf.

Additionally LNet should not be reconfigured when Lustre is mounted.

In order to reconfigure LNet, an admin do something like:
- take the node out of service
- stop the Puppet service (`systemctl stop puppet`)
- unmount Lustre (`umount -a -t lustre`)
- unload Lustre kernel modules (`lustre_rmmod`)
- remove the trigger file (`rm -f /etc/lnet.trigger`)
- make sure the node is on the correct branch
- apply changes using Puppet (`puppet agent -t`)
- restart the Puppet service, if necessary (`systemctl start puppet`)

Alternatively, a stateless node can just be rebooted and then Puppet can apply an updated config on boot.

### Telegraf Monitoring

#### Lustre Router Stats
Can use telegraf to monitor lustre router stats

To enable/disable set:
```yaml
profile_lustre::telegraf::lnet_router_stats::enabled: true
```

Some configuration must be done for telegraf monitoring to work. This configuration is handled with the `profile_lustre::telegraf::lnet_router_stats::script_cfg` hash

Example:
```
#For a lustre CLIENT system with these mounts
[root@hli-cn09 ~]# findmnt -t lustre
TARGET    SOURCE
/storage  192.168.1.2@o2ib,192.168.1.3@o2ib:192.168.1.4@o2ib,192.168.1.5@o2ib:192.168.1.6@o2ib,192.168.1.7@o2ib:192.168.1.8@o2ib,192.168.1.9@o2ib:/storage
/projects 192.168.1.2@o2ib,192.168.1.3@o2ib:192.168.1.4@o2ib,192.168.1.5@o2ib:192.168.1.6@o2ib,192.168.1.7@o2ib:192.168.1.8@o2ib,192.168.1.9@o2ib:/storage[/nsf/prg]
```

You can use a config like this:

```yaml
profile_lustre::telegraf::lnet_router_stats::script_cfg:
  # Array of Lustre filesystem(s)
  fs:
    - "storage"
```

#### Lustre Client Health
Can use telegraf to monitor lustre client health

To enable/disable set:
```yaml
profile_lustre::telegraf::lustre_client_health::enabled: true
```

Some configuration must be done for telegraf monitoring to work. This configuration is handled with the `profile_lustre::telegraf::lustre_client_health::script_cfg` hash

Example:
```
#For a system with these mounts
[root@login03]# findmnt -t lustre
TARGET         SOURCE
/prg/home      192.168.0.10@tcp,192.168.0.11@tcp:/prghom0
/u             192.168.0.10@tcp,192.168.0.11@tcp:/prghom0[/u]
/sw            192.168.0.10@tcp,192.168.0.11@tcp:/prghom0[/sw]
/prg/scratch   192.168.0.20@tcp,192.168.0.21@tcp:/prgscr0
/scratch       192.168.0.20@tcp,192.168.0.21@tcp:/prgscr0
/storage       192.168.1.2@o2ib,192.168.1.3@o2ib:192.168.1.4@o2ib,192.168.1.5@o2ib:192.168.1.6@o2ib,192.168.1.7@o2ib:192.168.1.8@o2ib,192.168.1.9@o2ib:/storage
/projects      192.168.1.2@o2ib,192.168.1.3@o2ib:192.168.1.4@o2ib,192.168.1.5@o2ib:192.168.1.6@o2ib,192.168.1.7@o2ib:192.168.1.8@o2ib,192.168.1.9@o2ib:/storage[/nsf/prg]

```

You can use a config like this:

```yaml
profile_lustre::telegraf::lustre_client_health::script_cfg:
  # Array of Mount Paths
  fs:
    - "/prg/home"
    - "/u"
    - "/sw"
    - "/prg/scratch"
    - "/scratch"
    - "/storage"
    - "/projects"
  # Array of paths to run ls check on
  paths:
    - "/prg/home"
    - "/u"
    - "/sw"
    - "/prg/scratch"
    - "/scratch"
    - "/storage"
    - "/projects"
  # Array of files to check stat
  files:
    - "/prg/home/.SETcheck"
    - "/u/.SETcheck"
    - "/sw/.SETcheck"
    - "/prg/scratch/.SETcheck"
    - "/scratch/.SETcheck"
    - "/storage/.SETcheck"
    - "/projects/.SETcheck"
  # Array of IP/Protocol String for the first server of each FS to check presence of mgs
  mgs:
    - "192.168.0.10@tcp"
    - "192.168.0.20@tcp"
    - "192.168.1.2@o2ib"
```

## Dependencies

* https://github.com/ncsa/puppet-telegraf
* https://github.com/ncsa/puppet-profile_monitoring
* https://forge.puppet.com/modules/saz/sudo

## Reference

See: [REFERENCE.md](REFERENCE.md)
