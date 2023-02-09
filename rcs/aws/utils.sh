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

# ec2 will query for ec2 instances by name, with option wildcard
# returns tab-separated: instance-id, private-ip, name
# examples on staging account
#   ec2 'api*'  ## returns api-staging instances, since wildcard passed in
#   ec2 api     ## returns nothing, since no machines named exactly "api"
ec2 () {
  aws ec2 describe-instances --filters="Name=tag:Name,Values=${1}*" | jq -r ' .Reservations[] .Instances[] | select(.State.Name == "running") | [.InstanceId, .PrivateIpAddress, (.Tags[]|select(.Key=="Name")|.Value)] | @tsv'
}

################################################################################
# AWS SSM
#############

# SSMs into either an instance id OR the first instance return from an "ec2" listing
# switches to supplied user (ubuntu default) and into sigot-api dir for convenience
#   ssm i-01234...   # specific instance
#   ssm api-staging  # whichever api-staging machine ec2 returns first
#   ssm dan-dev-box dan  # pops into /home/dan/sigopt-api as user=dan
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
  aws ssm start-session --target "${instance_id}" --parameters "command=cd /home/${SSM_USER}/sigopt-api; sudo su  ${SSM_USER}" --document-name "AWS-StartInteractiveCommand"
}
