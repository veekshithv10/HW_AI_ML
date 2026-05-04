# Milestone 2: Precision Analysis

## 1. Quantization Choice and Roofline Rationale
For the hardware implementation of the Convolutional Neural Network (CNN) compute core, an 8-bit signed integer (INT8) quantization scheme was selected to replace the 32-bit floating-point (FP32) representation used in the original software baseline. This decision is directly grounded in the Roofline Analysis performed in Milestone 1. As shown in our M1 profiling, the pure Python 2D Convolution (MAC) kernel is severely memory-bound. By quantizing the weights and image pixels from FP32 (4 bytes per parameter) to INT8 (1 byte per parameter), we effectively reduce the byte traffic over the AXI4-Stream interface by a factor of four. This artificially quadruples our arithmetic intensity (FLOPs/byte), pulling our operational point closer to the compute-bound ridge point on the roofline model. Furthermore, floating-point multipliers consume significant logic area, so INT8 minimizes the physical footprint of the pipeline.

## 2. Scale Factor Selection
The software baseline utilizes normalized data arrays, generally falling within the range of -1.0 to 1.0. To map these continuous decimal values onto the discrete hardware logic, a symmetric quantization approach was implemented. A scale factor of 127.0 was applied to translate the floating-point numbers into the 8-bit signed integer range (-127 to 127). Prior to transmission to the hardware interface, software-side scaling multiplies the floating-point value by the scale factor and applies a round-to-nearest operation. Upon completion of the hardware accumulation, the resulting 16-bit MAC output can be dequantized back to a decimal space by dividing by the squared scale factor ($127.0 \times 127.0$).

## 3. Empirical Error Analysis
To validate the precision of the hardware compute core against the pure NumPy baseline, an automated test bench executed 100 randomized simulated 3x3 convolutions. The inputs consisted of uniform random distributions mapping to standard CNN weights and image pixels.
The empirical analysis yielded the following results:
* **Mean Absolute Error (MAE):** 0.004226
* **Max Error:** 0.013897

## 4. Acceptability Statement
The quantization error introduced by the INT8 hardware core is highly acceptable for this CNN application. The Mean Absolute Error indicates an average deviation of less than 0.5% from the ideal FP32 calculation. Deep learning models, particularly Convolutional Neural Networks, are inherently robust to minor noise perturbations in their intermediate feature maps. Because the maximum error observed (1.3%) is exceedingly small, it will not disrupt the relative activation distributions passed to subsequent pooling or non-linear layers (like ReLU or Softmax). Ultimately, the tradeoff is overwhelmingly positive: a negligible decrease in mathematical precision is exchanged for massive gains in computational throughput, energy efficiency, and total hardware area.
