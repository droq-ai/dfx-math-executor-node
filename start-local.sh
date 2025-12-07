#!/bin/bash
# Start the Droq Math Executor Node locally

set -e

PORT=${1:-8003}

echo "🚀 Starting Droq Math Executor Node on port $PORT..."

# Check if running in Docker
if [ -n "${DOCKER_CONTAINER:-}" ]; then
    echo "Running in Docker container - using venv Python directly"
    # Use the venv that was copied from the builder stage
    if [ -d "/app/.venv" ]; then
        export PATH="/app/.venv/bin:$PATH"
        PYTHON_CMD="/app/.venv/bin/python"
    else
        PYTHON_CMD="python"
    fi
    
    # Set PYTHONPATH
    export PYTHONPATH="/app:${PYTHONPATH:-}"
    
    # Run using uvicorn directly
    cd /app
    exec $PYTHON_CMD -m uvicorn math_executor.api:app --host "${HOST:-0.0.0.0}" --port "${PORT}" --log-level "${LOG_LEVEL:-info}"
else
    # Local development - check if uv is available
    if ! command -v uv &> /dev/null; then
        echo "❌ Error: uv is not installed. Please install it first:"
        echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
    
    # Install local dfx package in editable mode
    echo "📦 Installing local dfx package..."
    uv pip install -e .
    
    # Run the service
    uv run droq-math-executor-node "$PORT"
fi

