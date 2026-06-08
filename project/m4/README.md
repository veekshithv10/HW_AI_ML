# Milestone 4 — File Catalog

INT8 Conv2D MAC accelerator (sky130A, OpenLane 2). This file catalogs every file in
`project/m4/`, with a one-line description and the checklist item or report section it supports.

**Design summary:** weight-stationary, INT8, nine-wide parallel MAC array with a three-stage
pipeline; 72-bit AXI4-Stream input. Closes at 83.3 MHz, clean signoff across all 9 PVT corners.
1.5 GOPS, 5.4× faster than the software baseline, 51,147 µm², 21.6 mW.

**Diff vs M3:** M3 was a single serial MAC (one multiplier + accumulator, 9 cycles/output,
0.166 GOPS, 6,596 µm²). M4 widens this to 9 parallel multipliers + a pipelined adder tree
(1 output/cycle, 1.5 GOPS, 51,147 µm²) and adds a 3-stage pipeline. Same INT8 format, same
weight-stationary dataflow, same 83.3 MHz target.

## rtl/ — final source code (Checklist §2)
| File | Description |
|---|---|
| `rtl/top.sv` | Top module: integrates interface + compute core, FSM (LOAD_WEIGHTS → COMPUTE). |
| `rtl/compute_core.sv` | 9 parallel INT8 MACs + pipelined adder tree (3-stage). The synthesized compute datapath. |
| `rtl/interface.sv` | AXI4-Stream slave: 72-bit pixel input, 16-bit result output. |

## tb/ — testbench (Checklist §2)
| File | Description |
|---|---|
| `tb/tb_top.sv` | Self-contained testbench driving `top`. Test 1 (unit weights → 450) + Test 2 (signed weights → 150). Produces `final_run.log`. |

## sim/ — simulation outputs (Checklist §2)
| File | Description |
|---|---|
| `sim/final_run.log` | Plain-text simulation log showing PASS (same PASS/FAIL contract as M2/M3). |
| `sim/final_waveform.png` | Annotated end-to-end transaction waveform. Report Figure 4. |

## synth/ — synthesis results (Checklist §3)
| File | Description |
|---|---|
| `synth/config.json` | OpenLane 2 config that produced the final run (CLOCK_PERIOD 12 ns, source list, constraints). |
| `synth/openlane_run.log` | Captured stdout/stderr of the run that produced the reports below. |
| `synth/timing_report.txt` | STA: closes at 12 ns (83.3 MHz); worst setup slack +1.62 ns @ max_ss; zero violations, all 9 corners. → Report §7. |
| `synth/area_report.txt` | 51,147 µm², 4,432 cells; dominant contributor = combinational arithmetic (XNOR/XOR + 453 dfrtp). → Report §7. |
| `synth/power_report.txt` | 21.6 mW @ nom_tt (82.3% combinational); OpenROAD report_power. → Report §7. |

## bench/ — benchmark vs software baseline (Checklist §4)
| File | Description |
|---|---|
| `bench/benchmark.md` | Measured throughput (1.5 GOPS), speedup vs M1 (5.4×), energy comparison; method stated. |
| `bench/benchmark_data.csv` | Raw numbers behind every figure in benchmark.md and the report. |
| `bench/roofline_final.png` | Final roofline: CPU + M3 + M4 hardware rooflines, SW point, and **measured** M4 point (8.47, 1.5 GOPS). → Report Figure 2. |

## report/ — design justification report (Checklist §5)
| File | Description |
|---|---|
| `report/design_justification.pdf` | 9-section report (Problem, Roofline, Precision, Dataflow/Architecture, Interface, Verification, Synthesis, Benchmark, What-did-not-work). ~2,860 words. THE graded report. |
| `report/figures/block_diagram.png` | Figure 1 — high-level system block diagram. |
| `report/figures/roofline_final.png` | Figure 2 — roofline (copy of bench/roofline_final.png). |
| `report/figures/dataflow_diagram.png` | Figure 3 — compute-core dataflow (9-wide MAC + adder tree). |
| `report/figures/waveform_placeholder.png` | Figure 4 — replace with sim/final_waveform.png before submitting. |
