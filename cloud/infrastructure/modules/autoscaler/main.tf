# Fetch the current AWS caller identity
data "aws_caller_identity" "current" {}

# Cluster Autoscaler Module

resource "helm_release" "autoscaler" {
  name             = var.helm_chart_release_name
  chart            = var.helm_chart_name
  repository       = var.helm_chart_repo
  namespace        = var.namespace
  version          = var.helm_chart_version
  create_namespace = var.create_namespace

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName          = var.cluster_name
        tags        = [
      "k8s.io/cluster-autoscaler/enabled",
      "k8s.io/cluster-autoscaler/${var.cluster_name}"
          ]
      }
      cloudProvider        = "aws"
      extraArgs = {
        "scan-interval"      = "10s"
        "scale-down-delay-after-add" = "2m"
        "max-node-provision-time" = "1m"
        "skip-nodes-with-local-storage" = "false"
        "skip-nodes-with-system-pods"="false"
        "expander"           = "least-waste"
      }
      awsRegion             = var.aws_region
      podAnnotations = {
        "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true"
      }
      rbac = {
        serviceAccount = {
          create = true
          name   = "cluster-autoscaler"
        }
      }
    })
  ]

  depends_on = [aws_iam_role.autoscaler_role]
}

# IAM Role for the Cluster Autoscaler
resource "aws_iam_role" "autoscaler_role" {
  name               = "${var.cluster_name}-autoscaler-role"
  assume_role_policy = data.aws_iam_policy_document.autoscaler_assume_role_policy.json

  tags = {
    Environment = var.environment
  }
}

# Policy Document for Cluster Autoscaler
data "aws_iam_policy_document" "autoscaler_policy" {
  statement {
    actions   = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:DescribeScalingActivities",
      "ec2:DescribeInstanceStatus",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "autoscaler_policy" {
  name        = "${var.cluster_name}-autoscaler-policy"
  description = "IAM policy for Cluster Autoscaler"
  policy      = data.aws_iam_policy_document.autoscaler_policy.json
}



# Assume Role Policy Document
data "aws_iam_policy_document" "autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${var.cluster_identity_oidc_issuer}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.aws_region}.amazonaws.com/id/${var.cluster_identity_oidc_issuer}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "autoscaler_attachment" {
  role       = aws_iam_role.autoscaler_role.name
  policy_arn = aws_iam_policy.autoscaler_policy.arn
}


module "eks-metrics-server" {
  source  = "lablabs/eks-metrics-server/aws"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  helm_release_name = "metrics-server"
  namespace         = "kube-system"
  helm_repo_url = "https://kubernetes-sigs.github.io/metrics-server/"
  helm_chart_version = "3.12.2"

  values = yamlencode({
    "podLabels" : {
      "app" : "test-metrics-server"
    }
  })

  helm_timeout = 240
  helm_wait    = true
}





