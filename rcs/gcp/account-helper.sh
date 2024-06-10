GCP_SANDBOX_PROJECT="TODO"

# NOTE: change this later?
GCP_DEFAULT_PROJECT="${GCP_SANDBOX_PROJECT}"


_gcp-hardcoded-projects () {
  echo "${GCP_SANDBOX_PROJECT}"
  # add more as needed
}

gcp-login () {
  gcloud auth login
  gcloud config set project "${GCP_DEFAULT_PROJECT}"
}

gcp-login-tool () {
  gcloud auth application-default login
  gcloud config set project "${GCP_DEFAULT_PROJECT}"
}

gcp-login-both () {
  gc-login
  gc-tool-login
}
