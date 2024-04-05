if [[ $(uname) == Darwin ]]; then
  _FIND=gfind
else
  _FIND=find
fi

alias py-clean="${_FIND} -iregex '.*pyc' -delete && ${_FIND} -iregex '.*__pycache__.*' -delete"

# NOTE: name would need to match that in initialize-python...
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
    echo "made venv '${DIR_NAME}' @ ${VENV_PATH}"
  else
    echo "venv '${DIR_NAME}' already exists @ ${VENV_PATH}"
  fi
}

# NOTE: could abstract a little more, but fine enough
CODE_BASE_DIR="${HOME}/coding"
CODE_DIRS=(
  dotfiles
  codecleanup
)

# creates some helper aliases to enable quick-smart-switching
# eg `cd-dotfiles` will go to the right place,
# and then source the venv if it exists
# also, can subsequently be extended with other things (eg `nvm use`, etc)
_src-setup() {
  DIR_NAME="${1}"
  BASE_DIR_NAME="${2}"
  VAR_NAME=$(echo ${DIR_NAME}_DIR | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  FULL_PATH="${CODE_BASE_DIR}/${DIR_NAME}"
  export "${VAR_NAME}"="${FULL_PATH}"

  VENV_ACTIVATE="${VENV_ROOT}/${DIR_NAME}/bin/activate"
  VENV_SOURCER="src-${DIR_NAME}-venv"
  alias "${VENV_SOURCER}"="if [[ -f ${VENV_ACTIVATE} ]]; then source ${VENV_ACTIVATE}; fi"

  CD_VENV="cd-${DIR_NAME}"
  alias "${CD_VENV}"="cd ${FULL_PATH} && ${VENV_SOURCER}"
  # TODO: previously, had to re-source fzf for some reason?
}

for DIR in "${CODE_DIRS[@]}"; do
  _src-setup "${DIR}" "${CODE_BASE_DIR}"
done
