locals {
  basic_agent_permissions = [
    "compute.firewalls.get",
    "compute.subnetworks.get",
    "resourcemanager.projects.get",
    "compute.networks.getRegionEffectiveFirewalls",
    "compute.networks.getEffectiveFirewalls",
    "compute.subnetworks.getIamPolicy", # required for validation/drift-detection
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

resource "google_project_iam_custom_role" "redpanda_agent" {
  count       = local.create_shared_vpc ? 1 : 0
  role_id     = replace("redpanda_agent_role${local.postfix}", "-", "_")
  title       = "Redpanda Agent Role"
  description = "A role granting the redpanda agent permissions to view network resources in the project of the vpc."
  permissions = local.agent_permissions
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
