# HW/SW Partition Rationale

**(a) Hardware Acceleration Target**
We will accelerate the 2D Convolution (MAC) kernel-specifically the forward pass, backward pass, and `_im2col` matrix transformations. Our `cProfile` data proved this kernel is the computational bottleneck, dominating total execution time. Furthermore, our Roofline analysis demonstrated that the software implementation has an Arithmetic Intensity (AI) of just 1.058 FLOPs/byte. This places it firmly on the slanted "memory wall" of the CPU roofline, making it an ideal candidate for hardware acceleration where specialized caching can significantly improve data reuse.

**(b) Software Responsibilities**
The software baseline running on the host CPU will continue to handle high-level training loop control, dataset batching, and less computationally dense network operations. This includes activation functions (ReLU), Max Pooling layers, the final Dense (fully connected) layers, and Softmax cross-entropy loss computations. These tasks contain complex branching and sequentially dependent logic that is highly efficient on a general-purpose processor but expensive to synthesize in hardware.

**(c) Interface Bandwidth Requirements
Our hypothetical hardware accelerator targets a peak compute throughput of 500 GFLOP/s. Assuming our hardware design uses on-chip BRAM to cache weights and image tiles—raising the operational Arithmetic Intensity to a target of 5.0 FLOPs/byte—the required interface bandwidth is exactly: 500 GFLOP/s ÷ 5.0 FLOPs/byte = 100 GB/s. Our chosen AXI4-Stream interface on a 300MHz FPGA has a rated bandwidth of 19.2 GB/s per 512-bit channel. Therefore, to avoid becoming interface-bound, we must partition the data across 5 to 6 parallel AXI4-Stream channels. 

**(d) Bound Classification Shift**
Currently, the 2D Conv kernel is severely memory-bound on the CPU, spending the vast majority of its clock cycles waiting for DRAM fetches due to zero data reuse. By offloading this to a custom accelerator featuring local BRAM caching, we structurally raise the AI. We expect this architectural change to successfully shift the kernel from being memory-bound to compute-bound, maximizing silicon utilization.