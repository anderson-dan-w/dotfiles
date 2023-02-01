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

alias v="vim"
# bindkey -v

# prompt. This seems weird to mix-and-match $fg with $FG :shrug:. Looks like:
# [venv] user@ip pwd (git) \
# time $
setopt PROMPT_SUBST ; PS1='%{$fg[red]$(virtualenv_prompt_info) $fg[yellow]%n@%m $FG[075]%c$fg[green]$(__git_ps1 " (%s)")$reset_color%}
$FG[134]%*$FG[255] \$ '

PATH="$HOME/bin:$PATH"

alias d="docker"
alias dps="docker ps --format='{{.Names}}' | sort"
alias dltf="docker logs --tail=0 --follow"
alias dclean="docker image prune && docker system prune -a"
