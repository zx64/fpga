import nmigen as nm

class LEDMatrix(nm.Elaboratable):
    def __init__(self, rows, cols):
        self.rows_enabled = nm.Signal(rows)
        self.cols_enabled = nm.Signal(cols)

    def elaborate(self, platform):
        m = nm.Module()

        matrix = platform.request("led_matrix", 0)
        cols = matrix.columns
        rows = matrix.rows

        m.d.comb += [
            cols.eq(self.cols_enabled),
            rows.eq(self.rows_enabled)
        ]

        return m

