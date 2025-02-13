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
      name = optional(string)
      cidr = optional(string)
      host_index = optional(string)
      network_id  = optional(string)
      subnet_id  = optional(string)
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