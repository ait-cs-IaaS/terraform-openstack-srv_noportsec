variable "image" {
  type        = string
  description = "name or id of the image to boot the hosts from"
}

variable "flavor" {
  type        = string
  description = "instance flavor for the server"
  default     = "m1.small"
}

variable "volume_size" {
  type        = string
  description = "volume_size"
  default     = 5
}

variable "config_drive" {
  type        = bool
  description = "Use a config drive to load initial configuration instead of using the network based metadata service"
  default     = false
}

variable "sshkey" {
  type        = string
  description = "ssh key for the server"
  default     = "cyberrange-key"
}

variable "tag" {
  type        = string
  description = "group tag"
  default     = null
}

variable "metadata" {
  type        = map(string)
  description = "The metadata values to assign to the instance"
  default     = {}
}

variable "hostname" {
  type        = string
  description = "hostname"
}

variable "network" {
  type        = string
  description = "Name or id of the main network"
}

variable "subnet" {
  type        = string
  description = "Name or id of the local sub-net"
}

variable "host_address_index" {
  type        = number
  description = "The host address index within the subnet the instances IP address will be assigned from"
  default     = null
}

variable "network_access" {
  type        = bool
  description = "If the main network should be the access_network"
  default     = false
}

# the attributes in the networks and additional_networks maps behave the same as their default network counter parts
# (e.g., network can be either the name or id)
variable "networks" {
  type = map(
    object({
      network            = string
      subnet             = string
      host_address_index = number
      access             = bool
    })
  )
  description = "Networks the instance should be created with"
  default     = {}
}

variable "additional_networks" {
  type = map(
    object({
      network            = string
      subnet             = string
      host_address_index = number
    })
  )
  description = "Additional networks that should be attached to the instance"
  default     = {}
}

variable "userdatafile" {
  type        = string
  description = "path to userdata file"
  default     = null
}

variable "userdata_vars" {
  type        = any
  description = "variables for the userdata template"
  default     = {}
}

# feature flags which can be used to disable UUID checks for image, network and subnet inputs
variable "allow_network_uuid" {
  type        = bool
  description = "Enable/Disable inputing uuids instead of names for network and additional_networks.*.network"
  default     = true
}
variable "allow_subnet_uuid" {
  type        = bool
  description = "Enable/Disable inputing uuids instead of names for subnet and additional_networks.*.subnet"
  default     = true
}
variable "allow_image_uuid" {
  type        = bool
  description = "Enable/Disable inputing uuids instead of names for image"
  default     = true
}

variable "use_volume" {
  type        = bool
  description = "If the a volume or a local file should be used for storage"
  default     = false
}

variable "extnet" {
  type        = bool
  description = "Network is an external network that does not allow port creation"
  default     = false
}

variable "security_groups" {
  type        = list(any)
  description = "List of security groups if extnet"
  default     = null
}
