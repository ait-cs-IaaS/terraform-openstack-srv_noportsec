variable "image" {
	type = string
	description = "name of the image to boot the hosts from"
}

variable "flavor" {
	type = string
	description = "instance flavor for the server"
	default = "m1.small"
}

variable "sshkey" {
	type = string
        description = "ssh key for the server"
	default = "cyberrange-key"
}

variable "network" {
	type = string
	description = "Name of the main network"
}

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

variable "subnet" {
	type = string
	description = "Name of the local sub-net"
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

variable "hostname" {
	type = string
	description = "hostname"
}

variable "tag" {
	type = string
	description = "group tag"
	default = null
}

variable "volume_size" {
	type = string
	description = "volume_size"
	default = 5
}

variable "ip_address" {
	type = string
	description = "fixed ip address"
	default = null
}
