variable "auth_image" {}
variable "backend_image" {}
variable "frontend_image" {}

variable "instance_name" {
  type = string
}

variable "instance_ami"{
  type = string
}

variable "instance_type" {
  type = string
}

variable "environment" {
  type = string
  default = "development"
}

variable "bucket_name" {
  description = "Path to the SSH key pair"
  type        = string
  default     = "bucketconf"  # Default value for the key path
}

variable "ecr_repo_url" {
  type = string
}
