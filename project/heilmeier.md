
# Heilmeier Catechism: Milestone 1 Update

### Q1: What are you trying to do? 
**Refined Answer:** I am designing a custom hardware accelerator for a Convolutional Neural Network (CNN). Specifically, I am targeting the computationally heavy 2D Convolution (Multiply-Accumulate / MAC) kernel found within the `forward` and `backward` passes of a purely analytical NumPy CNN. The accelerator will connect to the host system using an AXI4-Stream interface.

### Q2: What is done today, and what are the limits of current practice?
**Refined Answer:** Currently, the CNN executes entirely in software on a general-purpose CPU. The primary limit of this approach is that standard processors are highly inefficient at executing massively parallel spatial convolutions without specialized data reuse paths. 

Our explicit profiling data (using `cProfile` over 10 epochs) proves this limitation: the 2D Convolution kernel is the absolute computational bottleneck of the algorithm. The CPU spent the vast majority of its cumulative execution time inside `cnn.py:128(forward)` (1.671s total time) and `cnn.py:154(backward)` (1.061s total time), along with the associated `_im2col` matrix reshaping functions. The CPU is spending too many cycles fetching and reorganizing data rather than performing useful math.

### Q3: What is new in your approach and why do you think it will be successful?
**Refined Answer:** My approach is to offload the 2D Convolution kernel to dedicated hardware utilizing local on-chip BRAM caching. This will be successful because it fundamentally solves the memory bandwidth bottleneck identified in our software baseline. 

Based on my Roofline analysis, the current software implementation has an Arithmetic Intensity (AI) of just 1.058 FLOPs/byte (assuming no cache reuse). This places the software firmly on the slanted "memory wall" of the CPU roofline. By using a custom hardware accelerator with an AXI4-Stream interface and local caching, we can reuse weights and image patches across multiple MAC operations. This architectural change will artificially raise the Arithmetic Intensity to a target of 5.0 FLOPs/byte, successfully pulling the kernel off the memory wall and pushing it up to the flat, compute-bound ceiling of the hardware.