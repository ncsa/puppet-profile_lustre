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
    interface: "eth1"
  o2ib1:
    interface: "ib0"
profile_lustre::module::remote_networks:
  o2ib0:
    router_IPs: "172.28.16.[30-31]"
    router_net: "tcp0"

profile_lustre::nativemounts::map:
  /mnt/mount:
    src: "lustre-server1.local@o2ib,lustre-server2.local@o2ib:/filesystem"
    opts: "defaults,nodev,nosuid"
```

To include bindmounts you would include parameters like this:

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

Recommendations and/or defaults TBD.

### Telegraf Monitoring

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

## Reference

See: [REFERENCE.md](REFERENCE.md)
