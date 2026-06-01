# CMAN AI Analysis

### 1. Dominant Kernel, Dimensions, and Data Types
* **Dominant Kernel:** 2D Convolution (Multiply-Accumulate / MAC operations).
* **Dimensions:**
  * Input Shape: 16 x 16 pixels, 1 channel.
  * Filter Configuration: 8 filters, 3 x 3 kernel size, stride of 1.
  * Output Shape: 14 x 14 grid, 8 channels.
* **Data Types:** * Inputs/Weights: INT8 (1 byte per parameter).
  * Accumulated Output: INT16 (2 bytes per parameter).

### 2. Total FLOPs Count
The hardware completes one MAC (which equals 2 Operations/FLOPs) per cycle. The formula for the total MACs required for one invocation of this 2D Convolution layer is:

* **Total MACs** = (Output Width * Output Height) * Number of Filters * (Filter Width * Filter Height * Input Channels)
* **Total MACs** = (14 * 14) * 8 * (3 * 3 * 1) = 14,112 MACs
* **Total FLOPs** = 14,112 * 2 = 28,224 FLOPs

### 3 & 4. Arithmetic Intensity (AI) Bounds
*Note: The dominant kernel is a standard dense 2D Convolution, which follows the standard GEMM-style weight and input reuse pattern.*

**Lower Bound (No Data Reuse):**
Assuming no on-chip memory reuse, the hardware must fetch one weight and one input byte for every single MAC operation from off-chip memory.
* **Total Bytes** = Total MACs * (Bytes per Weight + Bytes per Input)
* **Total Bytes** = 14,112 * (1 + 1) = 28,224 bytes
* **Lower Bound AI** = 28,224 FLOPs / 28,224 bytes = **1.0 FLOPs/byte**

**Upper Bound (Perfect Data Reuse):**
Assuming perfect on-chip data reuse, we only count the compulsory data transferred across the interface.
* Input Read: 16 * 16 * 1 channel * 1 byte = 256 bytes
* Weight Read: 3 * 3 * 8 filters * 1 byte = 72 bytes
* Output Write: 14 * 14 * 8 filters * 2 bytes (INT16) = 3,136 bytes
* **Total Compulsory Bytes** = 256 + 72 + 3,136 = 3,464 bytes
* **Upper Bound AI** = 28,224 FLOPs / 3,464 bytes = **8.15 FLOPs/byte**

### 5. Bottleneck Identification and Improvement
* **Current Hardware Limitation:** The design is currently strictly **Compute-Bound** (limited by compute units). The AXI4-Stream `s_axis_tdata` interface is exactly 16 bits (2 bytes) wide. At the physical synthesis frequency of 83.3 MHz, the peak memory bandwidth is 0.166 GB/s. With a peak compute of 0.166 GOPS, the Roofline Ridge Point sits exactly at 1.0 Ops/byte. Because our Lower Bound AI (1.0) sits directly on the ridge point and the Upper Bound AI (8.15) sits to the right, the hardware is bottlenecked by the single 8x8 multiplier, not the AXI bus.
* **Highest-Leverage Change:** The single highest-leverage change to improve performance would be to **instantiate multiple parallel MAC units** (e.g., an unrolled 1D vector of multipliers or a 2D systolic array) within `compute_core.sv`. This would physically raise the flat "Compute Ceiling" of the roofline model, allowing the hardware to perform multiple Multiply-Accumulate operations per clock cycle to take better advantage of the available bandwidth.