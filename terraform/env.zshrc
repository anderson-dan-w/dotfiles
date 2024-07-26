########################################
# override-able defaults
TF_ALIAS="tf"
DEFAULT_TF_BACKEND_FILE="s3.tfbackend"
_TF_PLAN_EXTENSION=plan
DEFAULT_TF_PLAN_FILE="tf.${_TF_PLAN_EXTENSION}"
DEFAULT_HUMAN_FILE="human-readable.${_TF_PLAN_EXTENSION}"

########################################
# depend on other installed programs:
_GREP_TOOL="grep"
if command -v ag &>/dev/null; then
  _GREP_TOOL="ag"
elif command -v fgrep &>/dev/null; then
  _GREP_TOOL="fgrep"
fi

_FIND_TOOL="find"
if command -v gfind &>/dev/null; then
  _FIND_TOOL="gfind"
fi
########################################
VERBOSE=
if [[ "${1}" == "-v" ]]; then
  VERBOSE=1
fi

_verb () { if [[ "${VERBOSE}" ]]; then echo "$@" ; fi }
_make_tf_cmd_name () { echo "${TF_ALIAS}-${1}"; }

TERRAFORM_CMD=$(which terraform)
alias "${TF_ALIAS}"="${TERRAFORM_CMD}"
_verb "${TF_ALIAS}"

TF_FMT=$(_make_tf_cmd_name "fmt")
"${TF_FMT}"() {
  "${TERRAFORM_CMD}" fmt -recursive
}
_verb "${TF_FMT}"

TF_VALIDATE=$(_make_tf_cmd_name "validate")
"${TF_VALIDATE}"() {
  "${TERRAFORM_CMD}" validate
}
_verb "${TF_VALIDATE}"

TF_PLAN=$(_make_tf_cmd_name "plan")
"${TF_PLAN}"() {
  "${TERRAFORM_CMD}" plan -no-color -out "${DEFAULT_TF_PLAN_FILE}" "$@" | tee "${DEFAULT_HUMAN_FILE}"
  # NOTE: we want to capture the exit code of plan. zsh is `${pipestatus[1]}`, bash is `${PIPESTATUS[0]}`
  test ${pipestatus[1]} -eq 0
}
_verb "${TF_PLAN}"

TF_GREP=$(_make_tf_cmd_name "grep")
"${TF_GREP}"() {
  "${_GREP_TOOL}" '(created$|destroyed|updated|replaced|no.changes|changes to o)' "${DEFAULT_HUMAN_FILE}"
}
_verb "${TF_GREP}"

TF_PREP=$(_make_tf_cmd_name "prep")
"${TF_PREP}"() {
  "${TF_PLAN}" "$@" && "${TF_GREP}"
}
_verb "${TF_PREP}"

TF_CHECK=$(_make_tf_cmd_name "check")
"${TF_CHECK}"() {
  "${TF_PLAN}" "$@" && "${TF_GREP}"
}
_verb "${TF_CHECK}"

TF_CLEAN=$(_make_tf_cmd_name "clean")
"${TF_CLEAN}"() {
  "${_FIND_TOOL}" -iregex '.*[.]'"${_TF_PLAN_EXTENSION}" -delete
}
_verb "${TF_CLEAN}"

TF_APPLY=$(_make_tf_cmd_name "apply")
"${TF_APPLY}"() {
  "${TERRAFORM_CMD}" apply "${DEFAULT_TF_PLAN_FILE}" && "${TF_CLEAN}"
}
_verb "${TF_APPLY}"

TF_INIT=$(_make_tf_cmd_name "init")
"${TF_INIT}" () {
  if [ -f "${DEFAULT_TF_BACKEND_FILE}" ]; then
    BACKEND_ARG="-backend-config=${DEFAULT_TF_BACKEND_FILE}"
  fi
  "${TERRAFORM_CMD}" init ${BACKEND_ARG:+"${BACKEND_ARG}"} "$@"
}
_verb "${TF_INIT}"

# NOTE: not terraform-related, but helpful in some workflows
# NOTE: assumes sortable (semver or similar?) tags
TF_GET_LAST_TAG=$(_make_tf_cmd_name "last-tag")
"${TF_GET_LAST_TAG}" () {
  echo "$(git tag --sort=-v:refname -l | head -1 )"
}
_verb "${TF_GET_LAST_TAG}"

TF_SET_REF=$(_make_tf_cmd_name "set-ref")
"${TF_SET_REF}" () {
  if ! [ -f main.tf ]; then
    echo "no main.tf in this directory; aborting"
    return 1
  fi
  REFERENCE="${1}"
  for FH in $( "${_FIND_TOOL}" . -iregex '.*main.tf' -not -path '*/.terraform*' -print ); do
    echo updating "${FH}"
    # lines look like: source = "git@github.com:<ORG>/....modules/name?ref=v0.123.0
    # so this replaces `v0.123.0` with whatever reference we provide
    sed -i '' "s/ref=.*/ref=${REFERENCE}\"/" "${FH}"
  done
}
_verb "${TF_SET_REF}"

# grabs most recent git tag to set ref
TF_SET_TAG=$(_make_tf_cmd_name "set-tag")
"${TF_SET_TAG}" () {
  if [[ "${1}" != "" ]]; then
    echo "expected no arguments; did you mean '${TF_SET_REF} ${1}' instead?"
    return 1
  fi
  GIT_TAG=$("${TF_GET_LAST_TAG}")
  "${TF_SET_REF}" "${GIT_TAG}"
  "${TF_INIT}"
  echo
  echo "set to git-tag ${GIT_TAG}"
}

# uses current git hash to set ref; helpful for testing changes more quickly
# requires that commit is pushed to github
TF_SET_HASH=$(_make_tf_cmd_name "set-hash")
"${TF_SET_HASH}" () {
  if [[ "${1}" != "" ]]; then
    echo "expected no arguments; did you mean '${TF_SET_REF} ${1}' instead?"
    return 1
  fi
  GIT_HASH="$( git rev-parse HEAD )"
  "${TF_SET_REF}" "${GIT_HASH}"
  "${TF_INIT}"
  echo
  echo "set to git-hash ${GIT_HASH}"
}
_verb "${TF_SET_HASH}"

_set_tf_rc () {
  CACHE_DIR="${HOME}/.terraform.d"
  mkdir -p "${CACHE_DIR}"

  RC_FNAME="${HOME}/.terraformrc"
  if ! [ -f "${RC_FNAME}" ]; then
    echo "plugin_cache_dir = \"${CACHE_DIR}/plugin-cache\"" > "${RC_FNAME}"
    echo 'disable_checkpoint = true' >> "${RC_FNAME}"
    _verb "wrote ${RC_FNAME}"
  else
    _verb "${RC_FNAME} already exists"
  fi
}
_set_tf_rc
