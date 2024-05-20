alias k=kubectl
alias k-tx=kubectx
alias k-ns=kubens
alias k-nss="kubens | cat"
k-all() {
  kubectl api-resources --verbs=list --namespaced -o name  | xargs -n 1 kubectl get --show-kind --ignore-not-found  -n "${1}" | ag -v "^NAME" | cut -d' ' -f1
}
