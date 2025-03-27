locals {
  using_shared_vpc = (var.service_project_id != var.network_project_id)
  postfix          = var.unique_identifier != "" ? "-${var.unique_identifier}" : ""
}
