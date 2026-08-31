################################################################################
# assumes the following in sensitive:
#   CD_DIRS
#   OVERRIDE_CDS (optional)
#   ALIAS_CDS    (optional)
################################################################################

# creates some helper aliases to enable quick-smart-switching
# eg `cd-dotfiles` will go to the right place,
# and then source the venv if it exists
# also, can subsequently be extended with other things (eg `nvm use`, etc)
dir--cd-with-venv() {

  ABS_PATH="${1}"
  USE_VENV="${2:-false}" # NOTE: off for now, lately using uv instead
  BASE_NAME=$(basename "${ABS_PATH}")

  VAR_NAME=$(echo ${BASE_NAME}_DIR | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  export "${VAR_NAME}"="${ABS_PATH}"

  if [[ "${USE_VENV}" == true ]]; then
    VENV_ACTIVATE="${VENV_ROOT}/${BASE_NAME}/bin/activate"
    SOURCER="py-venv_src_${BASE_NAME}"
    alias "${SOURCER}"="if [[ -f ${VENV_ACTIVATE} ]]; then source ${VENV_ACTIVATE}; fi"
  else
    SOURCER=true
  fi

  # add key-value pairs for overrides, eg ()"long_foo_bar_BASE_NAME" "foo")
  CD_NAME="${OVERRIDE_CDS[${BASE_NAME}]:-${BASE_NAME}}"

  CD_AND_SOURCE="cd-${CD_NAME}"
  alias "${CD_AND_SOURCE}"="cd ${ABS_PATH} && ${SOURCER}"

  MAYBE_ALIAS="${ALIAS_CDS[${BASE_NAME}]}"
  if [[ -n "${MAYBE_ALIAS}" ]]; then
    alias "${MAYBE_ALIAS}"="${CD_AND_SOURCE}"
  fi
}

for DIR in "${CD_DIRS[@]}"; do
  dir--cd-with-venv "${DIR}"
done
