resource "google_project_iam_custom_role" "test_user_role" {
  role_id     = replace("byovpc_test_user_role${local.postfix}", "-", "_")
  title       = "BYOVPC Test User Role"
  project     = var.service_project_id
  description = <<EOT
  Provided only for documentation and testing purposes. Minimum required permissions when creating a BYOVPC cluster.
  As long as your user has at least these permissions you will be able to successfully run 'rpk byoc apply'.
  EOT
  permissions = [
    // required for pre-requisite validation
    "iam.roles.get",
    "iam.serviceAccounts.get",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "serviceusage.services.list",
    "storage.buckets.getIamPolicy",
    "iam.serviceAccounts.getIamPolicy",

    // required for terraform state management and configuration files saved during agent bootstrap
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",

    // required for lookup/reference in terraform
    "compute.subnetworks.get", // also required for prerequisite-validation
    "storage.buckets.get",     // also required for prerequisite-validation
    "compute.zones.list",

    // required for terraform resource creation
    "compute.instanceTemplates.create",
    "compute.instanceTemplates.get",
    "compute.instances.setLabels",
    "compute.instances.setTags",
    "compute.instances.setMetadata",
    "compute.subnetworks.use",
    "compute.disks.setLabels",
    "compute.disks.create",
    "compute.instances.create",
    "compute.instanceTemplates.useReadOnly",
    "compute.instanceGroupManagers.create",
    "compute.instanceTemplates.delete",
    "compute.instanceGroups.create",
    "compute.instanceGroupManagers.get",
    "iam.serviceAccounts.actAs",
    "compute.instanceGroupManagers.delete",
    "compute.instanceGroups.delete",
  ]
}

resource "google_service_account" "test_user_account" {
  count        = var.create_test_user ? 1 : 0
  account_id   = "byovpc-test-user${local.postfix}"
  display_name = "An account that may be used, for testing purposes, when running rpk to create a cluster."
  project      = var.service_project_id
}

resource "google_project_iam_member" "test_user_role_binding" {
  count   = var.create_test_user ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.test_user_role.id
  member  = "serviceAccount:${google_service_account.test_user_account[0].email}"
}

resource "google_project_iam_custom_role" "network_project_test_user_role" {
  count       = local.using_shared_vpc ? 1 : 0
  role_id     = replace("byovpc_test_user_role${local.postfix}", "-", "_")
  title       = "BYOVPC Test User Role"
  description = <<EOT
  Provided only for documentation and testing purposes. Minimum required permissions when creating a BYOVPC cluster
  using shared VPC. As long as your user has at least these permissions you will be able to successfully run 'rpk byoc apply'.
  EOT
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
  project = var.network_project_id
}

resource "google_project_iam_member" "test_user_shared_vpc_permissions" {
  count   = local.using_shared_vpc && var.create_test_user ? 1 : 0
  project = var.network_project_id
  role    = google_project_iam_custom_role.network_project_test_user_role[0].id
  member  = "serviceAccount:${google_service_account.test_user_account[0].email}"
  lifecycle {
    create_before_destroy = true
  }
}
