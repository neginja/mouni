#!/bin/sh
set -e

SCHEME=${SCHEME:-http}
HOST=${HOST:-"127.0.0.1"}
API_PORT=${API_PORT:-8080}
FRONTEND_PORT=${FRONTEND_PORT:-5000}

DEFAULT_API_BASE_URL="${SCHEME}://${HOST}:${API_PORT}"
API_BASE_URL=${API_BASE_URL:-$DEFAULT_API_BASE_URL}

cat > /app/frontend/build/web/config.json <<EOF
{
  "API_BASE_URL": "$API_BASE_URL"
}
EOF

gunicorn -k uvicorn.workers.UvicornWorker backend.src.api_server.wrapped_main:app \
    --bind 0.0.0.0:$API_PORT \
    --workers 2 \
    --timeout 120 &

python -m http.server $FRONTEND_PORT --directory /app/frontend/build/web