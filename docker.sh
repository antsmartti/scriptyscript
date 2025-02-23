#UBUNTU
#!/bin/sh

# Set colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Add Docker's official GPG key and repository for Ubuntu
install_ubuntu() {
    echo -e "${GREEN}Detected Ubuntu. Installing Docker and dependencies...${NC}"

    # Remove old versions of Docker
    sudo apt-get remove -y docker docker-engine docker.io containerd runc

    # Update package list and install prerequisites
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg

    # Add Docker's GPG key
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
    echo -e "${RED}Failed to add Docker's GPG key${NC}"
    exit 1
fi
    # Set up the Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package list again
    sudo apt-get update

    # Install Docker packages
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker installation completed on Ubuntu."

    sudo usermod -aG docker $USER
    echo -e "${GREEN}Added user to docker group.${NC}"
    echo -e "${BLUE}System will logout in 10 seconds to apply changes...${NC}"
    echo -e "${RED}Please log in with your new user afterwards!${NC}"
    sleep 10
    kill -9 -1
}
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
