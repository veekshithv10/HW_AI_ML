%%writefile nn_forward_gpu.py
import torch
import torch.nn as nn
import sys

# Task 1: Detect CUDA GPU
if torch.cuda.is_available():
    device = torch.device("cuda")
    print(f"✅ GPU found: {torch.cuda.get_device_name(0)}")
else:
    print("❌ No GPU found. Exiting script.")
    sys.exit()

# Task 2: Define the network (4 inputs -> 5 hidden (ReLU) -> 1 output)
model = nn.Sequential(
    nn.Linear(4, 5),
    nn.ReLU(),
    nn.Linear(5, 1)
)
# Move the model to the GPU
model.to(device)

# Task 3: Generate random input tensor of shape [16, 4] and move to GPU
print("Generating input batch of shape [16, 4]...")
input_tensor = torch.randn(16, 4).to(device)

# Run the forward pass
print("Running forward pass on GPU...")
output = model(input_tensor)

# Verify and print the output shape and device
print(f"Output tensor shape: {list(output.shape)}")
print(f"Output is on device: {output.device}")