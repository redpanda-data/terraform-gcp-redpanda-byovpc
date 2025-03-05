resource "google_project_service" "service_project_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "storage-api.googleapis.com",
    "container.googleapis.com",
    "serviceusage.googleapis.com"
  ])

  project = var.service_project_id
  service = each.key

  disable_on_destroy = false
}

resource "google_compute_subnetwork" "primary_subnet" {
  name          = var.primary_subnet_name
  project       = var.host_project_id
  network       = var.shared_vpc_name
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region

  secondary_ip_range {
    range_name    = var.secondary_ipv4_range_name_for_pods
    ip_cidr_range = "10.0.8.0/21"
  }

  secondary_ip_range {
    range_name    = var.secondary_ipv4_range_name_for_services
    ip_cidr_range = "10.0.1.0/24"
  }
}

resource "google_compute_router" "router" {
  name    = var.router_name
  project = var.host_project_id
  region  = var.region
  network = var.shared_vpc_name
}

resource "google_compute_address" "nat_ip" {
  name    = var.address_name
  project = var.host_project_id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_config_name
  project                            = var.host_project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_endpoint_independent_mapping = true
}

resource "google_compute_firewall" "redpanda_ingress" {
  name        = "redpanda-ingress"
  project     = var.host_project_id
  network     = var.shared_vpc_name
  description = "Allow access to Redpanda cluster"
  direction   = "INGRESS"

  target_tags = ["redpanda-node"]
  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "100.64.0.0/10"
  ]

  allow {
    protocol = "tcp"
    ports    = ["9092-9094", "30081", "30082", "30092"]
  }
}

resource "google_compute_firewall" "gke_webhooks" {
  name        = "gke-redpanda-cluster-webhooks"
  project     = var.host_project_id
  network     = var.shared_vpc_name
  description = "Allow master to hit pods for admission controllers/webhooks"
  direction   = "INGRESS"

  source_ranges = [var.gke_master_cidr_range]

  allow {
    protocol = "tcp"
    ports    = ["9443", "8443", "6443"]
  }
}

resource "google_storage_bucket" "tiered_storage" {
  name          = var.tiered_storage_bucket_name
  location      = var.region
  project       = var.service_project_id
  force_destroy = false

  uniform_bucket_level_access = true

  depends_on = [google_project_service.service_project_apis]
}

resource "google_storage_bucket" "management_storage" {
  name          = var.management_storage_bucket_name
  location      = var.region
  project       = var.service_project_id
  force_destroy = false

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  depends_on = [google_project_service.service_project_apis]
}