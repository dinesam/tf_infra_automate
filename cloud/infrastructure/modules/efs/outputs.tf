output "efs_file_system_id" {
  description = "The ID of the EFS file system"
  value       = module.efs.id
}

output "efs_security_group_id" {
  description = "The ID of the security group associated with EFS"
  value       = module.efs.security_group_id
}

output "efs_dns_name" {
  value = "${module.efs.id}.efs.${var.region}.amazonaws.com"
}