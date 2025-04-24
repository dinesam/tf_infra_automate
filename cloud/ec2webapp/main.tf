  # Access outputs from the infrastructure stage
data "terraform_remote_state" "infrastructure" {
  backend = "local"
  config = {
    path = "../infrastructure/terraform.tfstate"
  }
}

 # Access outputs from the deployment stage
data "terraform_remote_state" "deployment" {
  backend = "local"
  config = {
    path = "../deployment/terraform.tfstate"
  }
}

resource "aws_iam_policy" "ecr_read_only" {
  name        = "ECRReadOnly"
  description = "Read-only access to ECR"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnly"
  description = "Read-only access to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
    ]
  })
}


resource "aws_iam_policy" "efs_describe_policy" {
  name        = "EFSDescribePolicy"
  description = "Permission to describe EFS file systems"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "elasticfilesystem:DescribeFileSystems"
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_describe_policy" {
  name        = "EKSDescribePolicy"
  description = "Permission to describe EKS clusters"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "eks:DescribeCluster"
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_describe_instance_policy" {
  name        = "EC2DescribeInstancePolicy"
  description = "Allow EC2 instances to describe their own details"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:DescribeInstances"
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_security_group" "web_app_sg" {
  name        = "web_app_sg"
  description = "Security group for web application"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
# Security Group Rule for SSH (port 22)
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_app_sg.id
}

# Security Group Rule for HTTP (port 80)
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_app_sg.id
}

# Security Group Rule for HTTPS (port 443)
resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_app_sg.id
}

# Security Group Rule for Custom Port (6060)
resource "aws_security_group_rule" "allow_custom_port" {
  type              = "ingress"
  from_port         = 6060
  to_port           = 6060
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_app_sg.id
}

# Security Group Rule for Custom Port (6061)
resource "aws_security_group_rule" "allow_custom_port1" {
  type              = "ingress"
  from_port         = 6061
  to_port           = 6061
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_app_sg.id
}

# Security Group Rule for Egress (all traffic)
resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_app_sg.id
}

# Kubernetes provider configuration
provider "kubernetes" {
  
    host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_authority_ca)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.infrastructure.outputs.cluster_name]
      command     = "aws"
    }
    
  }
  


# EC2 instance module to launch an EC2 instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name                        = var.instance_name
  ami                         = var.instance_ami
 # key_name                    = "eccloud"
  instance_type               = var.instance_type
  root_block_device = [
    {
      volume_size = 25
      volume_type = "gp3"
    }
  ]
  monitoring             = true
  associate_public_ip_address = true
 vpc_security_group_ids = [
    
    aws_security_group.web_app_sg.id  # Use the web app security group ID here
  ]  # Update with the correct security group ID from the remote state
  subnet_id              = data.terraform_remote_state.infrastructure.outputs.public_subnets[0]
  user_data = templatefile("user_data.sh", {
  region        = data.terraform_remote_state.infrastructure.outputs.region
  cluster_name  = data.terraform_remote_state.infrastructure.outputs.cluster_name
  efs_dns_name  = data.terraform_remote_state.infrastructure.outputs.efs_dns_name
  ingress_hostname = data.terraform_remote_state.deployment.outputs.ingress_hostname
  auth_image    = var.auth_image
  backend_image = var.backend_image
  frontend_image = var.frontend_image
  bucket_name = var.bucket_name
  ecr_repo_url = var.ecr_repo_url
  }  )
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    ECRReadOnly                 = aws_iam_policy.ecr_read_only.arn
    S3ReadOnly                 = aws_iam_policy.s3_read_only.arn
    EFSDescribePolicy          = aws_iam_policy.efs_describe_policy.arn
    EKSDescribePolicy          = aws_iam_policy.eks_describe_policy.arn
    EC2DescribeInstancePolicy = aws_iam_policy.ec2_describe_instance_policy.arn
  }
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
  depends_on = [ module.s3_bucket ]
}

# s3 bucket for uploading the files in conf folder

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  create_bucket = true
  bucket = "bucketconf"
  acl    = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  versioning = {
    enabled = false
  }
}

# Upload object to S3 bucket
resource "aws_s3_object" "object" {
  bucket   = var.bucket_name
  key      = "nginx/nginx.conf"
  source   = "conf/nginx/nginx.conf"
  acl    = "private"
 depends_on = [ module.s3_bucket ]
}

resource "aws_s3_object" "certs-crt" {
  bucket = var.bucket_name
  key    = "certs/nginx-selfsigned.crt"
  source = "conf/certs/nginx-selfsigned.crt"
  acl    = "private"
  depends_on = [ module.s3_bucket ]
}

resource "aws_s3_object" "certs-key" {
  bucket = var.bucket_name
  key    = "certs/nginx-selfsigned.key"
  source = "conf/certs/nginx-selfsigned.key"
  acl    = "private"
  depends_on = [ module.s3_bucket ]
}

resource "aws_s3_object" "efs-utils" {
  bucket = var.bucket_name
  key    = "nginx/amazon-efs-utils-2.1.0-1_all.deb"
  source = "conf/nginx/amazon-efs-utils-2.1.0-1_all.deb"
  acl    = "private"
  depends_on = [ module.s3_bucket ]
}
