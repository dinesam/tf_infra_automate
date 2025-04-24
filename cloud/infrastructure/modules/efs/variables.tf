variable "vpc_id" {
  description = "The ID of the VPC where the EFS is deployed"
  type        = string
}

variable "name" {
  description = "The name of the EFS file system"
  type        = string
}


variable "subnet_ids" {
  description = "List of subnet IDs for the EFS mount targets"
  type        = list(string)
}

variable "lifecycle_policy" {
  description = "Lifecycle policy for transitioning files to Infrequent Access"
  type        = list(object({
    transition_to_ia = string
  }))
}

variable "tags" {
  description = "Tags to assign to the EFS"
  type        = map(string)
}

variable "region" {
  description = "AWS region for the EFS file system"
  type        = string
}


variable "azones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cidr_blocks" {
  description = "List of cidr blocks"
  type = list(string)
}
