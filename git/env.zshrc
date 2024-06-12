alias g="git"
:
source "${HOME}/.git-prompt.sh"

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# move to base of git repo (when inside repo, or $HOME otherwise, like 'cd ')
alias g-cd='cd $( dirname $( git rev-parse --git-dir 2>/dev/null ) 2>/dev/null  ) || ~'

gh-mark-unviewed() {
cat <<EOF
// toggle all to not-viewed
document.querySelectorAll('.js-reviewed-checkbox').forEach((elem) => {
  if (!elem.checked) { return }
  var clickEvent = new MouseEvent('click');
  elem.dispatchEvent(clickEvent);
}))
EOF
}
