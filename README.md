## Redpanda Cloud Terraform BYOVPC on GCP Module

This module generates the infrastructure required to support deployment of a Redpanda Cloud cluster in a Bring Your Own VPC (BYOVPC) configuration on Google Cloud Platform (GCP).

Please see the documentation here for more information: https://docs.redpanda.com/redpanda-cloud/get-started/cluster-types/byoc/gcp/vpc-byo-gcp/

### Usage

```hcl
module "redpanda" {
  source = "github.com/redpanda-data/terraform-gcp-redpanda-byovpc"

  host_project_id                        = "host-project-id"
  service_project_id                     = "service-project-id"
  region                                 = "us-central1"
  management_storage_bucket_name         = "redpanda-mgmt"
  tiered_storage_bucket_name             = "redpanda-tiered-storage"
  shared_vpc_name                        = "redpanda-vpc"
  primary_subnet_name                    = "redpanda-subnet"
  secondary_ipv4_range_name_for_pods     = "redpanda-pods"
  secondary_ipv4_range_name_for_services = "redpanda-services"
  router_name                            = "redpanda-router"
  nat_config_name                        = "redpanda-nat-config"
  address_name                           = "redpanda-nat-ip"
  gke_master_cidr_range                  = "172.16.0.0/28"
}
```

