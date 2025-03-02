#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try: sudo $0"
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Update package lists
echo "Updating package list..."
apt update -q

# Install required packages only if not already installed
REQUIRED_PACKAGES=(curl sudo)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! is_installed "$pkg"; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
    else
        echo "$pkg is already installed, skipping."
    fi
done

# Download and execute YOUR custom script
SCRIPT_NAME="install-node.sh"

if [ -f "$SCRIPT_NAME" ]; then
    echo "$SCRIPT_NAME already exists, removing old version..."
    rm -f "$SCRIPT_NAME"
fi

echo "Downloading latest version of $SCRIPT_NAME from your repo..."
curl -O https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main/install-node.sh

chmod +x "$SCRIPT_NAME"
./"$SCRIPT_NAME"
