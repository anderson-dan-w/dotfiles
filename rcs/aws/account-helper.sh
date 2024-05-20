#!/usr/bin/env bash
# no_set_e
set -o pipefail

aws-env-var-setup() {
  export AWS_PROFILE="${1}"
  # default is "e", which sets us-east-1; "e" sets us-west-2; anything else as-is
  REGION="${2:-e}"
  case "${REGION}" in
    w)
      REGION="us-west-2"
      ;;
    e)
      REGION="us-east-1"
      ;;
  esac

  export AWS_DEFAULT_REGION="${REGION}"
  aws sso login --profile "${AWS_PROFILE}"
  # nice confirmation that these creds work
  ACCOUNT_ID=$( aws sts get-caller-identity | jq .Account | tr -d '"' )
  export AWS_ACCOUNT_ID="${ACCOUNT_ID}"
}

aws-hardcoded-profiles () {
  echo app-dev
  echo app-prod
  echo terraform
  echo monitoring-dev
  echo monitoring-prod
  # add more as needed
}

# NOTE: currently unused, since we do SSO for login
# quick and dirty regex to pull out section-names from creds file
# where it finds "[staging]" and ignores the "[" "]" through "fancy" regex
aws-list-profile () {
  for PROFILE in $( ag -o '(?<=\[).*(?=\])' "${HOME}/.aws/credentials"); do
    echo "${PROFILE}"
  done
}

_load-aws-funcs () {
  # NOTE: this is NOT safe on untrusted input
  # for PROFILE in $(aws-list-profile); do
  for PROFILE in $(aws-hardcoded-profiles); do
    eval "aws-${PROFILE}() { aws-env-var-setup ${PROFILE} \${1}} "
  done
}

_load-aws-funcs
