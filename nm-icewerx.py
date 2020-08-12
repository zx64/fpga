import os
import argparse
import subprocess
import sys

from nmigen.build import *
from nmigen.vendor.lattice_ice40 import *
from .resources import *


__all__ = ["ICE40HX8KiceWerxPlatform", "ICE40HX8KiceFunPlatform"]

_common_resources = [
    # GBIN5
    Resource(
        "clk12",
        0,
        Pins("P7", dir="i"),
        Clock(12e6),
        Attrs(GLOBAL=True, IO_STANDARD="SB_LVCMOS"),
    ),
    # Connected to the onboard PIC's 10 bit ADC
    # 250k baud, 1 start, 8 data, 1 stop, no parity
    # To read ADx on iceWerx, send byte:
    # AD1 - 0xA1, AD2 - 0xA2, AD3 - 0xA3, AD4 - 0xA4
    # On iceFun:
    # AD1 - 0xA2, AD2 - 0xA1, AD3 - 0xA3, AD4 - 0xA4
    # Receive 2 bytes, high byte first. Combine for 10 bit right justified result.
    UARTResource(
        "adc", 0, rx="P5", tx="P4", attrs=Attrs(IO_STANDARD="SB_LVCMOS"), role="adc"
    ),
    # 1MB SPI Flash
    # First three 64k sectors reserved for FPGA configuration
    *SPIFlashResources(
        0,
        cs="P13",
        clk="P12",
        copi="P11",
        cipo="M11",
        attrs=Attrs(IO_STANDARD="SB_LVCMOS"),
    ),
]


class ICE40HX8KiceWerxPlatform(LatticeICE40Platform):
    device = "iCE40HX8K"
    package = "CB132"
    default_clk = "clk12"

    resources = _common_resources + [
        *LEDResources(pins="A5 M4", attrs=Attrs(IO_STANDARD="SB_LVCMOS")),
        # Aliases
        Resource("led_red", 0, Pins("A5", dir="i"), Attrs(IO_STANDARD="SB_LVCMOS")),
        Resource("led_green", 0, Pins("M4", dir="i"), Attrs(IO_STANDARD="SB_LVCMOS")),
    ]

    connectors = [
        Connector("J2", 0, "A4 A3 A1 C3 C1 E1 G1 H1 J1 K3 M1 M3 P2 P3 M6 M7 - -"),
        Connector("J2", 1, "C5 C4 A2 B1 D3 D1 F3 G3 H3 J3 L1 N1 P1 - - - -"),
        Connector(
            "J3",
            0,
            "A7 C7 D6 A10 C10 A11 B14 C12 D12 E12 F12 G12 J12 H11 K12 N14 M12 -",
        ),
        Connector(
            "J3",
            1,
            "A6 C6 D7 D10 C11 D10 C11 A12 C14 D14 E14 F14 G14 H12 K14 L14 L12 P14 P8 -",
        ),
    ]

    def toolchain_program(self, products, name):
        icefunprog = os.environ.get("ICEFUNPROG", "icefunprog")
        if sys.platform == "win32":
            default_port = "COM3"
        else:
            default_port = "/dev/ttyS0"
        port = os.environ.get("ICEFUNPORT", default_port)
        with products.extract("{}.bin".format(name)) as bitstream_filename:
            # TODO: this should be factored out and made customizable
            subprocess.check_call([icefunprog, port, bitstream_filename])


class ICE40HX8KiceFunPlatform(ICE40HX8KiceWerxPlatform):
    resources = _common_resources + [
        Resource(
            "led_matrix_x",
            0,
            Pins("A12 D10 A6 C5", dir="o"),
            Attrs(IO_STANDARD="SB_LVCMOS"),
        ),
        Resource(
            "led_matrix_y",
            0,
            Pins("C10 A10 D7 D6 A7 C7 A4 C4", dir="o"),
            Attrs(IO_STANDARD="SB_LVCMOS"),
        ),
        *ButtonResources(pins="A11 A5 C11 C6", attrs=Attrs(IO_STANDARD="SB_LVCMOS")),
        # Piezo speaker
        Resource(
            "audio",
            0,
            Subsignal("p", Pins("M12", dir="o")),
            Subsignal("n", Pins("M6", dir="o")),
        ),
        # Designed for 12V LED strips. 3A Max.
        # Must use the GND pin between P14 and N14!
        *LEDResources(
            "high_current_leds",
            pins="L14 N14 P14",
            attrs=Attrs(IO_STANDARD="SB_LVCMOS"),
        ),
    ]

    connectors = [
        Connector(
            "PL2",
            0,
            "A3 A2 A1 C3 D3 B1 C1 D1 E1 F3 G3 H3 J3 K3 M3 G1 H1 J1 L1 M1 N1 P1 P2 P3 - - - - -",
        ),
        Connector(
            "PL2",
            1,
            "B14 C12 C14 D12 D14 E12 E14 F12 F14 G12 G14 H12 J12 K12 K14 H11 L12 L14 N14 - P14 P10 M9 P9 P8 - - - -",
        ),
    ]


if __name__ == "__main__":
    from .test.blinky import *

    variants = {
        "icewerx": ICE40HX8KiceWerxPlatform,
        "icefun": ICE40HX8KiceFunPlatform,
    }

    parser = argparse.ArgumentParser()
    parser.add_argument("variant", choices=variants.keys())
    args = parser.parse_args()

    platform = variants[args.variant]
    platform().build(Blinky(), do_program=True)
