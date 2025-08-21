_FIND_TOOL=find
if command -v gfind &>/dev/null; then
  _FIND_TOOL=gfind
fi

if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi

######################
# env-vars
######################
DEFAULT_PYTHON_VERSION=$(pyenv global)
DEFAULT_PY_MINOR="${DEFAULT_PYTHON_VERSION%.*}"

PYTHONSTARTUP=$HOME/.pythonstartup
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"

export PYTHONPATH
# overspecified but, make my life easier
__DBNL_INTERNAL_DIR="${HOME}/coding/dbnl-internal"
[[ ":${PYTHONPATH}:" != *":${__DBNL_INTERNAL_DIR}/src:"* ]] && \
  PYTHONPATH="${__DBNL_INTERNAL_DIR}/src:${PYTHONPATH}"

######################
# venv
######################
VENV_ROOT="${HOME}/.venv"

# NOTE: name needs to match that in initialize::python...
DEFAULT_VENV="default-venv"
source "${VENV_ROOT}/${DEFAULT_VENV}/bin/activate"

py-mk-venv() {
  DIR_NAME="${1}"
  if [[ -z "${DIR_NAME}" ]]; then
    DIR_NAME="$(basename $(pwd))"
  fi
  VENV_PATH="${VENV_ROOT}/${DIR_NAME}"
  if [[ ! -d "${VENV_PATH}" ]]; then
    virtualenv -p "$(which python${DEFAULT_PY_MINOR})" "${VENV_PATH}"
    echo "made venv '${DIR_NAME}' @ ${VENV_PATH}"
  else
    echo "venv '${DIR_NAME}' already exists @ ${VENV_PATH}"
  fi
}

######################
# helper funcs
######################
alias py-clean="${_FIND_TOOL} -iregex '.*[.]pyc' -delete && ${_FIND_TOOL} -iregex '.*[_-]pycache[_-].*' -delete"

# NOTE: 'a' for all, and typing `py-` is cumbersome
pa-test() {
    pytest -vv "$@" --disable-warnings
}
# NOTE: 'x' for.. distributed?
px-test() {
    pytest -n auto "$@" --disable-warnings
}
