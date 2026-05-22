#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " Debian 13 Workstation Setup"
echo "========================================"

# Ensure script is not run as root
if [[ "$EUID" -eq 0 ]]; then
    echo "Please run this script as a normal user, not root."
    exit 1
fi

echo
echo "Updating package lists..."
sudo apt update
sudo apt upgrade -y

echo
echo "Installing base dependencies..."
sudo apt install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    software-properties-common \
    apt-transport-https

########################################
# Git
########################################
echo
echo "Installing Git..."
sudo apt install -y git

########################################
# Docker
########################################
echo
echo "Installing Docker..."

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo usermod -aG docker "$USER"

########################################
# Visual Studio Code
########################################
echo
echo "Installing VS Code..."

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" | \
sudo tee /etc/apt/sources.list.d/vscode.list

sudo apt update
sudo apt install -y code

########################################
# Firefox (Mozilla Official)
########################################
echo
echo "Installing Firefox..."

sudo install -d -m 0755 /etc/apt/keyrings

wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
    sudo gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] \
https://packages.mozilla.org/apt mozilla main" | \
sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

sudo apt update
sudo apt install -y firefox

########################################
# Brave Browser
########################################
echo
echo "Installing Brave Browser..."

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" | \
sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update
sudo apt install -y brave-browser

########################################
# Spotify
########################################
echo
echo "Installing Spotify..."

curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/spotify.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] \
http://repository.spotify.com stable non-free" | \
sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt update
sudo apt install -y spotify-client

########################################
# Discord
########################################
echo
echo "Installing Discord..."
sudo apt install -y discord

########################################
# Steam
########################################
echo
echo "Installing Steam..."

sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y steam-installer

########################################
# QGIS
########################################
echo
echo "Installing QGIS..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.qgis.org/downloads/qgis-archive-keyring.gpg | \
    sudo tee /etc/apt/keyrings/qgis-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] \
https://qgis.org/debian $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/qgis.list

sudo apt update
sudo apt install -y qgis qgis-plugin-grass

########################################
# LibreOffice
########################################
echo
echo "Installing LibreOffice..."
sudo apt install -y libreoffice

########################################
# VLC
########################################
echo
echo "Installing VLC..."
sudo apt install -y vlc

########################################
# Transmission
########################################
echo
echo "Installing Transmission..."
sudo apt install -y transmission

########################################
# BleachBit
########################################
echo
echo "Installing BleachBit..."
sudo apt install -y bleachbit

########################################
# Bitwarden
########################################
echo
echo "Installing Bitwarden..."

wget -O /tmp/bitwarden.deb \
    "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb"

sudo apt install -y /tmp/bitwarden.deb

########################################
# Postman
########################################
echo
echo "Installing Postman..."

POSTMAN_TARBALL="/tmp/postman.tar.gz"

wget -O "$POSTMAN_TARBALL" \
    https://dl.pstmn.io/download/latest/linux64

sudo tar -xzf "$POSTMAN_TARBALL" -C /opt
sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

########################################
# Surfshark VPN
########################################
echo
echo "Installing Surfshark VPN..."

curl -f https://downloads.surfshark.com/linux/debian-install.sh | sh

########################################
# Cleanup
########################################
echo
echo "Cleaning up..."
sudo apt autoremove -y

echo
echo "========================================"
echo " Installation Complete"
echo "========================================"
echo
echo "IMPORTANT:"
echo " - Reboot recommended"
echo " - Log out/in for Docker group changes"
echo

exit 0