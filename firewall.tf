resource "google_compute_firewall" "redpanda_ingress_allow_redpanda" {
  name        = "redpanda-ingress${local.postfix}"
  description = "Allow access to Redpanda cluster"
  network     = google_compute_network.redpanda.name
  project     = var.project_id

  allow {
    protocol = "tcp"
    ports = compact(
      concat(
        ["9092-9094"],
        [
          "30081",
          "30082",
        ],
        ["30092"],
      )
    )
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/10"]
  target_tags   = ["redpanda-node"]
  direction     = "INGRESS"
}


resource "google_compute_firewall" "master_webhooks" {
  name        = "gke-rp-cluster-webhooks${local.postfix}"
  description = "Managed by terraform gke module: Allow master to hit pods for admission controllers/webhooks"
  project     = var.project_id
  network     = google_compute_network.redpanda.name
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = [
    var.gke_master_ipv4_cidr_block,
  ]
  source_tags = []
  target_tags = []

  allow {
    protocol = "tcp"
    ports = [
      "9443",
      "8443",
      "6443",
    ]
  }
}
