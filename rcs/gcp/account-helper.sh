#!/usr/bin/env bash
# no_set_e
set -o pipefail

_gcp-env-var-setup() {
  # TODO: eventually add options (profile / configuration?, project, region/zone)
  GCP_DEFAULT_REGION="$(gcloud config get-value compute/region)"
  GCP_PROJECT="$(gcloud config get-value project)"

  if gcloud auth list --format json | jq -r '.[].status' == "ACTIVE" > /dev/null 2>&1; then
    echo already logged in to "${GCP_PROJECT}" in "${GCP_DEFAULT_REGION}"
  else
    gcloud auth login
    #gcloud config set project "${GCP_PROJECT}"
    #gcloud config set compute/region "${GCP_DEFAULT_REGION}"
  fi
}

_gcp-hardcoded-projects () {
  echo sandbox-dan-1a49
  # add more as needed
}

_load-gcp-funcs () {
  for PROFILE in $(_gcp-hardcoded-projects); do
    eval "gcp-${PROFILE}() { _gcp-env-var-setup; }"
  done
}

_load-gcp-funcs
