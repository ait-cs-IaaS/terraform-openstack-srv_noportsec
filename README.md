# Terraform: openstack-srv_noportsec

Creates a virtual machine without portsec enabled. If you need a need a counter, please use "openstack-srv_noportsec-count" instead

# Configuration 

```
module "datenverarbeitung" {
	source = "git@git-service.ait.ac.at:sct-cyberrange/terraform-modules/openstack-srv_noportsec.git"
	hostname = "datenverarbeitung"
	tag = "sec-net"
	ip_address = "192.168.33.9"
        image_id = "${var.image_id}"
        flavor = "${var.flavor}"
        sshkey = "${var.sshkey}"
        lannet_id = "${var.lannet_id}"
	lansubnet_id = "${var.lansubnet_id}"
	userdatafile = "${path.module}/scripts/default.yml"
}

```
