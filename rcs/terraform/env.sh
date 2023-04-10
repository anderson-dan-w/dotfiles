if [[ $(uname) == Darwin ]]; then
  _FIND="gfind"
else
  _FIND="find"
fi

DEFAULT_HUMAN_FILE=human-readable.plan
DEFAULT_TF_PLAN_FILE=tf.plan

alias tf="terraform"
alias tf-fmt="tf fmt -recursive"
alias tf-plan="tf plan -no-color -out ${DEFAULT_TF_PLAN_FILE} > ${DEFAULT_HUMAN_FILE}"
alias tf-grep="ag '(created$|destroyed|updated|replaced|no.changes|changes to o)' ${DEFAULT_HUMAN_FILE}"
alias tf-prep="tf-plan && tf-grep"
alias tf-check="tf-plan && tf-grep"
alias tf-apply="tf apply ${DEFAULT_TF_PLAN_FILE}"
alias tf-clean="${_FIND} -iregex '.*tf[.]plan' -delete && gfind -iregex '.*human[.].*' -delete"

tf-init () {
  if [ -f s3.tfbackend ]; then
    tf init -backend-config=s3.tfbackend
  else
    tf init
  fi
}

tf-set-ref() {
  for FH in $( "${_FIND}" . -regex '.*main.tf' -not -path '*/.terraform*' -print ); do
    echo updating "${FH}"
  # lines look like: source = "git@github.com:<ORG>/....modules/name?ref=v0.123.0
  # so this replaces `v0.123.0` with whatever reference we provide
  sed -i '' "s/ref=.*/ref=${1}\"/" "${FH}"
  done
}

# NOTE: same as `g tl` but don't want to assume gitconfig loaded
tf-last-tag() {
  echo "$(git tag --sort=-v:refname -l | head -1 )"
}

# grabs most recent git tag to set ref
tf-set-tag() {
  GIT_TAG=$(tf-last-tag)
  tf-set-ref "${GIT_TAG}"
  tf-init
  echo
  echo "set to git-tag ${GIT_TAG}"
}

# uses current git hash to set ref; helpful for testing changes
# requires that commit is pushed to github
tf-set-hash() {
  GIT_HASH="$( git rev-parse HEAD )"
  tf-set-ref "${GIT_HASH}"
  tf-init
  echo
  echo "set to git-hash ${GIT_HASH}"
}
