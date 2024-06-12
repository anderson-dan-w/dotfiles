alias gcp="gcloud"

gke-login() {
  gcloud container clusters get-credentials --location us-central1 "$@"
}
