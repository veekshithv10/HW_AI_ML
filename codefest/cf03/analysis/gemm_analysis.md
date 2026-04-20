# GEMM Kernel Analysis
# GEMM Kernel Analysis

## (a) Why the naive kernel is memory-bound
The naive kernel is severely memory-bound because it performs completely redundant memory fetches from global DRAM. Theoretically, it must read 2 floats (8 bytes) for every multiply-accumulate (2 FLOPs), resulting in a strictly low theoretical arithmetic intensity of **0.25 FLOP/Byte**. Our Nsight Compute profiling confirmed this memory wall, showing a massive warp stall rate waiting on global memory, yielding only `17.29 GFLOP/s`.

## (b) How tiling reduces DRAM traffic
Tiling mitigates the global memory wall by utilizing the GPU's fast, on-chip shared memory. By loading an `8x8` (T=8) block of matrices into shared memory, the GPU reuses those elements T times. This drops the theoretical DRAM traffic by 8x, successfully raising our theoretical arithmetic intensity from 0.25 to **2.0 FLOP/Byte**. 

## (c) Tiled kernel improvements and remaining bottlenecks
While tiling successfully improved performance to `59.58 GFLOP/s` (a 3.44x speedup), our Roofline plot shows it is still situated in the memory-bound region because 2.0 FLOP/Byte falls far short of the T4's ridge point of 25.3 FLOP/Byte. Furthermore, an 8x8 tile only yields 64 threads per block (just 2 warps), which cannot effectively hide memory latency. SM utilization drops, confirming latency and instruction stalls as the remaining bottlenecks. A much larger tile (e.g., 16x16 or 32x32) is required to increase occupancy and push the kernel into the compute-bound region.