#!/bin/bash

set -eo pipefail

docker run --rm \
    --volume "$(pwd):/terraform-docs" \
    -u $(id -u) \
    quay.io/terraform-docs/terraform-docs:0.16.0 /terraform-docs