# Use the data from the infrastructure remote state
output "cluster_endpoint" {
  value = data.terraform_remote_state.deployment.outputs.ingress_hostname
}

output "cluster_name" {
  value = data.terraform_remote_state.infrastructure.outputs.cluster_name
}


output "vpc_id_debug" {
  value = data.terraform_remote_state.infrastructure.outputs.vpc_id
}

output "public_subnet_ids" {
  value = data.terraform_remote_state.infrastructure.outputs.public_subnets[0]
}

output "efs_dns_name" {
  value = data.terraform_remote_state.infrastructure.outputs.efs_dns_name
  
}

output "efs_file_system_id" {

  value = data.terraform_remote_state.infrastructure.outputs.efs_file_system_id
}
  

output "region_name" {
  value = data.terraform_remote_state.infrastructure.outputs.region
}

output "public_IP"{
  value = module.ec2_instance.public_ip
}

