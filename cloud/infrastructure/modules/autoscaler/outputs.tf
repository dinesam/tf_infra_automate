output "autoscaler_role_arn" {
  description = "IAM Role ARN for Cluster Autoscaler"
  value       = aws_iam_role.autoscaler_role.arn
}

output "autoscaler_policy_arn" {
  description = "IAM Policy ARN for Cluster Autoscaler"
  value       = aws_iam_policy.autoscaler_policy.arn
}

