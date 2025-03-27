resource "google_compute_shared_vpc_host_project" "host" {
  count   = local.using_shared_vpc && var.attach_shared_vpc ? 1 : 0
  project = var.network_project_id
}

resource "google_compute_shared_vpc_service_project" "service_project" {
  count           = local.using_shared_vpc && var.attach_shared_vpc ? 1 : 0
  host_project    = google_compute_shared_vpc_host_project.host[0].project
  service_project = var.service_project_id
}

resource "google_compute_network" "redpanda" {
  name                            = "redpanda-network${local.postfix}"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  routing_mode                    = "GLOBAL"
  depends_on                      = [google_project_service.network_project_compute_api]
  project                         = var.network_project_id
}

resource "google_compute_subnetwork" "redpanda" {
  name                     = "redpanda-subnetwork${local.postfix}"
  network                  = google_compute_network.redpanda.id
  region                   = var.region
  ip_cidr_range            = "10.0.0.0/24"
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"
  secondary_ip_range {
    ip_cidr_range = "10.0.8.0/21"
    range_name    = "redpanda-pods"
  }
  secondary_ip_range {
    ip_cidr_range = "10.0.1.0/24"
    range_name    = "redpanda-services"
  }
  depends_on = [
    google_compute_network.redpanda
  ]
  project = var.network_project_id
}

resource "google_compute_router" "nat" {
  name    = "redpanda-router${local.postfix}"
  network = google_compute_network.redpanda.name
  region  = var.region
  depends_on = [
    google_compute_network.redpanda
  ]
  project = var.network_project_id
}

resource "google_compute_address" "nat" {
  name         = "redpanda-address${local.postfix}"
  region       = var.region
  network_tier = "PREMIUM"
  depends_on   = [google_project_service.network_project_compute_api]
  project      = var.network_project_id
}

resource "google_compute_router_nat" "redpanda" {
  name                               = "redpanda-nat"
  region                             = var.region
  router                             = google_compute_router.nat.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on = [
    google_compute_router.nat,
    google_compute_address.nat
  ]
  project = var.network_project_id
}

# The following attaches the required permissions to the GKE service account and Google API service account of the
# SERVICE PROJECT in the HOST PROJECT
# This is a good document showing these steps: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc

data "google_project" "service_project" {
  count      = local.using_shared_vpc ? 1 : 0
  project_id = var.service_project_id
}

data "google_iam_policy" "subnetwork_iam" {
  count = local.using_shared_vpc ? 1 : 0
  binding {
    role = "roles/compute.networkUser"
    members = [
      # without this permission the agent VM cannot be created as it lives in the host project subnet
      "serviceAccount:${data.google_project.service_project[0].number}@cloudservices.gserviceaccount.com",
      # without this permission gcp-redpanda-infra provisioner will be unable to create the k8s cluster
      "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com",
    ]
  }
}

# without this permission the gcp-redpanda-infra provisioner will be unable to create the k8s cluster (because the k8s
# cluster specifies that it belongs to this shared network, it needs to be able to 'use' that network)
resource "google_project_iam_binding" "gke_hostagent_iam" {
  count   = local.using_shared_vpc && var.attach_shared_vpc ? 1 : 0
  project = var.network_project_id
  role    = "roles/container.hostServiceAgentUser"
  members = [
    "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com",
  ]
  lifecycle {
    create_before_destroy = true
  }
}

# without this permission, the CreateCluster will succeeded, but not all of the required firewalls will be created
resource "google_project_iam_binding" "gke_firewall_iam" {
  count   = local.using_shared_vpc && var.attach_shared_vpc ? 1 : 0
  project = var.network_project_id
  role    = "roles/compute.securityAdmin"
  members = [
    "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com",
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_subnetwork_iam_policy" "policy" {
  count       = local.using_shared_vpc ? 1 : 0
  project     = google_compute_subnetwork.redpanda.project
  region      = google_compute_subnetwork.redpanda.region
  subnetwork  = google_compute_subnetwork.redpanda.name
  policy_data = data.google_iam_policy.subnetwork_iam[0].policy_data
}
