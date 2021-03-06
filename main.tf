locals {
  # UUID regex used to check if lookup dependencies by name or already have the id
  is_uuid = "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}"
}

data "openstack_networking_network_v2" "network" {
  # load by ID if we got a UUID and by name if not
  name       = can(regex(local.is_uuid, var.network)) && var.allow_network_uuid ? null : var.network
  network_id = can(regex(local.is_uuid, var.network)) && var.allow_network_uuid ? var.network : null
}

data "openstack_networking_subnet_v2" "subnet" {
  # load by ID if we got a UUID and by name if not
  name      = can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid ? null : var.subnet
  subnet_id = can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid ? var.subnet : null
}

data "openstack_networking_network_v2" "networks" {
  for_each   = var.networks
  name       = can(regex(local.is_uuid, each.value.network)) && var.allow_network_uuid ? null : each.value.network
  network_id = can(regex(local.is_uuid, each.value.network)) && var.allow_network_uuid ? each.value.network : null
}

data "openstack_networking_subnet_v2" "subnets" {
  for_each  = var.networks
  name      = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? null : each.value.subnet
  subnet_id = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? each.value.subnet : null
}

data "openstack_networking_network_v2" "additional_networks" {
  for_each   = var.additional_networks
  name       = can(regex(local.is_uuid, each.value.network)) && var.allow_network_uuid ? null : each.value.network
  network_id = can(regex(local.is_uuid, each.value.network)) && var.allow_network_uuid ? each.value.network : null
}

data "openstack_networking_subnet_v2" "additional_subnets" {
  for_each  = var.additional_networks
  name      = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? null : each.value.subnet
  subnet_id = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? each.value.subnet : null
}


data "openstack_images_image_v2" "image" {
  # note that this does not work if var.image input is from resource response in the same module
  count       = can(regex(local.is_uuid, var.image)) && var.allow_image_uuid ? 0 : 1
  name        = var.image
  most_recent = true
}

data "template_cloudinit_config" "cloudinit" {
  count         = var.userdatafile == null ? 0 : 1
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile(var.userdatafile, var.userdata_vars)
  }
}


locals {
  groups   = var.tag != null ? { groups = var.tag } : {}
  metadata = var.metadata == null ? {} : var.metadata
}

resource "openstack_compute_instance_v2" "server" {
  name        = var.hostname
  flavor_name = var.flavor
  key_pair    = var.sshkey
  image_id    = can(regex(local.is_uuid, var.image)) && var.allow_image_uuid ? var.image : data.openstack_images_image_v2.image[0].id

  user_data    = var.userdatafile == null ? null : data.template_cloudinit_config.cloudinit[0].rendered
  config_drive = var.config_drive

  metadata        = merge(local.metadata, local.groups)
  security_groups = var.security_groups

  block_device {
    uuid                  = can(regex(local.is_uuid, var.image)) && var.allow_image_uuid ? var.image : data.openstack_images_image_v2.image[0].id
    source_type           = "image"
    volume_size           = var.volume_size
    boot_index            = 0
    destination_type      = var.use_volume ? "volume" : "local"
    delete_on_termination = true
  }

  network {
    port           = length(openstack_networking_port_v2.srvport) > 0 ? openstack_networking_port_v2.srvport[0].id : null
    name           = can(regex(local.is_uuid, var.network)) ? null : (var.extnet ? var.network : null)
    uuid           = can(regex(local.is_uuid, var.network)) ? (var.extnet ? var.network : null) : null
    access_network = length(var.networks) > 0 ? var.network_access : true
    fixed_ip_v4    = var.host_address_index != null && var.extnet ? cidrhost(data.openstack_networking_subnet_v2.subnet.cidr, var.host_address_index) : null
  }

  dynamic "network" {
    for_each = var.networks
    content {
      port           = openstack_networking_port_v2.ports[network.key].id
      access_network = network.value.access
    }
  }
}

resource "openstack_networking_port_v2" "srvport" {
  count                 = var.extnet ? 0 : 1
  name                  = "${var.hostname}-port"
  admin_state_up        = "true"
  no_security_groups    = true
  port_security_enabled = false

  network_id = can(regex(local.is_uuid, var.network)) && var.allow_network_uuid ? var.network : data.openstack_networking_network_v2.network.id

  dynamic "fixed_ip" {
    # if var.subnet == null the fixed_ip block will be ommited due to the empty map
    for_each = var.subnet != null ? { srvport = "placeholder" } : {}
    content {
      subnet_id  = can(regex(local.is_uuid, var.subnet)) && var.allow_subnet_uuid ? var.subnet : data.openstack_networking_subnet_v2.subnet.id
      ip_address = var.host_address_index != null ? cidrhost(data.openstack_networking_subnet_v2.subnet.cidr, var.host_address_index) : null
    }
  }
}

resource "openstack_networking_port_v2" "ports" {
  for_each              = var.networks
  name                  = "${var.hostname}_${each.key}_net-port"
  admin_state_up        = "true"
  no_security_groups    = true
  port_security_enabled = false

  network_id = can(regex(local.is_uuid, each.value.network)) && var.allow_network_uuid ? each.value.network : data.openstack_networking_network_v2.networks[each.key].id

  dynamic "fixed_ip" {
    # if each.value.subnet == null the fixed_ip block will be ommited due to the empty map
    for_each = each.value.subnet != null ? { "fixed_ip_block_${each.key}" = "placeholder" } : {}
    content {
      subnet_id  = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? each.value.subnet : data.openstack_networking_subnet_v2.subnets[each.key].id
      ip_address = each.value.host_address_index != null ? cidrhost(data.openstack_networking_subnet_v2.subnets[each.key].cidr, each.value.host_address_index) : null
    }
  }
}

# create the ports for additional networks
resource "openstack_networking_port_v2" "additional_port" {
  for_each              = var.additional_networks
  name                  = "${var.hostname}_${each.key}_net-port"
  admin_state_up        = "true"
  no_security_groups    = true
  port_security_enabled = false

  network_id = can(regex(local.is_uuid, each.value.network)) && var.allow_network_uuid ? each.value.network : data.openstack_networking_network_v2.additional_networks[each.key].id

  dynamic "fixed_ip" {
    # if each.value.subnet == null the fixed_ip block will be ommited due to the empty map
    for_each = each.value.subnet != null ? { "fixed_ip_block_${each.key}" = "placeholder " } : {}
    content {
      subnet_id  = can(regex(local.is_uuid, each.value.subnet)) && var.allow_subnet_uuid ? each.value.subnet : data.openstack_networking_subnet_v2.additional_subnets[each.key].id
      ip_address = each.value.host_address_index != null ? cidrhost(data.openstack_networking_subnet_v2.additional_subnets[each.key].cidr, each.value.host_address_index) : null
    }
  }
}

# attach the instance to its additional networks
resource "openstack_compute_interface_attach_v2" "additional_port" {
  for_each    = var.additional_networks
  instance_id = openstack_compute_instance_v2.server.id
  port_id     = openstack_networking_port_v2.additional_port[each.key].id
}
