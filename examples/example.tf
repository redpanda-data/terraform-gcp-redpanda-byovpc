provider "google" {
  project = var.project_id
  region  = var.region
  credentials = base64decode(var.gcp_creds)
}

variable "gcp_creds" {
    description = "Base64 encoded Google Cloud credentials"
    type        = string
}

# Module for setting up Redpanda on GCP
module "redpanda_gcp" {
  source = "../"
  project_id        = var.project_id
  region            = var.region
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