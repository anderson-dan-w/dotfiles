if [[ $(uname) == Darwin ]]; then
  _FIND=gfind
else
  _FIND=find
fi

alias pyclean="${_FIND} -iregex '.*pyc' -delete && ${_FIND} -iregex '.*__pycache__.*' -delete"

DEFAULT_VENV="default-venv"
PYTHONSTARTUP=$HOME/.pythonstartup
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"

VENV_ROOT="${HOME}/.venv"
source "${VENV_ROOT}/${DEFAULT_VENV}/bin/activate"

if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi

mk-venv() {
  DIR_NAME="${1}"
  if [[ -z "${DIR_NAME}" ]]; then
    DIR_NAME="$(basename $(pwd))"
  fi
  VENV_PATH="${VENV_ROOT}/${DIR_NAME}"
  if [[ ! -d "${VENV_PATH}" ]]; then
    virtualenv -p "$(which python3.12)" "${VENV_PATH}"
  fi
}
