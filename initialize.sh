#!/bin/bash
set -e 
set -o pipefail

: "${EMAIL_ADDRESS:?ERROR: set your email address}"

initialize_git () {
  echo "initializing git"
  ln -fs "$( pwd )/rcs/git/gitconfig" "${HOME}/.gitconfig"
  ln -fs "$( pwd )/rcs/git/gitignore" "${HOME}/.gitignore"
}

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
  if [ ! -f "${HOME}/.git-prompt.sh" ]; then
    curl -LsSo "${HOME}/.git-prompt.sh" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  fi
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
  curl -LSso "${pathogen_path}" https://tpo.pe/pathogen.vim

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
  # copied from brew install output
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
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker "${USER}"
    sudo apt-get install docker-compose
    rm -f get-docker.sh
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
  pyenv install "${PY_VERSION}"
  pyenv shell "${PY_VERSION}"
  hash -r

  pip install virtualenv
  mkdir -p "${HOME}/.venv"
  if [ ! -d "${HOME}/.venv/default-venv" ]; then
    virtualenv -p $(which python) "${HOME}/.venv/default-venv"
    source "${HOME}/.venv/default-venv/bin/activate"

    pip install ipython
    hash -r
  fi
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

hash -r
