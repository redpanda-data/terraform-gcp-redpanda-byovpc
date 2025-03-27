locals {
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
