
# Interface Selection Rationale

### 1. Interface & Host Platform
* **Selected Interface:** AXI4-Stream
* **Host Platform Assumed:** FPGA SoC (e.g., Xilinx Zynq UltraScale+). This platform was chosen because it tightly couples a host ARM CPU with programmable logic, allowing direct, high-speed AXI4 streaming.

### 2. Bandwidth Requirement Calculation
Based on our Roofline Model and HW/SW partition analysis:
* **Target Accelerator Throughput:** 500 GFLOP/s
* **Target Arithmetic Intensity:** 5.0 FLOPs/byte (which means a data width requirement of 0.2 Bytes/FLOP)
* **Required Sustained Bandwidth:** `Throughput × Data Width = 500 GFLOP/s × 0.2 Bytes/FLOP = 100 GB/s`

### 3. Interface Comparison & Bottleneck Status
To meet the 100 GB/s requirement using AXI4-Stream on our target FPGA SoC:
* **Operating Point:** 300 MHz clock frequency.
* **Data Width per Channel:** 512-bit (64 bytes).
* **Rated Bandwidth per Channel:** `64 bytes * 300 MHz = 19.2 GB/s`.

**Bottleneck Status:** If we use a single AXI4-Stream channel, our design will be severely **interface-bound** (capped at ~96 GFLOP/s instead of 500 GFLOP/s). 

To resolve this and reach the compute-bound ceiling of our roofline, our design must implement a multi-channel configuration (5 to 6 parallel AXI4-Stream channels) reading from partitioned memory banks (like HBM) to fully saturate the 100 GB/s requirement.