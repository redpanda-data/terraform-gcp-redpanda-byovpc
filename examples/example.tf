provider "google" {
  project = var.project_id
  region  = var.region
  credentials = base64decode(var.gcp_creds)
}

variable "gcp_creds" {
    description = "Base64 encoded Google Cloud credentials"
    type        = string
}

# Create a VPC network for our Redpanda cluster
resource "google_compute_network" "redpanda_network" {
  name                    = "redpanda-network"
  auto_create_subnetworks = false
}

# Create a subnet for our Redpanda cluster
resource "google_compute_subnetwork" "redpanda_subnet" {
  name          = "redpanda-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.redpanda_network.id
}

# Module for setting up Redpanda on GCP
module "redpanda_gcp" {
  source = "../"
  project_id        = var.project_id
  region            = var.region
  network_project_id = var.project_id
  network_vpc_name   = google_compute_network.redpanda_network.name
  unique_identifier = var.environment
  enable_private_link = true
  force_destroy_mgmt_bucket = var.environment == "dev" ? true : false
  max_redpanda_node_count = 10
  create_customer_user = true
}
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy resources to"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}