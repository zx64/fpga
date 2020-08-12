import nmigen as nm
from ledmatrix import LEDMatrix


class TestMatrix(nm.Elaboratable):
    def elaborate(self, platform):
        m = nm.Module()
        clk_freq = platform.default_clk_frequency
        speed = int(clk_freq // (1 << 4))
        frame_counter = nm.Signal(range(speed), reset=speed - 1)
        stepctr = nm.Signal(4)
        step = nm.Signal(3)

        matrix = m.submodules.matrix = LEDMatrix(4, 8, clk_freq)

        with m.If(stepctr >= 8):
            m.d.comb += step.eq(7 - stepctr[0:3])
        with m.Else():
            m.d.comb += step.eq(stepctr)

        m.d.comb += [
            matrix.columns[0].eq(1 << step),
            matrix.columns[1].eq(1 << step | 2 << step),
            matrix.columns[2].eq(~0 ^ 4 << step),
            matrix.columns[3].eq(~0 ^ (1 << step | 8 << step)),
        ]

        with m.If(frame_counter == 0):
            m.d.sync += [stepctr.eq(stepctr + 1), frame_counter.eq(frame_counter.reset)]
        with m.Else():
            m.d.sync += [frame_counter.eq(frame_counter - 1)]
        return m


if __name__ == "__main__":
    from icewerx import ICE40HX8KiceFunPlatform

    platform = ICE40HX8KiceFunPlatform()
    platform.build(TestMatrix(), do_program=True)
