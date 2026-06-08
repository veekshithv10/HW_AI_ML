# INT8 Conv2D MAC Accelerator — ECE 410/510 (HW4AI), Spring 2026

A custom hardware accelerator for the 2D-convolution (Conv2D) kernel of a CNN, taken from
RTL through full physical synthesis to a signed-off layout on the open-source **sky130A**
process using **OpenLane 2**. The accelerator replaces a memory-bound software Conv2D kernel
with a weight-stationary, INT8, nine-wide parallel MAC array with a three-stage pipeline.

**Headline result:** 1.5 GOPS at 83.3 MHz, fully clean signoff across all nine PVT corners,
**5.4× faster** than the measured NumPy software baseline, in 51,147 µm² at 21.6 mW.

## Milestone 4 submission

- **All M4 deliverables:** [`project/m4/`](project/m4/) — see [`project/m4/README.md`](project/m4/README.md) for a catalog of every file.
- **Design justification report (9 sections, PDF):** [`project/m4/report/design_justification.pdf`](project/m4/report/design_justification.pdf)
- **Benchmark vs software baseline:** [`project/m4/bench/benchmark.md`](project/m4/bench/benchmark.md)

Earlier milestones remain at `project/m1/`, `project/m2/`, `project/m3/`, and `project/heilmeier.md`.
