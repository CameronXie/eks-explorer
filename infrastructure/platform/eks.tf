module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Cluster configuration
  name                   = local.project_identifier
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets
  endpoint_public_access = true

  # IAM configuration
  enable_cluster_creator_admin_permissions = true

  # CloudWatch logging
  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
  cloudwatch_log_group_retention_in_days = 30

  # EKS add-ons
  addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }

    coredns = {
      most_recent = true
    }

    eks-pod-identity-agent = {
      before_compute = true
      most_recent    = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  eks_managed_node_groups = {
    default = {
      aim_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types

      min_size     = 1
      max_size     = 5
      desired_size = 4

      update_config = {
        max_unavailable_percentage = 33
      }
    }
  }

  # Cluster upgrade policy
  upgrade_policy = {
    support_type = "STANDARD"
  }

  tags = local.eks_tags
}

# Create gp3 storage class and set as default
resource "kubernetes_storage_class" "gp3_storage_class" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  allow_volume_expansion = true
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type = "gp3"
  }
}