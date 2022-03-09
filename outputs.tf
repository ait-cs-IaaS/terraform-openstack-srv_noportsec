output "server" {
  value     = openstack_compute_instance_v2.server
  sensitive = true
}

output "networks" {
  value = {
    for name, port in openstack_networking_port_v2.ports :
    name => port
  }
}

output "additional_networks" {
  value = {
    for name, port in openstack_networking_port_v2.additional_port :
    name => port
  }
}
