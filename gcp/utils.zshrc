alias gcp="gcloud"

gcp-gke-login() {
  gcloud container clusters get-credentials --location "${GCP_REGION}" "$@"
}

gke-login() {
  gcp-gke-login "$@"
}
