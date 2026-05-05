#! /bin/bash


# WSL Setup For CC

# Changing Permission

sudo chmod 755 ~/3-iX-WSL-CC/ 

# Updating Ubuntu

sudo apt-get update && sudo apt-get full-upgrade -y

# Installing Dependancies

sudo apt install ipmitool sshpass pv postgresql-client sqlite3 python3 dialog pdfgrep lynx curl git zsh -y

# Installing oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y

# Copying theme over to oh-my-zsh

cp ~/3-iX-WSL-CC/SETUP/3eyedgod.zsh-theme ~/.oh-my-zsh/themes/

# Changing Theme On .zshrc File

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="3eyedgod"/g' ~/.zshrc


exit
