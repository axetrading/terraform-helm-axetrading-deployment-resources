nameOverride: ""
fullnameOverride: ${fullNameOverride}

serviceAccount:
  create: ${createServiceAccount}
  annotations: {}
  name: ""

secretsStore:
  %{~ if awsSecrets != null ~}
  enabled: true
  provider: aws
  secretProviderClasses:
    %{~ for secret in awsSecrets ~}
    - ${secret}
    %{~ endfor ~}
  %{~ endif ~}
  %{~ if awsSecrets == null ~}
  enabled: false
  %{~ endif ~}

terraformUpdateConfigmap:
  deploySh: |-
    #!/bin/bash
    set -eo pipefail
    while getopts ":w:i:t:" opt; do
      case $opt in
        w)
          WORKSPACE="$OPTARG"
          ;;
        i)
          IMAGE_REPOSITORY="$OPTARG"
          ;;
        t)
          IMAGE_TAG="$OPTARG"
          ;;
        \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
        :)
          echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
      esac
    done

    if [[ -z "$WORKSPACE" || -z "$IMAGE_REPOSITORY" || -z "$IMAGE_TAG" ]]; then
        echo "Usage: $0 -w <workspace> -i <image_repository> -t <image_tag>"
        exit 1
    fi

    ### Download Deployment Package from S3
    echo "Downloading Deployment Package from S3..."
    aws s3 cp s3://$ARTIFACT_LOCATION/$REPO_NAME/$IMAGE_TAG/deployment.zip .
    unzip -q deployment.zip

    dir="terraform"
    export TF_CLI_CHDIR="$dir"
    . $dir/utils/utils.sh

    ### looking for secrets in /mnt/secrets directory
    echo "Reading secrets from /mnt/secrets directory..."
    jq -s 'reduce .[] as $item ({}; . * $item)' /mnt/secrets/* > terraform/terraform.tfvars.json

    ### initialise the workspace
    echo "Initialising Terraform workspace..."
    initialise_terraform_workspace $TFSTATE_BUCKET $TFLOCKS_TABLE $REPO_NAME $WORKSPACE

    ### running terraform plan with detailed exit code.
    echo "Running Terraform plan..."
    terraform plan \
        -var name="$REPO_NAME" \
        -var image_repository="$IMAGE_REPOSITORY" \
        -var image_tag="$IMAGE_TAG" \
        -out=plan

    echo "Applying Terraform plan..."
    terraform apply plan