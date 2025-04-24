output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}


output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "The security group ID for the EKS cluster"
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}


output "cluster_oidc_issuer_url" {
  description = "The OIDC Identity issuer for the cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_oidc_issuer_arn" {
  description = "The OIDC Identity issuer ARN for the cluster"
  value       = module.eks.oidc_provider
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}


output "oidc_provider_arn" {
  value = module.eks.cluster_identity_providers
}

output "cluster_authority_ca" {

  value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint for the EKS cluster"
}

