output "management_bucket_name" {
  value       = google_storage_bucket.management_bucket.name
  description = "The name of the storage bucket to be used for terraform state."
}

output "network_name" {
  value       = data.google_compute_network.redpanda.name
  description = "The name of the network."
}

output "network_project_id" {
  value       = var.network_project_id
  description = "The project id of the network."
}

output "agent_service_account_email" {
  value       = google_service_account.redpanda_agent.email
  description = "The email address of the service account used by the redpanda agent."
}

output "connector_service_account_email" {
  value       = google_service_account.connectors.email
  description = "The email address of the service account used by the connectors."
}

output "console_service_account_email" {
  value       = google_service_account.console.email
  description = "The email address of the service account used by the console."
}

output "gke_service_account_email" {
  value       = google_service_account.redpanda_gke.email
  description = "The email address of the service account used by the GKE cluster."
}

output "psc_nat_subnet_name" {
  value       = var.enable_private_link ? data.google_compute_subnetwork.psc_nat.name : ""
  description = "The name of the PSC NAT subnet, if private link is enabled."
}

output "redpanda_cluster_service_account_email" {
  value       = google_service_account.redpanda_cluster.email
  description = "The email address of the service account used by the redpanda cluster."
}

output "redpanda_connect_api_service_account_email" {
  value       = google_service_account.redpanda_connect_api.email
  description = "The email address of the service account used by the redpanda connect api."
}

output "redpanda_connect_service_account_email" {
  value       = google_service_account.redpanda_connect.email
  description = "The email address of the service account used by redpanda connect."
}

output "redpanda_operator_service_account_email" {
  value       = google_service_account.redpanda_operator.email
  description = "The email address of the service account used by the redpanda operator."
}

output "k8s_master_ipv4_range" {
  value       = var.gke_master_ipv4_cidr_block
  description = "The IPv4 CIDR range of the GKE master."
}

output "subnet_name" {
  value       = data.google_compute_subnetwork.redpanda.name
  description = "The name of the subnet."
}

output "secondary_ipv4_range_pods_name" {
  value       = var.secondary_ipv4_range_pods_name
  description = "The name of the secondary IP range for pods."
}

output "secondary_ipv4_range_services_name" {
  value       = var.secondary_ipv4_range_services_name
  description = "The name of the secondary IP range for services."
}

output "tiered_storage_bucket_name" {
  value       = google_storage_bucket.redpanda_cloud_storage.name
  description = "The name of the storage bucket to be used for tiered storage."
}

output "test_user_account" {
  value       = var.create_test_user ? google_service_account.test_user_account[0].account_id : ""
  description = "The email address of the test user account, if created."
}
