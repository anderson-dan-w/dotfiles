alias k=kubectl
alias k-tx=kubectx
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
  if [[ "${4}" == "" ]] || [[ "${4}" == "--force" ]] ; then
    echo "ERROR: failed to set secret for $(k-tx -c)"
    echo "usage: k-registry-...  <secret-name> [--force]"
    return
  fi
  SECRET_NAME="${4}"
  if [[ "${5}" == "--force" ]] ; then
      kubectl delete secret "${SECRET_NAME}"
      echo
  fi

  echo "storing secret for registry ${SECRET_NAME}"
  kubectl create secret docker-registry "${SECRET_NAME}" \
    --docker-server="${1}" \
    --docker-username="${2}" \
    --docker-password="${3}" \
    --docker-email="dan@distributional.com"
}

k-registry-gcp() {
  d-login-gcr
  k-registry-secret "${GCR_URL}" "${GCR_USER}" "${GCR_TOKEN}" "$@"
}

k-registry-aws-dev() {
  d-login-ecr-dev
  k-registry-secret "${ECR_URL}" "${ECR_USER}" "${ECR_TOKEN}" "$@"
}

k-registry-aws-prod() {
  d-login-ecr-prod
  k-registry-secret "${ECR_URL}" "${ECR_USER}" "${ECR_TOKEN}" "$@"
}

k-tls-secret() {
  SECRET_NAME="${1:-tls-secret}"
  CERT_FILE="${2:-${HOME}/.config/dbnl/tls/tls.crt}"
  KEY_FILE="${3:-${HOME}/.config/dbnl/tls/tls.key}"
  if [[ "${4}" == "--force" ]] ; then
      kubectl delete secret "${SECRET_NAME}"
  fi

  echo "storing secret for tls ${SECRET_NAME}"
  kubectl create secret tls "${SECRET_NAME}" \
    --cert="${CERT_FILE}" \
    --key="${KEY_FILE}"
}
