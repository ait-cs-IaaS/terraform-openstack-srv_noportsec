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
}

variable "ip_address" {
	type = string
	description = "fixed ip address"
	default = null
}

# the attributes in the additional_networks map behave the same as their default network counter parts 
# (e.g., network can be either the name or id)
variable "additional_networks" { 
  type = map(
	  object({
		  network = string 
		  subnet = string
		  ip_address = string
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

