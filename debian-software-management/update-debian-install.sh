#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " Debian 13 Workstation Update"
echo "========================================"

# Ensure script is not run as root
if [[ "$EUID" -eq 0 ]]; then
    echo "Please run this script as a normal user, not root."
    exit 1
fi

########################################
# System Update
########################################
echo
echo "Updating package lists..."
sudo apt update

echo
echo "Upgrading installed packages..."
sudo apt full-upgrade -y

########################################
# Refresh External Repository Keys
########################################

echo
echo "Refreshing Docker repository key..."

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo
echo "Refreshing Mozilla repository key..."

sudo install -d -m 0755 /etc/apt/keyrings

wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
    sudo gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg

echo
echo "Refreshing Brave repository key..."

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo
echo "Refreshing Spotify repository key..."

curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/spotify.gpg > /dev/null

echo
echo "Refreshing QGIS repository key..."

curl -fsSL https://download.qgis.org/downloads/qgis-archive-keyring.gpg | \
    sudo tee /etc/apt/keyrings/qgis-archive-keyring.gpg > /dev/null

########################################
# Refresh Package Lists
########################################
echo
echo "Refreshing repositories..."
sudo apt update

########################################
# Update APT Applications
########################################
echo
echo "Updating installed APT applications..."

sudo apt install --only-upgrade -y \
    git \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    code \
    firefox \
    brave-browser \
    spotify-client \
    discord \
    steam-installer \
    qgis \
    qgis-plugin-grass \
    libreoffice \
    vlc \
    transmission \
    bleachbit

########################################
# Update Bitwarden
########################################
echo
echo "Updating Bitwarden..."

BITWARDEN_DEB="/tmp/bitwarden.deb"

wget -O "$BITWARDEN_DEB" \
    "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb"

sudo apt install -y "$BITWARDEN_DEB"

########################################
# Update Postman
########################################
echo
echo "Updating Postman..."

POSTMAN_TARBALL="/tmp/postman.tar.gz"

wget -O "$POSTMAN_TARBALL" \
    https://dl.pstmn.io/download/latest/linux64

sudo rm -rf /opt/Postman

sudo tar -xzf "$POSTMAN_TARBALL" -C /opt

sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

########################################
# Update Surfshark VPN
########################################
echo
echo "Updating Surfshark VPN..."

curl -f https://downloads.surfshark.com/linux/debian-install.sh | sh

########################################
# Flatpak Updates (Optional)
########################################
if command -v flatpak >/dev/null 2>&1; then
    echo
    echo "Updating Flatpak applications..."
    flatpak update -y
fi

########################################
# Cleanup
########################################
echo
echo "Removing unused packages..."
sudo apt autoremove -y

echo
echo "Cleaning package cache..."
sudo apt autoclean -y

########################################
# Finished
########################################
echo
echo "========================================"
echo " Update Complete"
echo "========================================"
echo
echo "Recommended:"
echo " - Reboot if the kernel or graphics stack updated"
echo " - Restart Docker if needed:"
echo "     sudo systemctl restart docker"
echo
echo "You can verify pending reboots with:"
echo "     [ -f /var/run/reboot-required ] && echo 'Reboot required'"
echo

exit 0