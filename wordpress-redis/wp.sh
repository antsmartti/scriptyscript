#!/bin/bash

CURRENT_DATE=$(date '+%d%m%Y-%H%M')
FOLDER_NAME=$(echo "$CURRENT_DATE" | sed 's#/#-#g')
DEST_DIR="/wordpress-$FOLDER_NAME"

# Navigate to the newly created directory
mkdir -p "$DEST_DIR" || cd "$DEST_DIR" || { echo "Failed to navigate to $DEST_DIR"; exit 1; }

# Set colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting WordPress with Redis setup...${NC}"

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
wget -q https://raw.githubusercontent.com/antsmartti/scriptyscript/main/wordpress-redis/docker-compose.yaml || {
   echo -e "${RED}Failed to download docker-compose.yaml${NC}"
   exit 1
}
wget -q https://raw.githubusercontent.com/antsmartti/scriptyscript/main/wordpress-redis/php.ini || {
   echo -e "${RED}Failed to download php.ini${NC}"
   exit 1
}

# Generate a random salt
REDIS_SALT=$(openssl rand -hex 12)
echo "Generated random salt for Redis!"

# Maximum number of attempts
MAX_ATTEMPTS=3

# Function to validate the Cloudflare token
validate_token() {
    local token=$1
    # Tokens are alphanumeric, with possible hyphens (-) and underscores (_), and typically at least 100 characters long.
    if [[ "$token" =~ ^[a-zA-Z0-9\-\_]{100,}$ ]]; then
        return 0  # Valid token
    else
        return 1  # Invalid token
    fi
}

# Prompt the user for the Cloudflare token
for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
    echo -e "${BLUE}Please enter your Cloudflare Tunnel token (Attempt $attempt of $MAX_ATTEMPTS):${NC}"
    read -r token </dev/tty

    # Trim whitespace (if any)
    token=$(echo "$token" | xargs)

    # Debug: Show the token entered
    echo -e "${BLUE}DEBUG: Token entered:${NC} '$token'"

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
# Add your code here to use the token (e.g., export it, pass it to a command, etc.)

# Create .env file with the token
echo "CLOUDFLARE_TOKEN=$token" > .env

# Start containers
echo -e "${BLUE}Starting containers...${NC}"
docker-compose up -d

# Wait for WordPress to create wp-config.php
echo -e "${BLUE}Waiting for WordPress to initialize...${NC}"
COUNTER=0
MAX_TRIES=30
while [ ! -f wordpress-data/wp-config.php ]; do
   sleep 2
   COUNTER=$((COUNTER + 1))
   if [ $COUNTER -eq $MAX_TRIES ]; then
       echo -e "${RED}Timeout waiting for WordPress initialization${NC}"
       exit 1
   fi
   echo -n "."
done
echo ""

# Create Redis configuration
echo -e "${BLUE}Configuring Redis...${NC}"
cat > redis-config.txt << EOL

/* Redis configuration */
define('WP_CACHE_KEY_SALT', '$REDIS_SALT');
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_CACHE', true);

EOL

# Insert Redis configuration before "That's all" comment
sed -i "/That's all/i $(cat redis-config.txt)" wordpress-data/wp-config.php

# Clean up
rm redis-config.txt

echo -e "${GREEN}Setup complete! Your WordPress installation is ready.${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Visit your site through Cloudflare Tunnel"
echo "2. Complete the WordPress installation"
echo "3. Install and activate Redis Object Cache plugin"
echo ""
echo -e "${BLUE}To stop the containers:${NC} docker-compose down"
echo -e "${BLUE}To view logs:${NC} docker-compose logs -f"
echo -e "${BLUE}To restart:${NC} docker-compose restart"
