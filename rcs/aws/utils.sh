################################################################################
# AWS Billing
#############
aws-bills() {
  AP="${1:-${AWS_PROFILE}}"
  THIS_MONTH=$( date  "+%Y-%m-01")
  LAST_MONTH=$(date -v-1m "+%Y-%m-01")
  SPEND=$(aws ce get-cost-and-usage \
    --profile "$AP" \
    --time-period "Start=${LAST_MONTH},End=${THIS_MONTH}" \
    --granularity MONTHLY \
    --metrics "BlendedCost" | jq -r '.ResultsByTime[0].Total.BlendedCost.Amount | tonumber | floor'
  )
  echo "${AP}: ${SPEND}"
}

all-aws-bills () {
  for PROFILE in $(aws-list-profile); do
    aws-bills "${PROFILE}"
  done
}

################################################################################
# AWS EC2
#############

# ec2 will query for ec2 instances by name, with trailing wildcard for convenience
# returns tab-separated: instance-id, private-ip, name
# eg: `ec2 dan` would SSM onto the "first" box named dan*, such as dan-dev-box
ec2 () {
  aws ec2 describe-instances --filters="Name=tag:Name,Values=${1}*" | jq -r ' .Reservations[] .Instances[] | select(.State.Name == "running") | [.InstanceId, .PrivateIpAddress, (.Tags[]|select(.Key=="Name")|.Value)] | @tsv'
}

################################################################################
# AWS SSM
#############

# SSMs into either an instance id OR the first instance return from an "ec2" listing
# switches to supplied user (ubuntu default) and into $HOME dir for convenience
#   ssm i-01234...   # specific instance
#   ssm api-staging  # whichever api-staging machine ec2 returns first
#   ssm dan-dev-box dan  # pops into /home/dan as user=dan
ssm () {
  if [[ "${1}" =~ i-0 ]]
  then
    instance="${1}"
  else
    instance="$( ec2 "${1}" | head -1 )"
  fi
  echo "instance:${instance}"
  SSM_USER="${2:-ubuntu}"
  instance_id="$( echo "${instance}" | cut -f1 )"
  aws ssm start-session --target "${instance_id}" --parameters "command=cd /home/${SSM_USER}; sudo su  ${SSM_USER}" --document-name "AWS-StartInteractiveCommand"
}
