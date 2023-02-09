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
