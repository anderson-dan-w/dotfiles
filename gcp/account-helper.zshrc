gcp-projects () {
  echo "${GCP_DEFAULT_PROJECT}"
  echo "${GCP_SANDBOX_PROJECT}"
  # add more as needed
}

gcp-login () {
  gcloud auth login
  gcloud config set project "${GCP_PROJECT}"
}

gcp-login-tool () {
  gcloud auth application-default login
  gcloud config set project "${GCP_PROJECT}"
}

gcp-login-both () {
  gc-login
  gc-login-tool
}
