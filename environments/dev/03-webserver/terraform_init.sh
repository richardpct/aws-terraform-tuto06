#!/bin/bash
#
# Launch this script for initializing the S3 backend
#

terraform init \
  -backend-config="bucket=${TF_VAR_bucket}" \
  -backend-config="key=${TF_VAR_dev_webserver_key}" \
  -backend-config="region=${TF_VAR_region}"
