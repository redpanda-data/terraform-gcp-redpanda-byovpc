resource "google_service_account" "connectors" {
  account_id                   = "redpanda-connectors${local.postfix}"
  display_name                 = "Redpanda Connectors Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "connectors_custom_role" {
  role_id = replace("redpanda_connectors_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Connectors Custom Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.versions.access",
  ]
}

resource "google_project_iam_member" "connectors_secret_manager" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.connectors_custom_role.id
  member  = "serviceAccount:${google_service_account.connectors.email}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account_iam_member" "connectors_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.connectors.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-connectors/connectors-${google_service_account.connectors.account_id}]"
}
