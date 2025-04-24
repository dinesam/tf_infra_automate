provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {

  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name # Adjust this according to your EKS module output
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"  # Specifying the version you mentioned
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"  # Specifying the version you mentioned
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"  # Specifying the version you mentioned
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.5"  # Specifying the version you mentioned
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"  # Specifying the version you mentioned
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.1"  # Specifying the version you mentioned
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.3"  # Specifying the version you mentioned
    }
  }
}
