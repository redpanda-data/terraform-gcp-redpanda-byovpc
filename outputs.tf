output "management_bucket_name" {
  value = google_storage_bucket.management_bucket.name
}

output "network_name" {
  value = data.google_compute_network.redpanda.name
}

output "network_project_id" {
  value = var.network_project_id
}

output "agent_service_account_email" {
  value = google_service_account.redpanda_agent.email
}

output "connector_service_account_email" {
  value = google_service_account.connectors.email
}

output "console_service_account_email" {
  value = google_service_account.console.email
}

output "gke_service_account_email" {
  value = google_service_account.redpanda_gke.email
}

output "psc_nat_subnet_name" {
  value = var.enable_private_link ? google_compute_subnetwork.psc_nat[0].name : ""
}

output "redpanda_cluster_service_account_email" {
  value = google_service_account.redpanda_cluster.email
}

output "redpanda_connect_api_service_account_email" {
  value = google_service_account.redpanda_connect_api.email
}

output "redpanda_connect_service_account_email" {
  value = google_service_account.redpanda_connect.email
}

output "redpanda_operator_service_account_email" {
  value = google_service_account.redpanda_operator.email
}

output "k8s_master_ipv4_range" {
  value = var.gke_master_ipv4_cidr_block
}

output "subnet_name" {
  value = data.google_compute_subnetwork.redpanda.name
}

output "secondary_ipv4_range_pods_name" {
  value = var.secondary_ipv4_range_pods_name
}

output "secondary_ipv4_range_services_name" {
  value = var.secondary_ipv4_range_services_name
}

output "tiered_storage_bucket_name" {
  value = google_storage_bucket.redpanda_cloud_storage.name
}

output "test_user_account" {
  value = var.create_test_user ? google_service_account.test_user_account[0].account_id : ""
}
