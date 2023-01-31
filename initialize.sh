#!/bin/bash
set -e 
set -o pipefail

: "${EMAIL_ADDRESS:?ERROR: set your email address}"

# TODO: specifying for MacOS now; will need ubuntu later
MAC=mac
UBUNTU=ubuntu
if [[ $(uname) == Darwin ]]; then
  PLATFORM="${MAC}"
else
  # TODO: surely not always true
  PLATFORM="${UBUNTU}"
fi

initialize_zsh () {
  echo "setting up zsh and oh-my-zsh"
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
  # oh-my-zsh overwrite, so we re-overwrite
  ln -fs ./rcs/shell/zshrc "${HOME}/.zshrc"
}

initialize_shell_programs () {
  echo "setting up shell program helpers"
  # ag, aka silver-searcher
  if [[ $PLATFORM == $MAC ]]; then
    brew install the_silver_searcher
  else
    sudo apt-get install silversearcher-ag
  fi
  # NOTE: if can't change for current user, edit .bash_profile to
  # set $SHELL and call zsh itself...

  # fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
  "${HOME}/.fzf/install"
}

initialize_ssh () {
  echo "setting up ssh key in .ssh"
  mkdir -p "${HOME}/.ssh"
  ssh-keygen -t ed25519 -C "${EMAIL_ADDRESS}"
}

initialize_vim () {
  echo "setting up vim-pathogen + modules"
  mkdir -p "${HOME}/.vim/autoload"
  mkdir -p "${HOME}/.vim/bundle"
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
  VIM_PACKAGES=(
    "dense-analysis/ale"
    "airblade/vim-gitgutter"
    "hashivim/vim-terraform"
  )
  # TODO: need to install git first?
  for VIM_PACKAGE in ${VIM_PACKAGES[@]}; do
    pkg_name=$(basename "${VIM_PACKAGE}")
    git clone "git@github.com:${VIM_PACKAGE}.git" "${HOME}/.vim/bundle/${pkg}"
  done
}

initialize_node () {
  echo "installing node-related things"
  if [[ $PLATFORM == $MAC ]]; then
    brew install nvm
  else
    echo "install NVM"
  fi
  mkdir -p "${HOME}/.nvm"
  # copied from brew install output
  export NVM_DIR="$HOME/.nvm"
  source "/usr/local/opt/nvm/nvm.sh"
  source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
  npm install --global yarn
}

initialize_docker () {
  echo "installing docker"
  if [[ $PLATFORM == $MAC ]]; then
    brew install docker
    brew install docker-compose
  else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker "${USER}"
    sudo apt-get install docker-compose
  fi
}

initialize_python () {
  "echo installing python"
  if [[ $PLATFORM == $MAC ]]; then
    brew install pyenv
  else
    echo TODO pyenv install
  fi
  # grabs most recent stable python 3.x.y version
  PY_VERSION=$(pyenv install --list | ag ' 3[.]\d+[.]\d+$' | tail -1 | tr -d '[:space:]')
  pyenv install "${PY_VERSION}"
  pyenv shell "${PY_VERSION}"
  hash -r

  pip install virtualenv
  mkdir -p "${HOME}/.venv"
  virtualenv -p $(which python) "${HOME}/.venv/default-venv"
  source "${HOME}/.venv/default-venv/bin/activate"

  pip install ipython
  hash -r
}

initialize_terraform () {
  echo "installing terraform"
  if [[ $PLATFORM == $MAC ]]; then
    brew install terraform
  else
    echo TODO terraform install
  fi
  hash -r
}

initialize_aws () {
  echo "installing awscli"
  if [[ $PLATFORM == $MAC ]]; then
    brew install awscli
  else
    echo TODO awscli install
  fi
  hash -r
  aws configure
}

initialize_zsh
initialize_ssh
initialize_vim
initialize_node
initialize_node
initialize_python
initialize_terraform
initialize_aws
