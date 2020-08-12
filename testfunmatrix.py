import nmigen as nm

class TestMatrix(nm.Elaboratable):
    def elaborate(self, platform):
        m = nm.Module()
        matrix = platform.request("led_matrix", 0)
        cols = matrix.columns
        rows = matrix.rows
        clk_freq = platform.default_clk_frequency
        timer = nm.Signal(range(int(clk_freq//2)), reset=int(clk_freq//2) - 1)
        cactive = nm.Signal(range(len(cols)))
        ractive = nm.Signal(range(len(rows)))

        m.d.comb += [
            nm.Cat(cols).eq(cactive),
            nm.Cat(rows).eq(ractive)
        ]
        with m.If(timer == 0):
            m.d.sync += [
                timer.eq(timer.reset),
                cactive.eq(cactive + 1),
                ractive.eq(ractive + 1)
            ]
        with m.Else():
            m.d.sync += timer.eq(timer - 1)

        return m


if __name__ == "__main__":
    from nmigen_boards.icewerx import ICE40HX8KiceFunPlatform
    platform = ICE40HX8KiceFunPlatform()
    platform.build(TestMatrix(), do_program=True)
