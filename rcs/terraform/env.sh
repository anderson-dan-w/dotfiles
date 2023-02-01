DEFAULT_HUMAN_FILE=human-readable.plan
DEFAULT_TF_PLAN_FILE=tf.plan

alias tf="terraform"
alias tf-fmt="tf fmt -recursive"
alias tf-plan="tf plan -no-color -out ${DEFAULT_TF_PLAN_FILE} > ${DEFAULT_HUMAN_FILE}"
alias tf-grep="ag '(created$|destroyed|updated|replaced|no.changes|changes to o)' ${DEFAULT_HUMAN_FILE}"
alias tf-check="tf-plan && tf-grep"
alias tf-apply="tf apply ${DEFAULT_TF_PLAN_FILE}"

# NOTE: expects tfbackend file to exist...
alias tf-s3-init="tf init -backend-config=s3.tfbackend"
