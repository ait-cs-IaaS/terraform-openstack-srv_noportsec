provider "openstack" {
}

terraform {
  backend "consul" {}
}

data "openstack_networking_network_v2" "network" {
  name = var.network
}

data "openstack_networking_subnet_v2" "subnet" {
  name = var.subnet
}

data "openstack_networking_network_v2" "additional_networks" {
  for_each = var.additional_networks
  name = each.value.network
}

data "openstack_networking_subnet_v2" "additional_subnets" {
  for_each = var.additional_networks
  name = each.value.subnet
}

data "openstack_images_image_v2" "image" {
  name        = var.image
  most_recent = true
}

data "template_file" "user_data" {
  template = file(var.userdatafile)
  vars = var.userdata_vars
}

data "template_cloudinit_config" "cloudinit" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}

resource "openstack_compute_instance_v2" "server" {
  name               = var.hostname
  flavor_name        = var.flavor
  key_pair           = var.sshkey

  user_data = data.template_cloudinit_config.cloudinit.rendered

  metadata = {
    groups = var.tag
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    source_type           = "image"
    volume_size           = var.volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
     port = openstack_networking_port_v2.srvport.id
  }
}

resource "openstack_networking_port_v2" "srvport" {
  name           = "${var.hostname}-port"
  admin_state_up = "true"
  no_security_groups = true
  port_security_enabled = false

  network_id = data.openstack_networking_network_v2.network.id

  fixed_ip {
      subnet_id = data.openstack_networking_subnet_v2.subnet.id
      ip_address = var.ip_address
  }

}
# create the ports for additional networks
resource "openstack_networking_port_v2" "additional_port" {
  for_each = var.additional_networks
  name           = "${var.hostname}_${each.key}_net-port"
  admin_state_up = "true"
  no_security_groups = true
  port_security_enabled = false

  network_id = data.openstack_networking_network_v2.additional_networks[each.key].id

  fixed_ip {
      subnet_id = data.openstack_networking_subnet_v2.additional_subnets[each.key].id
      ip_address = each.value.ip_address
  }
}

# attach the instance to its additional networks
resource "openstack_compute_interface_attach_v2" "additional_port" {
   for_each = var.additional_networks
   instance_id = openstack_compute_instance_v2.server.id
   port_id = openstack_networking_port_v2.additional_port[each.key].id
}
