variable "host_project_id" {
  description = "The ID of the host project where shared VPC exists"
  type        = string
}

variable "service_project_id" {
  description = "The ID of the service project to enable services in"
  type        = string
}

variable "shared_vpc_name" {
  description = "The name of the shared VPC network"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
}

variable "primary_subnet_name" {
  description = "The name for the primary subnet"
  type        = string
}

variable "secondary_ipv4_range_name_for_pods" {
  description = "The name for the secondary IPv4 range for pods"
  type        = string
}

variable "secondary_ipv4_range_name_for_services" {
  description = "The name for the secondary IPv4 range for services"
  type        = string
}

variable "router_name" {
  description = "The name for the Cloud Router"
  type        = string
}

variable "nat_config_name" {
  description = "The name for the Cloud NAT configuration"
  type        = string
}

variable "address_name" {
  description = "The name for the NAT external IP address"
  type        = string
}

variable "gke_master_cidr_range" {
  description = "The CIDR range for GKE master"
  type        = string
}

variable "tiered_storage_bucket_name" {
  description = "The name for the tiered storage bucket"
  type        = string
}

variable "management_storage_bucket_name" {
  description = "The name for the management storage bucket"
  type        = string
}

variable "redpanda_cluster_sa_name" {
  description = "Account ID for the Redpanda cluster service account"
  type        = string
  default     = "redpanda-cluster"
}

variable "redpanda_console_sa_name" {
  description = "Account ID for the Redpanda console service account"
  type        = string
  default     = "redpanda-console"
}

variable "redpanda_connectors_sa_name" {
  description = "Account ID for the Redpanda connectors service account"
  type        = string
  default     = "redpanda-connectors"
}

variable "redpanda_gke_sa_name" {
  description = "Account ID for the Redpanda GKE service account"
  type        = string
  default     = "redpanda-gke"
}

variable "kubernetes_namespace_redpanda" {
  description = "Kubernetes namespace for Redpanda resources"
  type        = string
  default     = "redpanda"
}

variable "kubernetes_namespace_connectors" {
  description = "Kubernetes namespace for Redpanda connectors"
  type        = string
  default     = "redpanda-connectors"
}

variable "kubernetes_namespace_cert_manager" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "kubernetes_namespace_external_dns" {
  description = "Kubernetes namespace for external-dns"
  type        = string
  default     = "external-dns"
}

variable "kubernetes_namespace_psc" {
  description = "Kubernetes namespace for PSC controller"
  type        = string
  default     = "redpanda-psc"
}
