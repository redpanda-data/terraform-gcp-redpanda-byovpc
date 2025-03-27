locals {
  using_shared_vpc = (var.service_project_id != var.network_project_id)
  basic_agent_permissions = [
    "compute.firewalls.get",
    "compute.globalOperations.get",
    "compute.disks.get",       # required for applying custom labels via go code
    "compute.disks.list",      # required for applying custom labels via go code
    "compute.disks.setLabels", # required for applying custom labels via go code
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.delete",
    "compute.instanceGroupManagers.update",
    "compute.instanceGroups.delete",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.setLabels", # required for applying custom labels via go code
    "compute.instanceTemplates.delete",
    "compute.networks.getRegionEffectiveFirewalls",
    "compute.networks.getEffectiveFirewalls",
    "compute.projects.get",
    "compute.subnetworks.get",
    "compute.subnetworks.getIamPolicy", # required for validation/drift-detection
    "compute.zoneOperations.get",
    "compute.zoneOperations.list", # required for detection/details of quota/stockout errors
    "compute.zones.get",
    "compute.zones.list",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.create",
    "dns.managedZones.delete",
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.managedZones.update",
    "dns.projects.get",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "iam.roles.get",
    "iam.roles.list",
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "serviceusage.services.list",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
  ]
  psc_agent_permissions = [
    "compute.subnetworks.use",
    "compute.instances.use",
    "compute.networks.use",
    "compute.regionOperations.get",
    "compute.serviceAttachments.create",
    "compute.serviceAttachments.delete",
    "compute.serviceAttachments.get",
    "compute.serviceAttachments.list",
    "compute.serviceAttachments.update",
    "compute.forwardingRules.use",
    "compute.forwardingRules.create",
    "compute.forwardingRules.delete",
    "compute.forwardingRules.get",
    "compute.forwardingRules.setLabels",
    "compute.forwardingRules.setTarget",
    "compute.forwardingRules.pscCreate",
    "compute.forwardingRules.pscDelete",
    "compute.forwardingRules.pscSetLabels",
    "compute.forwardingRules.pscSetTarget",
    "compute.forwardingRules.pscUpdate",
    "compute.regionBackendServices.create",
    "compute.regionBackendServices.delete",
    "compute.regionBackendServices.get",
    "compute.regionBackendServices.use",
    "compute.regionNetworkEndpointGroups.create",
    "compute.regionNetworkEndpointGroups.delete",
    "compute.regionNetworkEndpointGroups.get",
    "compute.regionNetworkEndpointGroups.use",
    "compute.regionNetworkEndpointGroups.attachNetworkEndpoints",
    "compute.regionNetworkEndpointGroups.detachNetworkEndpoints",
  ]
  agent_permissions = var.enable_private_link ? concat(local.basic_agent_permissions, local.psc_agent_permissions) : local.basic_agent_permissions

  postfix = var.unique_identifier != "" ? "-${var.unique_identifier}" : ""
}

resource "google_service_account" "redpanda_agent" {
  project                      = var.service_project_id
  account_id                   = "redpanda-agent${local.postfix}"
  display_name                 = "Redpanda Agent Service Account"
  description                  = "Redpanda Agent Service Account"
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_agent" {
  project     = var.service_project_id
  role_id     = replace("redpanda_agent_role${local.postfix}", "-", "_")
  title       = "Redpanda Agent Role"
  description = "A role comprising general permissions allowing the agent to manage Redpanda cluster resources."
  permissions = local.agent_permissions
}

resource "google_project_iam_member" "redpanda_agent_custom_role" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_agent.id
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_project_iam_member" "redpanda_agent_container_admin" {
  project = var.service_project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
}

resource "google_storage_bucket_iam_member" "redpanda_agent_storage_object_admin" {
  bucket  = google_storage_bucket.management_bucket.name
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
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
  project                      = var.service_project_id
  account_id                   = "redpanda-cluster${local.postfix}"
  display_name                 = "Redpanda Cluster Service Account"
  create_ignore_already_exists = true
}

resource "google_storage_bucket_iam_member" "redpanda_cluster_cloud_storage_admin" {
  bucket  = google_storage_bucket.redpanda_cloud_storage.name
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.redpanda_cluster.email}"
}

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

resource "google_service_account" "console" {
  account_id                   = "redpanda-console${local.postfix}"
  display_name                 = "Redpanda Console Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "console_secret_manager" {
  role_id = replace("redpanda_console_secret_manager_role${local.postfix}", "-", "_")
  project = var.service_project_id
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
  project = var.service_project_id
  role    = google_project_iam_custom_role.console_secret_manager.id
  member  = "serviceAccount:${google_service_account.console.email}"
}

resource "google_service_account" "redpanda_connect_api" {
  account_id                   = "redpanda-connect-api${local.postfix}"
  display_name                 = "Redpanda Connect API Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_connect_api_custom_role" {
  role_id = replace("redpanda_redpanda_connect_api_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Connect API Role"
  permissions = [
    "secretmanager.secrets.get"
  ]
}

resource "google_project_iam_member" "redpanda_connect_api" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_connect_api_custom_role.id
  member  = "serviceAccount:${google_service_account.redpanda_connect_api.email}"
}

resource "google_service_account" "connectors" {
  account_id                   = "redpanda-connectors${local.postfix}"
  display_name                 = "Redpanda Connectors Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "connectors_custom_role" {
  role_id = replace("redpanda_connectors_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Connectors Custom Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.versions.access",
  ]
}

resource "google_project_iam_member" "connectors_secret_manager" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.connectors_custom_role.id
  member  = "serviceAccount:${google_service_account.connectors.email}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account" "redpanda_connect" {
  account_id                   = "redpanda-connect${local.postfix}"
  display_name                 = "Redpanda Connect Service Account"
  project                      = var.service_project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_custom_role" "redpanda_connect_custom_role" {
  role_id = replace("redpanda_connect_role${local.postfix}", "-", "_")
  project = var.service_project_id
  title   = "Redpanda Connect Role"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.versions.access",
  ]
}

resource "google_project_iam_member" "redpanda_connect" {
  project = var.service_project_id
  role    = google_project_iam_custom_role.redpanda_connect_custom_role.id
  member  = "serviceAccount:${google_service_account.redpanda_connect.email}"
  lifecycle {
    create_before_destroy = true
  }
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

resource "google_service_account_iam_member" "redpanda_cluster_service_account_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_cluster.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda/rp-${google_service_account.redpanda_cluster.account_id}]"
}

resource "google_service_account_iam_member" "console_service_account_binding" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.console.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda/console-${google_service_account.console.account_id}]"
}

resource "google_service_account_iam_member" "redpanda_connect_api_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_connect_api.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-connect/${google_service_account.redpanda_connect_api.account_id}]"
}

resource "google_service_account_iam_member" "connectors_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.connectors.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-connectors/connectors-${google_service_account.connectors.account_id}]"
}

resource "google_service_account_iam_member" "redpanda_connect_workload_identity" {
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_connect.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-connect/${google_service_account.redpanda_connect.account_id}]"
}

resource "google_service_account_iam_member" "psc_controller_workload_identity" {
  count              = var.enable_private_link ? 1 : 0
  service_account_id = "projects/${var.service_project_id}/serviceAccounts/${google_service_account.redpanda_gke.account_id}@${var.service_project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.service_project_id}.svc.id.goog[redpanda-psc/psc-controller]"
}
