variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs to launch the EKS cluster in"
  type        = list(string)
}

variable "cluster_version" {
  description = "The Kubernetes version to use for the cluster"
  type        = string
}

variable "cluster_addons" {
  description = "A map of the Kubernetes addons to deploy"
  type        = map(any)
  default     = {}
}



variable "eks_managed_node_groups" {
  description = "Configuration for the EKS managed node groups"
  type = map(object({
    name                   = string
    instance_types         = list(string)
    disk_size              = number
    use_custom_launch_template = optional(bool)
    min_size               = number
    max_size               = number
  }))
}


variable "cluster_identity_oidc_issuer" {
  description = "OIDC identity issuer for the cluster"
  type        = string
}


variable "region" {
  description = "AWS region for deployment"
  type        = string
}





################################################################################
# Cluster IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}
