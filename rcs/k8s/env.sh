alias k=kubectl
alias k-tx=kubectx
alias k-ns=kubens
alias k-nss="kubens | cat"
k-all() {
  kubectl api-resources --verbs=list --namespaced -o name  | xargs -n 1 kubectl get --show-kind --ignore-not-found  -n "${1}" | ag -v "^NAME" | cut -d' ' -f1 | ag -v '^\d+[smh]'
}

k-store-registry-secret() {
  if [ -z "${GCR_TOKEN-}" ] ; then
    echo "ERROR: could not find GCR_TOKEN ; may need to (re) login to gcr: \`gcr-login\`"
    return 1
  fi
  SECRET_NAME="dbnl-registry"
  if [[ "${1}" == "--force" ]] ; then
      kubectl delete secret "${SECRET_NAME}"
  fi

  echo "storing secret for registry ${SECRET_NAME}"
  kubectl create secret docker-registry "${SECRET_NAME}" \
    --docker-server="${GCR_URL}" \
    --docker-username="${GCR_USER}" \
    --docker-password="${GCR_TOKEN}" \
    --docker-email="dan@distributional.com"
}
