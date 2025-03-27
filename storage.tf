resource "google_storage_bucket" "management_bucket" {
  name                        = "redpanda-mgmt${local.postfix}"
  location                    = var.region
  force_destroy               = var.force_destroy_mgmt_bucket
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  project = var.service_project_id
}

resource "google_storage_bucket" "redpanda_cloud_storage" {
  name                        = "redpanda-storage${local.postfix}"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy_cloud_storage_bucket
  versioning {
    enabled = false
  }
  project = var.service_project_id
}
