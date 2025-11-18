# Droq Math Executor Node

A simple executor node for basic math operations in the Droq workflow engine, using the **dfx (Droqflow Executor)** framework.

![CI Status](https://github.com/droq/dfx-math-executor-node/workflows/Docker%20Build%20and%20Publish/badge.svg)
![Security Scan](https://github.com/droq/dfx-math-executor-node/workflows/Container%20Image%20Security%20Scan/badge.svg)
![License](https://img.shields.io/github/license/droq/dfx-math-executor-node)

> **Note**: Replace `droq` with your GitHub organization name in the examples below. The CI/CD workflows automatically adapt to your organization.

## dfx Framework

The **dfx** framework is a standalone Python framework for building non-Langflow components. It provides:

- **Component**: Base class for all components
- **Data**: Data structure for component outputs
- **Inputs**: `FloatInput`, `IntInput`, `StrInput`
- **Outputs**: `Output` class for defining component outputs
- **NATS**: NATS client for stream-based communication

## Components

### DFXMultiplyComponent

A simple component that multiplies two numbers.

**Inputs:**
- `number1` (Float): First number
- `number2` (Float): Second number

**Outputs:**
- `result` (Data): Product of the two numbers

## Running Locally

### Using Docker Compose (Recommended)

The easiest way to run the project is with Docker Compose:

```bash
# Clone the repository
git clone <repository-url>
cd dfx-math-executor-node

# Configure ports (optional - edit .env file if needed)
# Default: HOST_PORT=8003 (host port), CONTAINER_PORT=8003 (container port)
# Edit .env file to customize ports and other settings

# Build and run the service
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Stop the service
docker compose down
```

#### Environment Variables

Create or edit the `.env` file to customize the configuration:

```bash
# Host port mapping (change the left side to customize the host port)
DFX_MATH_EXE_HOST_PORT=8003

# Container configuration
DFX_MATH_EXE_CONTAINER_PORT=8003
DFX_MATH_EXE_HOST=0.0.0.0

# Logging level (DEBUG, INFO, WARNING, ERROR)
DFX_MATH_EXE_LOG_LEVEL=INFO

# Container name
DFX_MATH_EXE_CONTAINER_NAME=droq-math-executor-node
```

**To use a different host port:**
```bash
# Edit .env file: DFX_MATH_EXE_HOST_PORT=8080
# Then restart: docker compose down && docker compose up -d
```

### Without Docker (Local Development)

```bash
# Install dependencies
uv sync

# Run the service
uv run droq-math-executor-node 8003
```

## API

- `GET /health` - Health check
- `GET /` - Service info
- `POST /api/v1/execute` - Execute a component method

## Testing the Docker Compose Setup

Once the service is running with `docker compose up -d`, you can test it:

```bash
# Test health check
curl http://localhost:8003/health

# Test service info
curl http://localhost:8003/

# Test multiplication (5 × 3 = 15)
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

# Run comprehensive tests
./test_api.sh
```

## Example Usage

```python
# Execute MultiplyComponent
POST /api/v1/execute
{
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
}
```

## CI/CD

### Automated Builds

This project uses GitHub Actions for automated CI/CD:

- **Pull Requests**: Automated testing and Docker build validation
- **Main Branch**: Automated builds pushed to GitHub Container Registry
- **Tags**: Release builds with automatic GitHub releases
- **Security Scans**: Daily vulnerability scanning of container images

### Docker Registry

Images are automatically published to **GitHub Container Registry (GHCR)**:

```bash
# Organization registry (replace with your organization name)
ghcr.io/droq/dfx-math-executor-node:latest
ghcr.io/droq/dfx-math-executor-node:v1.0.0
ghcr.io/droq/dfx-math-executor-node:main
```

### Pulling from Registry

```bash
# Pull latest version
docker pull ghcr.io/droq/dfx-math-executor-node:latest

# Pull specific version
docker pull ghcr.io/droq/dfx-math-executor-node:v1.0.0

# Use in docker-compose.yml
services:
  math-executor:
    image: ghcr.io/droq/dfx-math-executor-node:latest
    environment:
      - HOST=0.0.0.0
      - PORT=8003
      - LOG_LEVEL=INFO
    ports:
      - "8003:8003"
    restart: unless-stopped

# Or use the .env file approach for easier configuration
# See Environment Variables section above
```

### Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable release (main branch) |
| `main` | Latest build from main branch |
| `develop` | Latest build from develop branch |
| `vX.Y.Z` | Specific version releases |
| `main-<sha>` | Specific commits from main branch |

## Architecture

This executor node uses the **dfx** framework, which is:
- **Standalone**: No dependency on `lfx` (Langflow framework)
- **Lightweight**: Minimal dependencies (Pydantic, FastAPI, NATS)
- **Compatible**: Works with the Droq workflow engine backend
- **Multi-platform**: Supports AMD64 and ARM64 architectures

Components built with dfx can be:
- Executed in isolated executor nodes
- Registered in the Droq registry service
- Discovered and used in workflows via the editor

## Security

- ✅ **Vulnerability Scanning**: Automated daily security scans
- ✅ **Dependency Reviews**: Automated dependency analysis on PRs
- ✅ **SBOM Generation**: Software Bill of Materials for each build
- ✅ **Non-root Container**: Runs as non-root user for security
- ✅ **Minimal Base Image**: Uses slim Python base image
