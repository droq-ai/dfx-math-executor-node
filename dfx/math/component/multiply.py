"""Simple multiply component that multiplies two numbers."""

from dfx import Component, Data, FloatInput, Output


class DFXMultiplyComponent(Component):
    """Component that multiplies two numbers.
    
    This is a simple component that takes two numbers as input
    and returns their product.
    """

    display_name: str = "DFX Multiply"
    description: str = "Multiply two numbers and return the product."
    icon: str = "calculator"
    name: str = "DFXMultiply"

    inputs: list = [
        FloatInput(
            name="number1",
            display_name="First Number",
            info="The first number to multiply.",
            value=0.0,
        ),
        FloatInput(
            name="number2",
            display_name="Second Number",
            info="The second number to multiply.",
            value=0.0,
        ),
    ]

    outputs: list = [
        Output(
            display_name="Product",
            name="result",
            type_=Data,
            method="multiply",
        ),
    ]

    def multiply(self) -> Data:
        """Multiply two numbers and return the result.
        
        Returns:
            Data: Contains the product of the two numbers.
        """
        try:
            # Get the input values
            num1 = float(self.number1) if self.number1 is not None else 0.0
            num2 = float(self.number2) if self.number2 is not None else 0.0

            # Perform multiplication
            result = num1 * num2

            # Log the operation
            self.log(f"Multiplying {num1} × {num2} = {result}")

            # Set status
            self.status = f"{num1} × {num2} = {result}"

            # Return result as Data
            return Data(
                data={
                    "result": result,
                    "number1": num1,
                    "number2": num2,
                    "operation": "multiply",
                }
            )

        except (ValueError, TypeError) as e:
            error_message = f"Error multiplying numbers: {e}"
            self.status = error_message
            self.log(error_message)
            return Data(
                data={
                    "error": error_message,
                    "number1": self.number1,
                    "number2": self.number2,
                }
            )

    def build(self):
        """Return the main multiply function."""
        return self.multiply

