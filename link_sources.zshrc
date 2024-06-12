REPO_BASE_DIR="$(dirname "$(realpath "$(git rev-parse --git-dir)")")"

link::rcs() {
  echo "setting git"
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
    "shell/env.sh"
    "git/env.sh"
    "terraform/env.sh"
    "python/env.sh"
    "aws/account-helper.sh"
    "aws/utils.sh"
    "gcp/account-helper.sh"
    "gcp/utils.sh"
    "k8s/env.sh"
  )
  for SOURCE in "${STATIC_SOURCES[@]}"; do
    RENAMED="${SOURCE/\//-}"
    ln -sf "${REPO_BASE_DIR}/${SOURCE}" "${ENV_DIR}/${RENAMED}"
    echo "(over)wrote ${RENAMED}"
  done

  DYNAMIC_SOURCES=(
    "docker/env.sh"
    "proxy-env.sh"
  )
  for SOURCE in "${DYNAMIC_SOURCES[@]}"; do
    RENAMED="${SOURCE/\//-}"
    if [ -f "${ENV_DIR}/${RENAMED}" ] ; then
      echo "${RENAMED} already exists, so not overwriting"
      echo "    if you want to update, manually run:"
      echo "    cp ${REPO_BASE_DIR}/${SOURCE} ${ENV_DIR}/${RENAMED}"
      echo "    and update as needed"
    else
      # copy since these require tweaking
      cp "${REPO_BASE_DIR}/${SOURCE}" "${ENV_DIR}/${RENAMED}"
      echo "installed ${RENAMED}, which requires updating"
    fi
  done
}

link::rcs
link::env_sources
