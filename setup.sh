#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "  Monorepo Template - Project Setup"
echo "========================================="
echo ""

# --- Prompt for project name ---
read -rp "Project name (lowercase, no spaces, e.g. my-app): " PROJECT_NAME

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: project name cannot be empty."
  exit 1
fi

if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9_-]+$ ]]; then
  echo "Error: project name must contain only lowercase letters, digits, hyphens, or underscores."
  exit 1
fi

echo ""
echo "Setting up project: $PROJECT_NAME"
echo ""

# --- Copy example files ---
echo "[1/6] Copying example configuration files..."

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "  Created .env from .env.example"
else
  echo "  .env already exists, skipping"
fi

if [[ ! -f apps/web/public/config.js ]]; then
  cp config/web/config.example.js apps/web/public/config.js
  echo "  Created apps/web/public/config.js from config.example.js"
else
  echo "  apps/web/public/config.js already exists, skipping"
fi

# --- Replace template placeholders ---
echo "[2/6] Replacing 'template' with '$PROJECT_NAME'..."

# .env
sed -i "s/DB_NAME=template/DB_NAME=$PROJECT_NAME/g" .env
sed -i "s|localhost:5432/template|localhost:5432/$PROJECT_NAME|g" .env
sed -i "s|/realms/template|/realms/$PROJECT_NAME|g" .env

# config.js
sed -i "s/realm: 'template'/realm: '$PROJECT_NAME'/g" apps/web/public/config.js
sed -i "s/clientId: 'template-web'/clientId: '$PROJECT_NAME-web'/g" apps/web/public/config.js

# docker-compose.yml
sed -i "s/template_postgres/${PROJECT_NAME}_postgres/g" docker-compose.yml
sed -i "s/template_keycloak/${PROJECT_NAME}_keycloak/g" docker-compose.yml
sed -i "s/template_network/${PROJECT_NAME}_network/g" docker-compose.yml

echo "  Done."

# --- Install dependencies ---
echo "[3/6] Installing dependencies..."
npm install

# --- Start infrastructure ---
echo "[4/6] Starting infrastructure (PostgreSQL, Keycloak)..."
docker compose up -d

# --- Wait for PostgreSQL ---
echo "[5/6] Waiting for PostgreSQL to be ready..."
until docker exec "${PROJECT_NAME}_postgres" pg_isready -U postgres > /dev/null 2>&1; do
  sleep 1
done
echo "  PostgreSQL is ready."

# --- Prisma ---
echo "[6/6] Generating Prisma client and applying migrations..."
npm run prisma:generate
npm run prisma:migrate:deploy

echo ""
echo "========================================="
echo "  Setup complete!"
echo "========================================="
echo ""
echo "Start developing:"
echo "  npm run serve:api    # API:  http://localhost:3000"
echo "  npm run serve:web    # Web:  http://localhost:4200"
echo ""
echo "Don't forget to:"
echo "  - Configure your Keycloak realm '$PROJECT_NAME' at http://localhost:8080"
echo "  - Update KEYCLOAK_CLIENT_ID and KEYCLOAK_CLIENT_SECRET in .env"
echo "  - Update nxCloudId in nx.json (or remove it)"
echo "  - Set up GitHub repo variables/secrets (see README.md)"
