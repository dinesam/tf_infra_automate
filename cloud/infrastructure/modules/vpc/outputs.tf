output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "The list of public subnet IDs."
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The list of private subnet IDs."
  value       = module.vpc.private_subnets
}



output "default_security_group_id" {
  description = "The ID of the default security group."
  value       = module.vpc.default_security_group_id
}

output "default_route_table_id" {
  description = "The ID of the default route table."
  value       = module.vpc.default_route_table_id
}

output "azones"{
  value = module.vpc.azs
}

output "cidr_block"{
  value = module.vpc.vpc_cidr_block
}

