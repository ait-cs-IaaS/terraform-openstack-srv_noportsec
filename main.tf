# terraform {
#   backend "consul" {}
# }

locals {
  # UUID regex used to check if lookup dependencies by name or already have the id
  is_uuid = "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}"
}

data "openstack_networking_network_v2" "network" {
  count = can(regex(local.is_uuid, var.network)) ? 0 : 1
  name = var.network
}

data "openstack_networking_subnet_v2" "subnet" {
  count = can(regex(local.is_uuid, var.subnet)) ? 0 : 1
  name = var.subnet
}

data "openstack_networking_network_v2" "additional_networks" {
  for_each = {for name, config in var.additional_networks : name => config if !can(regex(local.is_uuid, config.network))}
  name = each.value.network
}

data "openstack_networking_subnet_v2" "additional_subnets" {
  for_each = {for name, config in var.additional_networks : name => config if !can(regex(local.is_uuid, config.subnet))}
  name = each.value.subnet
}

data "openstack_images_image_v2" "image" {
  count = can(regex(local.is_uuid, var.image)) ? 0 : 1
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
    uuid                  = can(regex(local.is_uuid, var.image)) ? var.image : data.openstack_images_image_v2.image[0].id
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

  network_id = can(regex(local.is_uuid, var.network)) ? var.network : data.openstack_networking_network_v2.network[0].id

  fixed_ip {
      subnet_id = can(regex(local.is_uuid, var.subnet)) ? var.subnet : data.openstack_networking_subnet_v2.subnet[0].id 
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

  network_id = can(regex(local.is_uuid, each.value.network )) ? each.value.network : data.openstack_networking_network_v2.additional_networks[each.key].id

  fixed_ip {
      subnet_id = can(regex(local.is_uuid, each.value.subnet )) ? each.value.subnet : data.openstack_networking_subnet_v2.additional_subnets[each.key].id
      ip_address = each.value.ip_address
  }
}

# attach the instance to its additional networks
resource "openstack_compute_interface_attach_v2" "additional_port" {
   for_each = var.additional_networks
   instance_id = openstack_compute_instance_v2.server.id
   port_id = openstack_networking_port_v2.additional_port[each.key].id
}
