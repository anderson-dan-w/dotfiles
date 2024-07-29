_GCLOUD_CMD="gcloud"
_GCLOUD_ALIAS="gcp"
alias "${_GCLOUD_ALIAS}"="${_GCLOUD_CMD}"

-gcloud-cmd-name() {
  echo "${_GCLOUD_ALIAS}-${1}"
}

###########
# GCP login
###########

_GCP_DEFAULT_REGION="us-central1"
GCP_REGION="${_GCP_DEFAULT_REGION}"

_GCLOUD_LOGIN_SELF="$(-gcloud-cmd-name login-self)"
"${_GCLOUD_LOGIN_SELF}"() {
  if [[ $(yes | "${_GCLOUD_CMD}" projects list 2>/dev/null) ]]; then
    echo "already logged in for GCP self account"
  else
    "${_GCLOUD_CMD}" auth login
    "${_GCLOUD_CMD}" config set project "${GCP_DEFAULT_PROJECT}"
  fi
}

_GCLOUD_LOGIN_APP="$(-gcloud-cmd-name login-app)"
"${_GCLOUD_LOGIN_APP}"() {
  if [[ $("${_GCLOUD_CMD}" auth application-default print-access-token 2>/dev/null) ]]; then
    echo "already logged in for GCP application-default"
  else
    "${_GCLOUD_CMD}" auth application-default login
    "${_GCLOUD_CMD}" config set project "${GCP_DEFAULT_PROJECT}"
  fi
}

_GCLOUD_LOGIN="$(-gcloud-cmd-name login)"
"${_GCLOUD_LOGIN}"() {
  "${_GCLOUD_LOGIN_SELF}"
  "${_GCLOUD_LOGIN_APP}"
}

##########
# GCP GCR
##########

GCP_ECR_USER="oauth2accesstoken"

_GCP_GCR_PROJECTS=(
    dbnlai
)

-gcp-gcr-url() {
  echo "us-docker.pkg.dev/${1}"
}

_GCP_GCR_LOGIN="$(-gcloud-cmd-name -gcr-login)"
"${_GCP_GCR_LOGIN}"() {
  _GCP_PROJECT="${1:-${GCP_DEFAULT_PROJECT}}"
  GCP_GCR_URL="$(-gcp-gcr-url "${_GCP_PROJECT}")"
  echo "logging in to ${GCP_GCR_URL}"

  GCP_GCR_TOKEN="$("${_GCLOUD_CMD}" auth print-access-token)"
  echo "${GCP_GCR_TOKEN}" | docker login -u "${GCP_GCR_USER}" --password-stdin "${GCP_GCR_URL}"
  echo "${GCP_GCR_TOKEN}" | pbcopy
}

-gcp-load-ecr-funcs() {
  for _GCP_GCR_PROJECT in "${_GCP_GCR_PROJECTS[@]}"; do
    _CMD_NAME="$(-gcloud-cmd-name gcr-login-${_GCP_GCR_PROJECT})"
    eval "${_CMD_NAME}() { ${_GCP_GCR_LOGIN} ${_GCP_GCR_PROJECT} }"
  done
}; -gcp-load-ecr-funcs

#########
# GCP GKE
#########

_GCP_GKE_CLUSTERS_LIST="$(-gcloud-cmd-name gke-clusters)"
"${_GCP_GKE_CLUSTERS_LIST}"() {
  "${_GCLOUD_CMD}" container clusters list --format="value(name,status)"
}

_GCP_GKE_CONFIG="$(-gcloud-cmd-name gke-config)"
"${_GCP_GKE_CONFIG}"() {
  _CLUSTER_NAME="${1:?cluster name required}" && shift
  "${_GCLOUD_CMD}" container clusters get-credentials --location "${GCP_REGION}" "${_CLUSTER_NAME}"  "$@"
}
