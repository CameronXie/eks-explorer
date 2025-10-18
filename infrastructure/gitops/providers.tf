provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_ssm_parameter.cluster_name.value, "--region", var.region]
    command     = "aws"
  }
}

provider "argocd" {
  port_forward_with_namespace = var.argocd_namespace
  username                    = "admin"
  password                    = data.kubernetes_secret_v1.argocd_initial_admin.data.password
  insecure                    = true

  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
