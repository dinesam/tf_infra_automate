variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_identity_oidc_issuer" {
  description = "OIDC identity issuer for the cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy Cluster Autoscaler"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Service account name for Cluster Autoscaler"
  type        = string
  default     = "cluster-autoscaler"
}

variable "helm_chart_name" {
  description = "Helm chart name for Cluster Autoscaler"
  type        = string
  default     = "cluster-autoscaler"
}

variable "helm_chart_repo" {
  description = "Helm repository for Cluster Autoscaler"
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
}

variable "helm_chart_version" {
  description = "Helm chart version for Cluster Autoscaler"
  type        = string
  
}

variable "helm_chart_release_name" {
  description = "Helm release name for Cluster Autoscaler"
  type        = string
  
}

variable "create_namespace" {
  description = "Whether to create the Kubernetes namespace"
  type        = bool
  default     = true
}

variable "environment"{
  type = string
}