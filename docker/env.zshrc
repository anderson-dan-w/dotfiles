alias d="docker"
alias d::ps="docker ps --format='{{.Names}}' | sort"
alias d::clean="docker image prune && docker system prune -a"
alias d::ltf="docker logs --tail=0 --follow"

d::login::hub () {
  echo "Logging in to Docker Hub as ${DOCKERHUB_USERNAME}"
  echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
}

d::login::ecr () {
  echo logging in to AWS ECR
  echo "${AWS_PROFILE} - ${AWS_ACCOUNT_ID} - ${AWS_DEFAULT_REGION}"
  echo "${AWS_ECR_URL}"
  aws --region="${AWS_DEFAULT_REGION}" ecr get-login-password | docker login -u AWS --password-stdin "https://${AWS_ECR_URL}"
}

d::login::gcr () {
  echo "logging in to GCP GCR"
  gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin "${GCP_GCR_URL}"
}

d::login::azr () {
  echo "logging in to Azure ACR"
  az acr login --name "${ACR_REGISTRY_NAME}"
}
