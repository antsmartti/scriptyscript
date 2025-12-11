#!/bin/bash

# Set colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CURRENT_DATE=$(date '+%d%m%Y-%H%M')
FOLDER_NAME=$(echo "$CURRENT_DATE" | sed 's#/#-#g')
DEST_DIR="./supabase_$FOLDER_NAME"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || { echo -e "${RED}Failed to navigate to $DEST_DIR${NC}"; exit 1; }

git clone --depth 1 https://github.com/supabase/supabase
cd supabase/docker && cp docker-compose.yml docker-compose.yml.bkp && cp .env.example .env

if ! command docker compose version &> /dev/null; then
   printf "%bDocker Compose is not installed. Please install Docker Compose first.%b\n" "${RED}" "${NC}"
   exit 1
fi

# Generate passwords
USE_STATIC_PASSWORDS=false
if [ ! -r /dev/urandom ]; then
    printf "%b/dev/urandom is not available. Using static passwords instead.%b\n" "${RED}" "${NC}"
    USE_STATIC_PASSWORDS=true
fi

generate_password() {
    local var_name=$1

    if [ "$USE_STATIC_PASSWORDS" = true ]; then
        case $var_name in
            SALT)
                rand_value="randomsalt"
                ;;
            DB_ROOT_PASSWORD|DB_PASSWORD)
                rand_value="randompassword"
                ;;
            *)
                rand_value="randompassword"
                ;;
        esac
    else
        # 12 bytes = 24 hex chars, similar to your old OpenSSL rand -hex 12
        rand_value=$(head -c 12 /dev/urandom | xxd -p)
    fi

    export "$var_name=$rand_value"
    echo "$var_name=$rand_value" >> .env
}

generate_password SALT
generate_password DB_ROOT_PASSWORD
generate_password DB_PASSWORD
