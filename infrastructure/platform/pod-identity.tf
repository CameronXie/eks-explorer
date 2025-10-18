module "aws_vpc_cni_ipv4_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${local.project_identifier}-vpc-cni"

  # Attach AWS VPC CNI policy
  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true

  # Associate with EKS cluster
  associations = {
    default = {
      cluster_name = module.eks.cluster_name
    }
  }

  # Service account configuration
  association_defaults = {
    namespace       = local.kube_system_namespace
    service_account = "aws-node"
  }

  tags = local.pod_identity_tags
}

module "aws_ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${local.project_identifier}-ebs-csi"

  # Attach AWS EBS CSI policy
  attach_aws_ebs_csi_policy = true

  # Associate with EKS cluster
  associations = {
    default = {
      cluster_name = module.eks.cluster_name
    }
  }

  # Service account configuration
  association_defaults = {
    namespace       = local.kube_system_namespace
    service_account = "ebs-csi-controller-sa"
  }

  tags = local.pod_identity_tags
}

module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${local.project_identifier}-aws-lbc"

  # Attach AWS Load Balancer Controller policy
  attach_aws_lb_controller_policy = true

  # Associate with EKS cluster
  associations = {
    default = {
      cluster_name = module.eks.cluster_name
    }
  }

  # Service account configuration
  association_defaults = {
    namespace       = local.kube_system_namespace
    service_account = "aws-load-balancer-controller-sa"
  }

  tags = local.pod_identity_tags
}