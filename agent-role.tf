resource "google_service_account" "redpanda_agent" {
  project      = var.service_project_id
  account_id   = "redpanda-agent"
  display_name = "Redpanda Agent Service Account"
}

resource "google_project_iam_custom_role" "redpanda_agent_role_service" {
  project     = var.service_project_id
  role_id     = "redpanda_agent_role"
  title       = "Redpanda Agent Role"
  description = "A role comprising general permissions allowing the agent to manage Redpanda cluster resources."
  permissions = [
    "compute.firewalls.get",
    "compute.globalOperations.get",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.delete",
    "compute.instanceGroups.delete",
    "compute.instances.list",
    "compute.instanceTemplates.delete",
    "compute.networks.getRegionEffectiveFirewalls",
    "compute.networks.getEffectiveFirewalls",
    "compute.projects.get",
    "compute.subnetworks.get",
    "compute.zoneOperations.get",
    "compute.zoneOperations.list",
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
    "compute.disks.list",
    "compute.disks.setLabels",
    "compute.instanceGroupManagers.update",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.instances.setLabels",
  ]
}

resource "google_project_iam_custom_role" "redpanda_agent_role_host" {
  count       = var.host_project_id != var.service_project_id ? 1 : 0
  project     = var.host_project_id
  role_id     = "redpanda_agent_role"
  title       = "Redpanda Agent Role"
  description = "A role comprising general permissions allowing the agent to manage Redpanda cluster resources."
  permissions = [
    "compute.firewalls.get",
    "compute.globalOperations.get",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.delete",
    "compute.instanceGroups.delete",
    "compute.instances.list",
    "compute.instanceTemplates.delete",
    "compute.networks.getRegionEffectiveFirewalls",
    "compute.networks.getEffectiveFirewalls",
    "compute.projects.get",
    "compute.subnetworks.get",
    "compute.zoneOperations.get",
    "compute.zoneOperations.list",
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
    "compute.disks.list",
    "compute.disks.setLabels",
    "compute.instanceGroupManagers.update",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.instances.setLabels",
  ]
}

resource "google_project_iam_member" "service_project_custom_role" {
  project = var.service_project_id
  role    = "projects/${var.service_project_id}/roles/redpanda_agent_role"
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"

  depends_on = [google_project_iam_custom_role.redpanda_agent_role_service]
}

resource "google_project_iam_member" "service_project_container_admin" {
  project = var.service_project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"
}

resource "google_storage_bucket_iam_member" "management_bucket_access" {
  bucket = var.management_storage_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.redpanda_agent.email}"
}

resource "google_project_iam_member" "host_project_custom_role" {
  count   = var.host_project_id != var.service_project_id ? 1 : 0
  project = var.host_project_id
  role    = "projects/${var.host_project_id}/roles/redpanda_agent_role"
  member  = "serviceAccount:${google_service_account.redpanda_agent.email}"

  depends_on = [google_project_iam_custom_role.redpanda_agent_role_host]
}