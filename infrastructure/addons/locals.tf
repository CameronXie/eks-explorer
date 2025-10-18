locals {
  # Stack configuration
  stack_name          = "addons"
  platform_ssm_prefix = "/${var.environment}/${var.project_name}/platform"

  # ArgoCD Helm values
  argocd_values_file = yamldecode(file("${path.module}/../../bootstrap/addons/argo-cd/values.yaml"))
  argocd_helm_values = lookup(local.argocd_values_file, "argo-cd", {})

  # Kubernetes namespaces
  observability_namespace = "observability"

  # Common tags applied to all addons resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Stack       = local.stack_name
    ManagedBy   = "terraform"
  }

  # Observability stack tags
  observability_tags = merge(local.common_tags, {
    Component = "observability"
  })
}

data "aws_ssm_parameter" "cluster_name" {
  name = "${local.platform_ssm_prefix}/eks/cluster-name"
}

data "aws_eks_cluster" "this" {
  name = data.aws_ssm_parameter.cluster_name.value
}
