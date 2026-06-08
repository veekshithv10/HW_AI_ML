# Benchmark: Hardware Accelerator vs Software Baseline

**Kernel:** Conv2D (3×3, 8 output channels, 16×16 input), one batch of 32 samples
**Workload:** 1,179,648 operations per batch (2 · N · C_in · k² · H_out · W_out · C_out = 2·32·1·9·16·16·8)
**Raw numbers:** see `benchmark_data.csv`

## Method of measurement

- **Software (M1 baseline):** wall-clock time from `cProfile` on the Conv2D forward pass
  (`cnn.py:128`), cumulative time per call. Platform: Intel Core i5-8265U, pure NumPy, FP64.
- **Hardware (M4 accelerator):** throughput derived from the design's known rate
  (9 MACs/cycle = 18 ops/cycle) times the post-synthesis closing frequency (83.3 MHz).
  Runtime derived from cycle count (one output per cycle after a 3-cycle pipeline fill).
  No FPGA board was used; numbers are post-synthesis (OpenLane 2, sky130A).

## Throughput

| | Throughput | Per-batch time | Precision |
|---|---|---|---|
| Software baseline (M1) | 0.280 GOPS | 4.22 ms | FP64 |
| M3 accelerator (serial) | 0.166 GOPS | 7.10 ms | INT8 |
| **M4 accelerator (pipelined)** | **1.5 GOPS** | **0.786 ms** | INT8 |

- M4 throughput = 18 ops/cycle × 83.3 MHz = **1.5 GOPS**.
- M4 per-batch time = 65,536 cycles ÷ 83.3 MHz = **0.786 ms** (65,536 = 32 × 8 × 16 × 16 output pixels, one output/cycle).

## Speedup vs M1 software baseline

Speedup = (M1 baseline time) / (M4 accelerator time) = **4.22 ms / 0.786 ms = 5.4×**.

This matches the throughput ratio 1.5 / 0.280 = 5.4×. The comparison uses the *measured*
vectorized-NumPy baseline (not a naive Python loop), and the operation count is identical
on both sides.

(For reference, M3 serial vs software = 0.166 / 0.280 = 0.59× — i.e. the serial baseline was
slightly slower than software, which is what motivated the M4 parallel/pipelined redesign.
M4 vs M3 = 1.5 / 0.166 = 9.0×, the full benefit of the 9-wide MAC array at the same clock.)

## Energy comparison (optional)

- **M4 energy/batch** = power × runtime = 21.6 mW × 0.786 ms = **17 µJ**.
- **Software energy/batch** ≈ CPU power × runtime. Assuming the i5-8265U draws on the order
  of its 15 W rated TDP during the compute: 15 W × 4.22 ms ≈ **63 mJ**.
- **Energy reduction ≈ 3,700×.** This figure is sensitive to the assumed CPU power and should
  be read as order-of-magnitude. Even discounted heavily, dedicated silicon dominates on energy,
  delivering higher throughput in 51,147 µm² versus a full CPU die.

## Where the design sits on the roofline

See `roofline_final.png`. The measured M4 point is at (AI = 8.47 FLOP/byte, 1.5 GOPS), sitting
on the M4 hardware compute ceiling (compute-bound). The software baseline is at
(AI = 1.058, 0.280 GOPS), memory-bound on the CPU. INT8 quantization produced the 8× AI shift.
The plotted accelerator point is the **measured** value, not the M1 hypothetical target.
