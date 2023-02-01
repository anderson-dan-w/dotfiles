
if [[ $(uname) == Darwin ]]; then
  _FIND=gfind
else
  _FIND=find
fi

alias pyclean="${FIND} -iregex '.*pyc' -delete && ${FIND} -iregex '.*__pycache__.*' -delete"

export PYTHONSTARTUP=$HOME/.pythonstartup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
source "${HOME}/.venv/default-venv/bin/activate"

if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi
