# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

export PAGER="less -XRF"

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias zs="source ${HOME}/.zshrc"
alias vzs="vim ${HOME}/.zshrc"

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
# a little annoying if history shares in real time across tabs
setopt no_share_history

alias ll='ls -lF'
alias lla='ls -alF'
alias la='ls -A'

alias ls='ls -G'
alias lt='ls -lrtG'
# default colors are atrocious
export LSCOLORS=gxGxbxDxCxEgEdxbxgxcxd

# prompt. This seems weird to mix-and-match $fg with $FG :shrug:. Looks like:
# [venv] user@ip pwd (git) \
# time $
setopt PROMPT_SUBST ; PS1='%{$fg[red]$(virtualenv_prompt_info) $fg[yellow]%n@%m $FG[075]%c$fg[green]$(__git_ps1 " (%s)")$reset_color%}
$FG[134]%*$FG[255] \$ '

source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

#####################
PATH="$HOME/bin:$PATH"

alias v="vim"
alias g="git"
# move to base of git repo (when inside repo, or $HOME otherwise, like 'cd ')
alias gcd='cd $( dirname $( git rev-parse --git-dir 2>/dev/null ) 2>/dev/null  ) || ~'
# help espec. with sigopt-terraform tagging
alias gtl="git tag --list | gsort -V"
alias gtll="git tag --list | gsort -V | tail -1 "
alias gpt="git push --tags"
alias grom="git rebase origin/master"

export PYTHONSTARTUP=$HOME/.pythonstartup
alias pyclean="gfind -iregex '.*pyc' -delete && gfind -iregex '.*__pycache__.*' -delete"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi

alias tf="terraform"
alias tfr="terraform fmt -recursive"
alias tfp="terraform plan -no-color -out tf.plan > human.out"
alias tfi="terraform init"
alias tfg="ag '(created|destroyed|updated|replaced|no.changes)' human.out"
alias tfpg="tfp && tfg"

alias d="docker"
alias dps="docker ps --format='{{.Names}}' | sort"
alias dltf="docker logs --tail=0 --follow"
alias dclean="docker image prune && docker system prune -a"
