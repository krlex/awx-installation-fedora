#!/usr/bin/env bash

export HOME="/root"

export TOOLS=~/awx/tools/
export INSTALLER=~/awx/installer/

echo "Upgrade and installation common"
sudo dnf -y  update
sudo dnf -y  install vim net-tools git gcc

echo "Git cloning AWX from krlex/awx github repo 9.0 version"
sudo git clone https://github.com/krlex/awx $HOME/awx
#chown -R vagrant vagrant $HOME/awx

echo "Update and install Python3"
sudo dnf -y install python3-pip.noarch python36 python2-libselinux.x86_64  #python36-devel python36-libs python36-tools
sudo python3 -m pip install -U pip

echo "Set up stable repo for docker"
sudo dnf -y install dnf-plugin-core
sudo dnf-config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

echo "Enable the nightly repo"
sudo dnf-config-manager --set-enabled docker-ce-nightly

echo "Installation docker"
sudo dnf -y install docker-ce docker-ce-cli containerd.io

echo "Starting docker"
sudo systemctl start docker

echo "Setup python-pip"
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"

echo "Update and install Python"
sudo python get-pip.py

echo "Install ansible"
sudo pip install docker-compose
sudo pip install docker ansible

echo "Docker-compose starting ...."
cd $TOOLS
/usr/local/bin/docker-compose up

echo "Ansible configuration and installation"
ansible-playbook -i ~/awx/installer/inventory ~/awx/installer/install.yml

echo "URL address"
URL=$(sudo ip -4 addr show enp0s8 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
