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
