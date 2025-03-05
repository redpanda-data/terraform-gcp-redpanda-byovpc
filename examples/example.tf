provider "google" {
  project = "hallowed-ray-376320"
  region  = "us-central1"
}

variable "project_id" {
  description = "The ID of the project"
  type        = string
  default     = "hallowed-ray-376320"
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "us-central1"
}

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com",
    "iam.googleapis.com",
    "dns.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

# Create a VPC network
resource "google_compute_network" "vpc" {
  name                    = "redpanda-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "redpanda-subnet"
  project       = var.project_id
  network       = google_compute_network.vpc.self_link
  region        = var.region
  ip_cidr_range = "10.0.0.0/24"

  # Secondary ranges for GKE
  secondary_ip_range {
    range_name    = "redpanda-pods"
    ip_cidr_range = "10.0.8.0/21"
  }

  secondary_ip_range {
    range_name    = "redpanda-services"
    ip_cidr_range = "10.0.1.0/24"
  }
}

# Create a router for NAT
resource "google_compute_router" "router" {
  name    = "redpanda-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.self_link
}

# Create NAT IP address
resource "google_compute_address" "nat_ip" {
  name    = "redpanda-nat-ip"
  project = var.project_id
  region  = var.region
}

# Create firewall rules
resource "google_compute_firewall" "redpanda_ingress" {
  name        = "redpanda-ingress"
  project     = var.project_id
  network     = google_compute_network.vpc.self_link
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
  project     = var.project_id
  network     = google_compute_network.vpc.self_link
  description = "Allow master to hit pods for admission controllers/webhooks"
  direction   = "INGRESS"

  source_ranges = ["172.16.0.0/28"] # GKE master CIDR

  allow {
    protocol = "tcp"
    ports    = ["9443", "8443", "6443"]
  }
}

# Create storage buckets
resource "google_storage_bucket" "tiered_storage" {
  name          = "redpanda-tiered-storage-${var.project_id}"
  location      = var.region
  project       = var.project_id
  force_destroy = false
  uniform_bucket_level_access = true
  depends_on    = [google_project_service.apis]
}

resource "google_storage_bucket" "management_storage" {
  name          = "redpanda-mgmt-${var.project_id}"
  location      = var.region
  project       = var.project_id
  force_destroy = false
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  depends_on    = [google_project_service.apis]
}

module "redpanda" {
  source = "../"

  host_project_id                        = var.project_id
  service_project_id                     = var.project_id
  region                                 = var.region
  management_storage_bucket_name         = google_storage_bucket.management_storage.name
  tiered_storage_bucket_name             = google_storage_bucket.tiered_storage.name
  shared_vpc_name                        = google_compute_network.vpc.name
  primary_subnet_name                    = google_compute_subnetwork.subnet.name
  secondary_ipv4_range_name_for_pods     = "redpanda-pods"
  secondary_ipv4_range_name_for_services = "redpanda-services"
  router_name                            = google_compute_router.router.name
  nat_config_name                        = "redpanda-nat-config"
  address_name                           = "redpanda-nat-ip"
  gke_master_cidr_range                  = "172.16.0.0/28"
}