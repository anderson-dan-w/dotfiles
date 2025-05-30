_AWS_CMD="aws"
_AWS_ALIAS="aws"

-aws-cmd-name() {
  echo "${_AWS_ALIAS}-${1}"
}

##############
# AWS PROFILES
##############

_AWS_DEFAULT_REGION="us-east-1"
AWS_DEFAULT_REGION="${_AWS_DEFAULT_REGION}"

# AWS Profile names are not sensitive
_AWS_PROFILES=(
  app-dev
  app-staging
  app-prod
  app-prod-readonly
  genai
  genai-user
  monitoring-dev
  terraform
  sandbox-dan
  # monitoring-prod
  # networking
  # add more as needed
)

_AWS_DEFAULT_PROFILE="app-dev"
AWS_PROFILE="${_AWS_DEFAULT_PROFILE}"

# NOTE: zsh-specific, and assumes, eg, AWS_APP_DEV_ACCOUNT var exists
# could also do a loop-check on the _AWS_PROFILES var...
-aws-account-id-by-name() {
    VAR_NAME="AWS_${(U)${1/-/_}}_ACCOUNT"
    echo "${(P)VAR_NAME}"
}

_AWS_LOGIN="$(-aws-cmd-name -login)"
"${_AWS_LOGIN}"() {
  export AWS_PROFILE="${1}"
  export AWS_DEFAULT_REGION="${2:-${_AWS_DEFAULT_REGION}}"

  if "${_AWS_CMD}" sts get-caller-identity > /dev/null 2>&1; then
    echo already logged in to "${AWS_PROFILE}" in "${AWS_DEFAULT_REGION}"
  else
    "${_AWS_CMD}" sso login --profile "${AWS_PROFILE}"
    echo
    echo "logged in to ${AWS_PROFILE} in ${AWS_DEFAULT_REGION}"
  fi
  export AWS_ACCOUNT_ID=$( "${_AWS_CMD}" sts get-caller-identity | jq -r ".Account" )
}

-aws-load-funcs () {
  for _AWS_PROFILE in "${_AWS_PROFILES[@]}"; do
      _CMD_NAME="$(-aws-cmd-name login-${_AWS_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_LOGIN} ${_AWS_PROFILE} \${1}}"
  done
}; -aws-load-funcs

# convenience func because 1 login should handle all accounts (with shared SSO configuration)
_AWS_SIMPLE_LOGIN="$(-aws-cmd-name login)"
"${_AWS_SIMPLE_LOGIN}"() {
    "${_AWS_LOGIN}" "${_AWS_DEFAULT_PROFILE}"
}

#########
# AWS ECR
#########

AWS_ECR_USER="AWS"

_AWS_ECR_PROFILES=(
    app-dev
    app-staging
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

    AWS_ECR_TOKEN=$("${_AWS_CMD}" ecr get-login-password --profile "${_AWS_PROFILE}" --region "${AWS_DEFAULT_REGION}")
    echo "${AWS_ECR_TOKEN}" | docker login --username "${AWS_ECR_USER}" --password-stdin "${AWS_ECR_URL}"
    echo "${AWS_ECR_TOKEN}" | pbcopy
}

-aws-load-ecr-funcs () {
  for _AWS_ECR_PROFILE in "${_AWS_ECR_PROFILES[@]}"; do
      _CMD_NAME="$(-aws-cmd-name ecr-${_AWS_ECR_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_ECR_LOGIN} ${_AWS_ECR_PROFILE}}"
  done
}; -aws-load-ecr-funcs

#########
# AWS EKS
#########

_AWS_EKS_CLUSTERS_LIST="$(-aws-cmd-name eks-clusters)"
"${_AWS_EKS_CLUSTERS_LIST}"() {
    "${_AWS_CMD}" eks list-clusters "$@" | jq -r ".clusters[]"
}

_AWS_EKS_CONFIG="$(-aws-cmd-name eks-update-config)"
"${_AWS_EKS_CONFIG}"() {
    _CLUSTER_NAME="${1:?cluster name required}" && shift
    "${_AWS_CMD}" eks update-kubeconfig --name "${_CLUSTER_NAME}" "$@"
}

_AWS_EKS_DEFAULT_CLUSTER="$(-aws-cmd-name eks-default-cluster)"
"${_AWS_EKS_DEFAULT_CLUSTER}"() {
    PROFILE="${1:?profile name required}" && shift
    "${_AWS_LOGIN}" "${PROFILE}"
    "${_AWS_EKS_CONFIG}" "${PROFILE/-/-eks-}" "$@"
}

-aws-load-eks-clusters() {
  for _AWS_EKS_PROFILE in "${_AWS_ECR_PROFILES[@]}"; do
      _CMD_NAME="$(-aws-cmd-name eks-${_AWS_EKS_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_EKS_DEFAULT_CLUSTER} ${_AWS_EKS_PROFILE}}"
  done
}; -aws-load-eks-clusters
