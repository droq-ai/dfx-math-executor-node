"""Pytest configuration and fixtures for testing."""

import os
import subprocess
import sys
import time
from pathlib import Path

import pytest

# Add src to path for imports
ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(ROOT))  # For dfx module imports


@pytest.fixture(scope="session")
def nats_server():
    """
    Fixture to check if NATS server is available.
    Relies on CI to start NATS server.
    """
    nats_url = os.getenv("NATS_URL", "nats://localhost:4222")

    # Check if NATS is already running
    try:
        import socket

        host, port = nats_url.replace("nats://", "").split(":")
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((host, int(port)))
        sock.close()
        if result == 0:
            # NATS is already running
            yield nats_url
            return
    except Exception:
        pass

    # If NATS is not running, skip tests that require it
    pytest.skip(f"NATS server not available at {nats_url}. Please start NATS or run in CI with NATS enabled.")


@pytest.fixture
def nats_url(nats_server):
    """Fixture that provides NATS URL."""
    return nats_server
