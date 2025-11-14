"""Main entry point for Droq Math Executor Node."""

import logging
import sys

import uvicorn

from math_executor.api import app

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def main():
    """Run the FastAPI application."""
    host = "0.0.0.0"
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8003

    logger.info(f"Starting Droq Math Executor Node on {host}:{port}")
    uvicorn.run(app, host=host, port=port, log_level="info")


if __name__ == "__main__":
    main()

