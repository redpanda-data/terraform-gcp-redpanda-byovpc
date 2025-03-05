resource "google_service_account" "redpanda_connectors" {
  project      = var.service_project_id
  account_id   = "redpanda-connectors"
  display_name = "Redpanda Connectors Service Account"
}

resource "google_project_iam_custom_role" "redpanda_connectors_role" {
  project     = var.service_project_id
  role_id     = "redpanda_connectors_role"
  title       = "Redpanda Connectors Custom Role"
  description = "Redpanda Connectors Custom Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.versions.access"
  ]
}

resource "google_project_iam_member" "redpanda_connectors_role_binding" {
  project = var.service_project_id
  role    = "projects/${var.service_project_id}/roles/redpanda_connectors_role"
  member  = "serviceAccount:${google_service_account.redpanda_connectors.email}"

  depends_on = [google_project_iam_custom_role.redpanda_connectors_role]
}
