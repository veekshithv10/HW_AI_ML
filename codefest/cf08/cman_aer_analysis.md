# CMAN - AER Bandwidth Analysis

## 1. Mean Aggregate Spike Rate (R)
* **Formula:** R = N * f
* **Values:** N = 1024 neurons, f = 50 Hz
* **Calculation:** R = 1024 * 50
* **Answer:** **R = 51,200 spikes/second** (or Hz)

## 2. Mean AER Bandwidth (B)
* **Formula:** B = R * 20 bits/packet
* **Calculation:** B = 51,200 * 20 = 1,024,000 bits/second
* **Answer:** **B = 1.024 Mbit/s**

## 3. Interface Comparison Table

| Interface | Max Bandwidth | Can Sustain Mean Rate? |
| :--- | :--- | :--- |
| **SPI** | <= 50 Mbit/s | **Yes** |
| **I2C** | <= 3.4 Mbit/s | **Yes** |
| **AXI4-Lite** | 100 Mbit/s | **Yes** |

* **Chosen Interface:** **I2C** is the lowest-complexity interface that suffices to sustain the 1.024 Mbit/s mean rate.

## 4. Burst Analysis
* **Burst Event:** 25% of 1024 neurons = 256 neurons firing in a 1 ms (0.001 s) window.
* **Data in Window:** 256 packets * 20 bits/packet = 5,120 bits.
* **Peak Bandwidth:** 5,120 bits / 0.001 s = 5,120,000 bps = **5.12 Mbit/s**
* **Burst-to-Mean Ratio:** 5.12 Mbit/s / 1.024 Mbit/s = **5** (or 5:1)
* **Buffering Decision:** The chosen I2C interface (max 3.4 Mbit/s) cannot absorb the 5.12 Mbit/s peak burst, so **buffering is required** (a depth of at least 86 packets/1,720 bits to survive the 1 ms window).

## 5. Frame-Based Comparison
* **Frame-based Bandwidth:** 1024 neurons * 1 bit/neuron = 1024 bits/frame. At 1000 frames/sec (1 ms samples), bandwidth = 1024 * 1000 = 1,024,000 bps = **1.024 Mbit/s**.
* **AER/Frame Ratio:** At f = 50 Hz, the ratio is 1.024 Mbit/s / 1.024 Mbit/s = **1**.
* **Crossover Firing Rate (f_crossover):** * Set AER Bandwidth = Frame Bandwidth
  * N * f * 20 = N * 1000
  * f * 20 = 1000
  * **f_crossover = 50 Hz**
* **Implication:** AER is the right choice when the neural activity is sparse, specifically when the average firing rate stays below 50 Hz.
