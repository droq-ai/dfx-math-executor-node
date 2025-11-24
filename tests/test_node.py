"""Basic tests for the Droq Math Executor Node."""

import sys
from pathlib import Path

import pytest

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))
# Add root to path for dfx imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from math_executor.main import main


def test_imports():
    """Test that the module can be imported."""
    from math_executor import main

    assert main is not None


def test_main_import():
    """Test that main function can be imported and is callable."""
    assert callable(main)
    # main is a synchronous function, so we don't call it here
    # as it would start the server and block


def test_main_callable():
    """Test that main function exists and is callable."""
    assert main is not None
    assert callable(main)


def test_dfx_multiply_import():
    """Test that the DFX multiply component can be imported."""
    try:
        from dfx.math.component.multiply import DFXMultiplyComponent
        assert DFXMultiplyComponent is not None
        # Test display_name on an instance, not the class
        component = DFXMultiplyComponent()
        assert component.display_name == "DFX Multiply"
    except ImportError as e:
        pytest.skip(f"Could not import DFXMultiplyComponent: {e}")


def test_dfx_multiply_component():
    """Test DFX multiply component basic functionality."""
    try:
        from dfx.math.component.multiply import DFXMultiplyComponent

        # Create component instance
        component = DFXMultiplyComponent()
        assert component is not None
        assert component.display_name == "DFX Multiply"
        assert component.name == "DFXMultiply"

        # Test that it has the expected inputs and outputs
        input_names = [inp.name for inp in component.inputs]
        assert "number1" in input_names
        assert "number2" in input_names

        output_names = [out.name for out in component.outputs]
        assert "result" in output_names

    except ImportError as e:
        pytest.skip(f"Could not test DFXMultiplyComponent: {e}")
