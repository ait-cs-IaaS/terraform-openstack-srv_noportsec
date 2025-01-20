# Create port in the parent network
resource "openstack_networking_port_v2" "port" {
  name                  = "port_${var.name}"
  network_id            = var.network_id
  admin_state_up        = true  # default?
  port_security_enabled = false # default?
  dynamic "fixed_ip" {
    for_each = var.assign_fixed_ip ? [1] : []
    content = {
      subnet_id  = var.subnet_id
      ip_address = cidrhost(var.cidr, var.host_index)
    }
  }
}

# Create ports in child network(s)
resource "openstack_networking_port_v2" "ports" {
  for_each              = var.additional_networks
  name                  = "port_${var.name}"
  network_id            = each.value.network_id
  admin_state_up        = true  # default?
  port_security_enabled = false # default?
  dynamic "fixed_ip" {
    iterator = "fixed_ip_each"
    for_each = each.value.assign_fixed_ip == null || each.value.assign_fixed_ip ? [1] : []
    content = {
      subnet_id = each.value.subnet_id
      # if host_index is set within the addional_networks object, then use it (each.value.host_index). otherwise use the parent host index (var.host_index)
      # #coalesce: returns first value, that is not null or "" --> https://developer.hashicorp.com/terraform/language/functions/coalesce
      ip_address = cidrhost(each.value.cidr, coalesce(each.value.host_index, var.host_index))
    }
  }
}

# Create instance and assign it to the created ports
resource "openstack_compute_instance_v2" "server" {
  name            = var.name
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = "cyberrange-key" # it should always be the same (I think there is no need to make that dynamic - 10/04/2024)
  security_groups = []
  user_data       = var.userdata == null ? file("${path.module}/scripts/default.yml") : var.userdata # if no userdata is passed, use the default-file, otherwise use the passed userdata
  metadata        = local.metadata

  # Assign instance to parent network port
  network { port = openstack_networking_port_v2.port.id }

  # Assign instance to all child network ports
  dynamic "network" {
    for_each = openstack_networking_port_v2.ports
    content {
      port = network.value.id
    }
  }
}

# Create Floating IP (if var.floating_ip is true)
resource "openstack_networking_floatingip_v2" "fip" {
  count = var.floating_ip ? 1 : 0
  pool  = var.fip_pool #"provider-cyberrange-207" # default?
}

# Associate Floating IP to parent network port (if var.floating_ip is true)
resource "openstack_networking_floatingip_associate_v2" "fip" {
  count       = var.floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  port_id     = openstack_networking_port_v2.port.id
}
