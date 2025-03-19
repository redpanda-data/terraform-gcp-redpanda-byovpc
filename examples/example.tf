provider "google" {
  project = var.project_id
  region  = "us-central1"
}

variable "project_id" {
  type        = string
  default = "hallowed-ray-376320"
  description = <<-HELP
    The project id
    HELP
}

module "redpanda" {
  source = "../"
  host_project_id = var.project_id

  # Region where resources will be created
  region = "us-central1"

  # Network configuration
  network_vpc_name = "redpanda-test-network"

  # Optional: Add a unique identifier if running multiple instances
  # unique_identifier = "prod"

  # Private Link configuration
  enable_private_link = false

  # Whether to create customer user for rpk
  create_customer_user = true

  # Bucket delete behavior
  force_destroy_mgmt_bucket         = true
  force_destroy_cloud_storage_bucket = true

  # Shared VPC is not needed since everything is in one project
  attach_shared_vpc = false
}
