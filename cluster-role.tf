resource "google_service_account" "redpanda_cluster" {
  project      = var.service_project_id
  account_id   = "redpanda-cluster"
  display_name = "Redpanda Cluster Service Account"
}

resource "google_storage_bucket_iam_member" "tiered_storage_bucket_access" {
  bucket = var.tiered_storage_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.redpanda_cluster.email}"
}