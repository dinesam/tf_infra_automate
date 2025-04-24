module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = var.cidr_block

  azs             = [var.availability_zone_1, var.availability_zone_2]
  private_subnets = [var.private_subnet_cidr_block, var.private_subnet_cidr_block_2]
  public_subnets  = [var.public_subnet_cidr_block, var.public_subnet_cidr_block_2]

  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_hostnames       = true
  enable_dns_support   = true
  manage_default_route_table  = true
  reuse_nat_ips              = false
  default_route_table_tags      = var.default_route_table_name
  manage_default_security_group = false
  default_security_group_tags = var.default_security_group_name
  igw_tags = var.igw_tags
  map_public_ip_on_launch = true
 



  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1" # Required for public Kubernetes Load Balancers
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1" # Required for internal Kubernetes Load Balancers
  }
}