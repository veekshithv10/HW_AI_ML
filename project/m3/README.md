# Milestone 3: Integration and Synthesis

## File Catalog
- `README.md`: Index of M3 submission and reproduction steps.
- `rtl/top.sv`: Top-level integration module connecting the AXI4-Stream interface and Compute Core.
- `tb/tb_top.sv`: End-to-end co-simulation testbench.
- `sim/cosim_run.log`: Console log output from co-simulation.
- `sim/cosim_waveform.png`: Annotated waveform showing AXI transaction and compute activity.
- `synth/config.json`: OpenLane 2 synthesis configuration file.
- `synth/openlane_run.log`: Full stdout/stderr from the OpenLane 2 synthesis run.
- `synth/timing_report.txt`: Post-PNR static timing analysis summary.
- `synth/area_report.txt`: Yosys-generated cell count and chip area report.
- `synth/critical_path.md`: Identification and explanation of the critical path.
- `synth/power_report.txt`: Documentation of power estimation status.
- `synth/synthesis_notes.md`: Detailed synthesis narrative and scope adjustment justification.

## Co-Simulation Reproduction
- **Simulator:** Icarus Verilog (iverilog)
- **Command:**
  iverilog -g2012 -o cosim.vvp ../../m2/rtl/compute_core.sv ../../m2/rtl/interface.sv ../rtl/top.sv ../tb/tb_top.sv
  vvp cosim.vvp | tee cosim_run.log

## Synthesis Reproduction
- **Tool:** OpenLane 2 (Dockerized)
- **Version:** efabless/openlane2:2.3.10
- **Configuration Path:** project/m3/synth/config.json
- **Command:**
  docker run --rm -v $(pwd):/work -w /work/project/m3/synth efabless/openlane2:2.3.10 openlane --flow Classic config.json > openlane_run.log 2>&1
