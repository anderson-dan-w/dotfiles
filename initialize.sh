#!/bin/bash
set -e
set -o pipefail

: "${EMAIL_ADDRESS:?ERROR: set your email address}"

MAC=mac
UBUNTU=ubuntu
if [[ $(uname) == Darwin ]]; then
  PLATFORM="${MAC}"
else
  # NOTE: surely not always true
  PLATFORM="${UBUNTU}"
fi

initialize_git () {
  echo "initializing git"
  ln -fs "$( pwd )/rcs/git/gitconfig" "${HOME}/.gitconfig"
  ln -fs "$( pwd )/rcs/git/gitignore" "${HOME}/.gitignore"
  if [ ! -f "${HOME}/.git-prompt.sh" ]; then
    curl -LsSo "${HOME}/.git-prompt.sh" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  fi
}

initialize_zsh () {
  echo "setting up zsh and oh-my-zsh"
  if [[ $PLATFORM == $MAC ]]; then
    brew install zsh
  else
    if [ ! -d "${HOME}/.zsh" ]; then
      sudo apt-get install zsh
      sudo chsh "${USER}" -s $(which zsh)
     fi
  fi
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
    # oh-my-zsh overwrite, so we re-overwrite
    ln -fs "$( pwd )/rcs/shell/zshrc" "${HOME}/.zshrc"
  fi
}

initialize_shell_programs () {
  # NOTE: installs ag, fzf, tree, tmux
  echo "setting up shell programs and helpers"
  # ag, aka silver-searcher, and others
  if [[ $PLATFORM == $MAC ]]; then
    brew install the_silver_searcher tree tmux
  else
    # NOTE: seems like tmux is pre-installed (ubuntu22)?
    sudo apt-get install silversearcher-ag tree
  fi
  ln -fs "$(pwd)/rcs/tmux/tmux.conf" "${HOME}/.tmux.conf"

  # fzf
  if [ ! -d "${HOME}/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install"
  fi
}

initialize_ssh () {
  echo "setting up ssh key in .ssh"
  mkdir -p "${HOME}/.ssh"
  if [ ! -f "${HOME}/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "${EMAIL_ADDRESS}"
  fi
}

initialize_vim () {
  echo "setting up vim-pathogen + modules"

  mkdir -p "${HOME}/.vim/autoload"
  pathogen_path="${HOME}/.vim/autoload/pathogen.vim"
  if [ ! -f "${pathogen_path}" ]; then
    curl -LSso "${pathogen_path}" https://tpo.pe/pathogen.vim
  fi

  mkdir -p "${HOME}/.vim/bundle"
  VIM_PACKAGES=(
    "dense-analysis/ale"
    "airblade/vim-gitgutter"
    "hashivim/vim-terraform"
  )
  for VIM_PACKAGE in ${VIM_PACKAGES[@]}; do
    pkg_name=$(basename "${VIM_PACKAGE}")
    pkg_path="${HOME}/.vim/bundle/${pkg}"
    if [ ! -d "${pkg_path}" ]; then
      git clone "https:/github.com/${VIM_PACKAGE}.git" "${pkg_path}"
    fi
  done

  mkdir -p "${HOME}/.vim/colors"
  ln -fs "$(pwd)/rcs/vim/vimrc" "${HOME}/.vimrc"
  ln -fs "$(pwd)/rcs/vim/colors/dwanderson-murphy.vim" "${HOME}/.vim/colors/dwanderson-murphy.vim"
}

initialize_node () {
  echo "installing node-related things"
  mkdir -p "${HOME}/.nvm"
  if [[ $PLATFORM == $MAC ]]; then
    brew install nvm
  else
    if [ ! -d "${HOME}/.nvm" ]; then
      curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    fi
  fi
  export NVM_DIR="$HOME/.nvm"
  source "${NVM_DIR}/nvm.sh"
  source "${NVM_DIR}/bash_completion"

  if [ ! -d "${NVM_DIR}/versions/node" ]; then
    nvm install node
    nvm alias default node
    npm install --global yarn
  fi
}

initialize_docker () {
  echo "installing docker"
  if [[ $PLATFORM == $MAC ]]; then
    brew install docker
    brew install docker-compose
  else
    if ! command -v docker; then
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      sudo usermod -aG docker "${USER}"
      sudo apt-get install docker-compose
      rm -f get-docker.sh
    fi
  fi
}

initialize_python () {
  echo "installing python"
  if [[ $PLATFORM == $MAC ]]; then
    brew install pyenv
  else
    sudo apt-get install build-essential zlib1g-dev libffi-dev libssl-dev libsqlite3-dev liblzma-dev libreadline-dev
    if [ ! -d "${HOME}/.pyenv" ]; then
      curl https://pyenv.run | bash
    fi
  fi
  export PATH="$HOME/.pyenv/bin:$PATH"
  # grabs most recent stable python 3.x.y version
  PY_VERSION=$(pyenv install --list | ag ' 3[.]\d+[.]\d+$' | tail -1 | tr -d '[:space:]')
  if ! [[ $( pyenv version ) =~ "${PY_VERSION}" ]]; then
    pyenv install "${PY_VERSION}"
    pyenv shell "${PY_VERSION}"
    pyenv global "${PY_VERSION}"
    hash -r
  fi

  pip install virtualenv
  mkdir -p "${HOME}/.venv"
  if [ ! -d "${HOME}/.venv/default-venv" ]; then
    virtualenv -p $(which python) "${HOME}/.venv/default-venv"
    source "${HOME}/.venv/default-venv/bin/activate"

    pip install ipython
    hash -r
  fi

  ln -sf "$(pwd)/rcs/python/pythonstartup" "${HOME}/.pythonstartup"
}

initialize_terraform () {
  echo "installing terraform"
  if [[ $PLATFORM == $MAC ]]; then
    brew install terraform
  else
    if [ ! -f /usr/bin/terraform ]; then
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update && sudo apt install terraform
    fi
  fi
  hash -r
}

initialize_aws () {
  echo "installing awscli"
  if [[ $PLATFORM == $MAC ]]; then
    brew install awscli
  else
    sudo apt-get install unzip
    if [ ! -f /usr/local/bin/aws ]; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      rm -rf awscliv2.zip aws/
    fi
  fi
  hash -r
  aws configure
}

initialize_env_sources () {
  ENV_DIR="${HOME}/.env-sources"
  if [ ! -d "${ENV_DIR}" ]; then
    mkdir -p "${ENV_DIR}"
    ln -sf "$(pwd)/rcs/shell/env.sh" "${ENV_DIR}/shell-env.sh"
    ln -sf "$(pwd)/rcs/git/env.sh" "${ENV_DIR}/git-env.sh"
    ln -sf "$(pwd)/rcs/terraform/env.sh" "${ENV_DIR}/terraform-env.sh"
    ln -sf "$(pwd)/rcs/python/env.sh" "${ENV_DIR}/python-env.sh"
    ln -sf "$(pwd)/rcs/docker/env.sh" "${ENV_DIR}/docker-env.sh"
  fi
}

initialize_git
initialize_zsh
initialize_ssh
initialize_vim
initialize_node
initialize_shell_programs
initialize_python
initialize_terraform
initialize_aws
initialize_docker
initialize_env_sources

hash -r

echo "

=========================
You'll want to add your SSH Public key  in ~/.ssh to GitHub
=========================
"
