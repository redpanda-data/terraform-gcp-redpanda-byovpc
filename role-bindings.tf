resource "google_service_account_iam_binding" "redpanda_cluster_wi_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${var.redpanda_cluster_sa_name}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_redpanda}/rp-${var.redpanda_cluster_sa_name}]"
  ]
}

resource "google_service_account_iam_binding" "redpanda_console_wi_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${var.redpanda_console_sa_name}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_redpanda}/console-${var.redpanda_console_sa_name}]"
  ]
}

resource "google_service_account_iam_binding" "redpanda_connectors_wi_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${var.redpanda_connectors_sa_name}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_connectors}/connectors-${var.redpanda_connectors_sa_name}]"
  ]
}

resource "google_service_account_iam_member" "gke_cert_manager_wi_member" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${var.redpanda_gke_sa_name}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_cert_manager}/cert-manager]"
}

resource "google_service_account_iam_member" "gke_external_dns_wi_member" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${var.redpanda_gke_sa_name}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_external_dns}/external-dns]"
}

resource "google_service_account_iam_member" "gke_psc_controller_wi_member" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${var.redpanda_gke_sa_name}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[${var.kubernetes_namespace_psc}/psc-controller]"
}