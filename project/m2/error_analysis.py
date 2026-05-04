import numpy as np

# Set seed for reproducible results
np.random.seed(42)

NUM_SAMPLES = 100
KERNEL_SIZE = 9  # 3x3 convolution window

mae_total = 0.0
max_error = 0.0

print(f"Running Precision Analysis over {NUM_SAMPLES} samples...\n")

for i in range(NUM_SAMPLES):
    # 1. Generate fake image pixels and weights (values between -1.0 and 1.0)
    pixels_fp = np.random.uniform(-1.0, 1.0, KERNEL_SIZE)
    weights_fp = np.random.uniform(-1.0, 1.0, KERNEL_SIZE)

    # 2. SOFTWARE MATH (FP32)
    # This is what your pure NumPy baseline does
    fp32_result = np.sum(pixels_fp * weights_fp)

    # 3. HARDWARE MATH (INT8)
    # We map -1.0 -> 1.0 onto the integer range -127 -> 127
    scale = 127.0
    pixels_int8 = np.round(pixels_fp * scale).astype(np.int32)
    weights_int8 = np.round(weights_fp * scale).astype(np.int32)
    
    # Hardware multiplies and accumulates integers
    hw_accum = np.sum(pixels_int8 * weights_int8)
    
    # We "dequantize" the result back to decimals to compare it
    hw_result_float = hw_accum / (scale * scale)

    # 4. Compare the two results
    error = abs(fp32_result - hw_result_float)
    mae_total += error
    
    if error > max_error:
        max_error = error

# Calculate final metrics
mae = mae_total / NUM_SAMPLES
print(f"Mean Absolute Error (MAE): {mae:.6f}")
print(f"Max Error:                 {max_error:.6f}")
