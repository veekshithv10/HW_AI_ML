# Critical Path Analysis

**Start Point:** The start point is the output of the data input registers in the AXI4-Stream interface (`s_axis_tdata`), specifically the registers holding the multiplicand and multiplier values.

**End Point:** The end point is the input to the accumulator register (`accumulator_reg`) inside the compute core.

**Logic Stages:**
1. **Interface Logic:** The signal propagates from the AXI registers through the input synchronization and gating logic.
2. **Multiplication:** The signal enters the 8x8-bit signed combinational multiplier array. This is the logic-intensive portion of the path where the partial products are calculated.
3. **Accumulation:** The product of the multiplication is fed into the 16-bit combinational adder, which sums the current product with the previous accumulation value.
4. **Capture:** The final sum is latched into the accumulator register at the next clock edge.

**Why this is the critical path:**
This path is critical because it captures the entire mathematical operation of the MAC unit within a single clock cycle. Multiplier trees are comprised of dense "clouds" of combinational logic gates (XNOR, NOR, and AND-OR-Invert cells, as seen in your cell statistics). The propagation delay of these gates, combined with the carry-chain delay of the 16-bit adder, represents the longest timing constraint in the design.

**How to shorten it:**
To significantly shorten this path, a pipeline stage should be inserted. By adding a register (flip-flops) immediately after the multiplier output, you would split the path into two cycles: one for the multiplication and one for the accumulation. This would allow for a much higher clock frequency (reducing the clock period target) at the cost of increasing the total latency by one clock cycle.
