FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY pyproject.toml README.md* ./
COPY src/ ./src/
COPY dfx/ ./dfx/

# Install dependencies directly
RUN pip install fastapi uvicorn pydantic httpx nats-py python-dotenv

# Skip the problematic pip install -e .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

# Expose port
EXPOSE 8003

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8003/health || exit 1

# Run the application directly
CMD ["python", "-c", "import sys; sys.path.append('/app/src'); sys.argv = ['main.py', '8003']; from math_executor.main import main; main()"]