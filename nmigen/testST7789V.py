import nmigen as nm

from ST7789V import ST7789VResource


class TestST7789V(nm.Elaboratable):
    def elaborate(self, platform):
        m = nm.Module()

        activity = platform.request("led", 0)
        activity_timer = nm.Signal(24)
        m.d.comb += activity.eq(activity_timer[-1])
        m.d.sync += activity_timer.eq(activity_timer + 1)

        spiclk = nm.Signal(8)
        m.d.sync += spiclk.eq(spiclk + 1)

        display = platform.request("ST7789V", 0)
        m.d.comb += [
            display.rst.eq(0),
            display.cs.eq(0),
            display.backlight.eq(activity_timer[-1]),
            display.dc.eq(0),
            display.clk.eq(spiclk[-1]),
            display.copi.eq(0),
        ]

        return m


if __name__ == "__main__":
    from icewerx import ICE40HX8KiceWerxPlatform

    plat = ICE40HX8KiceWerxPlatform()
    plat.add_resources(ST7789VResource("J2", 1))
    plat.build(TestST7789V(), do_program=True)
