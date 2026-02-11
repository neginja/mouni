#!/bin/bash

MOUNI_HOST=${MOUNI_HOST:-localhost}
MOUNI_PASSWORD=${MOUNI_PASSWORD:-NO_AUTH}

docker run -it --rm \
  -v ${PWD}/backend/data:/app/data \
  -e SCHEME=http \
  -e HOST=${MOUNI_HOST} \
  -e API_PORT=8080 \
  -e FRONTEND_PORT=5000 \
  -e PASSWORD=${MOUNI_PASSWORD} \
  -e CORS_ORIGINS=http://${MOUNI_HOST}:5000 \
  -e API_BASE_URL=http://${MOUNI_HOST}:8080 \
  -p 8080:8080 \
  -p 5000:5000 \
  mouni:vtest