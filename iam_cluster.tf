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

# BigLake (broker-native Iceberg via BigLake REST catalog) grants for the Redpanda cluster SA.
# Mirrors the grants Redpanda applies for Redpanda-managed clusters.
# The biglake/bigquery APIs are enabled unconditionally in api_enablement.tf. Storage access
# to the BigLake warehouse bucket is already covered above (redpanda_cluster_cloud_storage_admin, bucket-scoped) — the
# warehouse is this module's tiered-storage bucket, not a separate one.

# BigLake Editor — access the Iceberg REST catalog via the BigLake API.
resource "google_project_iam_member" "redpanda_cluster_biglake_editor" {
  project = var.service_project_id
  role    = "roles/biglake.editor"
  member  = "serviceAccount:${google_service_account.redpanda_cluster.email}"
}

# Service Usage Consumer — required by BigLake to interact with GCP services.
resource "google_project_iam_member" "redpanda_cluster_service_usage_consumer" {
  project = var.service_project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.redpanda_cluster.email}"
}
