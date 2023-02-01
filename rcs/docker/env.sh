alias d="docker"
alias dps="docker ps --format='{{.Names}}' | sort"
alias dltf="docker logs --tail=0 --follow"
alias dclean="docker image prune && docker system prune -a"
