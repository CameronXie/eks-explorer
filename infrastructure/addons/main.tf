# ArgoCD Helm release - Bootstrap GitOps
resource "helm_release" "argocd" {
  count = var.enable_argocd ? 1 : 0

  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  create_namespace = true
  wait             = true
  atomic           = true
  cleanup_on_fail  = true
  force_update     = false

  # Use ArgoCD values from bootstrap/addons/argo-cd chart
  values = [yamlencode(local.argocd_helm_values)]

  lifecycle {
    ignore_changes = all
  }
}

# Loki
module "loki" {
  count  = var.enable_loki ? 1 : 0
  source = "./modules/loki"

  environment     = var.environment
  project_name    = var.project_name
  cluster_name    = data.aws_ssm_parameter.cluster_name.value
  namespace       = local.observability_namespace
  service_account = "loki-sa"

  tags = merge(local.observability_tags, {
    Component = "loki"
  })
}

# Mimir
module "mimir" {
  count  = var.enable_mimir ? 1 : 0
  source = "./modules/mimir-distributed"

  environment     = var.environment
  project_name    = var.project_name
  cluster_name    = data.aws_ssm_parameter.cluster_name.value
  namespace       = local.observability_namespace
  service_account = "mimir-sa"

  tags = merge(local.observability_tags, {
    Component = "mimir"
  })
}

# Tempo
module "tempo" {
  count  = var.enable_tempo ? 1 : 0
  source = "./modules/tempo-distributed"

  environment     = var.environment
  project_name    = var.project_name
  cluster_name    = data.aws_ssm_parameter.cluster_name.value
  namespace       = local.observability_namespace
  service_account = "tempo-sa"

  tags = merge(local.observability_tags, {
    Component = "tempo"
  })
}
