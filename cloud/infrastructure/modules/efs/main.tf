data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
  
module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = var.name
  creation_token = var.name
  encrypted      = true
  # kms_key_arn    = module.kms.key_arn

 lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  # # File system policy
  attach_policy                             = false
  deny_nonsecure_transport_via_mount_target = false
  bypass_policy_lockout_safety_check        = false
  policy_statements = [
    {
      sid     = "efs"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.arn]
        }
      ]
    }
  ]
  mount_targets              = { for k, v in zipmap(var.azones, var.subnet_ids) : k => { subnet_id = v } }


  
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    sgid2 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      #cidr_blocks = [for s in data.aws_subnet.subnets : s.cidr_block]
      cidr_blocks = var.cidr_blocks
      description = "NFS ingress from VPC private subnets"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
	  
    }
    sgid1 = {
    description = "Allow outbound traffic to the same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true  # Allow traffic within the same security group
  }


  }
  # Backup policy
  enable_backup_policy = false



  tags = var.tags
}



