# Software Baseline Benchmark

### 1. Platform and Configuration
* **CPU Model:** Intel(R) Core(TM) i5-8265U CPU @ 1.60GHz
* **OS:** Windows 10/11
* **Python Version:** Python 3.13
* **Batch Size:** 32
* **Epochs:** 10

### 2. Execution Time
* **Measurement Method:** `cProfile` wall-clock time over 10 consecutive training epochs.
* **Total Execution Time (10 epochs):** 10.141 seconds
* **Median Time per Epoch:** ~1.014 seconds

### 3. Throughput
* **Dataset Size:** 2,400 samples per epoch (2,000 train + 400 validation).
* **Calculation:** 24,000 total samples processed / 10.141 seconds total runtime.
* **Throughput:** 2,366 samples/second

### 4. Memory Usage
* **Peak Memory (RSS):** ~65 MB
* *(Note: Measured via standard Windows process memory footprint for a pure NumPy CNN baseline executing on a 16x16 synthetic dataset).*