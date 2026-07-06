################################################################################
# assumes the following in sensitive:
# _AWS_DEFAULT_PROFILE
# _AWS_DEFAULT_REGION
# all AWS_<ACCOUNT_NAME>_ACCOUNT=<account id>
################################################################################

_AWS_CMD="aws"
_AWS_ALIAS="aws"
-aws-cmd-name() { echo "${_AWS_ALIAS}-${1}" }

_AWS_PROFILES="$(-aws-cmd-name profiles)"
"${_AWS_PROFILES}"() {
  "${_AWS_CMD}" configure list-profiles
}

# profile name in aws configs; check $_AWS_PROFILES for available profiles
_AWS_ACCT_ID_BY_NAME="$(-aws-cmd-name acct-id-by-name)"
"${_AWS_ACCT_ID_BY_NAME}"() {
    _AWS_PROFILE="${1:${_AWS_DEFAULT_PROFILE}}"
    ${_AWS_CMD} configure get sso_account_id --profile "${_AWS_PROFILE}"
}

_AWS_LOGIN="$(-aws-cmd-name -login)"
"${_AWS_LOGIN}"() {
  export AWS_PROFILE="${1:?profile name required}"
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
    for _AWS_PROFILE in $( "${_AWS_PROFILES}" ); do
      _CMD_NAME="$(-aws-cmd-name login-${_AWS_PROFILE})"
      eval "${_CMD_NAME}() { ${_AWS_LOGIN} ${_AWS_PROFILE} \${1}}"
  done
}; -aws-load-login-funcs

# no-arg will login to default profile, setting AWS_PROFILE
_AWS_SIMPLE_LOGIN="$(-aws-cmd-name login)"
"${_AWS_SIMPLE_LOGIN}"() {
    _AWS_DEFAULT_PROFILE="${1:-${_AWS_DEFAULT_PROFILE}}"
    "${_AWS_LOGIN}" "${_AWS_DEFAULT_PROFILE}"
}

#########
# AWS ECR
#########

_AWS_ECR_USER="AWS"

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
    echo "${AWS_ECR_TOKEN}" | docker login --username "${_AWS_ECR_USER}" --password-stdin "${AWS_ECR_URL}"
    echo "${AWS_ECR_TOKEN}" | pbcopy
}

-aws-load-ecr-funcs () {
  for _AWS_ECR_PROFILE in $( "${_AWS_PROFILES}" ); do
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
  for _AWS_ECR_PROFILE in $( "${_AWS_PROFILES}" ); do
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

_AWS_EC2_OPEN_TUNNEL="$(-aws-cmd-name ec2-open-tunnel)"
"${_AWS_EC2_OPEN_TUNNEL}"() {
  _INSTANCE_ID=
  _PROFILE="${AWS_PROFILE}"
  _LOCAL_PORT="8022"
  _REGION="us-east-1"

  _EXTRA_ARGS=()

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      -i|--instance-id)
        _INSTANCE_ID="${2:?instance id required after ${1}}"
        shift 2
      ;;
      -l|--local-port)
        _LOCAL_PORT="${2:?local port required after ${1}}"
        shift 2
      ;;
      -r|--region)
        _REGION="${2:?region required after ${1}}"
        shift 2
      ;;
      -p|--profile)
        _PROFILE="${2:?profile required after ${1}}"
        shift 2
      ;;
      --)
        shift
        _EXTRA_ARGS+=("$@")
        break
      ;;
      *)
        _EXTRA_ARGS+=("${1}")
        shift
      ;;
    esac
  done

  _CMD=("${_AWS_CMD}" ec2-instance-connect open-tunnel)
  _CMD+=(--instance-id "${_INSTANCE_ID}")
  _CMD+=(--local-port "${_LOCAL_PORT}")
  _CMD+=(--region "${_REGION}")
  [[ -n "${_PROFILE}" ]] && _CMD+=(--profile "${_PROFILE}")
  _CMD+=("${_EXTRA_ARGS[@]}")

  echo "Opening tunnel to ${_INSTANCE_ID}::${_LOCAL_PORT} (${_REGION}) as ${_PROFILE}"
  "${_CMD[@]}"
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
"${_AWS_SSM}"() {
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

_AWS_SET_CREDS="$(-aws-cmd-name set-creds)"
"${_AWS_SET_CREDS}"() {
  _AWS_PROFILE="${1:?profile name required}" && shift
  _AWS_REGION="${1:-${AWS_DEFAULT_REGION}}"
  eval "$($_AWS_CMD configure export-credentials --profile $_AWS_PROFILE --format env)"
}
