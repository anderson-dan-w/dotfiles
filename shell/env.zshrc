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

setopt PROMPT_SUBST
_VPN='%F{red}${HTTP_PROXY:+[VPN] }'
_AWS='%F{cyan}[aws:${AWS_PROFILE}::${AWS_DEFAULT_REGION}] '
_GCP='%F{yellow}[gcp:${GCP_PROJECT}:${GCP_REGION}] '
# WHOA: you can put a command: $( basename ....) inside parameter manipulation ${...##*_}
# NOTE: ${...##*_} removes everything _before_ the last underscore. GKE names are looooong
#_K8S='%F{green}<k8s:${$(basename $(k-tx -c))##*_}::$(k-ns -c)> '
# TODO: no k8s means the above fails with no contexts
_K8S='%F{green}<k8s:(none)> '
_PYTHON='%F{magenta}venv:$(virtualenv_prompt_info) '
_GIT='%F{red}$(__git_ps1 "(git:%s)") '
_TIME='%F{135}%* '
_CURDIR='%F{yellow}(%c) '
_SUCCESS='%(?.%F{green}√.%F{red}?%?)%f '
_ROOT='%(!.#ROOT#.$) '

PS1="${_VPN}${_AWS}${_GCP}${_K8S}
${_PYTHON}${_GIT}
${_TIME}${_CURDIR}${_SUCCESS}${_ROOT}"

## ag helpers
_AG_ARGS=(
    "--color" \
    "--hidden" \
    "--ignore" ".git" \
    "--ignore" ".terraform"  \
    "--ignore" "terraform.tfstate*" \
    "--ignore" "bootstrap" \
    "--ignore" "node_modules" \
    "--color-match" "1;35" \
    "--pager=less -RXF" \
)

_ag() {
    MY_ARGS=()
    MAYBE_SORT=("tee")
    while getopts "umtlor" opt 2>/dev/null; do
        case "$opt" in
            u)
                MY_ARGS+=("--ignore" "ui" "--ignore" "web") ;;
            m)
                MY_ARGS+=("--ignore" "src/distributional/migrations") ;;
            t)
                MY_ARGS+=("--ignore" "src/tests") ;;
            l)
                MY_ARGS+=("-l")
                MAYBE_SORT=("sort" "-u") ;;
            o)
                MY_ARGS+=("--only-matching") ;;
            r)
                MY_ARGS+=("--ignore" "terraform") ;;
            ?)
                break ;;
        esac
    done
    shift $((OPTIND - 1))

    /opt/homebrew/bin/ag "${MY_ARGS[@]}" "${_AG_ARGS[@]}" "$@" | "${MAYBE_SORT[@]}" | less -RXF
}

# case-insensitive by default...
ag() {
  _ag "$@" -i
}

# ... but occasionally i DO want case-sensitivity
AG() {
  _ag "$@"
}

# can't do git commands in gitconfig that rely on the shell, since it creates a new one (when !-ing)
g-acm() {
  fc -s -2
  fc -s -2  # since now, -1 is the previous fc command!
}

todo() {
  TICKET="${1}" && shift
  AG "(TODO.)?ENG-${TICKET}" "$@"
}

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

PATH="$HOME/bin:$PATH"

export GOBIN=${GOBIN:-$(go env GOPATH)/bin}
