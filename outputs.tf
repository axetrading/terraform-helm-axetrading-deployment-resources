output "namespace_name" {
  value       = kubernetes_namespace.this.metadata[0].name
  description = "The name of the Kubernetes namespace created by the 'kubernetes_namespace' resource."
}

output "role_name" {
  value       = kubernetes_role.this.metadata[0].name
  description = "The name of the Kubernetes role created by the 'kubernetes_role' resource."
}

output "role_binding_name" {
  value       = kubernetes_role_binding.this.metadata[0].name
  description = "The name of the Kubernetes role binding created by the 'kubernetes_role_binding' resource."
}

output "service_account_name" {
  value       = kubernetes_service_account.this.metadata[0].name
  description = "The name of the Kubernetes service account."
}

output "config_map_name" {
  value       = kubernetes_config_map.this.metadata[0].name
  description = "The name of the Kubernetes config map."
}

output "irsa_name" {
  value       = aws_iam_role.this[0].name
  description = "The name of the AWS IAM role."
}

output "secrets_policy_arn" {
  value       = aws_iam_policy.secrets[0].arn
  description = "The ARN of the AWS IAM policy created by the 'aws_iam_policy' resource for accessing AWS Secrets Manager and AWS SSM."
}

output "dynamodb_policy_arn" {
  value       = aws_iam_policy.dynamodb[0].arn
  description = "The ARN of the AWS IAM policy created by the 'aws_iam_policy' resource for accessing DynamoDB."
}

output "s3_policy_arn" {
  value       = aws_iam_policy.s3[0].arn
  description = "The ARN of the AWS IAM policy created by the 'aws_iam_policy' resource for accessing S3."
}
