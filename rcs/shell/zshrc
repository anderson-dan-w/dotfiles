# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  docker
  git
  vi-mode
  virtualenv
)

ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

######################
# Personal stuff added
# navigation
#
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
export LSCOLORS=gxGxbxDxCxEgEdxbxgxcxd

export PAGER="less -XRF"

# default colors are atrocious
# also, grepping minified bootstrap style files sucks
_AG_ARGS="--hidden \
  --ignore .git \
  --ignore .terraform \
  --ignore src/python/zigopt/gen \
  --ignore web/styles/bootstrap \
  --ignore web/static/js \
  --ignore web/static/bundle.js \
  --ignore web/static/css \
  --ignore web/nodebuild \
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

# fuzzy file search via ctrl-t
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag --nocolor --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
--color info:108,prompt:109,spinner:108,pointer:168,marker:168
'

source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# prompt. This seems weird to mix-and-match $fg with $FG but that's what I needed :shrug:
setopt PROMPT_SUBST ; PS1='%{$fg[red]$(virtualenv_prompt_info) $fg[yellow]%n@%m $FG[075]%c$fg[green]$(__git_ps1 " (%s)")$reset_color%}
$FG[134]%*$FG[255] \$ '

#####################
PATH="$HOME/bin:$PATH"

alias v='vim'
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

alias k="kubectl"
source <(kubectl completion zsh)
complete -F __start_kubectl k

alias myip="ipconfig getifaddr en0"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

source "${HOME}/.alias/sigopt.sh"
if [ -f "$HOME/.certs/sigopt-tokens" ]; then
  source "$HOME/.certs/sigopt-tokens"
fi

if [ -f "$HOME/.certs/github-tokens" ]; then
  source "$HOME/.certs/github-tokens"
fi

if command -v pyenv &>/dev/null; then eval "$(pyenv init -)"; fi

export PATH=~/bin:$PATH
