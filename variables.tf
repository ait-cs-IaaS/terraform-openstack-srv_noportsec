variable "name" { type = string }
variable "image" { type = string }
variable "flavor" { type = string }
variable "cidr" { type = string }
variable "host_index" { type = string }
variable "network_id" { type = string }
variable "subnet_id" { type = string }

variable "floating_ip" {
  type = bool
  default = false
}

variable additional_networks {
  type = map(
    object({
      name = string
      cidr = string
      host_index = optional(string) # this is an optional parameter.
      network_id  = string
      subnet_id  = string
      assign_fixed_ip = optional(bool)
    })
  )
  default = {}
}

variable userdata {
  type = string
  default = null
}

variable "fip_pool" {
  type = string
  default = ""
}

variable "metadata_groups" {
  type = string
  default = ""
}

variable "metadata_company_info" {
  type = string
  default = ""
}

variable "assign_fixed_ip" {
  type = bool
  default = true
}