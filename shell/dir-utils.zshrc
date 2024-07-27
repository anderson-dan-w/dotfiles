# NOTE: could abstract a little more, but fine enough
CODE_BASE_DIR="${HOME}/coding"
CODE_DIRS=(
  dbnl-internal
  dbnl-demos
  dbnl-sdk
  helm-charts
  terraform-google-dbnl
  terraform-aws-dbnl
  hello-world-dbnl
)

PERSONAL_BASE_DIR="${HOME}/personal"
PERSONAL_DIRS=(
  dotfiles
)

# creates some helper aliases to enable quick-smart-switching
# eg `cd-dotfiles` will go to the right place,
# and then source the venv if it exists
# also, can subsequently be extended with other things (eg `nvm use`, etc)
dir--cd-with-venv() {
  DIR_NAME="${1}"
  BASE_DIR_NAME="${2}"
  VAR_NAME=$(echo ${DIR_NAME}_DIR | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  FULL_PATH="${BASE_DIR_NAME}/${DIR_NAME}"
  export "${VAR_NAME}"="${FULL_PATH}"

  VENV_ACTIVATE="${VENV_ROOT}/${DIR_NAME}/bin/activate"
  VENV_SOURCER="py-venv_src_${DIR_NAME}"
  alias "${VENV_SOURCER}"="if [[ -f ${VENV_ACTIVATE} ]]; then source ${VENV_ACTIVATE}; fi"

  CD_NAME="${DIR_NAME}"
  # dir-specific overrides, eg `cd-dotfiles` -> `cd-rc`
  if [[ "${CD_NAME}" == "dotfiles" ]]; then
    CD_NAME="rc"
  elif [[ "${CD_NAME}" == "hello-world-dbnl" ]]; then
    CD_NAME="world"
  fi

  # TODO: getting clunky and unreadable...
  CD_AND_VENV="cd-${CD_NAME}"
  alias "${CD_AND_VENV}"="cd ${FULL_PATH} && ${VENV_SOURCER}"
  if [[ "${CD_NAME}" == "dbnl-internal" ]]; then
    alias "cd-dbnl"="${CD_AND_VENV}"
  fi
}

for DIR in "${CODE_DIRS[@]}"; do
  dir--cd-with-venv "${DIR}" "${CODE_BASE_DIR}"
done
for DIR in "${PERSONAL_DIRS[@]}"; do
  dir--cd-with-venv "${DIR}" "${PERSONAL_BASE_DIR}"
done
