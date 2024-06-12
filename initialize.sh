#!/bin/bash
set -e
set -o pipefail

: "${EMAIL_ADDRESS:?ERROR: set your email address}"

REPO_BASE_DIR="$(dirname $(realpath $(git rev-parse --git-dir)))"

MAC=mac
UBUNTU=ubuntu
if [[ $(uname) == Darwin ]]; then
  PLATFORM="${MAC}"
else
  # NOTE: surely not always true
  PLATFORM="${UBUNTU}"
fi

_announce() {
  echo -e "\n############################################################"
  echo -e "SETTING UP :: ${1}\n"
}

init::git () {
  _announce git
  if [ ! -f "${HOME}/.git-prompt.sh" ]; then
    curl -LsSo "${HOME}/.git-prompt.sh" "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
  fi
}

init::zsh () {
  _announce zsh
  if [[ $PLATFORM == "${MAC}" ]]; then
    if [ ! -d "${HOME}/.zsh" ]; then
      brew install zsh
    fi
  else
    if [ ! -d "${HOME}/.zsh" ]; then
      sudo apt-get install zsh
      sudo chsh "${USER}" -s "$(which zsh)"
     fi
  fi
  if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
  fi
}

init::shell-programs () {
  _announce shell-programs
  # NOTE: installs ag, fzf, tree, tmux
  # ag, aka silver-searcher, and others
  # tmux already installed? or being weird?
  if [[ $PLATFORM == "${MAC}" ]]; then
    brew install the_silver_searcher tree jq
  else
    sudo apt-get install silversearcher-ag tree jq
  fi

  # fzf
  if [ ! -d "${HOME}/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install"
  fi

}

init::ssh () {
  _announce ssh
  mkdir -p "${HOME}/.ssh"
  if [ ! -f "${HOME}/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "${EMAIL_ADDRESS}"
  fi
  if [ ! -f "${HOME}/.ssh/config" ]; then
    # copy, since it needs to be changed with username, proxy
    cp  "${REPO_BASE_DIR}/ssh/config" "${HOME}/.ssh/config"
  fi
}

init::vim () {
  _announce vim

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
  for VIM_PACKAGE in "${VIM_PACKAGES[@]}"; do
    pkg_name=$(basename "${VIM_PACKAGE}")
    pkg_path="${HOME}/.vim/bundle/${pkg_name}"
    if [ ! -d "${pkg_path}" ]; then
      (
        git clone "https://github.com/${VIM_PACKAGE}.git" "${pkg_path}"
        cd "${pkg_path}"
        git branch -m main
      )
    else
      (
        cd "${pkg_path}"
        git fetch --all && git checkout main && git pull
      )
    fi
  done
}

init::node () {
  _announce node
  if [ ! -f "${HOME}/.nvm/nvm.sh" ]; then
    mkdir -p "${HOME}/.nvm"
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
  fi
  export NVM_DIR="$HOME/.nvm"
  source "${NVM_DIR}/nvm.sh"
  source "${NVM_DIR}/bash_completion"

  if [ ! -d "${NVM_DIR}/versions/node" ]; then
    nvm install node
    nvm alias default node
  fi

  # some standard / helper installs
  nvm use node
  npm install --global yarn aws-cost-cli
}

init::docker () {
  _announce docker
  if [[ $PLATFORM == "${MAC}" ]]; then
    brew install docker docker-compose
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

init::k8s () {
  _announce k8s
  if [[ $PLATFORM == "${MAC}" ]]; then
    brew install kubectl kubectx
  else
    if ! command -v kubectl; then
      echo "************************************************************"
      echo "TODO - haven't bothered with this yet..."
      echo "************************************************************"
    fi
  fi
}

init::python () {
  _announce python
  if [[ $PLATFORM == "${MAC}" ]]; then
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
  if ! [[ $( pyenv version ) =~ ${PY_VERSION} ]]; then
    echo "skipping pyenv setup, seems to be erroring weirdly?"
  #  pyenv install "${PY_VERSION}"
  #  pyenv shell "${PY_VERSION}"
  #  pyenv global "${PY_VERSION}"
  #  hash -r
  fi

  DEFAULT_VENV="default-venv"
  pip install virtualenv
  VENV_BASE="${HOME}/.venv"
  mkdir -p "${VENV_BASE}"
  if [ ! -d "${VENV_BASE}/${DEFAULT_VENV}" ]; then
    virtualenv -p "$(which python)" "${VENV_BASE}/${DEFAULT_VENV}"
    source "${VENV_BASE}/${DEFAULT_VENV}/bin/activate"

    pip install ipython
    hash -r
  fi
}

init::terraform () {
  _announce terraform
  if [[ $PLATFORM == "${MAC}" ]]; then
    if ! command -v terraform; then
      brew install terraform
    fi
  else
    if [ ! -f /usr/bin/terraform ]; then
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update && sudo apt install terraform
    fi
  fi
  hash -r
}

init::aws () {
  _announce awscli
  if [[ $PLATFORM == "${MAC}" ]]; then
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
  if [ ! -d "${HOME}/.aws" ]; then
    aws configure
    touch "${HOME}/.aws/credentials"
  fi
}

init::gcp () {
  echo "TODO: install gcloud etc"
}

init::git
init::zsh
init::ssh
init::vim
init::node
init::shell-programs
init::python
init::terraform
init::aws
init::gcp
init::docker
init::k8s

hash -r

source "${REPO_BASE_DIR}/link_sources.zshrc"
source ~/.zshrc

echo "

############################################################
You'll want to:
- add your SSH Public key  in ~/.ssh to GitHub
- update username (in ~/.ssh/config)
- set references to proxy (in ~/.ssh/config)
- store dockerhub login credentials (in ${ENV_DIR}/docker-env.sh)
- set proxy URLs if needed (in ${ENV_DIR}/proxy-env.sh)
"
