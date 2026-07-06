
resource "google_storage_bucket" "redpanda_sql" {
  count                       = var.enable_redpanda_sql ? 1 : 0
  name                        = "redpanda-sql-storage${local.postfix}"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy_sql_storage_bucket
  versioning {
    enabled = false
  }
  project = var.service_project_id
}


