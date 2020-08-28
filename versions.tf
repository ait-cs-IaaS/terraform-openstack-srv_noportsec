terraform {
  required_providers {
    openstack = {
      source = "terraform-providers/openstack"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
