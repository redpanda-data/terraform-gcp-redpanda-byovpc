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
