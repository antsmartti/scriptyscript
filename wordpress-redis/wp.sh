#!/bin/bash

CURRENT_DATE=$(date '+%d%m%Y-%H%M')
FOLDER_NAME=$(echo "$CURRENT_DATE" | sed 's#/#-#g')
DEST_DIR="./wordpress-$FOLDER_NAME"
PLUGIN_REPO="https://github.com/rhubarbgroup/redis-cache.git"
PLUGIN_SLUG="redis-cache"
PLUGINS_DIR="$DEST_DIR/wp-content/plugins"

# Navigate to the newly created directory
mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || { echo -e "${RED}Failed to navigate to $DEST_DIR${NC}"; exit 1; }

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

# Generate random passwords or use static passwords if OpenSSL is unavailable
USE_STATIC_PASSWORDS=false
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}OpenSSL is not installed. Using static passwords instead.${NC}"
    USE_STATIC_PASSWORDS=true
fi

# Password generation logic
generate_passwords() {
    local var_name=$1
    if [ "$USE_STATIC_PASSWORDS" = true ]; then
        case $var_name in
            REDIS_SALT)
                rand_value="randomsalt"
                ;;
            DB_ROOT_PASSWORD)
                rand_value="randompassword"
                ;;
            DB_PASSWORD)
                rand_value="randompassword"
                ;;
            *)
                rand_value="randompassword"
                ;;
        esac
    else
        rand_value=$(openssl rand -hex 12)
    fi
    export $var_name=$rand_value
    echo "$var_name=$rand_value" >> .env
}

# Call the function for necessary variables
generate_passwords REDIS_SALT
generate_passwords DB_ROOT_PASSWORD
generate_passwords DB_PASSWORD

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

# Wait for WordPress to create wp-config.php
echo -e "${BLUE}Waiting for WordPress to initialize...${NC}"
COUNTER=0
MAX_TRIES=30
while [ ! -f wordpress-data/wp-config.php ]; do
   sleep 3
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

cd "$PLUGINS_DIR" || { echo "Plugins directory not found at $PLUGINS_DIR"; exit 1; }

#Clone the redis plugin
echo "Cloning plugin from $PLUGIN_REPO..."
git clone "$PLUGIN_REPO" || { echo "Failed to clone the plugin repository"; exit 1; }

echo "Setting permissions for $PLUGIN_SLUG..."
chmod -R 755 "$PLUGIN_SLUG" || { echo "Failed to set permissions"; exit 1; }

#Activate the plugin using WP-CLI
echo "Activating plugin $PLUGIN_SLUG..."
wp plugin activate "$PLUGIN_SLUG" --path="$DEST_DIR" || { echo "Failed to activate plugin"; exit 1; }

echo "Plugin successfully installed and activated."

echo -e "${GREEN}Setup complete! Your WordPress installation is ready.${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Visit your site"
echo "2. Complete the WordPress installation"
echo "3. Redis Object Cache plugin should already be installed and activated"
echo ""
echo -e "${BLUE}To stop the containers:${NC} docker-compose down"
echo -e "${BLUE}To view logs:${NC} docker-compose logs -f"
echo -e "${BLUE}To restart:${NC} docker-compose restart"
