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
HISTSIZE=1000
HISTFILESIZE=2000

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

## intelligent history traversal
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind Space:magic-space

if [ "$_myos" = "Darwin" ]; then
  if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
      # shellcheck source=/dev/null
      . $(brew --prefix)/etc/bash_completion
  fi
fi

## assumes on mac, with brew install findutils so it's in gfind;
## TODO: normalize
function gf () {
  gfind -iregex ".*""$1"".*" ;
}

function pathmunge () {
  if ! echo "$PATH" | $( which grep ) -Eq "(^|:)$1($|:)" ; then
     if [ "$2" = "after" ] ; then
        PATH="$PATH:$1"
     else
        PATH="$1:$PATH"
     fi
  fi
}

##############################################################################
# sigopt-related things
if [ -f "$HOME/.certs/sigopt-tokens.bash" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.certs/sigopt-tokens.bash"
fi

export EVAL_DIR="${HOME}/sigopt/eval-framework"
export SIG2_DIR="${HOME}/sigopt/sigopt-api-2"
export EVAL_PP="$EVAL_DIR:$SIG2_DIR/test:$SIG2_DIR/prod:$SIG2_DIR/src/python"

export SIGOPT_DIR="${HOME}/sigopt/sigopt-api"
export PAGERDUTY_SIGOPT_DIR="${HOME}/sigopt/pagerduty-sigopt-api"
alias src-sigopt-api='source ${HOME}/venv/sigopt-api/bin/activate'
alias sig='cd ${SIGOPT_DIR} && src-sigopt-api'
alias pgr='cd ${PAGERDUTY_SIGOPT_DIR} && src-sigopt-api && git fetch --all --prune'
alias api='cd ${SIGOPT_DIR} && ./build config/development.json'
alias quiet-api='cd ${SIGOPT_DIR} && ./build scratch/quiet.json,config/development.json'
alias web='cd ${SIGOPT_DIR} && ./web/web_serve_dev.sh'

function update_local_token() {
  python ~/sigopt/personal-sigopt-testing/src/python/update_local_token.py "$@" && src
}

##############################################################################
## programming language related things

#######################
# brew-related things
alias bottomsup="brew update && brew upgrade && brew doctor"

#######################
# python-related things
export PYTHONSTARTUP=$HOME/.pythonstartup
alias pyclean="gfind -iregex '.*pyc' -delete && gfind -iregex '.*__pycache__.*' -delete"
alias p80x="python -c \"print('x'*80)\""

#######################
# R-related things
export R_HISTFILE=$HOME/.Rhistory

#######################
# Java-related things
export M2_HOME=/usr/local/Cellar/maven/3.5.0/libexec
export M2=$M2_HOME/bin
pathmunge $M2 after

#########################
# additional executables:
# symbolic links for things like redis, node, rabbitmq-(server,env)
pathmunge "$HOME/bin"
PATH="$HOME/bin:$PATH"

pathmunge "$HOME/.rbenv/shims" after

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
[ -f "$HOME/.git-prompt.sh" ] && . $HOME/.git-prompt.sh

_LIGHT_BLUE='\[\e[0;94m\]'
_GREEN='\[\e[0;32m\]'
_YELLOW='\[\e[0;33m\]'
_NO_COLOR='\[\e[m\]'
PS1="${_YELLOW}\\u@\\h ${_LIGHT_BLUE}\\W${_NO_COLOR}${_GREEN}"'$(__git_ps1 " (%s)")'"${_NO_COLOR}\\n${_LIGHT_BLUE}\\t${_NO_COLOR} \$ "
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
## along with virtualenv package-preface, prompt now looks like:
## (env-name) user@host dirname (branch-name status) \n HH:MM:SS $

# move to base of git repo (when inside repo, or $HOME otherwise, like 'cd ')
alias gcd='cd $( dirname $( git rev-parse --git-dir 2>/dev/null ) 2>/dev/null  ) || ~'

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
_AG_ARGS="--hidden --ignore .git --ignore web/styles/bootstrap --color-match '1;35' --pager='less -RXF'"

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

## easy open on mac
function fopen () {
    /usr/bin/open -a TextEdit "$1" ;
}

## make diff suck less
function diff {
    colordiff -u "$@" | less -RXF
}

## resize a terminal to be @a n screens wide (meaning 80 characters * n)
## @note Doesn't work inside tmux
function res () { 
    if [ -z "$1" ]; then 
        n=1;
    else n=$1; fi ;
    resize -s 50 $(( "$n" * 80 + "$n" - 1 )) ;
    export LINES=${LINES};
    export COLUMNS=${COLUMNS};
}

## source fuzzy file search (cmd+t)
# shellcheck source=/dev/null
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

##############################################################################
# silly fun

# generate coverterms
alias ct="echo ; echo ; look . | gshuf | head -2 | tr '\\n' ' ' | tr '[:lower:]' '[:upper:]' ; echo ; echo; echo"
