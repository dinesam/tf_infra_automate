
variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_cidr_block_2" {
  description = "CIDR block for the second private subnet"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
}
variable "public_subnet_cidr_block_2" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}



variable "cluster_version" {
  description = "Version of the Kubernetes cluster"
  type        = string
}

variable "default_route_table_name" {
  description = "Route table name for the VPC"
  type        = map(string)
}

variable "default_security_group_name" {
  description = "Security group name for the VPC"
  type        = map(string)
}

variable "igw_tags" {
  description = "Tags for the Internet Gateway"
  type        = map(string)
}


variable "eks_managed_node_groups" {
  description = "Configuration for managed node groups in EKS"
  type = map(object({
    name                       = string
    instance_types             = list(string)
    disk_size                  = number
    use_custom_launch_template = bool
    min_size                   = number
    max_size                   = number
  }))
}

variable "environment" {
  type = string
  
}


# EFS Variables
variable "name" {
  description = "EFS name"
  type        = string
}

variable "lifecycle_policy" {
  description = "EFS lifecycle policy"
  type        = list(object({
    transition_to_ia = string
  }))
}

# Autoscaler Variables
variable "namespace" {
  description = "Kubernetes namespace for Cluster Autoscaler"
  type        = string
}

variable "service_account_name" {
  description = "Service account name for Cluster Autoscaler"
  type        = string
}

variable "helm_chart_name" {
  description = "Helm chart name for Cluster Autoscaler"
  type        = string
}

variable "helm_chart_repo" {
  description = "Helm chart repository for Cluster Autoscaler"
  type        = string
}

variable "helm_chart_version" {
  description = "Helm chart version for Cluster Autoscaler"
  type        = string
}

variable "helm_chart_release_name" {
  description = "Helm release name for Cluster Autoscaler"
  type        = string
}

variable "create_namespace" {
  description = "Whether to create the Kubernetes namespace"
  type        = bool
  default     = true
}


