#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env"

YES=false
if [ "${1:-}" = "-y" ]; then
  YES=true
fi

if [ -f "$ENV_FILE" ]; then
  echo ".env already exists: $ENV_FILE"
  echo "Remove it first if you want to regenerate."
  exit 1
fi

if [ "$YES" = true ]; then
  POSTGRES_USER="postgres"
  POSTGRES_PASSWORD="postgres"
  POSTGRES_DB="practice"
  POSTGRES_PORT="5432"
else
  read -rp "POSTGRES_USER [postgres]: " POSTGRES_USER
  POSTGRES_USER="${POSTGRES_USER:-postgres}"

  read -rp "POSTGRES_PASSWORD [postgres]: " POSTGRES_PASSWORD
  POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"

  read -rp "POSTGRES_DB [practice]: " POSTGRES_DB
  POSTGRES_DB="${POSTGRES_DB:-practice}"

  read -rp "POSTGRES_PORT [5432]: " POSTGRES_PORT
  POSTGRES_PORT="${POSTGRES_PORT:-5432}"
fi

cat > "$ENV_FILE" <<EOF
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_PORT=${POSTGRES_PORT}
EOF

echo ".env created: $ENV_FILE"
