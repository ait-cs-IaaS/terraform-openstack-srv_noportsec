output "server" {
  value = openstack_compute_instance_v2.server
}

output "additional_networks" {
  value = {
    for name, port in openstack_networking_port_v2.additional_port :
    name => port
  }
}