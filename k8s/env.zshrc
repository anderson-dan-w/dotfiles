alias k=kubectl
alias k-tx=kubectx
alias k-txs="kubectx | cat"
alias k-ns=kubens
alias k-nss="kubens | cat"

alias h=helm

k-gp() {
  kubectl get pods "$@"
}

k-all() {
  kubectl api-resources --verbs=list --namespaced -o name  | xargs -n 1 kubectl get --show-kind --ignore-not-found  -n "${1}" | ag -v "^NAME" | cut -d' ' -f1 | ag -v '^\d+[smh]'
}

k-registry-secret() {
  echo
  _REGISTRY_SERVER="${1}" && shift
  _REGISTRY_USER="${1}" && shift
  _REGISTRY_TOKEN="${1}" && shift
  if [[ "${1}" == "" ]] || [[ "${1}" == "--force" ]] ; then
    echo "ERROR: failed to set secret for $(k-tx -c)"
    echo "usage: k-registry-...  <secret-name> [--force]"
    return
  fi
  _K8S_REGISTRY_SECRET_NAME="${1}"
  if [[ "${2}" == "--force" ]] ; then
      kubectl delete secret "${_K8S_REGISTRY_SECRET_NAME}"
      echo
  fi

  echo "storing secret for registry ${_K8S_REGISTRY_SECRET_NAME}"
  kubectl create secret docker-registry "${_K8S_REGISTRY_SECRET_NAME}" \
    --docker-server="${_REGISTRY_SERVER}" \
    --docker-username="${_REGISTRY_USER}" \
    --docker-password="${_REGISTRY_TOKEN}" \
    --docker-email="dan@distributional.com"
}

k-registry-gcp() {
  d-login-gcr
  k-registry-secret "${GCR_URL}" "${GCR_USER}" "${GCR_TOKEN}" "$@"
}

k-registry-aws-dev() {
  aws-ecr-app-dev
  k-registry-secret "${AWS_ECR_URL}" "${AWS_ECR_USER}" "${AWS_ECR_TOKEN}" "$@"
}

k-registry-aws-prod() {
  aws-ecr-app-prod
  k-registry-secret "${AWS_ECR_URL}" "${AWS_ECR_USER}" "${AWS_ECR_TOKEN}" "$@"
}

k-tls-secret() {
  _K8S_TLS_SECRET_NAME="${1:-tls-secret}"
  _CERT_FILE="${2:-${HOME}/.config/dbnl/tls/tls.crt}"
  _KEY_FILE="${3:-${HOME}/.config/dbnl/tls/tls.key}"
  # TODO: well this won't work right if 1 thru 3 are defaults and there is no 4...
  if [[ "${4}" == "--force" ]] ; then
      kubectl delete secret "${_K8S_TLS_SECRET_NAME}"
  fi

  echo "storing secret for tls ${_K8S_TLS_SECRET_NAME}"
  kubectl create secret tls "${_K8S_TLS_SECRET_NAME}" \
    --cert="${_CERT_FILE}" \
    --key="${_KEY_FILE}"
}
