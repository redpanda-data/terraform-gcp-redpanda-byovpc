// Redpanda Connect API

resource "google_service_account" "redpanda_connect_api" {
  account_id                   = "redpanda-connect-api${local.postfix}"
  display_name                 = "Redpanda Connect API Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_connect_api_custom_role" {
  role_id = replace("redpanda_redpanda_connect_api_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Connect API Role"
  permissions = [
    "secretmanager.secrets.get"
  ]
}

resource "google_project_iam_member" "redpanda_connect_api" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_connect_api_custom_role.id
  member  = "serviceAccount:${google_service_account.redpanda_connect_api.email}"
}

resource "google_service_account_iam_member" "redpanda_connect_api_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_connect_api.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-connect/${google_service_account.redpanda_connect_api.account_id}]"
}

// Redpanda Connect

resource "google_service_account" "redpanda_connect" {
  account_id                   = "redpanda-connect${local.postfix}"
  display_name                 = "Redpanda Connect Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_connect_custom_role" {
  role_id = replace("redpanda_connect_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Connect Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.versions.access",
  ]
}

resource "google_project_iam_member" "redpanda_connect" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_connect_custom_role.id
  member  = "serviceAccount:${google_service_account.redpanda_connect.email}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account_iam_member" "redpanda_connect_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_connect.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-connect/${google_service_account.redpanda_connect.account_id}]"
}
