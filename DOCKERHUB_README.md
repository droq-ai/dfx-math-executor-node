# Droq Math Executor Node

A simple executor node for basic math operations in the Droq workflow engine, using the **dfx (Droqflow Executor)** framework.

## Overview

This Docker image provides a FastAPI-based service that can execute math components within the Droq workflow ecosystem. It's built using the dfx framework and supports multiplication operations via the `DFXMultiplyComponent`.

## Quick Start

```bash
# Pull the image
docker pull ghcr.io/droq/dfx-math-executor-node:latest

# Run with docker-compose (recommended)
curl -O https://raw.githubusercontent.com/droq/dfx-math-executor-node/main/compose.yml
curl -O https://raw.githubusercontent.com/droq/dfx-math-executor-node/main/.env
docker compose up -d

# Or run with docker directly
docker run -d \
  --name droq-math-executor-node \
  -p 8003:8003 \
  -e HOST=0.0.0.0 \
  -e PORT=8003 \
  -e LOG_LEVEL=INFO \
  ghcr.io/droq/dfx-math-executor-node:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST` | `0.0.0.0` | Host to bind the service to |
| `PORT` | `8003` | Port inside the container |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |

## API Endpoints

- `GET /health` - Health check
- `GET /` - Service information
- `POST /api/v1/execute` - Execute component methods

## Example Usage

```bash
# Test health check
curl http://localhost:8003/health

# Execute multiplication (5 × 3 = 15)
curl -X POST http://localhost:8003/api/v1/execute \
  -H "Content-Type: application/json" \
  -d '{
    "component_state": {
      "component_class": "DFXMultiplyComponent",
      "component_module": "dfx.math.component.multiply",
      "parameters": {
        "number1": 5.0,
        "number2": 3.0
      }
    },
    "method_name": "multiply",
    "is_async": false
  }'
```

## Tags

- `latest` - Latest stable release from main branch
- `main` - Latest build from main branch
- `develop` - Latest build from develop branch
- `vX.Y.Z` - Specific version releases
- `main-<sha>` - Specific commits from main branch

## Architecture

- **Base Image**: `python:3.11-slim`
- **Framework**: FastAPI with uvicorn
- **Dependencies**: Pydantic, httpx, nats-py, python-dotenv
- **Multi-platform**: Supports `linux/amd64` and `linux/arm64`

## Security

- Uses non-root user `app` inside container
- Minimal dependencies and base image
- Regular security updates via automated builds

## Support

For issues and questions:
- Repository: https://github.com/droq/dfx-math-executor-node
- Documentation: https://github.com/droq/dfx-math-executor-node#readme

## License

See the [LICENSE](https://github.com/droq/dfx-math-executor-node/blob/main/LICENSE) file for details.