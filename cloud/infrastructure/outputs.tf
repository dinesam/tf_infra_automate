output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "The security group ID for the EKS cluster"
}
output "node_security_group_id" {
  value = module.eks.node_security_group_id
}


output "region" {
  value = var.region
}

output "cluster_authority_ca" {
  value = module.eks.cluster_certificate_authority_data
}

#EFS

output "efs_file_system_id" {
  description = "The ID of the EFS file system"
  value       = module.efs.efs_file_system_id
}

output "efs_dns_name" {
  description = "The DNS name of the EFS file system"
  value       = module.efs.efs_dns_name
}

#Autoscaler 

# Outputs for Cluster Autoscaler

output "autoscaler_role_arn" {
  description = "IAM Role ARN for Cluster Autoscaler"
  value       = module.autoscaler.autoscaler_role_arn
}

output "autoscaler_policy_arn" {
  description = "IAM Policy ARN for Cluster Autoscaler"
  value       = module.autoscaler.autoscaler_policy_arn
}

output "autoscaler_helm_release_name" {
  description = "Helm release name of the Cluster Autoscaler"
  value       = var.helm_chart_release_name
}

output "autoscaler_namespace" {
  description = "Kubernetes namespace where Cluster Autoscaler is deployed"
  value       = var.namespace
}

output "default_security_group_id" {
  description = "The ID of the default security group."
  value       = module.vpc.default_security_group_id
}

