alias d="docker"
alias d-ps="docker ps --format='{{.Names}}' | sort"
alias d-clean="docker image prune && docker system prune -a"
alias d-ltf="docker logs --tail=0 --follow"

GCP_GCR_USER="oauth2accesstoken"
GCR_USER="oauth2accesstoken"

d-login-hub () {
  echo "Logging in to Docker Hub as ${DOCKERHUB_USERNAME}"
  echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
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

d-login-ghcr () {
  echo "Logging in to GitHub Container Registry"

  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "NOT IMPLEMENTED"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  # echo "${GHCR_PACKAGE_PAT}" | docker login ghcr.io -u "${GH_USERNAME}" --password-stdin
}

d-last-image () {
  docker images --format='{{.Tag}}' | head -1
}
