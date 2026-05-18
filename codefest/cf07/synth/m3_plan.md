# Milestone 3 Plan

Because I synthesized my actual project core (Option A), I now have a clear, data-driven hardware baseline. The OpenLane 2 synthesis revealed a setup violation with a WNS of -0.1509 ns against a strict 10.0 ns clock. 

For Milestone 3, I have two primary options to resolve this timing failure:
1. **Reduce the Clock Speed:** I can relax the clock target in `config.json` to 11.0 ns (~90 MHz) to allow the unpipelined combinational multiplication enough time to complete.
2. **Pipeline the Critical Path:** I can break the MAC operation into a two-stage pipeline by registering the multiplication output before feeding it into the accumulator. 

I plan to explore pipelining the multiplier first, as hitting the 100MHz target aligns better with the AXI4-Stream interface goals.