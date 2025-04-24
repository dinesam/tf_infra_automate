

module "vpc" {
  source = "./modules/vpc"

  cidr_block                  = var.cidr_block
  availability_zone_1         = var.availability_zone_1
  availability_zone_2         = var.availability_zone_2
  private_subnet_cidr_block   = var.private_subnet_cidr_block
  private_subnet_cidr_block_2 = var.private_subnet_cidr_block_2
  public_subnet_cidr_block    = var.public_subnet_cidr_block
  public_subnet_cidr_block_2  = var.public_subnet_cidr_block_2
  cluster_name                = var.cluster_name
  default_route_table_name    = var.default_route_table_name
  default_security_group_name = var.default_security_group_name
  igw_tags                    = var.igw_tags
  environment = var.environment
}

module "eks" {
  source                       = "./modules/eks"

  region                       = var.region
  cluster_name                 = var.cluster_name
  cluster_version              = var.cluster_version
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnets
  cluster_identity_oidc_issuer = module.eks.cluster_oidc_issuer_url
  eks_managed_node_groups = var.eks_managed_node_groups
}

module "autoscaler" {
  source = "./modules/autoscaler"

  cluster_name                 = var.cluster_name
  namespace                    = var.namespace
  aws_region                   = var.region
  helm_chart_name              = var.helm_chart_name
  helm_chart_repo              = var.helm_chart_repo
  helm_chart_release_name      = var.helm_chart_release_name
  helm_chart_version           = var.helm_chart_version
  create_namespace             = true
  cluster_identity_oidc_issuer = module.eks.cluster_oidc_issuer_url
  environment = var.environment
}


module "efs" {
  source           = "./modules/efs"
  
  vpc_id           = module.vpc.vpc_id
  region           = var.region
  name             = var.name
  subnet_ids       = module.vpc.private_subnets
  lifecycle_policy = var.lifecycle_policy
  tags             = { Name = var.name }
  azones           = module.vpc.azones
  cidr_blocks      = [module.vpc.cidr_block]
}


