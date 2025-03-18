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

output "shared_vpc_custom_role" {
  value = length(google_project_iam_custom_role.redpanda_agent) > 0 ? google_project_iam_custom_role.redpanda_agent[0].id : ""
}

output "rpk_user_custom_role" {
  value = length(google_project_iam_custom_role.rpk_user_role) > 0 ? google_project_iam_custom_role.rpk_user_role[0].id : ""
}

output "psc_nat_subnet_id" {
  value = var.enable_private_link ? google_compute_subnetwork.psc_nat[0].id : ""
}
