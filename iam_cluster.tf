resource "google_service_account" "redpanda_cluster" {
  project                      = var.service_project_id
  account_id                   = "redpanda-cluster${local.postfix}"
  display_name                 = "Redpanda Cluster Service Account"
  create_ignore_already_exists = true
}

resource "google_storage_bucket_iam_member" "redpanda_cluster_cloud_storage_admin" {
  bucket = google_storage_bucket.redpanda_cloud_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.redpanda_cluster.email}"
}

resource "google_service_account_iam_member" "redpanda_cluster_service_account_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_cluster.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda/rp-${google_service_account.redpanda_cluster.account_id}]"
}
