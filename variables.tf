variable "service_project_id" {
  type        = string
  description = <<-HELP
  The project id where the redpanda cluster will be deployed. Required.
  HELP
}

variable "region" {
  type        = string
  description = <<-HELP
  The region where the redpanda cluster will be deployed. Required.
  HELP
}

variable "network_project_id" {
  type        = string
  description = <<-HELP
  The project id of the vpc
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

variable "create_test_user" {
  type        = bool
  default     = false
  description = <<-HELP
  When true a test user will be created with the minimum necessary permissions for running 'rpk byoc apply'
  Not commonly used in a production setting. Test user is provided only for documentation and testing purposes.
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

variable "gke_master_ipv4_cidr_block" {
  default     = "10.3.0.0/28"
  description = <<-HELP
  A /28 CIDR is required for the GKE master IP addresses. This CIDR is not used in the GCP networking configuration,
  but is input into the Redpanda UI; for example, 10.0.7.240/28.
  HELP
}

variable "attach_shared_vpc" {
  type        = bool
  default     = true
  description = <<-HELP
  When true will create the shared_vpc_host_project and shared_vpc_service_project attachments.
  HELP
}

variable "psc_nat_subnet_ipv4_range" {
  type        = string
  default     = "10.0.2.0/29"
  description = <<-HELP
  The IPv4 CIDR range of the PSC NAT subnet
  HELP
}
