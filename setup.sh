#!/bin/bash
set -e
set -o pipefail

# ssh keys for github and other great good
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# upload to github

# shell and environment
sudo apt-get install zsh
sudo chsh -s /usr/bin/zsh root
# NOTE: if can't change for current user, edit .bash_profile to i
# set $SHELL and call zsh itself...

# zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
# oh-my-zsh overwrites your local .zshrc, so we repopulate it
cp ~/personal/dotfiles/.zshrc ~

# vim setup
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd ~/.vim/bundle || exit
git clone git@github.com:dense-analysis/ale.git
git clone git@github.com:airblade/vim-gitgutter.git
git clone git@github.com:hashivim/vim-terraform.git

##################
# bin and programs
mkdir ~/bin
cd ~/bin || exit

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
npm install --global yarn
sudo apt-get install silversearcher-ag
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# jfc docker install instructions are involved...
# visit: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker "<your-user>"
sudo apt-get install docker-compose

# hmm, not always needed / kinda janky
# NOTE: check if `python -V` is 3.6+ or 2.7 still
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
#sudo update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3 10
# ORR
#sudo cp /usr/local/bin/pip3 /usr/local/bin/pip
# NOTE: what?? why do I need this here and not inside my virtual env??
# TODO: and this version is broken / sucks anyway??
pip3 install docker-compose==1.17.1
pip3 install --upgrade docker-compose # >=1.26.0?

# NOTE: or update for newest tf version, whatever
wget https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
unzip terraform_0.14.5_linux_amd64.zip
mv terraform terraform0.14
ln -s terraform0.14 terraform

sudo snap install kubectl --classic-only  # or something; not sure here

sudo apt-get install awscli
aws configure

# should probably close out and re-open shell, but
hash -r
