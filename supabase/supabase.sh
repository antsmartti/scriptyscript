#!/bin/bash

git clone --depth 1 https://github.com/supabase/supabase
cd supabase/docker && cp docker-compose.yml docker-compose.yml.bkp && cp .env.example .env

if ! command docker compose version &> /dev/null; then
   echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
   exit 1
fi
