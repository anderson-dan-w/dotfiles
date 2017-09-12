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
#force_color_prompt=yes

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
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias ll='ls -lF'
alias lla='ls -alF'
alias la='ls -A'

_myos="$(uname)"
if [ "$_myos" = "Darwin" ]; then
    alias lt='ls -lrtG'
else
    alias lt='ls -lrt --color=auto'
fi

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias l='/usr/bin/less'
alias src='source $HOME/.bashrc'

export PAGER=less

## intelligent history traversal
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

alias ggrep="ggrep --color=auto"
export GREP_COLORS="ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36"

##############################################################################
# python-related things
export PYTHONSTARTUP=$HOME/.pythonstartup
alias pyclean='find . -name "*.pyc" -exec rm {} \;'
alias p80x="python -c \"print('x'*80)\""

# R-related things
export R_HISTFILE=$HOME/.Rhistory

##############################################################################
# git-related auto-completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
[ -f $HOME/.git-completion.bash ] && . $HOME/.git-completion.bash

##############################################################################
## easy open on mac
function fopen () {
    /usr/bin/open -a TextEdit $1 ;
}

function diff {
    colordiff -u "$@" | less -RF
}

## resize a terminal to be @a n screens wide (meaning 80 characters * n)
## @note Doesn't work inside tmux
function res () { 
    if [ -z "$1" ]; then 
        n=1;
    else n=$1; fi ;
    resize -s 50 $(( $n * 80 + $n - 1 )) ;
    export LINES=${LINES};
    export COLUMNS=${COLUMNS};
}

## Set prompt to be green if last call was successful (returned 0) else red
function error_test {
	if [[ $? = "0" ]]; then
		echo -e "\[\033[1;32m\]"
	else
		echo -e "\[\033[1;31m\]"
	fi
}

function set_prompt() {
    ## deals w spaces in dirnames
    MYBASENAME=$(basename "$PWD")
	PS1="$(error_test)\t:\[\\033[00m\]$MYBASENAME\$ "
}

PROMPT_COMMAND=set_prompt
