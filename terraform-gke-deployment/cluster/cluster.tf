# /cluster/cluster.tf

module "gke" {
  source              = "terraform-google-modules/kubernetes-engine/google"
  version             = "33.0.2"
  project_id          = var.project_id
  name                = var.gke_cluster_name
  region              = var.region
  zones               = ["us-central1-a"]
  network             = module.vpc.network_name
  subnetwork          = module.vpc.subnets_names[0]
  kubernetes_version  = var.gke_cluster_version
  deletion_protection = false

  remove_default_node_pool = true # Prevent GKE from creating the default node pool
  initial_node_count       = 3    # Required when `remove_default_node_pool` is true

  node_pools = [
    {
      name         = "default-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 3
      preemptible  = true
      disk_size_gb = 20
    },
    {
      name         = "secondary-pool"
      machine_type = "e2-standard-2" # Machine type for the second node pool
      min_count    = 2               # At least 2 nodes in the second node pool
      max_count    = 4               # Optionally, set max count to scale if needed
      preemptible  = false           # Non-preemptible nodes for the second node pool
      disk_size_gb = 50              # Larger disk size for the secondary node pool
    },
  ]

  ip_range_pods     = "pods-range"
  ip_range_services = "services-range"

  depends_on = [module.vpc]
}

output "gke_cluster_name" {
  value = module.gke.name
}

output "connect_to_cluster" {
  description = "Command to connect to the GKE cluster"
  value       = "Run the following command to connect to the cluster: gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${var.project_id}"
}
