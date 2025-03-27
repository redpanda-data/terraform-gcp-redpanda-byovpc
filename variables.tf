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

variable "network_vpc_name" {
  type        = string
  description = <<-HELP
  The name of the vpc
  HELP
}

variable "network_project_id" {
  type        = string
  description = <<-HELP
  The project id of the vpc
  HELP
}

variable "shared_vpc_custom_role" {
  type        = string
  default     = ""
  description = <<-HELP
  id of the role in the host project we want to grant to the redpada-agent
  HELP
}

variable "rpk_user_custom_role" {
  type        = string
  default     = ""
  description = <<-HELP
  id of the role in the host project we want to grant to the rpk user
  HELP
}

variable "enable_private_link" {
  type        = bool
  default     = false
  description = <<-HELP
  toggle the creation of Private Link/ PSC-related resources
  HELP
}

variable "force_destroy_mgmt_bucket" {
  type        = bool
  default     = false
  description = <<-HELP
  When deleting the mgmt bucket, this boolean option will delete all contained objects. if you try to delete the mgmt
  bucket without this option terraform will fail.
  HELP
}

variable "force_destroy_cloud_storage_bucket" {
  type        = bool
  default     = true
  description = <<-HELP
  When deleting the cloud storage bucket, this boolean option will delete all contained objects. if you try to delete
  the cloud storage bucket without this option terraform will fail.
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

variable "create_customer_user" {
  type        = bool
  default     = false
  description = <<-HELP
  Whether or not to create the customer user service account. The customer user service account is used to simulate a
  user with limited permissions when running rpk.
  HELP
}

variable "max_redpanda_node_count" {
  type        = number
  default     = 20
  description = <<-HELP
  Redpanda node count for setting up the firewall rules
  HELP
}

variable "psc_config" {
  type = object({
    kafka_api_seed_node_port       = number
    redpanda_proxy_seed_node_port  = number
    schema_registry_seed_node_port = number
    console_seed_node_port         = number
    kafka_api_base_node_port       = number
    redpanda_proxy_base_node_port  = number
    port_offset                    = number
  })
  default = {
    kafka_api_seed_node_port       = 30292
    redpanda_proxy_seed_node_port  = 30282
    schema_registry_seed_node_port = 30181
    console_seed_node_port         = 31004
    kafka_api_base_node_port       = 32092
    redpanda_proxy_base_node_port  = 31082
    port_offset                    = 100
  }
  description = <<-HELP
  PSC configuration
  HELP
}
