import matplotlib.pyplot as plt
import numpy as np

# T4 GPU Theoretical Peak Numbers
peak_compute = 8100.0  # FP32 GFLOP/s
peak_bandwidth = 320.0 # GB/s

# Measured Data from your Nsight Compute & Execution Profiling
naive_ai = 17.29 / 23.31
naive_perf = 17.29

tiled_ai = 59.58 / 19.24
tiled_perf = 59.58

# Generate the X-axis for Arithmetic Intensity (log scale)
ai = np.logspace(-2, 3, 500)

# Calculate the Roofline boundaries
memory_roof = peak_bandwidth * ai
compute_roof = np.full_like(ai, peak_compute)
actual_roof = np.minimum(memory_roof, compute_roof)

# Set up the plot
plt.figure(figsize=(10, 6))
plt.loglog(ai, actual_roof, color='black', linewidth=2, label='T4 Hardware Limit')

# Shade the memory-bound vs compute-bound regions
ridge_point = peak_compute / peak_bandwidth
plt.axvline(x=ridge_point, color='gray', linestyle='--', alpha=0.5)
plt.fill_between(ai, 0, actual_roof, where=(ai < ridge_point), color='blue', alpha=0.05, label='Memory Bound Region')
plt.fill_between(ai, 0, actual_roof, where=(ai >= ridge_point), color='red', alpha=0.05, label='Compute Bound Region')

# ---- NEW: PLOT THE ACTUAL RIDGE POINT DOT ----
plt.scatter(ridge_point, peak_compute, color='black', s=100, zorder=5)
plt.annotate(f'Ridge Point\n({ridge_point:.1f} FLOP/B)', (ridge_point, peak_compute), 
             textcoords="offset points", xytext=(10,-20), ha='left', 
             fontsize=10, weight='bold', color='black')

# Plot your specific kernels
plt.scatter(naive_ai, naive_perf, color='red', s=100, zorder=5, label='Naive GEMM')
plt.annotate(f'Naive\n({naive_perf:.1f} GFLOP/s)', (naive_ai, naive_perf), textcoords="offset points", xytext=(-10,15), ha='center', fontsize=10, weight='bold', color='red')

plt.scatter(tiled_ai, tiled_perf, color='green', s=100, zorder=5, label='Tiled GEMM (8x8)')
plt.annotate(f'Tiled\n({tiled_perf:.1f} GFLOP/s)', (tiled_ai, tiled_perf), textcoords="offset points", xytext=(-10,15), ha='center', fontsize=10, weight='bold', color='green')

# Graph aesthetics
plt.title('Roofline Model: Naive vs Tiled Matrix Multiply (NVIDIA T4)', fontsize=14, weight='bold')
plt.xlabel('Arithmetic Intensity (FLOP/Byte)', fontsize=12)
plt.ylabel('Performance (GFLOP/s)', fontsize=12)
plt.grid(True, which="both", ls="--", alpha=0.3)
plt.legend(loc='lower right')
plt.xlim(10**-1, 10**2)
plt.ylim(10**0, 10**4)

# Save the plot in your current folder
save_path = 'gemm_roofline.png'
plt.savefig(save_path, bbox_inches='tight', dpi=300)
plt.show()