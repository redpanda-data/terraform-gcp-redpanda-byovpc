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
  The project id of the vpc. May be the same project as the service project or may be a host project. Required.
  HELP
}

variable "enable_private_link" {
  type        = bool
  default     = false
  description = <<-HELP
  When true PSC-related resources will be created.
  HELP
}

variable "force_destroy_mgmt_bucket" {
  type        = bool
  default     = false
  description = <<-HELP
  When deleting the mgmt bucket, this boolean option will delete all contained objects. If you try to delete the mgmt
  bucket without this option terraform will fail.
  HELP
}

variable "force_destroy_cloud_storage_bucket" {
  type        = bool
  default     = false
  description = <<-HELP
  When deleting the cloud storage bucket, this boolean option will delete all contained objects. If you try to delete
  the cloud storage bucket without this option terraform will fail. Not recommended for production use.
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
  default     = "10.0.7.240/28"
  description = <<-HELP
  A /28 CIDR is required for the GKE master IP addresses.
  HELP
}

variable "attach_shared_vpc" {
  type        = bool
  default     = true
  description = <<-HELP
  When true will create the shared_vpc_host_project and shared_vpc_service_project attachments. In a shared VPC setup
  this is typically a one time configuration and would commonly be done outside of this module.
  HELP
}

variable "psc_subnet_name" {
  type        = string
  default     = ""
  description = <<-HELP
    The name of the PSC subnet if created outside of this module. If vpc_name is provided and private link is enabled,
    this value is required.
    HELP
}

resource "terraform_data" "validation" {
  input = "validation-only"

  #    If private link is not enabled, psc_subnet_name should not be provided
  #    If private link is enabled and vpc_name is provided, psc_subnet_name is required
  #    If private link is enabled and vpc_name is not provided, psc_subnet_name should not be provided
  lifecycle {
    precondition {
      condition = (
      (!var.enable_private_link && var.psc_subnet_name == "") ||
      (var.enable_private_link && (var.vpc_name == "") == (var.psc_subnet_name == ""))
      )
      error_message = "Configuration error: If private link is enabled and vpc_name is provided, psc_subnet_name is required. If private link is not enabled, psc_subnet_name should not be provided."
    }
  }
}

variable "psc_nat_subnet_ipv4_range" {
  type        = string
  default     = "10.0.2.0/29"
  description = <<-HELP
  The IPv4 CIDR range of the PSC NAT subnet
  HELP
}

variable "vpc_name" {
  type        = string
  default     = ""
  description = <<-HELP
  The name of the VPC network if created outside of this module
  HELP
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = <<-HELP
  The name of the subnet if created outside of this module. If vpc_name is provided, this value is required.
  HELP
}

resource "terraform_data" "subnet_validation" {
  input = "validation-only"
  # We expect that when vpc_name and subnet_name are both nil or both not nil, this should pass. Otherwise, this should fail.
  lifecycle {
    precondition {
      condition     = (var.vpc_name == "") == (var.subnet_name == "")
      error_message = "If vpc_name is provided, subnet_name is required. Both must be either specified or unspecified."
    }
  }
}

variable "secondary_ipv4_range_pods_name" {
  type        = string
  default     = "redpanda-pods"
  description = <<-HELP
    The name of the secondary IP range for pods
    HELP
}

variable "secondary_ipv4_range_services_name" {
  type        = string
  default     = "redpanda-services"
  description = <<-HELP
    The name of the secondary IP range for services
    HELP
}

variable "subnetwork_ip_cidr_range" {
  type        = string
  default     = "10.0.0.0/24"
  description = <<-HELP
    The IP CIDR range of the subnetwork
    HELP
}

variable "subnetwork_pods_secondary_ip_range" {
  type        = string
  default     = "10.0.8.0/21"
  description = <<-HELP
    The IP CIDR range of the subnetwork pods secondary IP range
    HELP
}

variable "subnetwork_services_secondary_ip_range" {
  type        = string
  default     = "10.0.1.0/24"
  description = <<-HELP
    The IP CIDR range of the subnetwork services secondary IP range
    HELP
}
