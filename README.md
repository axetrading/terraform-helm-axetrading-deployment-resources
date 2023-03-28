# terraform-kubernetes-axetrading-deployment-resources
The "terraform-kubernetes-axetrading-deployment-resources" repository contains Terraform code for deploying the kubernetes dependencies for kubernetes deployments trigger - lambda.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.58 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.18.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.58 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.18.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_short-name"></a> [short-name](#module\_short-name) | axetrading/short-name/null | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_config_map.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_manifest.secretstore](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_service_account.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_iam_policy_document.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_s3_bucket"></a> [artifacts\_s3\_bucket](#input\_artifacts\_s3\_bucket) | Artifacts S3 Bucket ARN - on this bucket, we store the packages generated by Github Actions builds (.zip files) | `string` | `""` | no |
| <a name="input_assume_role_condition_test"></a> [assume\_role\_condition\_test](#input\_assume\_role\_condition\_test) | Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role | `string` | `"StringEquals"` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether to create or not the IAM Role for the lambda function | `bool` | `true` | no |
| <a name="input_dynamodb_tables_list"></a> [dynamodb\_tables\_list](#input\_dynamodb\_tables\_list) | DynamoDb tables arns where the k8s deployment iam role has access | `list(string)` | `[]` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Map of environment variables to set for the Lambda function. | `map(string)` | `{}` | no |
| <a name="input_existing_role_arn"></a> [existing\_role\_arn](#input\_existing\_role\_arn) | The ARN of an existing IAM role to be used for this deployment. | `string` | `null` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether policies should be detached from this role when destroying | `bool` | `true` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum CLI/API session duration in seconds between 3600 and 43200 | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the K8S deployment lambda and its resources | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace | `string` | `"default"` | no |
| <a name="input_oidc_providers"></a> [oidc\_providers](#input\_oidc\_providers) | Map of OIDC providers where each provider map should contain the `provider`, `provider_arn`, and `namespace_service_accounts` | `any` | `{}` | no |
| <a name="input_policy_name_prefix"></a> [policy\_name\_prefix](#input\_policy\_name\_prefix) | IAM policy name prefix | `string` | `"aws"` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | IAM Role description | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of IAM role | `string` | `null` | no |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | IAM role name prefix | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | Path of IAM role | `string` | `"/"` | no |
| <a name="input_role_permissions_boundary_arn"></a> [role\_permissions\_boundary\_arn](#input\_role\_permissions\_boundary\_arn) | Permissions boundary ARN to use for IAM role | `string` | `null` | no |
| <a name="input_role_policy_arns"></a> [role\_policy\_arns](#input\_role\_policy\_arns) | ARNs of any policies to attach to the IAM role | `set(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secret that will be used by the SecretsStore. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add the the IAM role | `map(any)` | `{}` | no |
| <a name="input_tfstate_s3_bucket"></a> [tfstate\_s3\_bucket](#input\_tfstate\_s3\_bucket) | Terraform tfstate s3 bucket ARN | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_map_name"></a> [config\_map\_name](#output\_config\_map\_name) | The name of the Kubernetes config map. |
| <a name="output_dynamodb_policy_arn"></a> [dynamodb\_policy\_arn](#output\_dynamodb\_policy\_arn) | The ARN of the AWS IAM policy created by the 'aws\_iam\_policy' resource for accessing DynamoDB. |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | The name of the AWS IAM role. |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The name of the Kubernetes namespace created by the 'kubernetes\_namespace' resource. |
| <a name="output_role_binding_name"></a> [role\_binding\_name](#output\_role\_binding\_name) | The name of the Kubernetes role binding created by the 'kubernetes\_role\_binding' resource. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the Kubernetes role created by the 'kubernetes\_role' resource. |
| <a name="output_s3_policy_arn"></a> [s3\_policy\_arn](#output\_s3\_policy\_arn) | The ARN of the AWS IAM policy created by the 'aws\_iam\_policy' resource for accessing S3. |
| <a name="output_secrets_policy_arn"></a> [secrets\_policy\_arn](#output\_secrets\_policy\_arn) | The ARN of the AWS IAM policy created by the 'aws\_iam\_policy' resource for accessing AWS Secrets Manager and AWS SSM. |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | The name of the Kubernetes service account. |
<!-- END_TF_DOCS -->