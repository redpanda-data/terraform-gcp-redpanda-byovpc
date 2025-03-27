resource "google_service_account" "redpanda_gke" {
  project                      = var.service_project_id
  account_id                   = "redpanda-gke${local.postfix}"
  display_name                 = "Redpanda GKE cluster default node service account"
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_utility_node" {
  project = var.service_project_id
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
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_utility_node.id
  member  = "serviceAccount:${google_service_account.redpanda_gke.email}"
}

resource "google_service_account_iam_member" "gke_cert_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[cert-manager/cert-manager]"
}

resource "google_service_account_iam_member" "gke_dns_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[external-dns/external-dns]"
}

resource "google_service_account_iam_member" "psc_controller_workload_identity" {
  count              = var.enable_private_link ? 1 : 0
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-psc/psc-controller]"
}
