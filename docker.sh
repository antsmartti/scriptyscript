#!/bin/sh

#UBUNTU
install_ubuntu() {
    echo "Detected Ubuntu. Installing dependencies..."
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get remove docker docker-engine docker.io || true
    sudo apt-get update
    sudo apt install curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo systemctl enable docker
    echo "Installation completed for Ubuntu."
}

# ALPINE
install_alpine() {
    echo "Detected Alpine. Installing dependencies..."
    apk update
    apk add curl nano docker docker-compose git github-cli python3 py3-pip
    rc-update add docker default
    /etc/init.d/docker start
    echo "Installation completed for Alpine."
}

# Detect the OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu)
            install_ubuntu
            ;;
        alpine)
            install_alpine
            ;;
        *)
            echo "Unsupported operating system: $ID"
            exit 1
            ;;
    esac
else
    echo "Unable to detect the operating system."
    exit 1
fi
