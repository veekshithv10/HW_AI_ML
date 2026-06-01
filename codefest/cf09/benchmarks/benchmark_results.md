# CLLM Benchmarking Results

### Acceleration Performance Summary
The table below evaluates the computational efficiency and throughput of a single 2D Convolution layer kernel invocation (16x16 input feature map, 3x3 filter size, 8 output channels, 1 input channel). The total work is fixed at 14,112 Multiply-Accumulate (MAC) operations, which translates analytically to 28,224 Floating-Point/Integer Operations.

| Metric | M1 Software Baseline (CPU) | M3 Hardware Accelerator (ASIC) |
| :--- | :--- | :--- |
| **Target Platform** | Laptop Core CPU (Sequential execution) | sky130A PDK Standard Cell Netlist |
| **Operating Frequency** | ~4.0 GHz | 83.3 MHz (12.0 ns clock period) |
| **Precision Strategy** | FP32 (Floating Point) | Quantized INT8 (8-bit Signed Integer) |
| **Execution Latency** | 4.0 ms | 0.169 ms (Projected) |
| **Kernel Throughput** | 0.007 GOPS | 0.166 GOPS (Projected Peak) |
| **Data Interface Width** | 64-bit Cache Line / System Bus | 16-bit AXI4-Stream Interface |
| **Measured Speedup** | **1.0x (Baseline)** | **23.66x** |

### Benchmarking Methodology & Disclaimers
* **Software Baseline Extraction:** The execution latency of 4.0 ms represents the cumulative time (`cumtime`) per call captured sequentially by `cProfile` during a 10-epoch training pass.
* **Hardware Accelerator Extraction:** Latency and throughput figures are designated as **Projected Peak** values. This projection assumes a deterministic execution timeline where a single combinational Multiply-Accumulate unit runs continuously for 14,112 clock cycles at 83.3 MHz without stall penalties.
* **Energy Efficiency:** Energy improvement figures are omitted (N/A) due to signoff constraints in the OpenLane 2 Classic flow reporting setup. Consolidated power data will be parsed using native OpenROAD parasitic database commands during Milestone 4.