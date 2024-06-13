aws--account() {
  export AWS_PROFILE="${1}"
  # default is "e", which sets us-east-1; "w" sets us-west-2; anything else as-is
  REGION="${2:-e}"
  case "${REGION}" in
    e)
      REGION="us-east-1"
      ;;
    w)
      REGION="us-west-2"
      ;;
  esac

  export AWS_DEFAULT_REGION="${REGION}"
  if aws sts get-caller-identity > /dev/null 2>&1; then
    echo already logged in to "${AWS_PROFILE}" in "${AWS_DEFAULT_REGION}"
  else
    aws sso login --profile "${AWS_PROFILE}"
  fi
  # nice confirmation that these creds work
  ACCOUNT_ID=$( aws sts get-caller-identity | jq .Account | tr -d '"' )
  export AWS_ACCOUNT_ID="${ACCOUNT_ID}"
}

aws-profiles () {
  echo app-dev
  echo app-prod
  echo terraform
  echo monitoring-dev
  echo monitoring-prod
  # add more as needed
}

aws--load-funcs () {
  for PROFILE in $(aws-profiles); do
    eval "aws-${PROFILE}() { aws--account ${PROFILE} \${1}} "
  done
}

aws--load-funcs
