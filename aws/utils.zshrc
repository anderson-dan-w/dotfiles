-aws-cmd-name() {
  _AWS_CMD_PREFIX="aws"
  echo "${_AWS_CMD_PREFIX}-${1}"
}

##############
# AWS PROFILES
##############

_AWS_DEFAULT_REGION="us-east-1"
AWS_DEFAULT_REGION="${_AWS_DEFAULT_REGION}"

_AWS_PROFILES=(
  app-dev
  app-prod
  terraform
  monitoring-dev
  # monitoring-prod
  # networking
  # add more as needed
)

_AWS_DEFAULT_PROFILE="app-dev"
AWS_PROFILE="${_AWS_DEFAULT_PROFILE}"

# NOTE: zsh-specific, and assumes, eg, AWS_APP_DEV_ACCOUNT var exists
-aws-account-id-by-name() {
    VAR_NAME="AWS_${(U)${1/-/_}}_ACCOUNT"
    echo "${(P)VAR_NAME}"
}

_AWS_LOGIN="$(-aws-cmd-name -login)"
"${_AWS_LOGIN}"() {
  export AWS_PROFILE="${1}"
  export AWS_DEFAULT_REGION="${2:-${_AWS_DEFAULT_REGION}}"

  if aws sts get-caller-identity > /dev/null 2>&1; then
    echo already logged in to "${AWS_PROFILE}" in "${AWS_DEFAULT_REGION}"
  else
    aws sso login --profile "${AWS_PROFILE}"
  fi
  export AWS_ACCOUNT_ID=$( aws sts get-caller-identity | jq -r ".Account" )
}

-aws-load-funcs () {
  for _PROFILE in "${_AWS_PROFILES[@]}"; do
      _CMD_NAME="$(-aws-cmd-name ${_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_LOGIN} ${_PROFILE} \${1}}"
  done
}; -aws-load-funcs

#########
# AWS ECR
#########

AWS_ECR_USER="AWS"

_AWS_ECR_PROFILES=(
    app-dev
    app-prod
)

-aws-ecr-url() {
    _AWS_ACCOUNT="$(-aws-account-id-by-name ${1})"
    echo "${_AWS_ACCOUNT}.dkr.ecr.${2:-${AWS_DEFAULT_REGION}}.amazonaws.com"
}

_AWS_ECR_LOGIN="$(-aws-cmd-name -ecr-login)"
"${_AWS_ECR_LOGIN}"() {
    _AWS_PROFILE="${1:-${AWS_PROFILE}}"
    AWS_ECR_URL="$(-aws-ecr-url ${_AWS_PROFILE})"
    echo "logging in to ${AWS_ECR_URL}"

    AWS_ECR_TOKEN=$(aws ecr get-login-password --profile "${_AWS_PROFILE}" --region "${AWS_DEFAULT_REGION}")
    echo "${AWS_ECR_TOKEN}" | docker login --username "${AWS_ECR_USER}" --password-stdin "${AWS_ECR_URL}"
    echo "${AWS_ECR_TOKEN}" | pbcopy
}

-aws-load-ecr-funcs () {
  for _AWS_ECR_PROFILE in "${_AWS_ECR_PROFILES[@]}"; do
      _CMD_NAME="$(-aws-cmd-name ecr-${_AWS_ECR_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_ECR_LOGIN} ${_AWS_ECR_PROFILE}}"
  done
}; -aws-load-ecr-funcs
