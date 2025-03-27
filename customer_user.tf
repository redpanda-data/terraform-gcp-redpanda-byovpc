resource "google_project_iam_custom_role" "customer_user_role" {
  role_id     = replace("byovpc_customer_user_role${local.postfix}", "-", "_")
  title       = "BYOVPC Customer User Role"
  project     = var.service_project_id
  description = <<EOT
  The role that a customer might use when running rpk.
  It has limited access to create things (in particular you cannot create service accounts, storage buckets, enable
  APIs, etc).
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

resource "google_service_account" "customer_user_account" {
  count        = var.create_customer_user ? 1 : 0
  account_id   = "byovpc-customer${local.postfix}"
  display_name = "The account that should be used when creating the agent using rpk"
  project      = var.service_project_id
}

resource "google_project_iam_member" "customer_user_role_binding" {
  count   = var.create_customer_user ? 1 : 0
  project = var.service_project_id
  role    = google_project_iam_custom_role.customer_user_role.id
  member  = "serviceAccount:${google_service_account.customer_user_account[0].email}"
}

resource "google_project_iam_member" "rpk_user_shared_vpc_permissions" {
  count   = local.using_shared_vpc && var.create_customer_user ? 1 : 0
  project = var.network_project_id
  role    = var.rpk_user_custom_role
  member  = "serviceAccount:${google_service_account.customer_user_account[0].email}"
  lifecycle {
    create_before_destroy = true
  }
}
