# Arithmetic Intensity Calculation for Dominant Kernel

The dominant kernel is the Conv2D forward and backward pass (MAC operations), accounting for 26.9% of the total runtime.

**Parameters (Synthetic Data Baseline):**
* Batch size (N): 32
* Input channels (Cin): 1
* Kernel size (k): 3x3
* Output channels (Cout): 8
* Spatial dimensions (Hout, Wout): 16, 16

### 1. FLOPs Calculation
* **Formula:** `FLOPs = 2 * N * Cin * k^2 * Hout * Wout * Cout`
* **Calculation:** `2 * 32 * 1 * 9 * 256 * 8`
* **Total:** 1,179,648 FLOPs

### 2. Bytes Transferred (Assuming FP64 / 8 bytes per element)
Using the exact footprint of the `im2col` matrix transformation:
* **Load Input Patch Matrix:** `N * Cin * k^2 * Hout * Wout = 32 * 1 * 9 * 256 = 73,728 elements`
* **Load Weights:** `Cout * Cin * k^2 = 8 * 1 * 9 = 72 elements`
* **Store Output:** `N * Cout * Hout * Wout = 32 * 8 * 256 = 65,536 elements`
* **Total Elements:** `73,728 + 72 + 65,536 = 139,336 elements`

**Total Bytes:** `139,336 elements * 8 bytes = 1,114,688 Bytes`

### 3. Arithmetic Intensity (AI)
* **Formula:** `AI = Total FLOPs / Total Bytes`
* **Calculation:** `1,179,648 / 1,114,688`
* **Result:** 1.058 FLOP/byte