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
    DRY_RUN=false
    eval $(ssh-agent)
    echo "$SSH_AUTH_KEY" | ssh-add -
    while [[ "$#" -gt 0 ]]; do
      case $1 in
          -workspace) WORKSPACE="$2"; shift ;;
          -image) IMAGE_REPOSITORY="$2"; shift ;;
          -tag) IMAGE_TAG="$2"; shift ;;
          -dry-run) DRY_RUN=true ;;
          *) echo "Unknown parameter passed: $1"; exit 1 ;;
      esac
      shift
    done
    echo $WORKSPACE
    echo $IMAGE_REPOSITORY
    echo $IMAGE_TAG
    if [[ -z \"$WORKSPACE\" || -z \"$IMAGE_REPOSITORY\" || -z \"$IMAGE_TAG\" ]]; then
        echo \"Usage: $0 -workspace <workspace> -image <image_repository> -tag <image_tag>\"
        exit 1
    fi
    
    echo \"Downloading Deployment Package from S3...\"
    aws s3 cp s3://$ARTIFACT_LOCATION/$REPO_NAME/$IMAGE_TAG/deployment.zip .
    unzip -q deployment.zip
    
    dir=terraform
    export TF_CLI_CHDIR=$dir
    export FIRST_RUN=1
    . $dir/utils/k8s-job-utils.sh
    
    echo \"Reading secrets from /mnt/secrets directory...\"
    jq -s 'reduce .[] as $item ({}; . * $item)' /mnt/secrets/* > terraform/terraform.tfvars.json
    
    echo \"Appending secrets from terraform/environments/$WORKSPACE.tfvars.json to terraform/terraform.tfvars.json...\"
    jq -s '.[0] + .[1]' terraform/terraform.tfvars.json terraform/environments/$WORKSPACE.tfvars.json > temp.json && mv temp.json terraform/terraform.tfvars.json
    
    echo \"Initialising Terraform workspace...\"
    initialise_terraform_workspace $TFSTATE_BUCKET $TFLOCKS_TABLE $REPO_NAME $WORKSPACE
    
    echo \"Running Terraform plan...\"
    if [ $DRY_RUN = true ]; then
      terraform -chdir=$TF_CLI_CHDIR plan \
        -var name=$REPO_NAME \
        -var image_repository=$IMAGE_REPOSITORY \
        -var image_tag=$IMAGE_TAG \
      -detailed-exitcode
    else
      terraform -chdir=$TF_CLI_CHDIR plan \
        -var name=$REPO_NAME \
        -var image_repository=$IMAGE_REPOSITORY \
        -var image_tag=$IMAGE_TAG \
        -out=plan
    fi
    
    echo \"Applying Terraform plan...\"
    
    if [ $DRY_RUN = true ]; then
      echo \"Dry run: Terraform apply skipped\"
    else
      terraform -chdir=$TF_CLI_CHDIR apply plan
    fi