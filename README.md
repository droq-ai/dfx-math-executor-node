# Droq Math Executor Node

**Droq Math Executor Node** provides a unified interface for mathematical operations.

## 🚀 Installation

### Using UV (Recommended)

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone and setup
git clone https://github.com/droq-ai/dfx-math-executor-node.git
cd dfx-math-executor-node
uv sync

# Verify installation
uv run droq-math-executor-node --help
```

### Using Docker

```bash
docker build -t droq-math-executor-node:latest .
docker run --rm -p 8003:8003 droq-math-executor-node:latest
```

## 🧩 Usage

### Running the Node

```bash
# Run locally (defaults to port 8003)
./start-local.sh

# or specify a port
./start-local.sh 8003

# or use uv directly
uv run droq-math-executor-node --port 8003
```

### API Endpoints

The server exposes:

- `GET /health` – readiness probe
- `POST /api/v1/execute` – execute math components

## ⚙️ Configuration

Environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `8003` | HTTP port |
| `LOG_LEVEL` | `INFO` | Python logging level |
| `NATS_URL` | `nats://localhost:4222` | NATS server connection URL |
| `NODE_ID` | `droq-math-executor-node` | Node identifier |

## 🔧 Development

```bash
# Install development dependencies
uv sync --group dev

# Run tests
uv run pytest

# Format code
uv run black src/ tests/
uv run ruff check src/ tests/
uv run ruff format src/ tests/

# Type checking
uv run mypy src/
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [Droq Node Registry](https://github.com/droq-ai/droq-node-registry) - Node discovery and registration
- [DroqFlow](https://github.com/droq-ai/droqflow) - Visual workflow builder
