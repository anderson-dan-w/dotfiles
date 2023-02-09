alias d="docker"
alias d-ps="docker ps --format='{{.Names}}' | sort"
alias d-ltf="docker logs --tail=0 --follow"
alias d-clean="docker image prune && docker system prune -a"

DOCKERHUB_USERNAME="<name-here>"
DOCKERHUB_PASSWORD="<bad-practice>"

dh-login () {
  echo "Logging in to Docker Hub as ${DOCKERHUB_USERNAME}"
  echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
}

# AWS ECR, assume aws-account-helper.sh functions / variables set
ecr-login () {
  echo logging in to AWS ECR
  echo "${AWS_PROFILE} - ${AWS_ACCOUNT_ID} - ${AWS_DEFAULT_REGION}"
  echo "${AWS_ECR_URL}"
  aws --region="${AWS_DEFAULT_REGION}" ecr get-login-password | docker login -u AWS --password-stdin "https://${AWS_ECR_URL}"
}

# GCP GCR, assumes some variables and installs (gcloud) that I don't have (yet)
gcr-login () {
  echo "logging in to GCP GCR"
  gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin "${GCP_GCR_URL}"
}

# azure AZR, assumes some variables and installs (az) that I don't have (yet)
acr-login () {
  echo "logging in to Azure ACR"
  az acr login --name "${ACR_REGISTRY_NAME}"
}
