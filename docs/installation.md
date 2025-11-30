# Installation Guide

This guide covers different ways to install and set up the DFX Math Executor Node.

## Prerequisites

- Python 3.8 or higher
- [UV package manager](https://github.com/astral-sh/uv) (recommended)
- NATS server (for local development)

## Option 1: Using UV (Recommended)

### Install UV

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Clone and Install

```bash
# Clone the repository
git clone https://github.com/droq-ai/dfx-math-executor-node.git
cd dfx-math-executor-node

# Install dependencies
uv sync --all-extras

# Verify installation
uv run droq-math-executor-node --help
```

## Option 2: Using the Installation Script

```bash
# Download and run the installation script
curl -fsSL https://raw.githubusercontent.com/droq-ai/dfx-math-executor-node/main/install.sh | bash
```

## Option 3: From Source with pip

```bash
# Clone the repository
git clone https://github.com/droq-ai/dfx-math-executor-node.git
cd dfx-math-executor-node

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -e .

# Install dev dependencies (optional)
pip install -e ".[dev]"
```

## NATS Server Setup

For local development, you'll need a NATS server:

### Option A: Docker

```bash
docker run -d --name nats -p 4222:4222 nats:latest
```

### Option B: Local Installation

```bash
# Download NATS
curl -L https://github.com/nats-io/nats-server/releases/latest/download/nats-server-linux-amd64.zip -o nats-server.zip
unzip nats-server.zip
./nats-server
```

### Option C: System Package

```bash
# On macOS
brew install nats-server

# On Ubuntu/Debian
sudo apt-get install nats-server
```

## Environment Configuration

Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

Edit `.env` as needed:

```env
# NATS Configuration
NATS_URL=nats://localhost:4222
STREAM_NAME=droq-stream

# HTTP Client Configuration
HTTP_TIMEOUT=30
HTTP_MAX_RETRIES=3

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
```

## Verify Installation

### Check Service Health

```bash
# Start the service
uv run droq-math-executor-node

# In another terminal, check health
curl http://localhost:8000/health
```

### Run Tests

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=math_executor --cov-report=html

# Run specific test
uv run pytest tests/test_api.py
```

### Check Code Quality

```bash
# Linting
uv run ruff check .

# Formatting
uv run ruff format .

# Type checking
uv run mypy src/math_executor
```

## Docker Installation

### Build Docker Image

```bash
docker build -t droq-math-executor-node .
```

### Run with Docker

```bash
# Simple run
docker run -p 8000:8000 droq-math-executor-node

# With NATS
docker run -p 8000:8000 --env NATS_URL=nats://host.docker.internal:4222 droq-math-executor-node

# With custom configuration
docker run -p 8000:8000 \
  --env-file .env \
  droq-math-executor-node
```

### Docker Compose

```yaml
version: '3.8'
services:
  nats:
    image: nats:latest
    ports:
      - "4222:4222"
    command: ["-js"]

  math-executor:
    build: .
    ports:
      - "8000:8000"
    environment:
      - NATS_URL=nats://nats:4222
      - STREAM_NAME=droq-stream
    depends_on:
      - nats
```

Run with:

```bash
docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **ImportError: No module named 'math_executor'**
   - Make sure you're in the project directory
   - Run `uv sync` to install dependencies

2. **NATS connection failed**
   - Ensure NATS server is running: `docker run -p 4222:4222 nats:latest`
   - Check NATS URL in your `.env` file

3. **Port already in use**
   - Change the port: `uv run droq-math-executor-node 8003`
   - Or kill the process using the port: `lsof -ti:8000 | xargs kill`

4. **Permission denied on install.sh**
   - Make it executable: `chmod +x install.sh`

### Getting Help

- 📖 [Documentation](https://github.com/droq-ai/dfx-math-executor-node#readme)
- 🐛 [Bug Reports](https://github.com/droq-ai/dfx-math-executor-node/issues)
- 💬 [Discussions](https://github.com/droq-ai/dfx-math-executor-node/discussions)