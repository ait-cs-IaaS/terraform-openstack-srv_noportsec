# Terraform: terraform-openstack-srv_noportsec

## TODO: CHECK THE FOLLOWING DESCRIPTION

Creates a virtual machine without portsec enabled. If you need a need a counter, please use "[terraform-openstack-srv_noportsec-count](https://github.com/ait-cs-IaaS/terraform-openstack-srv_noportsec-count)" instead.

This module allows you to input image, network and subnet (including as part of the networks and additional_networks maps) configurations
either as name or UUIDs. UUIDs will be used directly as input for the underlying resources and names will first be resolved to UUIDs
using data sources. UUIDs are identified using a regular expression meaning that names which are UUID strings will not be recognized as names. This feature can be disabled using by setting the following boolean flags to `false`:

- `allow_network_uuid`
- `allow_subnet_uuid`
- `allow_image_uuid`

Once disabled all input for the input type (e.g., network) will be considered to be names regardless of the UUID regular expression.

Networks configured via the `networks` input are considered as inherent parts of the created server instances.
Thus any configuration changes resulting in the removal or addition of new ports (created from `networks`) will also
force the recreation of the server instance. In contrast networks configured via `additional_networks` are attached
to server instances after they have been created. The relationship between the two is thus weaker, meaning removal and
addition of new `additional_networks` do not result in the recreation of the server instance. They just attach or detach
the created network ports. Note that this also means networks configured through the `additional_networks` input cannot
be guaranteed to be available during the instance boot (i.e., cloud-init). Thus brining the resulting network interfaces
online in the operating system layer and configuring them must be handled separately from the terraform provisioning.

**Note that for the image input it is not possible to use outputs from resources to assign a value to the input (e.g., using an image resources and then referencing the resulting id). Doing so will result in an error and planning/applying will only be possible after the referenced resource has been deployed using the terraform `-target`
option.**

## Configuration

### TODO: ADD NEW CONFIGURATION EXAMPLES

### Simple Instance with fixed ip

```terraform
module "datenverarbeitung" {
  source = "git@github.com:ait-cs-IaaS/terraform-openstack-srv_noportsec.git"
  hostname = "datenverarbeitung"
  tag = "sec_net"
  host_address_index = 150
  image = var.image
  flavor = var.flavor
  config_drive = var.config_drive
  sshkey = var.sshkey
  network = var.network
  subnet = var.subnet
  userdatafile = "${path.module}/scripts/default.yml"
}

```

### Dual-Homed Instance Instance with DHCP on all networks

```terraform
module "datenverarbeitung" {
  source = "git@github.com:ait-cs-IaaS/terraform-openstack-srv_noportsec.git"
  hostname = "datenverarbeitung"
  tag = "sec_net"
  image = var.image
  flavor = var.flavor
  config_drive = var.config_drive
  sshkey = var.sshkey
  network = var.network
  subnet = var.subnet
  assign_fixed_ip = false
  host_address_index = var.host_address_index
  userdatafile = "${path.module}/scripts/default.yml"
  networks = {
    second_network = {
      network = var.network_2
      subnet = var.subnet_2
      host_address_index = var.host_address_index2
      assign_fixed_ip = false
      access = null
    }
  }
}
```