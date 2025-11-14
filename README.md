# Droq Math Executor Node

A simple executor node for basic math operations in the Droq workflow engine, using the **dfx (Droqflow Executor)** framework.

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

## Architecture

This executor node uses the **dfx** framework, which is:
- **Standalone**: No dependency on `lfx` (Langflow framework)
- **Lightweight**: Minimal dependencies (Pydantic, FastAPI, NATS)
- **Compatible**: Works with the Droq workflow engine backend

Components built with dfx can be:
- Executed in isolated executor nodes
- Registered in the Droq registry service
- Discovered and used in workflows via the editor
