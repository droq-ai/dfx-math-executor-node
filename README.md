# Droq Math Executor Node

**Droq Math Executor Node** provides a unified interface for mathematical operations in Droq workflows — simplifying workflow automation and computational lifecycle operations.

## 🚀 Installation

### Using UV (Recommended)

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create and install Droq Math Executor Node
uv init my-math-project && cd my-math-project
uv add "droq-math-executor-node @ git+ssh://git@github.com/droq-ai/dfx-math-executor-node.git@main"

# Verify installation
uv run droq-math-executor-node --help
```

## 🧩 DroqFlow Integration

The Droq Math Executor Node seamlessly integrates with DroqFlow workflows through the **dfx (Droqflow Executor)** framework — a standalone, lightweight Python framework for building non-Langflow components.

### DroqFlow YAML Example

```yaml
workflow:
  name: math-workflow
  version: "1.0.0"
  description: A workflow demonstrating math operations

  nodes:
    - name: multiply-node
      type: executor
      did: did:droq:node:droq-math-executor-node-v1
      source_code:
        path: "./src"
        type: "local"
        docker:
          type: "file"
          dockerfile: "./Dockerfile"
      config:
        host: "0.0.0.0"
        port: 8003
        log_level: "INFO"
        nats_url: "nats://droq-nats-server:4222"

  streams:
    sources:
      - droq.local.public.math.results.*

permissions: []
```

## 📊 Component Categories

### Math Operations

| Component | Description | Inputs | Outputs |
|-----------|-------------|--------|---------|
| **DFXMultiplyComponent** | Multiply two numbers and return the product | `number1` (float), `number2` (float) | `result` (data) |

### Framework Components

| Component | Description | Type |
|-----------|-------------|------|
| **Component** | Base component class with input/output management | Base Class |
| **Data** | Flexible data container with attribute-like access | Data Structure |
| **NATSClient** | NATS integration for message publishing | Integration |

### Input Types

| Input Type | Description | Validation |
|------------|-------------|------------|
| **FloatInput** | Float input field with type conversion | Number validation |
| **IntInput** | Integer input field with type conversion | Number validation |
| **StrInput** | String input field with normalization | Text validation |

## ⚙️ Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `host` | `0.0.0.0` | Server host address |
| `port` | `8003` | Server port |
| `log_level` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `nats_url` | `nats://localhost:4222` | NATS server connection URL |
| `stream_name` | `droq-stream` | NATS stream name |
| `default_timeout` | `30` | Execution timeout in seconds |

## 🌐 API Endpoints

### Execute Component
```bash
POST /api/v1/execute
Content-Type: application/json

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

**Response:**
```json
{
    "status": "success",
    "result": {
        "result": 15.0,
        "number1": 5.0,
        "number2": 3.0,
        "operation": "multiply"
    },
    "execution_time": 0.001
}
```

### Health Check
```bash
GET /health
```

**Response:**
```json
{
    "status": "healthy",
    "service": "droq-math-executor-node",
    "version": "1.0.0"
}
```

## 🏗️ Architecture

The Droq Math Executor Node is built on the **dfx framework**, which provides:

- **Standalone**: No dependency on Langflow framework
- **Lightweight**: Minimal dependencies (Pydantic, FastAPI, NATS)
- **Compatible**: Works with Droq workflow engine backend
- **Scalable**: Supports async execution and NATS streaming

### Key Features

- ✅ **NATS Integration**: Real-time message streaming and publishing
- ✅ **Async Execution**: Support for both synchronous and asynchronous operations
- ✅ **Timeout Handling**: Configurable execution timeouts with proper error handling
- ✅ **Status Tracking**: Component status monitoring and logging
- ✅ **Dynamic Loading**: Runtime component loading and execution
- ✅ **Input Validation**: Type-safe input validation and conversion

## 🚀 Running Locally

```bash
# Install dependencies
uv sync

# Run the service (default port 8003)
uv run droq-math-executor-node

# Run on custom port
uv run droq-math-executor-node 9000

# Run with environment variables
NATS_URL=nats://localhost:4222 uv run droq-math-executor-node
```

## 📚 Examples

### Basic Math Operations
```python
import httpx

async def execute_multiplication():
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://localhost:8003/api/v1/execute",
            json={
                "component_state": {
                    "component_class": "DFXMultiplyComponent",
                    "component_module": "dfx.math.component.multiply",
                    "parameters": {
                        "number1": 7.5,
                        "number2": 2.5
                    }
                },
                "method_name": "multiply",
                "is_async": False
            }
        )

        result = response.json()
        print(f"Result: {result['result']['result']}")  # Output: 18.75
```

### Component Integration
```python
from dfx.math.component.multiply import DFXMultiplyComponent

# Direct component usage
component = DFXMultiplyComponent()
component.number1 = 10.0
component.number2 = 5.0

result = component.multiply()
print(f"Product: {result.result}")  # Output: 50.0
```

## 🧪 Development

### Setup Development Environment
```bash
# Install development dependencies
uv sync --dev

# Run tests
uv run pytest

# Run linting
uv run ruff check

# Run type checking
uv run mypy src/
```

### Building and Testing
```bash
# Build the package
uv build

# Run integration tests
uv run pytest tests/integration/

# Test API endpoints
uv run python examples/test_api.py
```

## 📖 Documentation

* [Installation Guide](docs/installation.md)
* [API Reference](docs/api.md)
* [Component Development](docs/components.md)
* [DroqFlow Integration](docs/droqflow.md)
* [Examples](examples/)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
