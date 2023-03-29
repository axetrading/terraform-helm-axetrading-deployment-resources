
output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = try(aws_iam_role.this[0].arn, "")
}

output "helm_release_id" {
  value       = helm_release.main.id
  description = "Helm Release ID"
}

output "helm_release_name" {
  value       = helm_release.main.name
  description = "Helm Release Name"
}

output "helm_release_namespace" {
  value       = helm_release.main.namespace
  description = "Helm Release Namespace"
}

output "helm_release_status" {
  value       = helm_release.main.status
  description = "Helm Release Status"
}

output "helm_release_values" {
  value       = helm_release.main.values
  description = "Helm Release Values"
}