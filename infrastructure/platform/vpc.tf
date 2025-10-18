module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0.0"

  # Basic configuration
  name = local.project_identifier
  cidr = local.vpc_cidr
  azs  = local.azs

  # Subnets
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  # NAT Gateway configuration
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # DNS configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Kubernetes tags for AWS Load Balancer Controller
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.vpc_tags
}
