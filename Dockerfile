# ────────────────────────────────
# Stage 1: Build Flutter Web
# ────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.35.2 AS flutter-builder
WORKDIR /app/frontend
COPY frontend/ .
ARG API_BASE_URL=http://127.0.0.1:8080
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ────────────────────────────────
# Stage 2: Build Backend
# ────────────────────────────────
FROM python:3.12-slim-bookworm AS backend-builder

# Install build dependencies for OpenAPI generator
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    openjdk-17-jdk \
    curl \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install uv binary
COPY --from=ghcr.io/astral-sh/uv:0.10.9 /uv /usr/local/bin/uv

WORKDIR /app/backend
COPY backend/pyproject.toml backend/uv.lock ./

# Create a virtual environment and install only production dependencies
# Using --frozen ensures consistency with your lock file
RUN uv sync --group dev

# Copy remaining code and generate API
COPY backend/ .
RUN make generate

# ────────────────────────────────
# Stage 3: Final image (The "Lean" Production Stage)
# ────────────────────────────────
FROM alpine:3.23.3

# Install uv binary
COPY --from=ghcr.io/astral-sh/uv:0.10.9 /uv /usr/local/bin/uv

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/backend/src \
    DB_PATH=/app/data/mouni.db \
    API_PORT=8080 \
    FRONTEND_PORT=5000 \
    PATH="/usr/local/bin:/app/backend/.venv/bin:$PATH"

WORKDIR /app

# Copy only the necessary backend code files
COPY --from=backend-builder /app/backend/pyproject.toml /app/backend/uv.lock /app/backend/
# Install prod only dependencies
RUN cd backend && uv sync --group deploy --no-dev --frozen --no-editable
COPY --from=backend-builder /app/backend/src /app/backend/src

# Copy frontend built app
COPY --from=flutter-builder /app/frontend/build/web /app/frontend/build/web

# Configure entrypoint
COPY docker-entrypoint.sh ./
RUN chmod +x ./docker-entrypoint.sh

EXPOSE $API_PORT $FRONTEND_PORT

ENTRYPOINT ["./docker-entrypoint.sh"]