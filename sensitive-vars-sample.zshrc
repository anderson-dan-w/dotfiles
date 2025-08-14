GH_PAT=""

# NOTE: could abstract a little more, like multiple dirs, but whatever for now
CODE_BASE_DIR="${HOME}/coding"
CODE_DIRS=(
  # add repos here, gets used in shell-dir-utils
)

declare -A _AWS_ACCOUNTS
_AWS_ACCOUNTS["fake"]="1234"

GCP_PROJECT=""
GCP_REGION=""

DOCKERHUB_USERNAME=""
DOCKERHUB_PASSWORD=""

PROXY=""
SECURE_PROXY=""
NOPROXY=""

JOB_SPECIFIC_TOKEN=""
JOB_PHONE_NUMBER=""
