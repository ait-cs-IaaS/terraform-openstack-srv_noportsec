# Terraform: openstack-srv_noportsec

Creates a virtual machine without portsec enabled. If you need a need a counter, please use "openstack-srv_noportsec-count" instead.

This module allows you to input image, network and subnet (including as part of the additional_networks map) configurations
either as name or UUIDs. UUIDs will be used directly as input for the underlying resources and names will first be resolved to UUIDs
using data sources. UUIDs are identified using a regular expression meaning that names which are UUID strings will not be recognized as names. This feature can be disabled using by setting the following boolean flags to `false`:

 - `allow_network_uuid`
 - `allow_subnet_uuid`
 - `allow_image_uuid`

Once disabled all input for the input type (e.g., network) will be considered to be names regardless of the UUID regular expression.

# Configuration 

## Simple Instance
```
module "datenverarbeitung" {
	source = "git@git-service.ait.ac.at:sct-cyberrange/terraform-modules/openstack-srv_noportsec.git"
	hostname = "datenverarbeitung"
	tag = "sec_net"
	ip_address = "192.168.33.9"
	image = var.image
	flavor = var.flavor
	sshkey = var.sshkey
	network = var.network
	subnet = var.subnet
	userdatafile = "${path.module}/scripts/default.yml"
}

```

## Dual-Homed Instance Instance
```
module "datenverarbeitung" {
	source = "git@git-service.ait.ac.at:sct-cyberrange/terraform-modules/openstack-srv_noportsec.git"
	hostname = "datenverarbeitung"
	tag = "sec_net"
	image = var.image
	flavor = var.flavor
	sshkey = var.sshkey
	network = var.network
	subnet = var.subnet
	ip_address = var.ip_address
	userdatafile = "${path.module}/scripts/default.yml"
	additional_networks = {
		second_network = {
			network = var.network_2
			subnet = var.subnet_2
			ip_address = var.ip_address2
		}
	}
}
```

## Use network and subnet IDs to configure instance

```
module "example" {
	source = "git@git-service.ait.ac.at:sct-cyberrange/terraform-modules/openstack-srv_noportsec.git"
	hostname = "example"
	ip_address = null
	image = var.image
	flavor = var.flavor
	sshkey = var.sshkey
	network = "62e04be3-641f-4abe-88d6-87f397a31d7e"
	subnet = "a4c9f461-7c1e-4666-8d0f-4f0ae6404483"
	userdatafile = "${path.module}/scripts/default.yml"
	additional_networks = {
		id_input = {
			network = "62e04be3-641f-4abe-88d6-87f397a31d7e"
			subnet = "a4c9f461-7c1e-4666-8d0f-4f0ae6404483"
			ip_address = null
		}

		name_input = {
			network = "cyberrange-public"
			subnet = "cyberrange-public-4"
			ip_address = null
		}
	}
}
```

