resource "kubernetes_manifest" "secretstore" {
  for_each = toset(var.secrets)

  manifest = {
    "apiVersion" = "secrets-store.csi.x-k8s.io/v1"
    "kind"       = "SecretProviderClass"
    "metadata" = {
      "name"      = each.value
      "namespace" = var.namespace
    }
    "spec" = {
      "parameters" = {
        "objects" = <<-EOT
        - objectName: ${each.value}
          objectType: "secretsmanager"
        EOT
      }
      "provider" = "aws"
    }
  }
}