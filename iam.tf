
resource "google_service_account" "redpanda_agent" {
  account_id                   = "redpanda-agent${local.postfix}"
  display_name                 = "Redpanda Agent Service Account"
  description                  = "Redpanda Agent Service Account"
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_agent" {
  count       = local.create_shared_vpc ? 1 : 0
  role_id     = replace("redpanda_agent_role${local.postfix}", "-", "_")
  title       = "Redpanda Agent Role"
  description = "A role granting the redpanda agent permissions to view network resources in the project of the vpc."
  permissions = local.agent_permissions
}

resource "google_project_iam_member" "redpanda_agent_custom_role" {
  project = var.host_project_id
  role    = google_project_iam_custom_role.redpanda_agent.id
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
  lifecycle {
    create_before_destroy = true
  }
}
resource "google_project_iam_member" "redpanda_agent_container_admin" {
  project = var.host_project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
}

resource "google_storage_bucket_iam_member" "redpanda_agent_storage_object_admin" {
  bucket = google_storage_bucket.management_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.redpanda_agent.email}"
}

resource "google_project_iam_member" "redpanda_agent_shared_vpc_permissions" {
  count   = local.using_shared_vpc ? 1 : 0
  project = var.network_project_id
  role    = var.shared_vpc_custom_role
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account" "redpanda_cluster" {
  account_id                   = "redpanda-cluster${local.postfix}"
  display_name                 = "Redpanda Cluster Service Account"
  create_ignore_already_exists = true
}

resource "google_storage_bucket_iam_member" "redpanda_cluster_cloud_storage_admin" {
  bucket = google_storage_bucket.redpanda_cloud_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.redpanda_cluster.email}"
}

resource "google_service_account" "redpanda_gke" {
  account_id                   = "redpanda-gke${local.postfix}"
  display_name                 = "Redpanda GKE cluster default node service account"
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_utility_node" {
  role_id = replace("redpanda_gke_utility_role${local.postfix}", "-", "_")
  title   = "Redpanda cluster utility node role"
  permissions = [
    # Artifact Registry Reader
    "artifactregistry.dockerimages.get",
    "artifactregistry.dockerimages.list",
    "artifactregistry.files.get",
    "artifactregistry.files.list",
    "artifactregistry.locations.get",
    "artifactregistry.locations.list",
    "artifactregistry.mavenartifacts.get",
    "artifactregistry.mavenartifacts.list",
    "artifactregistry.npmpackages.get",
    "artifactregistry.npmpackages.list",
    "artifactregistry.packages.get",
    "artifactregistry.packages.list",
    "artifactregistry.projectsettings.get",
    "artifactregistry.pythonpackages.get",
    "artifactregistry.pythonpackages.list",
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.repositories.listEffectiveTags",
    "artifactregistry.repositories.listTagBindings",
    "artifactregistry.repositories.readViaVirtualRepository",
    "artifactregistry.tags.get",
    "artifactregistry.tags.list",
    "artifactregistry.versions.get",
    "artifactregistry.versions.list",
    # Logs Writer
    "logging.logEntries.create",
    "logging.logEntries.route",
    # Monitoring Metric Writer
    "monitoring.metricDescriptors.create",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.monitoredResourceDescriptors.get",
    "monitoring.monitoredResourceDescriptors.list",
    "monitoring.timeSeries.create",
    # Monitoring Viewer
    "cloudnotifications.activities.list",
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list",
    "monitoring.dashboards.get",
    "monitoring.dashboards.list",
    "monitoring.groups.get",
    "monitoring.groups.list",
    "monitoring.notificationChannelDescriptors.get",
    "monitoring.notificationChannelDescriptors.list",
    "monitoring.notificationChannels.get",
    "monitoring.notificationChannels.list",
    "monitoring.publicWidgets.get",
    "monitoring.publicWidgets.list",
    "monitoring.services.get",
    "monitoring.services.list",
    "monitoring.slos.get",
    "monitoring.slos.list",
    "monitoring.snoozes.get",
    "monitoring.snoozes.list",
    "monitoring.timeSeries.list",
    "monitoring.uptimeCheckConfigs.get",
    "monitoring.uptimeCheckConfigs.list",
    "opsconfigmonitoring.resourceMetadata.list",
    "resourcemanager.projects.get",
    "stackdriver.projects.get",
    "stackdriver.resourceMetadata.list",
    # cert-manager & external-dns
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    # Redpanda connectors Secret Manager read-only
    "secretmanager.versions.access",
    # Stackdriver Resource Metadata Writer
    "stackdriver.resourceMetadata.write",
    # Storage Object Viewer
    "storage.objects.get",
    "storage.objects.list",
    # PSC controller
    "compute.instances.use",
    "iam.serviceAccounts.getAccessToken",
    "compute.regionNetworkEndpointGroups.create",
    "compute.regionNetworkEndpointGroups.delete",
    "compute.regionNetworkEndpointGroups.get",
    "compute.regionNetworkEndpointGroups.use",
    "compute.regionNetworkEndpointGroups.attachNetworkEndpoints",
    "compute.regionNetworkEndpointGroups.detachNetworkEndpoints",
  ]
}

resource "google_project_iam_member" "redpanda_utility" {
  project = var.host_project_id
  role    = google_project_iam_custom_role.redpanda_utility_node.id
  member  = "serviceAccount:${google_service_account.redpanda_gke.email}"
}

resource "google_service_account" "console" {
  account_id                   = "redpanda-console${local.postfix}"
  display_name                 = "Redpanda Console Service Account"
  project                      = var.host_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "console_secret_manager" {
  role_id = replace("redpanda_console_secret_manager_role${local.postfix}", "-", "_")
  project = var.host_project_id
  title   = "Redpanda Console Secret Manager Writer"
  permissions = [
    "secretmanager.secrets.get",
    "secretmanager.secrets.create",
    "secretmanager.secrets.delete",
    "secretmanager.secrets.list",
    "secretmanager.secrets.update",
    "secretmanager.versions.add",
    "secretmanager.versions.destroy",
    "secretmanager.versions.disable",
    "secretmanager.versions.enable",
    "secretmanager.versions.list",
    "iam.serviceAccounts.getAccessToken"
  ]
}

resource "google_project_iam_member" "console_secret_manager" {
  project = var.host_project_id
  role    = google_project_iam_custom_role.console_secret_manager.id
  member  = "serviceAccount:${google_service_account.console.email}"
}

resource "google_service_account" "connectors" {
  account_id                   = "redpanda-connectors${local.postfix}"
  display_name                 = "Redpanda Connectors Service Account"
  project                      = var.host_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "connectors_custom_role" {
  role_id = replace("redpanda_connectors_role${local.postfix}", "-", "_")
  project = var.host_project_id
  title   = "Redpanda Connectors Custom Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.versions.access",
  ]
}

resource "google_project_iam_member" "connectors_secret_manager" {
  project = var.host_project_id
  role    = google_project_iam_custom_role.connectors_custom_role.id
  member  = "serviceAccount:${google_service_account.connectors.email}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account_iam_member" "gke_cert_workload_identity" {
  service_account_id = "projects/${var.host_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.host_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.host_project_id}.svc.id.goog[cert-manager/cert-manager]"
}

resource "google_service_account_iam_member" "gke_dns_workload_identity" {
  service_account_id = "projects/${var.host_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.host_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.host_project_id}.svc.id.goog[external-dns/external-dns]"
}

resource "google_service_account_iam_member" "redpanda_cluster_service_account_binding" {
  service_account_id = "projects/${var.host_project_id}/serviceAccounts/${google_service_account.redpanda_cluster.account_id}@${var.host_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.host_project_id}.svc.id.goog[redpanda/rp-${google_service_account.redpanda_cluster.account_id}]"
}

resource "google_service_account_iam_member" "console_service_account_binding" {
  service_account_id = "projects/${var.host_project_id}/serviceAccounts/${google_service_account.console.account_id}@${var.host_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.host_project_id}.svc.id.goog[redpanda/console-${google_service_account.console.account_id}]"
}

resource "google_service_account_iam_member" "connectors_workload_identity" {
  service_account_id = "projects/${var.host_project_id}/serviceAccounts/${google_service_account.connectors.account_id}@${var.host_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.host_project_id}.svc.id.goog[redpanda-connectors/connectors-${google_service_account.connectors.account_id}]"
}

resource "google_service_account_iam_member" "psc_controller_workload_identity" {
  count              = var.enable_private_link ? 1 : 0
  service_account_id = "projects/${var.host_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.host_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.host_project_id}.svc.id.goog[redpanda-psc/psc-controller]"
}

resource "google_project_iam_custom_role" "rpk_user_role" {
  count       = local.create_shared_vpc ? 1 : 0
  role_id     = replace("rpk_user_role${local.postfix}", "-", "_")
  title       = "RPK User Role"
  description = "A role granting permissions to the our simulated customer who is running rpk as themselves"
  permissions = [
    "resourcemanager.projects.get",
    "compute.subnetworks.get",
    "compute.subnetworks.getIamPolicy",
    "compute.networks.getRegionEffectiveFirewalls",
    "resourcemanager.projects.getIamPolicy",
    "iam.roles.get",
    "compute.subnetworks.list",
    "compute.subnetworks.use",
  ]
}
