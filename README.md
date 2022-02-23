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

## Dependencies

n/a


## Reference

See: [REFERENCE.md](REFERENCE.md)
