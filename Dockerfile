# ────────────────────────────────
# Stage 1: Build Flutter Web
# ────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.35.2 AS flutter-builder

# Set working directory
WORKDIR /app/frontend

# Copy Flutter project
COPY frontend/ .

# Accept API_BASE_URL as build argument (default to localhost)
ARG API_BASE_URL=http://localhost:8080

# Build Flutter web
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ────────────────────────────────
# Stage 2: Build Backend
# ────────────────────────────────
FROM python:3.12-slim-bookworm AS backend-builder

WORKDIR /app/backend

# Install Java (required for OpenAPI generator/building wheels)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        openjdk-17-jdk \
        curl \
        unzip \
        && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt backend/requirements_dev.txt .

# Install backend dev dependencies
RUN pip install --no-cache-dir -r requirements.txt -r requirements_dev.txt

# Copy backend code
COPY backend/ .

# (Re-)Generate API server code
RUN make generate

# ────────────────────────────────
# Stage 3: Final image
# ────────────────────────────────
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app/backend/src
ENV DB_PATH=/app/data/mouni.db
ENV API_PORT=8080
ENV FRONTEND_PORT=5000
ENV HOST=localhost
ENV SCHEME=http
ENV CORS_ORIGINS=$SCHEME://$HOST:$FRONTEND_PORT
ENV API_BASE_URL=$SCHEME://$HOST:$API_PORT

# Create app directory
WORKDIR /app

# Copy backend
COPY --from=backend-builder /app/backend /app/backend

# Copy Flutter web build
COPY --from=flutter-builder /app/frontend/build/web /app/frontend/build/web

# Copy entrypoint
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install backend requirements
RUN pip install --no-cache-dir -r /app/backend/requirements.txt && pip install --no-cache-dir gunicorn

# Expose ports
EXPOSE $API_PORT $FRONTEND_PORT

# Use entrypoint
ENTRYPOINT ["/entrypoint.sh"]

