variable "project_id" {
  type        = string
  description = <<-HELP
  The project id
  HELP
}

variable "region" {
  type        = string
  description = <<-HELP
  The region where the VPC lives. Required.
  HELP
}

variable "service_project_id" {
  type        = string
  description = <<-HELP
  The service project id
  HELP
}

variable "enable_private_link" {
  type        = bool
  default     = false
  description = <<-HELP
  toggle the creation of Private Link/ PSC-related resources
  HELP
}

variable "psc_nat_subnet_ipv4_range" {
  type        = string
  default     = "10.0.2.0/29"
  description = <<-HELP
  The IPv4 CIDR range of the PSC NAT subnet
  HELP
}

variable "unique_identifier" {
  type        = string
  default     = ""
  description = <<-HELP
  If you intend to run multiple copies of this terraform you will need to provide a distinguishing string so that the
  resources created will not have naming conflicts.
  HELP
}

variable "attach_shared_vpc" {
  type        = bool
  default     = true
  description = <<-HELP
  When true will create the shared_vpc_host_project and shared_vpc_service_project attachments.
  HELP
}
