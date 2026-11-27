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

  # Secret Manager resource names in IAM Conditions use the project number, never the project ID:
  # https://cloud.google.com/iam/docs/conditions-resource-attributes#resource-name
  condition {
    title       = "RPSqlSecretsRestriction"
    description = "Restrict access to Redpanda SQL Secret Manager prefix"
    expression  = "resource.name.startsWith('projects/${data.google_project.service_project[0].number}/secrets/redpanda-')"
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

# storage.objects.list is checked on the bucket, so it cannot be scoped to the oxla prefix.
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
    description = "Restrict list access to the Redpanda SQL bucket"
    # The exact match keeps buckets that only share this name as a prefix out.
    expression = "resource.name == 'projects/_/buckets/${google_storage_bucket.redpanda_sql[0].name}'"
  }

  lifecycle {
    # The condition is ForceNew; bind the new one before the old one goes so listing never loses access.
    create_before_destroy = true
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
  # Bucket-wide read; writes go through the Iceberg write role, under the rpsql_ prefix only.
  permissions = [
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
    # The exact match keeps buckets that only share this name as a prefix out.
    expression = "resource.name == 'projects/_/buckets/${google_storage_bucket.redpanda_cloud_storage.name}' || resource.name.startsWith('projects/_/buckets/${google_storage_bucket.redpanda_cloud_storage.name}/objects/')"
  }

  lifecycle {
    # The condition is ForceNew; bind the new one before the old one goes so reads never lose access.
    create_before_destroy = true
  }
}

resource "google_project_iam_custom_role" "redpanda_sql_iceberg_write" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role_id = replace("redpanda_sql_iceberg_write${local.postfix}", "-", "_")
  title   = "Redpanda SQL Iceberg Write Role"
  # Overwriting an object needs delete as well as create.
  permissions = [
    "storage.objects.create",
    "storage.objects.delete",
  ]
}

resource "google_project_iam_member" "redpanda_sql_iceberg_write" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_sql_iceberg_write[0].id
  member  = "serviceAccount:${google_service_account.redpanda_sql[0].email}"

  condition {
    title       = "IcebergWritePrefixRestriction"
    description = "Restrict Iceberg writes to the Redpanda SQL prefix of the Redpanda cloud storage bucket"
    # No cluster ID before the cluster exists; the bucket is per cluster, so rpsql_ alone keeps broker paths out.
    expression = "resource.name.startsWith('projects/_/buckets/${google_storage_bucket.redpanda_cloud_storage.name}/objects/rpsql_')"
  }
}

# BigLake (Iceberg REST catalog on GCP) grants for the Redpanda SQL cluster SA.
# Mirrors the grants Redpanda applies for Redpanda-managed clusters
# BigLake warehouse bucket is already covered above (redpanda_sql_iceberg_storage/_write,
# scoped to the redpanda_cloud_storage bucket) — no separate warehouse bucket is in play.

# BigLake Editor — read and write the Iceberg REST catalog via the BigLake API.
resource "google_project_iam_member" "redpanda_sql_biglake_editor" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = "roles/biglake.editor"
  member  = "serviceAccount:${google_service_account.redpanda_sql[0].email}"

  lifecycle {
    # The role is ForceNew; grant editor before viewer goes so catalog access is never lost.
    create_before_destroy = true
  }
}

# v1.0.5 named this binding redpanda_sql_biglake_viewer; earlier versions already use this address.
moved {
  from = google_project_iam_member.redpanda_sql_biglake_viewer
  to   = google_project_iam_member.redpanda_sql_biglake_editor
}

# Service Usage Consumer — required by BigLake to interact with GCP services.
resource "google_project_iam_member" "redpanda_sql_service_usage_consumer" {
  count   = var.enable_redpanda_sql ? 1 : 0
  project = var.service_project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.redpanda_sql[0].email}"
}

