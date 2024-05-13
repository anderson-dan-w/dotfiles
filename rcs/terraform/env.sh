_GREP_TOOL="ag"  # could be grep, or maybe fgrep on some Macs?
_FIND_TOOL="gfind"  # could be find, or maybe gfind on some Macs?

DEFAULT_HUMAN_FILE=human-readable.plan
DEFAULT_TF_PLAN_FILE=tf.plan
DEFAULT_TF_BACKEND_FILE="IGNORE-backend.tf"

TERRAFORM=$(which terraform)
TERRAFORM_ALIAS="tf"
alias "${TERRAFORM_ALIAS}"="${TERRAFORM}"
_make_tf_alias_name () { echo "${TERRAFORM_ALIAS}-${1}"; }

TF_FMT_ALIAS=$(_make_tf_alias_name "fmt")
alias "${TF_FMT_ALIAS}"="${TERRAFORM_ALIAS} fmt -recursive"
TF_PLAN_ALIAS=$(_make_tf_alias_name "plan")
alias "${TF_PLAN_ALIAS}"="${TERRAFORM_ALIAS} plan -no-color -out ${DEFAULT_TF_PLAN_FILE} | tee ${DEFAULT_HUMAN_FILE}"
TF_GREP_ALIAS=$(_make_tf_alias_name "grep")
alias "${TF_GREP_ALIAS}"="${_GREP_TOOL} '(created$|destroyed|updated|replaced|no.changes|changes to o)' ${DEFAULT_HUMAN_FILE}"
TF_PREP_ALIAS=$(_make_tf_alias_name "prep")
alias "${TF_PREP_ALIAS}"="${TF_PLAN_ALIAS} && ${TF_GREP_ALIAS}"
TF_CHECK_ALIAS=$(_make_tf_alias_name "check")
alias "${TF_CHECK_ALIAS}"="${TF_PLAN_ALIAS} && ${TF_GREP_ALIAS}"
TF_APPLY_ALIAS=$(_make_tf_alias_name "apply")
 alias "${TF_APPLY_ALIAS}"="${TERRAFORM_ALIAS} apply ${DEFAULT_TF_PLAN_FILE}"
 TF_CLEAN_ALIAS=$(_make_tf_alias_name "clean")
 alias "${TF_CLEAN_ALIAS}"="rm -rf ${DEFAULT_TF_PLAN_FILE} ${DEFAULT_HUMAN_FILE}"

TF_INIT=$(_make_tf_alias_name "init")
"${TF_INIT}" () {
  if [ -f "${DEFAULT_TF_BACKEND_FILE}" ]; then
    BACKEND_ARG="-backend-config=${DEFAULT_TF_BACKEND_FILE}"
  fi
  "${TERRAFORM}" init ${BACKEND_ARG:+"${BACKEND_ARG}"} "$@"
}

############################################################
# NOTE: not terraform-related, but helpful in some workflows
# NOTE: assumes sortable (semver or similar?) tags
TF_GET_LAST_TAG=$(_make_tf_alias_name "last-tag")
"${TF_GET_LAST_TAG}" () {
  echo "$(git tag --sort=-v:refname -l | head -1 )"
}

TF_SET_REF=$(_make_tf_alias_name "set-ref")
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

# grabs most recent git tag to set ref
TF_SET_TAG=$(_make_tf_alias_name "set-tag")
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
TF_SET_HASH=$(_make_tf_alias_name "set-hash")
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
