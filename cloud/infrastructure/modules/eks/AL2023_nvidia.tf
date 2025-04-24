locals {
  eks_managed_node_groups_algpu = {
    one = {
      ami_type       = "AL2023_x86_64_NVIDIA"
      labels         = { "role" = "GPU"}
      instance_types = var.eks_managed_node_groups.one.instance_types
      min_size       = var.eks_managed_node_groups.one.min_size
      max_size       = var.eks_managed_node_groups.one.max_size
      desired_capacity = var.eks_managed_node_groups.one.min_size
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