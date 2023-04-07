#!/usr/bin/env bash
# no_set_e
set -o pipefail

aws-env-var-setup() {
  export AWS_PROFILE="${1}"

  # default is "w", which sets us-west-2; "e" sets us-east-1; anything else as-is
  REGION="${2:-w}"
  case "${REGION}" in
    w)
      REGION="us-west-2"
      ;;
    e)
      REGION="us-east-1"
      ;;
  esac

  export AWS_DEFAULT_REGION="${REGION}"
  # nice confirmation that these creds work
  ACCOUNT_ID=$( aws sts get-caller-identity | jq .Account | tr -d '"' )
  export AWS_ACCOUNT_ID="${ACCOUNT_ID}"
  export AWS_ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
}

# quick and dirty regex to pull out section-names from creds file
# where it finds "[staging]" and ignores the "[" "]" through "fancy" regex
aws-list-profile () {
  for PROFILE in $( ag -o '(?<=\[).*(?=\])' "${HOME}/.aws/credentials"); do
    echo "${PROFILE}"
  done
}

# NOTE: this is NOT safe on untrusted input
_make-aws-func () {
  for PROFILE in $(aws-list-profile); do
    eval "aws-${PROFILE}() { aws-env-var-setup ${PROFILE} \${1}} "
  done
}
_make-aws-func
