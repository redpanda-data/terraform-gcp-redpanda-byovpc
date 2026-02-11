resource "google_service_account" "redpanda_operator" {
  account_id                   = "rp-op${local.postfix}"
  display_name                 = "Redpanda Operator Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_service_account_iam_member" "redpanda_operator_service_account_binding" {
  service_account_id = google_service_account.redpanda_operator.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-system/redpanda-operator-sa]"
}

resource "google_project_iam_custom_role" "redpanda_operator_custom_role" {
  role_id = replace("redpanda_operator_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda operator Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.secrets.get",
    "secretmanager.versions.access"
  ]
}

resource "google_project_iam_member" "redpanda_operator" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_operator_custom_role.id
  member  = "serviceAccount:${google_service_account.redpanda_operator.email}"
  lifecycle {
    create_before_destroy = true
  }
}
