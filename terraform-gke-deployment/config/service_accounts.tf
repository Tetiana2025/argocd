
## CERT-MANAGER ##
# Create the namespace for cert-manager if it doesn't already exist
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Create a service account for cert-manager in Google Cloud
resource "google_service_account" "cert_manager" {
  account_id   = "cert-manager-sa"
  display_name = "Cert Manager Service Account"
}

# Assign DNS Admin role to the Google Cloud service account
resource "google_project_iam_member" "cert_manager_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager.email}"
}

# Create Kubernetes service account in the GKE cluster for cert-manager
resource "kubernetes_service_account" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.cert_manager.email}"
    }
  }
}

# Bind the Kubernetes service account to the Google Cloud service account using Workload Identity
resource "google_service_account_iam_member" "cert_manager_binding" {
  service_account_id = google_service_account.cert_manager.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"
}


## EXTERNAL DNS ##

# Create the namespace for external-dns if it doesn't already exist
resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

# Create a service account for External DNS in Google Cloud
resource "google_service_account" "external_dns" {
  account_id   = "external-dns-sa"
  display_name = "External DNS Service Account"
}

# Assign DNS Admin role to the Google Cloud service account
resource "google_project_iam_member" "external_dns_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

# Create Kubernetes service account in the GKE cluster
resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.external_dns.email}"
    }
  }
}

# Bind the Kubernetes service account to the Google Cloud service account using Workload Identity
resource "google_service_account_iam_member" "external_dns_binding" {
  service_account_id = google_service_account.external_dns.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"
}

