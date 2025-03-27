resource "google_compute_firewall" "redpanda_ingress_allow_redpanda" {
  name        = "redpanda-ingress${local.postfix}"
  description = "Allow access to Redpanda cluster"
  network     = var.network_vpc_name
  project     = var.network_project_id

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

resource "google_compute_firewall" "redpanda_ingress_allow_psc" {
  count       = var.enable_private_link ? 1 : 0
  name        = "redpanda-ingress${local.postfix}-psc"
  description = "Allow access to Redpanda cluster"
  network     = var.network_vpc_name
  project     = var.network_project_id

  allow {
    protocol = "tcp"
    ports = compact(
      concat(
        # Open all the possible ports for PSC for supporting two tier migrations.
        [format("%d-%d", var.psc_config.kafka_api_base_node_port, var.psc_config.kafka_api_base_node_port + var.max_redpanda_node_count - 1)],
        [format("%d-%d", var.psc_config.redpanda_proxy_base_node_port, var.psc_config.redpanda_proxy_base_node_port + var.max_redpanda_node_count - 1)],
        [format("%d-%d", var.psc_config.kafka_api_base_node_port + var.psc_config.port_offset, var.psc_config.kafka_api_base_node_port + var.psc_config.port_offset + var.max_redpanda_node_count - 1)],
        [format("%d-%d", var.psc_config.redpanda_proxy_base_node_port + var.psc_config.port_offset, var.psc_config.redpanda_proxy_base_node_port + var.psc_config.port_offset + var.max_redpanda_node_count - 1)],
        [format("%d-%d", var.psc_config.kafka_api_base_node_port + var.psc_config.port_offset * 2, var.psc_config.kafka_api_base_node_port + var.psc_config.port_offset * 2 + var.max_redpanda_node_count - 1)],
        [format("%d-%d", var.psc_config.redpanda_proxy_base_node_port + var.psc_config.port_offset * 2, var.psc_config.redpanda_proxy_base_node_port + var.psc_config.port_offset * 2 + var.max_redpanda_node_count - 1)],
        [
          tostring(var.psc_config.kafka_api_seed_node_port),
          tostring(var.psc_config.redpanda_proxy_seed_node_port),
          tostring(var.psc_config.schema_registry_seed_node_port),
          tostring(var.psc_config.console_seed_node_port),
        ],
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
  project     = var.network_project_id
  network     = var.network_vpc_name
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
