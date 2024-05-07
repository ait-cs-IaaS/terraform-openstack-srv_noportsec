locals {
  metadata = merge(
    {
      groups = var.metadata_groups
    },
    var.metadata_company_info != "" ? { company_info = var.metadata_company_info } : {}
  )
}