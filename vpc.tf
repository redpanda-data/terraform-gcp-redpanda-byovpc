resource "google_compute_network" "redpanda" {
  name                            = "redpanda-network${local.postfix}"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  routing_mode                    = "GLOBAL"
  depends_on = [
    google_project_service.compute_api
  ]
  project = var.service_project_id
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
  project = var.service_project_id
}

resource "google_compute_router" "nat" {
  name    = "redpanda-router${local.postfix}"
  network = google_compute_network.redpanda.name
  region  = var.region
  depends_on = [
    google_compute_network.redpanda,
    google_project_service.compute_api
  ]
  project = var.service_project_id
}

resource "google_compute_address" "nat" {
  name         = "redpanda-address${local.postfix}"
  region       = var.region
  network_tier = "PREMIUM"
  depends_on = [
    google_project_service.compute_api
  ]
  project = var.service_project_id
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
    google_compute_address.nat,
    google_project_service.compute_api
  ]
  project = var.service_project_id
}
