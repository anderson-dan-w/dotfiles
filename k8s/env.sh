alias k=kubectl
alias k-tx=kubectx
alias k-ns=kubens
alias k-nss="kubens | cat"

alias h=helm

k-all() {
  kubectl api-resources --verbs=list --namespaced -o name  | xargs -n 1 kubectl get --show-kind --ignore-not-found  -n "${1}" | ag -v "^NAME" | cut -d' ' -f1 | ag -v '^\d+[smh]'
}

k-store-registry-secret() {
  SECRET_NAME="dbnl-registry"
  if [[ "${4}" == "--force" ]] ; then
      kubectl delete secret "${SECRET_NAME}"
  fi

  echo "storing secret for registry ${SECRET_NAME}"
  kubectl create secret docker-registry "${SECRET_NAME}" \
    --docker-server="${1}" \
    --docker-username="${2}" \
    --docker-password="${3}" \
    --docker-email="dan@distributional.com"
}

k-store-gcp-registry() {
  GCR_URL="us-docker.pkg.dev/dbnlai"
  GCR_USER="oauth2accesstoken"
  GCR_TOKEN=$(gcloud auth print-access-token)
  k-store-registry-secret "${GCR_URL}" "${GCR_USER}" "${GCR_TOKEN}" "$@"
}

_k-store-aws-registry() {
  ECR_URL="${1}" && shift
  ECR_USER="AWS"
  ECR_TOKEN=$(aws --region="${AWS_DEFAULT_REGION}" ecr get-login-password)
  k-store-registry-secret "${ECR_URL}" "${ECR_USER}" "${ECR_TOKEN}" "$@"
}

k-store-aws-dev() {
  ECR_URL="729505466205.dkr.ecr.us-east-1.amazonaws.com"
  _k-store-aws-registry "${ECR_URL}" "$@"
}

k-store-aws-prod() {
  ECR_URL="203721542088.dkr.ecr.us-east-1.amazonaws.com"
  _k-store-aws-registry "${ECR_URL}" "$@"
}
