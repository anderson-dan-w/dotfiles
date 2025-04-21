if [[ $(uname) == Darwin ]]; then
  _FIND=gfind
else
  _FIND=find
fi

# NOTE: name needs to match that in initialize::python...
DEFAULT_VENV="default-venv"

PYTHONSTARTUP=$HOME/.pythonstartup
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"

VENV_ROOT="${HOME}/.venv"
source "${VENV_ROOT}/${DEFAULT_VENV}/bin/activate"

alias py-clean="${_FIND} -iregex '.*[.]pyc' -delete && ${_FIND} -iregex '.*[_-]pycache[_-].*' -delete"
if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi

py-mk-venv() {
  DIR_NAME="${1}"
  if [[ -z "${DIR_NAME}" ]]; then
    DIR_NAME="$(basename $(pwd))"
  fi
  VENV_PATH="${VENV_ROOT}/${DIR_NAME}"
  if [[ ! -d "${VENV_PATH}" ]]; then
    virtualenv -p "$(which python3.12)" "${VENV_PATH}"
    echo "made venv '${DIR_NAME}' @ ${VENV_PATH}"
  else
    echo "venv '${DIR_NAME}' already exists @ ${VENV_PATH}"
  fi
}

# NOTE: 'q' for quiet, and typing `py-` is cumbersome
pq-test() {
    pytest "$@" --disable-warnings 2>/dev/null | tee /dev/null
}

pa-test() {
    pytest "$@" --disable-warnings
}

px-test() {
    pytest -n auto "$@" --disable-warnings
}
