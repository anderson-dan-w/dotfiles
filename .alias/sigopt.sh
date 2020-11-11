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

if [ -f "$HOME/.certs/sigopt-tokens" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.certs/sigopt-tokens"
fi
if [ -f "$HOME/.certs/github-tokens" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.certs/github-tokens"
fi

# env setup
alias src-sigopt-api='source ${HOME}/venv/sigopt-api/bin/activate'
alias src-sigopt-python-path='if [[ "${PYTHONPATH}" != *"${SIGOPT_DIR}"* ]] ; then source ${SIGOPT_DIR}/scripts/set_python_path ${SIGOPT_DIR} ; fi'
alias src-eval-framework='source ${HOME}/venv/eval-framework/bin/activate'
alias src-eval-python-path='if [[ "${PYTHONPATH}" != *"${EVAL_DIR}"* ]] ; then source ${EVAL_DIR}/eval_infra/local/set_python_path ${EVAL_DIR}  ${SIGOPT_DIR} ; fi'
alias src-mpm='source ${HOME}/venv/mpm/bin/activate'

# cd helpers
alias sig='cd ${SIGOPT_DIR} && src-sigopt-api && src-sigopt-python-path && nvm use'
alias ef='cd ${EVAL_DIR} && src-eval-framework && src-eval-python-path'
alias efw='cd ${EVAL_DIR}/web && source ${HOME}/venv/eval-interactive/bin/activate && nvm use'
alias pgr='cd ${PAGERDUTY_SIGOPT_DIR} && src-sigopt-api && git fetch --all --prune'
alias mrk='cd ${MARKETING_DIR} && nvm use'
alias pt='sig && cd ${PLATFORM_TOOLS_DIR} && ipython'
alias st='sig && cd ${TERRAFORM_DIR}'
alias mpm='cd ${MPM_DIR} && src-mpm'

# sigopt command running
alias sigq='cd ${SIGOPT_DIR} && ./scripts/launch/all_live scratch/quiet.json'
alias siglocal='cd ${SIGOPT_DIR} && ./scripts/launch/all_live'
alias repllocal='cd ${SIGOPT_DIR} && ./scripts/launch/repl'

export AUTH_CONFS='scratch/external-authorization.json,config/external-authorization.json'
alias authsig='siglocal ${AUTH_CONFS}'
alias authrepl='repllocal ${AUTH_CONFS}'

alias eweb='cd ${EVAL_DIR}/web && ./node_modules/watchify/bin/cmd.js js/app.js -o static/bundle.js -v ; ./run_buckets config/development.py'
