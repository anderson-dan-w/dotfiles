export EDITOR='vim'
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
bindkey -v

# NOTE: zsh-specific codes in this
# [VPN] [aws: ] <k8s: ::ns> venv:[] (git: )
# time (pwd) resultstatus $
setopt PROMPT_SUBST ; PS1='%F{red}${HTTP_PROXY:+[VPN] }%F{cyan}[aws:${AWS_PROFILE}::${AWS_DEFAULT_REGION}] %F{green}<k8s:$(basename $(k-tx -c))::$(k-ns -c)> %F{magenta}venv:$(virtualenv_prompt_info) %F{red}$(__git_ps1 "(git:%s)")
%F{135}%* %F{yellow}(%c) %(?.%F{green}√.%F{red}?%?)%f %(!.#ROOT#.$) '

PATH="$HOME/bin:$PATH"

## ag helpers
_AG_ARGS="--hidden \
  --ignore .git \
  --ignore .terraform \
  --ignore bootstrap \
  --ignore node_modules \
  --color-match '1;35' \
  --pager='less -RXF' \
"

# case-insensitive by default...
# shellcheck disable=SC2139
alias ag="ag -i $_AG_ARGS"

# ... but occasionally i DO want case-sensitivity
# shellcheck disable=SC2139
alias AG="/usr/local/bin/ag $_AG_ARGS"

## fzf helpers
export FZF_DEFAULT_COMMAND='ag --nocolor --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
--color info:108,prompt:109,spinner:108,pointer:168,marker:168
'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# node / nvm - may get stubbed into zshrc too though
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
