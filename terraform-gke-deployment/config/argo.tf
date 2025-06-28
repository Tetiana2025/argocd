resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"

  create_namespace = true

  values = [
    <<EOF
    server:
      service:
        type: LoadBalancer
        annotations:
          external-dns.alpha.kubernetes.io/hostname: "argocd.${var.domain}"
    EOF
  ]
}

# Create a Secret for GitHub credentials
resource "kubernetes_secret" "argocd_repo_creds" {
  metadata {
    name      = "argocd-repo-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    username = var.github_username
    password = var.github_token
    url      = var.github_repo_url
 }
}

# Define the template file with the bootstrap.yaml content
data "template_file" "bootstrap" {
  template = templatefile("${path.module}/template/bootstrap.yaml", {
    github_repo_url     = var.github_repo_url,
    project_id          = var.project_id,
    hostedzone_name     = var.hostedzone_name,
    domain              = var.domain,
    letsencrypt_email   = var.letsencrypt_email
  })
}

# Apply the Kubernetes manifest using the generated YAML
resource "kubernetes_manifest" "all_apps" {
  depends_on = [helm_release.argo_cd]

  manifest = yamldecode(data.template_file.bootstrap.rendered)
}
