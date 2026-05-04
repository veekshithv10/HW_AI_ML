# Milestone 2: Compute Core and Interface RTL

## Overview
This milestone contains the synthesizable SystemVerilog implementation of an INT8 Multiply-Accumulate (MAC) compute core for a Convolutional Neural Network (CNN), wrapped in an AXI4-Stream interface.

## 1. Prerequisites and Dependencies
To simulate this hardware from a clean clone, you need the following tools installed (instructions are for Ubuntu/WSL):
* **Simulator:** Icarus Verilog (`iverilog` version 11.0 or newer).
* **Build Tool:** `make`
* **Waveform Viewer (Optional):** GTKWave
* **Python (For Precision Analysis):** Python 3 and NumPy

**Installation Command (Ubuntu/WSL):**
`sudo apt update && sudo apt install iverilog make gtkwave python3-numpy -y`

## 2. Running the Testbenches
All simulations are automated using the provided `Makefile`. The simulator uses the SystemVerilog 2012 standard (`-g2012` flag).

### Compute Core Testbench
To run the representative 3x3 convolution vector through the standalone compute core and verify the math:
1. Navigate to the `project/m2` directory.
2. Run the command:
   `make`
3. **Expected Output:** The console will print `PASS: Hardware output (90) matches expected (90)` and the detailed log will be saved to `sim/compute_core_run.log`. It will also generate a waveform file (`compute_core_waves.vcd`).

### Interface Testbench
To run the AXI4-Stream TVALID/TREADY handshake simulation:
1. Navigate to the `project/m2` directory.
2. Run the command:
   `make sim_interface`
3. **Expected Output:** The console will print `PASS: Interface correctly unpacked AXI data` and save the log to `sim/interface_run.log`.

## 3. Deviations from M1 Plan
There are no major deviations from the Milestone 1 plan. 
* **Precision:** The design successfully implements the planned INT8 (8-bit signed integer) quantization schema.
* **Interface:** The design strictly adheres to the selected AXI4-Stream protocol. 
* *Note on file naming:* To satisfy the rubric's file naming requirement (`interface.sv`) while avoiding conflicts with SystemVerilog's reserved `interface` keyword, the module itself is named `axis_interface` internally.
