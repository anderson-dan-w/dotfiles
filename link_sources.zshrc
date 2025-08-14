REPO_BASE_DIR="$(dirname "$(realpath "$(git rev-parse --git-dir)")")"

# TODO: some of these will require updating, like gitconfig?
link::rcs() {
  ln -fs "${REPO_BASE_DIR}/git/gitconfig" "${HOME}/.gitconfig"
  ln -fs "${REPO_BASE_DIR}/git/gitignore" "${HOME}/.gitignore"

  ln -fs "${REPO_BASE_DIR}/shell/zshrc" "${HOME}/.zshrc"

  ln -fs "${REPO_BASE_DIR}/tmux/tmux.conf" "${HOME}/.tmux.conf"

  ln -fs "${REPO_BASE_DIR}/vim/vimrc" "${HOME}/.vimrc"
  mkdir -p "${HOME}/.vim/colors"
  ln -fs "${REPO_BASE_DIR}/vim/colors/dwanderson-murphy.vim" "${HOME}/.vim/colors/dwanderson-murphy.vim"

  ln -sf "${REPO_BASE_DIR}/python/pythonstartup" "${HOME}/.pythonstartup"

  PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache"
  mkdir -p "${PLUGIN_CACHE_DIR}"
  ln -sf "${REPO_BASE_DIR}/terraform/terraformrc" "${HOME}/.terraformrc"
}

link::env_sources () {
  ENV_DIR="${HOME}/.env-sources"
  if [ ! -d "${ENV_DIR}" ]; then
    mkdir -p "${ENV_DIR}"
  fi
  STATIC_SOURCES=(
    "aws/utils.zshrc"
    "aws/old-utils.zshrc"
    "docker/env.zshrc"
    "gcp/utils.zshrc"
    "git/env.zshrc"
    "k8s/env.zshrc"
    "proxy/env.zshrc"
    "python/env.zshrc"
    "shell/env.zshrc"
    "shell/dir-utils.zshrc"
    "terraform/env.zshrc"
  )
  for SOURCE in "${STATIC_SOURCES[@]}"; do
    RENAMED="${SOURCE/\//-}"
    ln -sf "${REPO_BASE_DIR}/${SOURCE}" "${ENV_DIR}/${RENAMED}"
    echo "(over)wrote ${RENAMED}"
  done
}

link::rcs
link::env_sources
