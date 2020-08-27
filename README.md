# Terraform: openstack-srv_noportsec

Creates a virtual machine without portsec enabled. If you need a need a counter, please use "openstack-srv_noportsec-count" instead

# Configuration 

## Simple Instance
```
module "datenverarbeitung" {
	source = "git@git-service.ait.ac.at:sct-cyberrange/terraform-modules/openstack-srv_noportsec.git"
	hostname = "datenverarbeitung"
	tag = "sec_net"
	ip_address = "192.168.33.9"
	image_id = var.image_id
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
	ip_address = var.ip_address
	image_id = var.image_id
	flavor = var.flavor
	sshkey = var.sshkey
	network = var.network
	subnet = var.subnet
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

