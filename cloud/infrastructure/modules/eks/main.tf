module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  enable_efa_support = true # Elastic fabric adaptor supports High IO for low latency (Need to enable custom launch template)

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    aws-efs-csi-driver     = {}
  }

  eks_managed_node_groups = merge(
    local.eks_managed_node_groups_algpu,local.eks_managed_node_groups_al2  ) # ,local.eks_managed_node_groups_al2        Add this line if 2nd node is required for compilation. 


  
  eks_managed_node_group_defaults = {
    
    create_iam_role          = true
      
      iam_role_policy_statements = [
        {
          sid    = "AutoscalingActions"
          effect = "Allow"
          actions = [
            "ec2:DescribeInstanceStatus",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:DescribeTags",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeAutoScalingGroups",
            "ec2:DescribeLaunchTemplateVersions",
            "eks:DescribeNodegroup",
            "eks:ListNodegroups"
          ]
          resources = ["*"]
        },
        {
          sid    = "ECRPullAccess"
          effect = "Allow"
          actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage"
          ]
          resources = ["*"]
        }
      ]
      ami_type                   = "AL2023_x86_64_NVIDIA"
    one = {
      ami_type    =  "CUSTOM"
      labels          = { "role" = "GPU" }
      instance_types  = var.eks_managed_node_groups.one.instance_types
      min_size        = var.eks_managed_node_groups.one.min_size
      max_size        = var.eks_managed_node_groups.one.max_size
      desired_capacity = var.eks_managed_node_groups.one.min_size
    }
    two = {
      
      labels          = { "role" = "CPU" }
      instance_types  = var.eks_managed_node_groups.two.instance_types
      min_size        = var.eks_managed_node_groups.two.min_size
      max_size        = var.eks_managed_node_groups.two.max_size
      desired_capacity = var.eks_managed_node_groups.two.min_size
    }
  }
  

  cluster_security_group_additional_rules = {
    ingress_self_all = {
      description = "cluster security addition rules"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress = {
      from_port   = 30001
      to_port     = 30001
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_icmp = {
      description = "Allow ICMP Ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_ssh = {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_alb_http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_alb_https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_custom = {
      from_port   = 6060
      to_port     = 6060
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
    ingress_custom1 = {
      from_port   = 6061
      to_port     = 6061
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      type        = "ingress"
    }
  }
}

