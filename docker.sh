#!/bin/sh

#UBUNTU
install_ubuntu() {
    echo "Detected Ubuntu. Installing dependencies..."
sudo apt update
sudo apt-get update  
sudo apt-get install docker.io docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
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
