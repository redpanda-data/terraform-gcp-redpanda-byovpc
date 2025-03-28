locals {
  create_psc_subnetwork = local.create_vpc && var.enable_private_link
}

# This resource isn't required for all BYOVPC deployments.
# It's only here to make testing Private Link on BYOVPC clusters a little bit easier.
resource "google_compute_subnetwork" "psc_nat" {
  count         = local.create_psc_subnetwork ? 1 : 0
  name          = "redpanda-psc-nat-subnetwork${local.postfix}"
  region        = var.region
  ip_cidr_range = var.psc_nat_subnet_ipv4_range
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = data.google_compute_network.redpanda.id
  project       = var.network_project_id
}

data "google_compute_subnetwork" "psc_nat" {
  name    = local.create_psc_subnetwork ? google_compute_subnetwork.psc_nat[0].name : var.psc_subnet_name
  region  = var.region
  project = var.network_project_id
}

data "google_iam_policy" "nat_subnet_iam" {
  count = local.is_shared_vpc && var.enable_private_link ? 1 : 0
  binding {
    role = "roles/compute.networkUser"
    members = [
      # without this permission the Service Attachment cannot be created as it lives in the host project subnet
      "serviceAccount:${data.google_project.service_project[0].number}@cloudservices.gserviceaccount.com",
    ]
  }
}

# Required so the service attachment can use the PSC NAT subnet, which exists in the HOST project.
resource "google_compute_subnetwork_iam_policy" "nat_subnet_policy" {
  count       = local.is_shared_vpc && var.enable_private_link ? 1 : 0
  project     = data.google_compute_subnetwork.psc_nat.project
  region      = data.google_compute_subnetwork.psc_nat.region
  subnetwork  = data.google_compute_subnetwork.psc_nat.name
  policy_data = data.google_iam_policy.nat_subnet_iam[0].policy_data
}
