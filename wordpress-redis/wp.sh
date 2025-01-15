#!/bin/bash

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

# Create directory and cd into it
mkdir -p wordpress && cd wordpress

# Download files from GitHub
echo -e "${BLUE}Downloading configuration files...${NC}"
wget -q https://raw.githubusercontent.com/antsmartti/scriptyscript/main/wordpress-redis/docker-compose.yaml || {
   echo -e "${RED}Failed to download docker-compose.yml${NC}"
   exit 1
}
wget -q https://raw.githubusercontent.com/antsmartti/scriptyscript/main/wordpress-redis/php.ini || {
   echo -e "${RED}Failed to download php.ini${NC}"
   exit 1
}

# Generate a random salt
REDIS_SALT=$(openssl rand -hex 12)

# Prompt for Cloudflare token
echo -e "${BLUE}Please enter your Cloudflare Tunnel token:${NC}"
read -r token

# Validate token format (basic check)
if [[ ! $token =~ ^[a-zA-Z0-9\-\_]{10,}$ ]]; then
   echo -e "${RED}Invalid token format. Please check your token and try again.${NC}"
   exit 1
fi

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

# Print final Redis info
echo -e "\n${BLUE}Redis configuration:${NC}"
echo "Host: redis"
echo "Port: 6379"
echo "Salt: $REDIS_SALT"
