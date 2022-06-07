#!/bin/zsh

# Script Name: Setup
# Created: 2/14/2022
# Last Modified: 2/17/2022
# Maintained By: Drew Karriker
# Description:
#   This script should walk you through setting up your laptop for engineering needs - I made the script as I was installing stuff on a new mac i7 intel. If you
#   are running a mac m1 or a windows machine, this script will not work as intended.
#   If you find any problems, please submit an issue to this repo.

[ -z ~/Dev-Local/ ] || mkdir ~/Dev-Local/
cd ~/Dev-Local/
brew --version && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install brew
xcode-select --install
brew update --preinstall


# Setup github SSH access
function github_ssh(){
    brew install git # If on mac M1, Things might be weird here
    git config --global color.ui true
    vared -r "What is your github username? " -c gituser
    git config --global user.name "${gituser}"
    echo "Your git username is set to $(git config --global user.name)"
    vared -r "What is your github email address? " -c gitemail
    git config --global user.email "$gitemail"
    echo "Your git email is set to $(git config --global user.email)"
    ssh-keygen -t ed25519 -C "${$(git config --global user.email)}" -f ${HOME}/.ssh/id_ed25519
    echo "Paste into github https://github.com/settings/ssh/new"
    echo ~/.ssh/id_ed25519.pub
    pbcopy < ~/.ssh/id_ed25519.pub
    open -a "Google Chrome"  https://github.com/settings/ssh/new
    vared -r "Press return when you have saved your ssh key into github" -c a
}
[ ! -s ~/.ssh/id_ed25519.pub ] && github_ssh

## Test github SSH connection
ssh -T git@github.com

# Setup github GPG signature
function github_gp(){
    brew install gnupg gnupg2 pinentry-mac
    gpg --full-generate-key
    vared -r "What email address is your GPG you set up under so we can find it?" -c gpgemail
    echo "Paste into github https://github.com/settings/gpg/new"
    gpg --armor --export ${gpgemail}
    pbcopy < gpg --armor --export ${gpgemail} 
    open -a "Google Chrome" https://github.com/settings/gpg/new
    vared -r "Press return after pasting into github" -c a
    gpg --list-secret-keys --keyid-format=long
    vared -r "Press return after copying the GPG key ID to your clipboard." -c a
    gpg_key=$(gpg --list-signatures --with-colons | grep 'sig' | grep 'drew.karriker@freshly.com' | head -n 1 | cut -d':' -f5)
    git config --global user.signingkey ${gpg_key}
    git config --global user.signingkey
    git config --global commit.gpgsign true # sign all commits
    git config --global gpg.program gpg # https://stackoverflow.com/a/47087248
    echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf # https://stackoverflow.com/a/47087248
    echo "no-tty" >> ~/.gnupg/gpg.conf # https://stackoverflow.com/a/47087248
    killall gpg-agent # https://stackoverflow.com/a/47087248
    if [ -r ~/.zshrc ]; then echo 'export GPG_TTY=$(tty)' >> ~/.zprofile; \
        else echo 'export GPG_TTY=$(tty)' >> ~/.zprofile; fi
    if [ -r ~/.bash_profile ]; then echo 'export GPG_TTY=$(tty)' >> ~/.bash_profile; \
        else echo 'export GPG_TTY=$(tty)' >> ~/.profile; fi
    open -a "Google Chrome" https://github.com/settings/keys 
    vared -r "Press return after checking the box 'Flag unsigned commits as unverified' at https://github.com/settings/keys" -c a
}
[ ! gpg ] && github_gp


# Setup VS code command in PATH
echo 'export PATH="$PATH:/usr/local/bin/code"' >> ~/.profile
