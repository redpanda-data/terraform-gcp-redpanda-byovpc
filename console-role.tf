resource "google_service_account" "redpanda_console" {
  project      = var.service_project_id
  account_id   = "redpanda-console"
  display_name = "Redpanda Console Service Account"
}

resource "google_project_iam_custom_role" "redpanda_console_secret_manager_role" {
  project     = var.service_project_id
  role_id     = "redpanda_console_secret_manager_role"
  title       = "Redpanda Console Secret Manager Writer"
  description = "Redpanda Console Secret Manager Writer"
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

resource "google_project_iam_member" "redpanda_console_secret_manager_binding" {
  project = var.service_project_id
  role    = "projects/${var.service_project_id}/roles/redpanda_console_secret_manager_role"
  member  = "serviceAccount:${google_service_account.redpanda_console.email}"

  depends_on = [google_project_iam_custom_role.redpanda_console_secret_manager_role]
}