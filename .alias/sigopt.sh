if [ -f "${HOME}/.nvm/nvm.sh" ]; then
  # shellcheck source=../.nvm/nvm.sh
  . "${HOME}/.nvm/nvm.sh"
fi

export SIGOPT_DIR="${HOME}/sigopt/sigopt-api"
export EVAL_DIR="${HOME}/sigopt/eval-framework"
export EVALSET_DIR="${HOME}/sigopt/evalset"
export PAGERDUTY_SIGOPT_DIR="${HOME}/sigopt/pagerduty-sigopt-api"
export TERRAFORM_DIR="${HOME}/sigopt/sigopt-terraform"
export MARKETING_DIR="${HOME}/sigopt/marketing-site"
export PLATFORM_TOOLS_DIR="${HOME}/sigopt/platform-tools"
export MPM_DIR="${HOME}/sigopt/mpm"
export ORCHESTRATE_DIR="${HOME}/sigopt/orchestrate"
export ORCHESTRATE_RUNS_DIR="${HOME}/sigopt/orchestrate-runs"

if [ -f "$HOME/.certs/sigopt-tokens.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.certs/sigopt-tokens.sh"
fi
if [ -f "$HOME/.certs/github-tokens.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.certs/github-tokens.sh"
fi

alias rr='${PLATFORM_TOOLS_DIR}/circleci/circleci.py --rerun-failed'

# env setup
alias src-sigopt-api='source ${HOME}/venv/sigopt-api/bin/activate'
alias src-sigopt-python-path='if [[ "${PYTHONPATH}" != *"${SIGOPT_DIR}"* ]] ; then source ${SIGOPT_DIR}/scripts/set_python_path ${SIGOPT_DIR} ; fi'
alias src-eval-framework='source ${HOME}/venv/eval-framework/bin/activate'
alias src-eval-python-path='if [[ "${PYTHONPATH}" != *"${EVAL_DIR}"* ]] ; then source ${EVAL_DIR}/eval_infra/local/set_python_path ${EVAL_DIR}  ${SIGOPT_DIR} ; fi'
alias src-mpm='source ${HOME}/venv/mpm/bin/activate'
alias src-orch='source ${HOME}/venv/orchestrate-dev/bin/activate'
alias src-orun='source ${HOME}/venv/orchestrate/bin/activate'

# cd helpers
alias sig='cd ${SIGOPT_DIR} && src-sigopt-api && src-sigopt-python-path && nvm use'
alias ef='cd ${EVAL_DIR} && src-eval-framework && src-eval-python-path'
alias efw='cd ${EVAL_DIR}/web && source ${HOME}/venv/eval-interactive/bin/activate && nvm use'
alias pgr='cd ${PAGERDUTY_SIGOPT_DIR} && src-sigopt-api && git fetch --all --prune'
alias mrk='cd ${MARKETING_DIR} && nvm use'
alias pt='sig && cd ${PLATFORM_TOOLS_DIR} && ipython'
alias st='sig && cd ${TERRAFORM_DIR}'
alias mpm='cd ${MPM_DIR} && src-mpm'
alias orch='cd ${ORCHESTRATE_DIR} && src-orch'
alias orun='cd ${ORCHESTRATE_RUNS_DIR} && src-orun'

# sigopt command running
alias sigq='cd ${SIGOPT_DIR} && ./scripts/launch/all_live scratch/quiet.json'
alias siglocal='cd ${SIGOPT_DIR} && ./scripts/launch/all_live'
alias repllocal='cd ${SIGOPT_DIR} && ./scripts/launch/repl'

export AUTH_CONFS='config/external-authorization.json'
alias authsig='siglocal ${AUTH_CONFS}'
alias authrepl='repllocal ${AUTH_CONFS}'

alias eweb='cd ${EVAL_DIR}/web && ./node_modules/watchify/bin/cmd.js js/app.js -o static/bundle.js -v ; ./run_buckets config/development.py'

export SIGOPT_SSL_DIR="${SIGOPT_DIR}/artifacts/ssl"
export LOCAL_KEY="${SIGOPT_SSL_DIR}/ssl.key"
export LOCAL_CRT="${SIGOPT_SSL_DIR}/ssl.crt"
export LOCATION_IP_DIR="${SIGOPT_SSL_DIR}/pki/servers/sc-10.0.0.36"
export PKI_KEY="${LOCATION_IP_DIR}/ssl.key"
export PKI_CRT="${LOCATION_IP_DIR}/ssl.crt"
export PKI_CLIENT_CA_CERT="${SIGOPT_SSL_DIR}/pki/ca/authorization-server-ca.crt"
export PKI_AUTHZ_CA_CERT="${SIGOPT_SSL_DIR}/pki/ca/client-ca.crt"

export ONPREM_ARGS="--ssl-only --api-cert-file ${LOCAL_CRT} --api-key-file ${LOCAL_KEY} --web-cert-file ${LOCAL_CRT} --web-key-file ${LOCAL_KEY}"
export ONPREM_PKI_ARGS="--pki-server-cert-file ${PKI_CRT} --pki-server-key-file ${PKI_KEY} --pki-client-ca-certs-file ${PKI_CLIENT_CA_CERT} --pki-authorization-server-ca-certs-file ${PKI_AUTHZ_CA_CERT}"

# shellcheck disable=SC2139
alias onprem-start="./start ${ONPREM_ARGS}"
# shellcheck disable=SC2139
alias iqt-onprem-start="./start ${ONPREM_ARGS} ${ONPREM_PKI_ARGS}"


# convenience for local orchestrate dev updates
alias mk-orch="orch && cd docker && make build-python-3.6 && make tag-python-3.6-version && cd ../ && make update"

# simpler ssl cert swapping?
_set_ssl_cert() {
  rm -f "${SIGOPT_SSL_DIR}"/ssl.* || true
  for SSL_FILE in ssl.crt ssl.key ssl.csr; do
    cp "${1}/${SSL_FILE}" "${SIGOPT_SSL_DIR}"
  done
}

alias ninja-ssl="_set_ssl_cert ${SIGOPT_SSL_DIR}/dev/star-sigopt-ninja"
alias dan-ssl="_set_ssl_cert ${SIGOPT_SSL_DIR}/dev/star-dan-sigopt-ninja"
