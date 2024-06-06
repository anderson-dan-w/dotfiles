GCP_SANDBOX_PROJECT="sandbox-dan-1a49"

# NOTE: change this later?
GCP_DEFAULT_PROJECT="${GCP_SANDBOX_PROJECT}"


_gcp-hardcoded-projects () {
  echo "${GCP_SANDBOX_PROJECT}"
  # add more as needed
}

gc-login () {
  gcloud config set project "${GCP_DEFAULT_PROJECT}"
  gcloud auth login
}

gc-tool-login () {
  gcloud config set project "${GCP_DEFAULT_PROJECT}"
  gcloud auth application-default login
}
