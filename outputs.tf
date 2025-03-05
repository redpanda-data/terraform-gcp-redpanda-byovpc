output "primary_subnet_id" {
  description = "ID of the created subnet"
  value       = google_compute_subnetwork.primary_subnet.id
}

output "nat_ip" {
  description = "External IP used for NAT gateway"
  value       = google_compute_address.nat_ip.address
}

output "tiered_storage_bucket_url" {
  description = "URL of the tiered storage bucket"
  value       = google_storage_bucket.tiered_storage.url
}

output "management_storage_bucket_url" {
  description = "URL of the management storage bucket"
  value       = google_storage_bucket.management_storage.url
}

output "redpanda_cluster_sa_email" {
  description = "Email address of the Redpanda cluster service account"
  value       = google_service_account.redpanda_cluster.email
}

output "redpanda_agent_email" {
  description = "Email address of the Redpanda agent service account"
  value       = google_service_account.redpanda_agent.email
}

output "redpanda_agent_service_role_id" {
  description = "ID of the Redpanda agent custom role in service project"
  value       = google_project_iam_custom_role.redpanda_agent_role_service.id
}

output "redpanda_agent_host_role_id" {
  description = "ID of the Redpanda agent custom role in host project (if created)"
  value       = var.host_project_id != var.service_project_id ? google_project_iam_custom_role.redpanda_agent_role_host[0].id : "Not created - same as service project"
}

output "redpanda_console_sa_email" {
  description = "Email address of the Redpanda Console service account"
  value       = google_service_account.redpanda_console.email
}

output "redpanda_console_role_id" {
  description = "ID of the Redpanda Console Secret Manager role"
  value       = google_project_iam_custom_role.redpanda_console_secret_manager_role.id
}

output "redpanda_connectors_sa_email" {
  description = "Email address of the Redpanda Connectors service account"
  value       = google_service_account.redpanda_connectors.email
}

output "redpanda_connectors_role_id" {
  description = "ID of the Redpanda Connectors custom role"
  value       = google_project_iam_custom_role.redpanda_connectors_role.id
}

output "redpanda_gke_sa_email" {
  description = "Email address of the Redpanda GKE service account"
  value       = google_service_account.redpanda_gke.email
}

output "redpanda_gke_role_id" {
  description = "ID of the Redpanda GKE utility custom role"
  value       = google_project_iam_custom_role.redpanda_gke_utility_role.id
}

output "workload_identity_bindings" {
  description = "List of all workload identity bindings created"
  value = [
    "Redpanda cluster: ${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_redpanda}/rp-${var.redpanda_cluster_sa_name}]",
    "Redpanda console: ${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_redpanda}/console-${var.redpanda_console_sa_name}]",
    "Redpanda connectors: ${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_connectors}/connectors-${var.redpanda_connectors_sa_name}]",
    "Cert Manager: ${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_cert_manager}/cert-manager]",
    "External DNS: ${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_external_dns}/external-dns]",
    "PSC Controller: ${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_psc}/psc-controller]"
  ]
}