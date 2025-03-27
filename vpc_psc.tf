
# This resource isn't required for all BYOVPC deployments.
# It's only here to make testing Private Link on BYOVPC clusters a little bit easier.
resource "google_compute_subnetwork" "psc_nat" {
  count         = var.enable_private_link ? 1 : 0
  name          = "redpanda-psc-nat-subnetwork${local.postfix}"
  region        = var.region
  ip_cidr_range = var.psc_nat_subnet_ipv4_range
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = google_compute_network.redpanda.id
  project       = var.network_project_id
}

data "google_iam_policy" "nat_subnet_iam" {
  count = local.using_shared_vpc && var.enable_private_link ? 1 : 0
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
  count       = local.using_shared_vpc && var.enable_private_link ? 1 : 0
  project     = google_compute_subnetwork.psc_nat[0].project
  region      = google_compute_subnetwork.psc_nat[0].region
  subnetwork  = google_compute_subnetwork.psc_nat[0].name
  policy_data = data.google_iam_policy.nat_subnet_iam[0].policy_data
}
