output "management_bucket_name" {
  value = google_storage_bucket.management_bucket.name
}

output "redpanda_cloud_storage_bucket_name" {
  value = google_storage_bucket.redpanda_cloud_storage.name
}

output "agent_service_account_account_id" {
  value = google_service_account.redpanda_agent.account_id
}

output "agent_service_account_email" {
  value = google_service_account.redpanda_agent.email
}

output "redpanda_cluster_service_account_account_id" {
  value = google_service_account.redpanda_cluster.account_id
}

output "redpanda_cluster_service_account_email" {
  value = google_service_account.redpanda_cluster.email
}

output "gke_service_account_account_id" {
  value = google_service_account.redpanda_gke.account_id
}

output "gke_service_account_email" {
  value = google_service_account.redpanda_gke.email
}

output "console_service_account_account_id" {
  value = google_service_account.console.account_id
}

output "console_service_account_email" {
  value = google_service_account.console.email
}

output "connectors_service_account_account_id" {
  value = google_service_account.connectors.account_id
}

output "connectors_service_account_email" {
  value = google_service_account.connectors.email
}

output "customer_user_account" {
  value = var.create_customer_user ? google_service_account.customer_user_account[0].account_id : ""
}

output "network-vpc-name" {
  value = google_compute_network.redpanda.name
}

output "network-project-id" {
  value = var.project_id
}

output "network-subnet-name-external" {
  value = google_compute_subnetwork.redpanda.name
}

output "secondary_ipv4_range_pods" {
  value = google_compute_subnetwork.redpanda.secondary_ip_range[0].range_name
}

output "secondary_ipv4_range_services" {
  value = google_compute_subnetwork.redpanda.secondary_ip_range[1].range_name
}