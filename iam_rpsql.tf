# Redpanda SQL API
resource "google_service_account" "redpanda_sql_api" {
  count                        = var.enable_redpanda_sql ? 1 : 0
  account_id                   = "redpanda-sql-api${local.postfix}"
  display_name                 = "Redpanda SQL API Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_sql_api_secrets_access" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role_id = replace("redpanda_sql_api_role${local.postfix}", "-", "_")
  title   = "Redpanda SQL API Secrets Access Role"
  permissions = [
    "secretmanager.secrets.get",
    "secretmanager.versions.access",
  ]
}

resource "google_project_iam_member" "redpanda_sql_api_secrets_access" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_sql_api_secrets_access[0].id
  member  = "serviceAccount:${google_service_account.redpanda_sql_api[0].email}"

  condition {
    title       = "RPSqlSecretsRestriction"
    description = "Restrict access to Redpanda SQL Secret Manager prefix"
    expression  = "resource.name.startsWith('projects/_/secrets/${local.rpsql_secret_manager_prefix}')"
  }
}

resource "google_service_account_iam_member" "redpanda_sql_api_workload_identity" {
  count              = var.enable_redpanda_sql ? 1 : 0
  service_account_id = google_service_account.redpanda_sql_api[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-oxla/${google_service_account.redpanda_sql_api[0].account_id}]"
}


# Redpanda SQL
resource "google_service_account" "redpanda_sql" {
  count                        = var.enable_redpanda_sql ? 1 : 0
  account_id                   = "redpanda-sql${local.postfix}"
  display_name                 = "Redpanda SQL Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

# This role gives editor permissions to the RPSql storage bucket. This role can be scoped to the name of the bucket.
resource "google_project_iam_custom_role" "redpanda_sql_cluster_storage" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role_id = replace("redpanda_sql_storage${local.postfix}", "-", "_")
  title   = "Redpanda SQL Cluster Storage Role"
  permissions = [
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
  ]
}

resource "google_project_iam_member" "redpanda_sql_cluster_storage" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_sql_cluster_storage[0].id
  member  = "serviceAccount:${google_service_account.redpanda_sql[0].email}"

  condition {
    title       = "RPSqlPathRestriction"
    description = "Restrict access to oxla prefix only"
    expression  = "resource.name.startsWith('projects/_/buckets/${google_storage_bucket.redpanda_sql[0].name}/objects/oxla')"
  }

  depends_on = [google_storage_bucket.redpanda_sql]
}

# storage.objects.list permission is granted at the bucket level and cannot be name scoped.
resource "google_project_iam_custom_role" "redpanda_sql_cluster_storage_list" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role_id = replace("redpanda_sql_storage_list${local.postfix}", "-", "_")
  title   = "Redpanda SQL Cluster Storage List Role"
  permissions = [
    "storage.objects.list",
  ]
}

resource "google_project_iam_member" "redpanda_sql_cluster_storage_list" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_sql_cluster_storage_list[0].id
  member  = "serviceAccount:${google_service_account.redpanda_sql[0].email}"

  condition {
    title       = "RPSqlListRestriction"
    description = "Restrict access to oxla prefix only"
    expression  = "resource.name.startsWith('projects/_/buckets/${google_storage_bucket.redpanda_sql[0].name}')"
  }

  depends_on = [google_storage_bucket.redpanda_sql]
}

resource "google_service_account_iam_member" "redpanda_oxla_cluster_workload_identity" {
  count              = var.enable_redpanda_sql ? 1 : 0
  service_account_id = google_service_account.redpanda_sql[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-oxla/${google_service_account.redpanda_sql[0].account_id}]"
}

resource "google_project_iam_custom_role" "redpanda_sql_iceberg_storage" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role_id = replace("redpanda_sql_storage_iceberg${local.postfix}", "-", "_")
  title   = "Redpanda SQL Iceberg Storage Role"
  permissions = [
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

resource "google_project_iam_member" "redpanda_sql_iceberg_storage" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_sql_iceberg_storage[0].id
  member  = "serviceAccount:${google_service_account.redpanda_sql[0].email}"

  condition {
    title       = "IcebergBucketRestriction"
    description = "Restrict Iceberg access to the Redpanda cloud storage bucket"
    expression  = "resource.name.startsWith('projects/_/buckets/${google_storage_bucket.redpanda_cloud_storage.name}')"
  }
}

