################################################################################
# assumes the following in sensitive:
#   CD_DIRS
#   OVERRIDE_CDS (optional)
################################################################################

# creates some helper aliases to enable quick-smart-switching
# eg `cd-dotfiles` will go to the right place,
# and then source the venv if it exists
# also, can subsequently be extended with other things (eg `nvm use`, etc)
dir--cd-with-venv() {
  ABS_PATH="${1}"
  BASE_DIR_NAME=$(dirname "${ABS_PATH}")
  DIR_NAME=$(basename "${ABS_PATH}")

  VAR_NAME=$(echo ${DIR_NAME}_DIR | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  export "${VAR_NAME}"="${ABS_PATH}"

  VENV_ACTIVATE="${VENV_ROOT}/${DIR_NAME}/bin/activate"
  VENV_SOURCER="py-venv_src_${DIR_NAME}"
  alias "${VENV_SOURCER}"="if [[ -f ${VENV_ACTIVATE} ]]; then source ${VENV_ACTIVATE}; fi"

  # add key-value pairs for overrides, eg ()"long_foo_bar_dir_name" "foo")
  CD_NAME="${OVERRIDE_CDS[${DIR_NAME}]:-${DIR_NAME}}"

  CD_AND_VENV="cd-${CD_NAME}"
  alias "${CD_AND_VENV}"="cd ${ABS_PATH} && ${VENV_SOURCER}"
  # NOTE: to add an alias as well
  # if [[ "${CD_NAME}" == "dbnl-internal" ]]; then
  #   alias "cd-dbnl"="${CD_AND_VENV}"
  # fi
}

for DIR in "${CD_DIRS[@]}"; do
  dir--cd-with-venv "${DIR}"
done
