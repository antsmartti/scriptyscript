#!/bin/bash

CURRENT_DATE=$(date '+%d%m%Y-%H%M')
FOLDER_NAME=$(echo "$CURRENT_DATE" | sed 's#/#-#g')
DEST_DIR="./n8n-$FOLDER_NAME"

# Navigate to the newly created directory
mkdir -p "$DEST_DIR" || cd "$DEST_DIR" || { echo "Failed to navigate to $DEST_DIR"; exit 1; }

# Set colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting n8n setup...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
   echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
   exit 1
fi

if ! command docker compose version &> /dev/null; then
   echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
   exit 1
fi

cd "$DEST_DIR"

# Download files from GitHub
echo -e "${BLUE}Downloading configuration files...${NC}"
wget -q https://raw.githubusercontent.com/antsmartti/scriptyscript/main/n8n-watchtower/docker-compose.yaml || {
   echo -e "${RED}Failed to download docker-compose.yaml${NC}"
   exit 1
}

# Prompt the user for domain
echo -e "${BLUE}Please enter your domain (example.com):${NC}"
read -r domain </dev/tty

# Trim whitespace and normalize the token
domain=$(echo "$domain" | tr -d '\r\n' | xargs)
echo "DOMAIN_NAME=$domain" >> .env

# Prompt the user for subdomain
echo -e "${BLUE}Please enter your subdomain:${NC}"
read -r subdomain </dev/tty

# Trim whitespace and normalize the token
subdomain=$(echo "$subdomain" | tr -d '\r\n' | xargs)
echo "SUBDOMAIN=$subdomain" >> .env
echo ""
echo "WEBHOOK_DOMAIN=https://$subdomain.$domain" >> .env
echo ""
echo "GENERIC_TIMEZONE=Europe/Tallinn" >> .env
echo ""

# Maximum number of attempts
MAX_ATTEMPTS=3

validate_token() {
    local token=$1

    # Check token length (minimum 100 characters)
    if [[ $(echo -n "$token" | wc -c) -lt 100 ]]; then
        echo -e "${RED}DEBUG: Token too short.${NC}"
        return 1  # Invalid token
    fi

    # Check for invalid characters (non-printable or unexpected)
    if ! echo "$token" | grep -qE '^[a-zA-Z0-9\-_]+$'; then
        echo -e "${RED}DEBUG: Token contains invalid characters.${NC}"
        return 1  # Invalid token
    fi

    return 0  # Valid token
}

# Prompt the user for the Cloudflare token
for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
    echo -e "${BLUE}Please enter your Cloudflare Tunnel token (Attempt $attempt of $MAX_ATTEMPTS):${NC}"
    read -r token </dev/tty

    # Trim whitespace and normalize the token
    token=$(echo "$token" | tr -d '\r\n' | xargs)

    # Debugging: Show token info
    #echo -e "${BLUE}DEBUG: Token length: $(echo -n "$token" | wc -c)${NC}"
    #echo -e "${BLUE}DEBUG: Visible token:${NC} '$(echo "$token" | cat -v)'"

    # Validate the token
    if validate_token "$token"; then
        echo -e "${GREEN}Token is valid.${NC}"
        break
    else
        echo -e "${RED}Invalid token format. Please check your token and try again.${NC}"
        if [[ $attempt -eq $MAX_ATTEMPTS ]]; then
            echo -e "${RED}Maximum attempts reached. Exiting.${NC}"
            exit 1
        fi
    fi
done

# Proceed with the rest of the script
echo -e "${GREEN}Proceeding with the valid token...${NC}"
echo "CLOUDFLARE_TOKEN=$token" >> .env

# Start containers
echo -e "${BLUE}Starting containers...${NC}"
docker compose up -d

echo -e "${GREEN}Setup complete! Your n8n installation is ready.${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Visit your site through Cloudflare Tunnel"
echo "2. Complete the n8n installation"
echo "3. Activate 2FA!"
echo ""
echo -e "${BLUE}To stop the containers:${NC} docker-compose down"
echo -e "${BLUE}To view logs:${NC} docker-compose logs -f"
echo -e "${BLUE}To restart:${NC} docker-compose restart"
