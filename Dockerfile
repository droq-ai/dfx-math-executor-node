# syntax=docker/dockerfile:1
# Dockerfile for Droq Math Executor Node
# Build from repo root: docker build -f Dockerfile -t droqai/dfx-math-executor-node:latest .

################################
# BUILDER STAGE
################################
FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base libffi-dev openssl-dev

WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Copy dependency files
COPY pyproject.toml /app/pyproject.toml
COPY README.md /app/README.md

# Copy source code
COPY dfx/ /app/dfx/
COPY src/ /app/src/

# Copy configuration files
COPY node.json /app/node.json
COPY start-local.sh /app/start-local.sh

# Create venv and install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    uv venv && \
    uv pip install --python /app/.venv/bin/python --no-cache -e .

################################
# RUNTIME STAGE
################################
FROM python:3.12-alpine AS runtime

# Install runtime dependencies
RUN apk add --no-cache curl bash

# Create non-root user
RUN adduser -D -u 1000 -G root -h /app -s /sbin/nologin executor

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder --chown=executor:root /app/.venv /app/.venv

# Copy application code
COPY --from=builder --chown=executor:root /app/dfx /app/dfx
COPY --from=builder --chown=executor:root /app/src /app/src
COPY --from=builder --chown=executor:root /app/node.json /app/node.json
COPY --from=builder /app/start-local.sh /app/start-local.sh

# Add venv to PATH
ENV PATH="/app/.venv/bin:$PATH"

# Make startup script executable
RUN chmod +x /app/start-local.sh && \
    chown executor:root /app/start-local.sh

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV HOST=0.0.0.0
ENV PORT=8003
ENV DOCKER_CONTAINER=1

# Switch to non-root user
USER executor

# Expose port
EXPOSE 8003

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8003/health || exit 1

# Run the service
CMD ["/bin/bash", "./start-local.sh"]
