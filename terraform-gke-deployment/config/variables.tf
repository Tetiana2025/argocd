# /config/variable.tf
variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt"
  type        = string
}

variable "domain" {
  description = "Domain for external DNS and certificates"
  type        = string
}

variable "hostedzone_name" {
  description = "Hosted zone name in Google CloudDNS"
  type        = string
}

variable "github_repo_url" {
  description = "The URL of the private GitHub repository where ArgoCD will deploy applications."
  type        = string
}

variable "github_username" {
  description = "The username for accessing the private GitHub repository."
  type        = string
}

variable "github_token" {
  description = "The token for accessing the private GitHub repository."
  type        = string
  sensitive   = true
}
