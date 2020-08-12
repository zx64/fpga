import nmigen as nm


class NotGate(nm.Elaboratable):
    def __init__(self):
        self.input = nm.Signal()
        self.output = nm.Signal()

    def elaborate(self, platform):
        m = nm.Module()
        m.d.comb += self.output.eq(~self.input)
        return m


def make_verilog():
    from nmigen.back import verilog

    top = NotGate()
    with open("notgate.v", "w") as f:
        f.write(verilog.convert(top, ports=[top.input, top.output]))


def testbench():
    from nmigen.sim.pysim import Settle, Simulator

    unit = NotGate()

    def bench():
        yield unit.input.eq(0)
        yield Settle()
        assert (yield unit.output)

        yield unit.input.eq(1)
        yield Settle()
        assert not (yield unit.output)

    sim = Simulator(unit)
    sim.add_process(bench)
    with sim.write_vcd("notgate.vcd", "notgate.gtkw", traces=[unit.input, unit.output]):
        sim.run()


if __name__ == "__main__":
    make_verilog()
    testbench()
