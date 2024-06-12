# NOTE: could abstract a little more, but fine enough
CODE_BASE_DIR="${HOME}/coding"
CODE_DIRS=(
  dbnl-internal
  dbnl-demos
  dbnl-sdk
  helm-charts
  terraform-google-dbnl
  terraform-aws-dbnl
)

# creates some helper aliases to enable quick-smart-switching
# eg `cd-dotfiles` will go to the right place,
# and then source the venv if it exists
# also, can subsequently be extended with other things (eg `nvm use`, etc)
dir::_cd_with_venv() {
  DIR_NAME="${1}"
  BASE_DIR_NAME="${2}"
  VAR_NAME=$(echo ${DIR_NAME}_DIR | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  FULL_PATH="${CODE_BASE_DIR}/${DIR_NAME}"
  export "${VAR_NAME}"="${FULL_PATH}"

  VENV_ACTIVATE="${VENV_ROOT}/${DIR_NAME}/bin/activate"
  VENV_SOURCER="py::venv_src_${DIR_NAME}"
  alias "${VENV_SOURCER}"="if [[ -f ${VENV_ACTIVATE} ]]; then source ${VENV_ACTIVATE}; fi"

  CD_VENV="cd::${DIR_NAME}"
  alias "${CD_VENV}"="cd ${FULL_PATH} && ${VENV_SOURCER}"
}

for DIR in "${CODE_DIRS[@]}"; do
  dir::_cd_with_venv "${DIR}" "${CODE_BASE_DIR}"
done
