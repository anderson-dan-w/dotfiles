if [[ $(uname) == Darwin ]]; then
  _FIND=gfind
else
  _FIND=find
fi

DEFAULT_PYTHON_VERSION=$(pyenv shell)

# NOTE: name needs to match that in initialize::python...
DEFAULT_VENV="default-venv"

PYTHONSTARTUP=$HOME/.pythonstartup
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"

export PYTHONPATH
# overspecified but, make my life easier
__DBNL_INTERNAL_DIR="${HOME}/coding/dbnl-internal"
[[ ":${PYTHONPATH}:" != *":${__DBNL_INTERNAL_DIR}/src:"* ]] && \
  PYTHONPATH="${__DBNL_INTERNAL_DIR}/src:${PYTHONPATH}"

VENV_ROOT="${HOME}/.venv"
# NOTE: name needs to match that in initialize::python...
DEFAULT_VENV="default-venv"
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
    virtualenv -p "$(which python${DEFAULT_PYTHON_VERSION})" "${VENV_PATH}"
    echo "made venv '${DIR_NAME}' @ ${VENV_PATH}"
  else
    echo "venv '${DIR_NAME}' already exists @ ${VENV_PATH}"
  fi
}

# NOTE: 'a' for all, and typing `py-` is cumbersome
pa-test() {
    pytest -vv "$@" --disable-warnings
}
# NOTE: 'x' for.. distributed?
px-test() {
    pytest -n auto "$@" --disable-warnings
}
