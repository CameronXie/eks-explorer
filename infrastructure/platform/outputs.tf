output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}