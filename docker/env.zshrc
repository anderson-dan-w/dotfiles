alias d="docker"
alias d-ps="docker ps --format='{{.Names}}' | sort"
alias d-clean="docker image prune && docker system prune -a"
alias d-ltf="docker logs --tail=0 --follow"

AWS_ECR_USER="AWS"
ECR_USER="AWS"

GCP_GCR_USER="oauth2accesstoken"
GCR_USER="oauth2accesstoken"

d-login-hub () {
  echo "Logging in to Docker Hub as ${DOCKERHUB_USERNAME}"
  echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
}

d-login-ecr-dev () {
  echo "logging into AWS dev ECR :: ${AWS_PROFILE}::${AWS_ACCOUNT_ID}::${AWS_DEFAULT_REGION}"
  echo "${AWS_ECR_DEV_URL}"
  export AWS_ECR_URL="${AWS_ECR_DEV_URL}"
  export ECR_URL="${AWS_ECR_URL}"

  export ECR_TOKEN=$(aws --region="${AWS_DEFAULT_REGION}" ecr get-login-password)
  echo "${ECR_TOKEN}" | docker login -u "${ECR_USER}" --password-stdin "https://${AWS_ECR_URL}"
  echo "${ECR_TOKEN}" | pbcopy
}

d-login-ecr-prod () {
  echo "logging into AWS prod ECR :: ${AWS_PROFILE}:${AWS_ACCOUNT_ID}::${AWS_DEFAULT_REGION}"
  echo "${AWS_ECR_PROD_URL}"
  export AWS_ECR_URL="${AWS_ECR_PROD_URL}"
  export ECR_URL="${AWS_ECR_URL}"

  export ECR_TOKEN=$(aws --region="${AWS_DEFAULT_REGION}" ecr get-login-password)
  echo "${ECR_TOKEN}" | docker login -u "${ECR_USER}" --password-stdin "https://${AWS_ECR_URL}"
  echo "${ECR_TOKEN}" | pbcopy
}

d-login-ecr() {
  if [[ "$1" == "dev" ]]; then
    d-login-ecr-dev
  elif [[ "$1" == "prod" ]]; then
    d-login-ecr-prod
  else
    echo "Please specify 'dev' or 'prod'"
  fi
}

d-login-gcr () {
  echo "logging into GCR: ${GCP_PROJECT}::${GCP_REGION} :: ${GCR_URL}"

  export GCR_TOKEN=$(gcloud auth print-access-token)
  echo "${GCR_TOKEN}" | docker login -u "${GCR_USER}" --password-stdin "${GCR_URL}" >/dev/null
  echo "${GCR_TOKEN}" | pbcopy
}

d-login-azr () {
  echo "logging in to Azure ACR"
  az acr login --name "${ACR_REGISTRY_NAME}"
}

d-last-image () {
  docker images --format='{{.Tag}}' | head -1
}
