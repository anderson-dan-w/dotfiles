# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u:\W\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
# esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    # shellcheck source=/dev/null
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck source=/dev/null
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck source=/dev/null
    . /etc/bash_completion
  fi
fi

##############################################################################
# convenience settings and aliases
alias ll='ls -lF'
alias lla='ls -alF'
alias la='ls -A'

_myos="$(uname)"
if [ "$_myos" = "Darwin" ]; then
    alias ls='ls -G'
    alias lt='ls -lrtG'
else
    alias lt='ls -lrt --color=auto'
fi
export LSCOLORS=gxGxbxDxCxEgEdxbxgxcxd

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias l='/usr/bin/less'
alias src='source $HOME/.bashrc'
alias v='vim'
## vi-mode for bash
set -o vi

export PAGER=less
export EDITOR=vim

## intelligent history traversal
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind Space:magic-space

if [ "$_myos" = "Darwin" ]; then
  if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
      # shellcheck source=/dev/null
      . "$(brew --prefix)/etc/bash_completion"
  fi
fi

##############################################################################
# sigopt-related things

export SIGOPT_DIR="${HOME}/sigopt/sigopt-api"
export TERRAFORM_DIR="${HOME}/sigopt/sigopt-terraform"
export MARKETING_DIR="${HOME}/sigopt/marketing-site"
export PLATFORM_TOOLS_DIR="${HOME}/sigopt/platform-tools"

if [ -f "$HOME/.certs/sigopt-tokens.bash" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.certs/sigopt-tokens.bash"
fi
if [ -f "$HOME/.certs/github-tokens.bash" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.certs/github-tokens.bash"
fi

# dir-switching and env setup
alias src-sigopt-api='source ${HOME}/venv/sigopt-api/bin/activate'
alias sig='cd ${SIGOPT_DIR} && src-sigopt-api && nvm use'

##############################################################################
## programming language related things

#######################
# brew-related things
alias bottomsup="brew update && brew upgrade && brew doctor"

#######################
# python-related things
export PYTHONSTARTUP=$HOME/.pythonstartup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

alias pyclean="gfind -iregex '.*pyc' -delete && gfind -iregex '.*__pycache__.*' -delete"
alias p80x="python -c \"print('x'*80)\""

#######################
# R-related things
export R_HISTFILE=$HOME/.Rhistory

#########################
# additional executables:
# symbolic links for things like redis, node, rabbitmq-(server,env)
PATH="$HOME/bin:$PATH"

##############################################################################
# git-related

# lazy
alias g="git"

# auto-completion
# shellcheck source=/dev/null
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
if [ -f "$HOME/.git-completion.bash" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.git-completion.bash"

  # add completion for alias(es) above
  __git_complete g __git_main
fi

# prompt tells repo status
# shellcheck source=/dev/null
[ -f "$HOME/.git-prompt.sh" ] && . "$HOME/.git-prompt.sh"

_LIGHT_BLUE='\[\e[0;94m\]'
_GREEN='\[\e[0;32m\]'
_YELLOW='\[\e[0;33m\]'
# _RED='\[\e[0;31m\]'
_NO_COLOR='\[\e[m\]'
PS1="${_YELLOW}\\u@\\h ${_LIGHT_BLUE}\\W${_NO_COLOR}${_GREEN}"'$(__git_ps1 " (%s)")'"${_NO_COLOR}\\n${_LIGHT_BLUE}\\t${_NO_COLOR} \$ "
ORIGINAL_PS1="${PS1}"
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
## along with virtualenv package-preface, prompt now looks like:
## (env-name) user@host dirname (branch-name status) \n HH:MM:SS $

# move to base of git repo (when inside repo, or $HOME otherwise, like 'cd ')
alias gcd='cd $( dirname $( git rev-parse --git-dir 2>/dev/null ) 2>/dev/null  ) || ~'
# help espec. with sigopt-terraform tagging
alias gtl="git tag --list | gsort -V"
alias gpt="git push --tags"

##############################################################################
# terraform
alias tf="terraform"
alias tfr="terraform fmt -recursive"
alias tfp="terraform plan -no-color -out tf.plan > human.out"
alias tfi="terraform init"
alias tfclean="gfind -iregex '.*tf.plan$' -delete && gfind -iregex '.*human.out' -delete"

##############################################################################
# containers - docker, k8s
alias d="docker"
alias dps="docker ps --format='{{.Names}}' | sort"
alias k="kubectl"
alias mk="minikube"
function mk-set () {
  # shellcheck disable=SC2046,SC2086
  eval $(minikube docker-env $1)
  if [ "${DOCKER_HOST}" ]; then
    PS1="${_GREEN}{minikube}${_NO_COLOR} ${PS1}"
  else
    PS1=${ORIGINAL_PS1}
  fi
}

# shellcheck disable=SC1090
source <(kubectl completion bash)
complete -F __start_kubectl k

##############################################################################
## fzf helpers
export FZF_DEFAULT_COMMAND='ag --nocolor --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
--color info:108,prompt:109,spinner:108,pointer:168,marker:168
'

##############################################################################
# better-grep (ag, Silver Searcher)

# default colors are atrocious
# also, grepping minified bootstrap style files sucks
_AG_ARGS="--hidden \
  --ignore .git \
  --ignore .terraform \
  --ignore terraform.tfstate* \
  --color-match '1;35' \
  --pager='less -RXF' \
"

# case-insensitive by default...
# shellcheck disable=SC2139
alias ag="ag -i $_AG_ARGS"

# ... but occasionally i DO want case-sensitivity
# shellcheck disable=SC2139
alias AG="/usr/local/bin/ag $_AG_ARGS"

# get only unique usages of exact regex
# not sure why I can't put _ago inside the function but it fails
# shellcheck disable=SC2139
alias _ago="/usr/local/bin/ag $_AG_ARGS --nofilename --nonumbers -o"
ago () {
  _ago "$1" | sort -u
}

# ignore test folders when searching (nt = Not Tests)
# shellcheck disable=SC2139
alias .agnt="ag --ignore *test -i $_AG_ARGS"
alias agnt="fc -s 'ag =.agnt '"

##############################################################################
## random tidbits

## make diff suck less
function diff {
    colordiff -u "$@" | less -RXF
}

## source fuzzy file search (cmd+t)
# shellcheck source=/dev/null
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# shellcheck disable=SC1090
source "$HOME/bin/tmuxinator.bash"

# colorize virtualenv prefix: inside bin.activate, ~l60
# _RED="\[\033[0;31m\]"
# _NO_COLOR="\[\e[0m\]"
# PS1="${_RED}(`basename \"$VIRTUAL_ENV\"`)${_NO_COLOR} $PS1"
if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi
