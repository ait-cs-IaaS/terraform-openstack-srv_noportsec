variable "image" {
	type = string
	description = "name or id of the image to boot the hosts from"
}

variable "flavor" {
	type = string
	description = "instance flavor for the server"
	default = "m1.small"
}

variable "volume_size" {
	type = string
	description = "volume_size"
	default = 5
}

variable "sshkey" {
	type = string
        description = "ssh key for the server"
	default = "cyberrange-key"
}

variable "tag" {
	type = string
	description = "group tag"
	default = null
}

variable "hostname" {
	type = string
	description = "hostname"
}

variable "network" {
	type = string
	description = "Name or id of the main network"
}

variable "subnet" {
	type = string
	description = "Name or id of the local sub-net"
	default = null
}

variable "host_address_index" {
	type = number
	description = "The host address index within the subnet the instances IP address will be assigned from"
	default = null
}

# the attributes in the additional_networks map behave the same as their default network counter parts 
# (e.g., network can be either the name or id)
variable "additional_networks" { 
  type = map(
	  object({
		  network = string 
		  subnet = string
		  host_address_index = number
	  })
  )
  description = "Additional networks instances should be connected to"
  default = {}
}

variable "userdatafile" {
	type = string
	description = "path to userdata file"
}

variable "userdata_vars" {
	type = map(string)
	description = "variables for the userdata template"
	default = {}
}

# feature flags which can be used to disable UUID checks for image, network and subnet inputs
variable "allow_network_uuid" {
	type = bool
	description = "Enable/Disable inputing uuids instead of names for network and additional_networks.*.network"
	default = true
}
variable "allow_subnet_uuid" {
	type = bool
	description = "Enable/Disable inputing uuids instead of names for subnet and additional_networks.*.subnet"
	default = true
}
variable "allow_image_uuid" {
	type = bool
	description = "Enable/Disable inputing uuids instead of names for image"
	default = true
}
