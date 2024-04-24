data "aws_iam_policy_document" "this" {
  count = var.create_role ? 1 : 0

  dynamic "statement" {
    for_each = var.oidc_providers

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [statement.value.provider_arn]
      }

      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(statement.value.provider_arn, "/^(.*provider/)/", "")}:sub"
        values   = [for sa in statement.value.namespace_service_accounts : "system:serviceaccount:${sa}"]
      }
      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(statement.value.provider_arn, "/^(.*provider/)/", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }

    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name        = var.role_name
  name_prefix = var.role_name == null && var.role_name_prefix != null ? module.short-name[0].result : null
  path        = var.role_path
  description = var.role_description

  assume_role_policy    = data.aws_iam_policy_document.this[0].json
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.role_permissions_boundary_arn
  force_detach_policies = var.force_detach_policies

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = length(var.role_policy_arns) > 0 ? var.role_policy_arns : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

module "short-name" {
  count      = var.role_name_prefix != null ? 1 : 0
  source     = "axetrading/short-name/null"
  version    = "1.0.0"
  max_length = 38
  value      = var.role_name_prefix
}

#### Secrets 

data "aws_iam_policy_document" "secrets" {
  count = var.create_role ? 1 : 0

  statement {
    actions = [
      "secretsmanager:ListSecrets",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:Decrypt",
      "kms:GetKeyRotationStatus",
      "kms:GetKeyPolicy",
      "kms:DescribeKey",
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "secrets" {
  count = var.create_role ? 1 : 0

  name_prefix = "${var.policy_name_prefix}-secrets-policy-"
  path        = var.role_path
  description = "Provides permissions for IRSA attached to a kubernetes SA to get secrets from AWS SSM and AWS Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.secrets[0].arn
}

### DynamoDB 

data "aws_iam_policy_document" "dynamodb" {
  count = var.create_role ? 1 : 0

  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem"
    ]
    resources = var.dynamodb_tables_list
  }
  statement {
    actions = [
      "dynamodb:ListTables"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "dynamodb" {
  count = var.create_role ? 1 : 0

  name_prefix = "${var.policy_name_prefix}-dynamodb-policy-"
  path        = var.role_path
  description = "Provides permissions for IRSA attached to a kubernetes SA to list and update dynamodb tables"
  policy      = data.aws_iam_policy_document.dynamodb[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.dynamodb[0].arn
}

### S3

data "aws_iam_policy_document" "s3" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectTagging",
      "s3:DeleteObject",
      "s3:GetObjectVersion"
    ]
    resources = ["${var.artifacts_s3_bucket}/*"]
  }
  statement {
    sid = "AllowKMS"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.artifacts_s3_bucket]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.tfstate_s3_bucket]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:GetObjectTagging",
      "s3:PutObjectAcl"
    ]
    resources = ["${var.tfstate_s3_bucket}/*"]
  }
}

resource "aws_iam_policy" "s3" {
  count = var.create_role ? 1 : 0

  name_prefix = "${var.policy_name_prefix}-s3-policy-"
  path        = var.role_path
  description = "Provides permissions for IRSA attached to a kubernetes SA to list, get and put objects/buckets"
  policy      = data.aws_iam_policy_document.s3[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.s3[0].arn
}

# STS

data "aws_iam_policy_document" "sts" {
  count = var.create_role ? 1 : 0

  statement {
    actions = [
      "sts:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sts" {
  count = var.create_role ? 1 : 0

  name_prefix = "${var.policy_name_prefix}-sts-policy-"
  path        = var.role_path
  description = "Provides permissions for STS actions"
  policy      = data.aws_iam_policy_document.sts[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sts" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.sts[0].arn
}
