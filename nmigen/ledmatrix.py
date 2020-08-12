import nmigen as nm
from nmigen.cli import main


class LEDMatrix(nm.Elaboratable):
    def __init__(self, rows, cols, sys_clk_freq):
        scan_speed = int(sys_clk_freq) >> 8
        self.row_counter = nm.Signal(range(scan_speed), reset=scan_speed - 1)
        self.columns = nm.Array([nm.Signal(cols) for _ in range(rows)])

    def elaborate(self, platform):
        m = nm.Module()

        matrix = platform.request("led_matrix", 0)
        cols = matrix.columns
        rows = matrix.rows

        row_idx = nm.Signal(range(len(rows)))

        m.d.comb += [
            cols.eq(self.columns[row_idx]),
            rows.eq(1 << row_idx),
        ]

        with m.If(self.row_counter == 0):
            m.d.sync += [
                self.row_counter.eq(self.row_counter.reset),
                row_idx.eq(row_idx + 1),
            ]
        with m.Else():
            m.d.sync += [self.row_counter.eq(self.row_counter - 1)]

        return m


if __name__ == "__main__":
    from icewerx import ICE40HX8KiceFunPlatform

    platform = ICE40HX8KiceFunPlatform()
    matrix = LEDMatrix(4, 8, platform.default_clk_frequency)
    main(matrix, platform=platform)
