###  Namespace
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

###  Role

resource "kubernetes_role" "this" {
  metadata {
    name = var.name
  }

  rule {
    verbs      = ["create", "read", "update", "patch", "delete"]
    api_groups = [""]
    resources  = ["pods", "jobs", "configmaps", "deployments"]
  }
}

###  Role Binding

resource "kubernetes_role_binding" "this" {
  metadata {
    name = var.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.name
  }
}

### Service Account

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = var.create_role ? aws_iam_role.this[0].arn : var.existing_role_arn
    }
  }
}

### ConfigMap

resource "kubernetes_config_map" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = {
    "deploy.sh" = "#!/bin/bash\n\nset -eo pipefail\n\nwhile getopts \":w:i:t:\" opt; do\n  case $opt in\n    w)\n      WORKSPACE=\"$OPTARG\"\n      ;;\n    i)\n      IMAGE_REPOSITORY=\"$OPTARG\"\n      ;;\n    t)\n      IMAGE_TAG=\"$OPTARG\"\n      ;;\n    \\?)\n      echo \"Invalid option: -$OPTARG\" >&2\n      exit 1\n      ;;\n    :)\n      echo \"Option -$OPTARG requires an argument.\" >&2\n      exit 1\n      ;;\n  esac\ndone\n\nif [[ -z \"$WORKSPACE\" || -z \"$IMAGE_REPOSITORY\" || -z \"$IMAGE_TAG\" ]]; then\n    echo \"Usage: $0 -w <workspace> -i <image_repository> -t <image_tag>\"\n    exit 1\nfi\n### Download Deployment Package from S3 \naws s3 cp s3://$ARTIFACT_LOCATION/$REPO_NAME/$IMAGE_TAG/deployment.zip .\nunzip -q deployment.zip\n\ndir=\"terraform\"\nexport TF_CLI_CHDIR=\"$dir\"\n\n. $dir/utils/utils.sh\n\n### looking for secrets in /mnt/secrets directory\njq -s 'reduce .[] as $item ({}; . * $item)' /mnt/secrets/* > terraform/terraform.tfvars.json\n\n### initialise the workspace\ninitialise_terraform_workspace $TFSTATE_BUCKET $TFLOCKS_TABLE $REPO_NAME $WORKSPACE\n\n### running terraform plan with detailed exit code.\nterraform_exec plan \\\n    -var name=\"$REPO_NAME\" \\\n    -var image_repository=\"$IMAGE_REPOSITORY\" \\\n    -var image_tag=\"$IMAGE_TAG\" \\\n    -out=plan\nterraform_exec apply plan"
  }
}



