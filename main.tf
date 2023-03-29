resource "helm_release" "main" {
  name             = var.name
  chart            = "${path.module}/helm/axetrading-deployment-dependencies"
  atomic           = var.atomic
  create_namespace = var.create_namespace
  namespace        = var.namespace
  timeout          = var.timeout
  wait             = var.wait

  values = [
    templatefile("${path.module}/helm/axetrading-deployment-dependencies/values.yaml.tpl", {
      awsSecrets           = var.secrets
      createServiceAccount = var.create_service_account
      }
    )
  ]

  dynamic "set" {
    for_each = var.create_role && var.create_service_account ? [aws_iam_role.this[0].arn] : [var.existing_role_arn]
    content {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = set.value
      type  = "string"
    }
  }
}
 