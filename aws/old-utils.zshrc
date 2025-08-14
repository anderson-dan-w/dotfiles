################################################################################
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Currently unused, hence leading "-" in function names
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
################################################################################

#############
# AWS EC2
#############

# -aws-ec2 will query for ec2 instances by name, with trailing wildcard for convenience
# returns tab-separated: instance-id, private-ip, name
-aws-ec2 () {
  aws ec2 describe-instances --filters="Name=tag:Name,Values=${1}*" | \
      jq -r ' .Reservations[] .Instances[]
        | select(.State.Name == "running")
        | [.InstanceId, .PrivateIpAddress, (.Tags[]|select(.Key=="Name")|.Value)]
        | @tsv
      '
}

#############
# AWS SSM
#############

# SSMs into either an instance id OR the first instance return from an "ec2" listing
# switches to supplied user (ubuntu default) and into $HOME dir for convenience
#   -aws-ssm i-01234...   # specific instance
#   -aws-ssm api-staging  # whichever api-staging machine ec2 returns first
#   -aws-ssm dan-dev-box dan  # pops into /home/dan as user=dan
-aws-ssm () {
  _DEFAULT_SSM_USER="ubuntu"
  if [[ "${1}" =~ i-0 ]]
  then
    _AWS_INSTANCE="${1}"
  else
    _AWS_INSTANCE="$( -aws-ec2 "${1}" | head -1 )"
  fi
  echo "INSTANCE:${_AWS_INSTANCE}"
  _AWS_SSM_USER="${2:-${_DEFAULT_SSM_USER}}"
  _AWS_INSTANCE_ID="$( echo "${_AWS_INSTANCE}" | cut -f1 )"
  aws ssm start-session \
      --target "${_AWS_INSTANCE_ID}" \
      --parameters "command=cd /home/${_AWS_SSM_USER}; sudo su  ${_AWS_SSM_USER}" --document-name "AWS-StartInteractiveCommand"
}

#############
# AWS ELBv2
#############

# Checks the health of all target groups in the account, or for the supplied name
-aws-lb-health() {
  for ARN in $(aws elbv2 describe-target-groups | jq -r '.TargetGroups[].TargetGroupArn' | ag "${1}"); do
    echo "$(basename $(dirname "${ARN}"))"
    aws elbv2 describe-target-health --target-group-arn "${ARN}" | \
        jq -r '.TargetHealthDescriptions[]
            | [.Target.Id, .TargetHealth.State, .TargetHealth.Description]
            | @tsv
        '
  done
}

#############
# AWS Billing
#############
-aws-bills() {
  _AWS_PROFILE="${1:-${AWS_PROFILE}}"
  _THIS_MONTH=$( date  "+%Y-%m-01")
  _LAST_MONTH=$(date -v-1m "+%Y-%m-01")
  _SPEND=$(aws ce get-cost-and-usage \
    --profile "$_AWS_PROFILE" \
    --time-period "Start=${_LAST_MONTH},End=${_THIS_MONTH}" \
    --granularity MONTHLY \
    --metrics "BlendedCost" | jq -r '.ResultsByTime[0].Total.BlendedCost.Amount | tonumber | floor'
  )
  echo "${_LAST_MONTH} :: ${_AWS_PROFILE}: ${_SPEND}"
}

-aws-bills-all () {
  for PROFILE in "${_AWS_PROFILES}"; do
    -aws-bills "${_AWS_PROFILE}"
  done
}
