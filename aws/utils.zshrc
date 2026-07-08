################################################################################
# assumes the following in sensitive:
# _AWS_PROFILES
# _AWS_ECR_PROFILES
# _AWS_DEFAULT_PROFILE
# _AWS_DEFAULT_REGION
# all AWS_<ACCOUNT_NAME>_ACCOUNT=<account id>
################################################################################

_AWS_CMD="aws"
_AWS_ALIAS="aws"
-aws-cmd-name() {
  echo "${_AWS_ALIAS}-${1}"
}

# NOTE: zsh-specific, and assumes, eg, AWS_FOO_BAR_ACCOUNT var exists, can do "{func-name} foo-bar" to get ID
_AWS_ACCT_ID_BY_NAME="$(-aws-cmd-name acct-id-by-name)"
"${_AWS_ACCT_ID_BY_NAME}"() {
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

-aws-load-login-funcs () {
  for _AWS_PROFILE in "${_AWS_PROFILES[@]}"; do
      _CMD_NAME="$(-aws-cmd-name login-${_AWS_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_LOGIN} ${_AWS_PROFILE} \${1}}"
  done
}; -aws-load-login-funcs

# convenience func because 1 login should handle all accounts (with shared SSO configuration)
_AWS_SIMPLE_LOGIN="$(-aws-cmd-name login)"
"${_AWS_SIMPLE_LOGIN}"() {
    "${_AWS_LOGIN}" "${_AWS_DEFAULT_PROFILE}"
}

#########
# AWS ECR
#########

AWS_ECR_USER="AWS"

-aws-ecr-url() {
    _AWS_ACCOUNT="$(${_AWS_ACCT_ID_BY_NAME} ${1})"
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
      # alternative: d-login
      _D_LOGIN_CMD_NAME="d-login-aws-${_AWS_ECR_PROFILE}"
      eval "${_D_LOGIN_CMD_NAME}() { ${_AWS_ECR_LOGIN} ${_AWS_ECR_PROFILE}}"
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

_AWS_EC2_DESCRIBE="$(-aws-cmd-name ec2-describe)"
"${_AWS_EC2_DESCRIBE}"() {
  "${_AWS_CMD}" ec2 describe-instances --filters="Name=tag:Name,Values=${1}*" | \
      jq -r ' .Reservations[] .Instances[]
        | [.InstanceId, .PrivateIpAddress, .InstanceType, .State.Name]
        | @tsv
      '
}

#######################################################################
# SSM
#######################################################################

# SSMs into either an instance id OR the first instance return from an "ec2" listing
# switches to supplied user (ubuntu default) and into $HOME dir for convenience
#   -aws-ssm i-01234...   # specific instance
#   -aws-ssm api-staging  # whichever api-staging machine ec2 returns first
#   -aws-ssm dan-dev-box dan  # pops into /home/dan as user=dan
_AWS_SSM="$(-aws-cmd-name ssm)"
-aws-ssm () {
  _DEFAULT_SSM_USER="ubuntu"
  if [[ "${1}" =~ i-0 ]]
  then
    _AWS_INSTANCE_ID="${1}"
  else
    _AWS_INSTANCE_INFO="$( ${_AWS_EC2_DESCRIBE} "${1}" | head -1 )"
  fi
  echo "INSTANCE:${_AWS_INSTANCE_INFO}"
  _AWS_SSM_USER="${2:-${_DEFAULT_SSM_USER}}"
  _AWS_INSTANCE_ID="$( echo "${_AWS_INSTANCE_INFO}" | cut -f1 )"
  "${_AWS_CMD}" ssm start-session \
      --target "${_AWS_INSTANCE_ID}" \
      --document-name "AWS-StartInteractiveCommand" \
      --parameters "command=cd /home/${_AWS_SSM_USER}; sudo su  ${_AWS_SSM_USER}"
}
