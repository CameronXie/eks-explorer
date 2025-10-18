locals {
  # Project naming
  project_identifier = "${var.environment}-${var.project_name}"
  stack_name         = "platform"

  # Network configuration
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # Kubernetes configuration
  kube_system_namespace = "kube-system"

  # SSM parameter path prefix
  ssm_prefix = "/${var.environment}/${var.project_name}/${local.stack_name}"

  # Platform infrastructure parameters for SSM
  platform_parameters = {
    # VPC
    "vpc/id"                    = module.vpc.vpc_id
    "vpc/cidr"                  = module.vpc.vpc_cidr_block
    "vpc/dns-hostnames-enabled" = tostring(module.vpc.vpc_enable_dns_hostnames)
    "vpc/dns-support-enabled"   = tostring(module.vpc.vpc_enable_dns_support)

    # Networking
    "networking/private-subnet-ids" = jsonencode(module.vpc.private_subnets)
    "networking/public-subnet-ids"  = jsonencode(module.vpc.public_subnets)
    "networking/availability-zones" = jsonencode(module.vpc.azs)
    "networking/nat-gateway-ids"    = jsonencode(module.vpc.natgw_ids)

    # EKS cluster
    "eks/cluster-name"              = module.eks.cluster_name
    "eks/cluster-endpoint"          = module.eks.cluster_endpoint
    "eks/cluster-version"           = module.eks.cluster_version
    "eks/cluster-ca-certificate"    = module.eks.cluster_certificate_authority_data
    "eks/cluster-arn"               = module.eks.cluster_arn
    "eks/cluster-security-group-id" = module.eks.cluster_security_group_id
    "eks/node-security-group-id"    = module.eks.node_security_group_id

    # Metadata
    "metadata/region"       = var.region
    "metadata/project-name" = var.project_name
    "metadata/environment"  = var.environment
  }

  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Stack       = local.stack_name
    ManagedBy   = "terraform"
  }

  # VPC tags
  vpc_tags = merge(local.common_tags, {
    Component = "vpc"
  })

  # EKS cluster tags
  eks_tags = merge(local.common_tags, {
    Component = "eks"
  })

  # Pod identity tags
  pod_identity_tags = merge(local.common_tags, {
    Component = "pod-identity"
  })
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
