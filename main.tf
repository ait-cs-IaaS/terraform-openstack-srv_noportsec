# terraform {
#   backend "consul" {}
# }

locals {
  # UUID regex used to check if lookup dependencies by name or already have the id
  is_uuid = "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}"
}

data "openstack_networking_network_v2" "network" {
  count = can(regex(local.is_uuid, var.network)) && var.allow_network_uuid ? 0 : 1
  name = var.network
}

data "openstack_networking_subnet_v2" "subnet" {
  # if subnet is given
  # we need to load subnet info if we need it to calculate instance instance fixed IP addresses (i.e., var.host_address_index != null)
  # or if we where given a name (i.e., var.subnet is not a regex)
  count = var.subnet == null || (var.host_address_index == null && can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid) ? 0 : 1
  name = can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid ? null : var.subnet
  subnet_id = can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid ? var.subnet : null
}

data "openstack_networking_network_v2" "additional_networks" {
  for_each = {for name, config in var.additional_networks : name => config if !can(regex(local.is_uuid, config.network)) || !var.allow_network_uuid}
  name = each.value.network
}

data "openstack_networking_subnet_v2" "additional_subnets" {
  # if subnet is given
  # we need to load subnet info if we need it to calculate instance instance fixed IP addresses (i.e., var.host_address_index != null)
  # or if we where given a name (i.e., var.subnet is not a regex)
  for_each = {for name, config in var.additional_networks : name => config if config.subnet != null && (config.host_address_index != null || !can(regex(local.is_uuid, config.subnet)) || !var.allow_subnet_uuid)}
  name = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? null : each.value.subnet
  subnet_id = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? each.value.subnet : null
}


data "openstack_images_image_v2" "image" {
  count = can(regex(local.is_uuid, var.image)) && var.allow_image_uuid ? 0 : 1
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
    uuid                  = can(regex(local.is_uuid, var.image)) && var.allow_image_uuid ? var.image : data.openstack_images_image_v2.image[0].id
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

  network_id = can(regex(local.is_uuid, var.network)) && var.allow_network_uuid ? var.network : data.openstack_networking_network_v2.network[0].id

  dynamic "fixed_ip" {
      # if var.subnet == null the fixed_ip block will be ommited due to the empty map
      for_each = var.subnet != null ? { srvport = "placeholder"} : {}
      content {
        subnet_id = can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid ? var.subnet : data.openstack_networking_subnet_v2.subnet[0].id
        ip_address = var.host_address_index != null ? cidrhost(data.openstack_networking_subnet_v2.subnet[0].cidr, var.host_address_index) : null
      }
  }

}
# create the ports for additional networks
resource "openstack_networking_port_v2" "additional_port" {
  for_each = var.additional_networks
  name           = "${var.hostname}_${each.key}_net-port"
  admin_state_up = "true"
  no_security_groups = true
  port_security_enabled = false

  network_id = can(regex(local.is_uuid, each.value.network )) && var.allow_network_uuid ? each.value.network : data.openstack_networking_network_v2.additional_networks[each.key].id

  dynamic "fixed_ip" {
      # if each.value.subnet == null the fixed_ip block will be ommited due to the empty map
      for_each = each.value.subnet != null ? { "fixed_ip_block_${each.key}" = "placeholder "} : {}
      content {
        subnet_id = can(regex(local.is_uuid, each.value.subnet )) && var.allow_subnet_uuid ? each.value.subnet : data.openstack_networking_subnet_v2.additional_subnets[each.key].id
        ip_address = each.value.host_address_index != null ? cidrhost(data.openstack_networking_subnet_v2.additional_subnets[each.key].cidr, each.value.host_address_index) : null
      }
  }
}

# attach the instance to its additional networks
resource "openstack_compute_interface_attach_v2" "additional_port" {
   for_each = var.additional_networks
   instance_id = openstack_compute_instance_v2.server.id
   port_id = openstack_networking_port_v2.additional_port[each.key].id
}
