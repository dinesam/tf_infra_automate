locals {
  eks_managed_node_groups_al2 = {
    two = {
      ami_type       = "AL2_x86_64"
      labels         = { "role" = "CPU"}
      instance_types = var.eks_managed_node_groups.two.instance_types
      min_size       = var.eks_managed_node_groups.two.min_size
      max_size       = var.eks_managed_node_groups.two.max_size
      desired_capacity = var.eks_managed_node_groups.two.min_size
      block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = var.eks_managed_node_groups.one.disk_size
        }
      }
    }
    }
  }
}