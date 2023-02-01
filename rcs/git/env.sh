alias g="git"
source "${HOME}/.git-prompt.sh"

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# move to base of git repo (when inside repo, or $HOME otherwise, like 'cd ')
alias gcd='cd $( dirname $( git rev-parse --git-dir 2>/dev/null ) 2>/dev/null  ) || ~'

# help espec. with sigopt-terraform tagging
alias gtl="git tag --list | gsort -V"
alias gtll="git tag --list | gsort -V | tail -1 "
alias gpt="git push --tags"
alias grom="git rebase origin/master"
