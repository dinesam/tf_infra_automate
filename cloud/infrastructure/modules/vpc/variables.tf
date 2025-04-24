variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zone_1" {
  description = "First availability zone."
  type        = string
}

variable "availability_zone_2" {
  description = "Second availability zone."
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the first private subnet."
  type        = string
}

variable "private_subnet_cidr_block_2" {
  description = "CIDR block for the second private subnet."
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet."
  type        = string
}
variable "public_subnet_cidr_block_2" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster."
  type        = string
}

variable "default_route_table_name" {
  description = "Name for the default route table"
  type        = map(string)
}

variable "default_security_group_name" {
  description = "Name for the default security group"
  type        = map(string)
}


variable "igw_tags" {
  type        = map(string)
  description = "Tags for the Internet Gateway (IGW)"
 
}

variable "environment"{
  type = string
}