#!/bin/bash
# Start the Droq Math Executor Node locally

set -e

PORT=${1:-8003}

echo "🚀 Starting Droq Math Executor Node on port $PORT..."

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ Error: uv is not installed. Please install it first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Run the service
uv run droq-math-executor-node "$PORT"

