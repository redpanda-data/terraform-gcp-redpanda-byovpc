resource "google_service_account" "console" {
  account_id                   = "redpanda-console${local.postfix}"
  display_name                 = "Redpanda Console Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "console_secret_manager" {
  role_id = replace("redpanda_console_secret_manager_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Console Secret Manager Writer"
  permissions = [
    "secretmanager.secrets.get",
    "secretmanager.secrets.create",
    "secretmanager.secrets.delete",
    "secretmanager.secrets.list",
    "secretmanager.secrets.update",
    "secretmanager.versions.add",
    "secretmanager.versions.destroy",
    "secretmanager.versions.disable",
    "secretmanager.versions.enable",
    "secretmanager.versions.list",
    "iam.serviceAccounts.getAccessToken"
  ]
}

resource "google_project_iam_member" "console_secret_manager" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.console_secret_manager.id
  member  = "serviceAccount:${google_service_account.console.email}"
}

resource "google_service_account_iam_member" "console_service_account_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.console.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda/console-${google_service_account.console.account_id}]"
}
