from nmigen import *
from nmigen.build import *

__all__ = ["ST7789VResource"]


def ST7789VResource(connector, connector_id):
    def pin(pin, dir="o"):
        return PinsN(str(pin), dir=dir, conn=(connector, connector_id))

    return [
        Resource(
            "ST7789V",
            0,
            Subsignal("copi", pin(1)),
            Subsignal("clk", pin(2)),
            Subsignal("cs", pin(3)),  # active low
            Subsignal("dc", pin(4)),  # high => data, low => command
            Subsignal("rst", pin(5)),
            Subsignal("backlight", pin(6)),
        )
    ]
