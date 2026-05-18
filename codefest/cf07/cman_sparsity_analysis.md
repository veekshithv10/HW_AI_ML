# CMAN — Sparsity Breakeven Analysis

**Given Parameters:**
* Matrix size $N = 512$
* Sparsity $s$ = fraction of zeros
* Fraction of non-zeros = $(1 - s)$
* Total elements = $N^2$
* Number of non-zero elements (NNZ) = $(1 - s)N^2$

---

### 1. Expressions for Compute and Memory

**(a) Dense MVM compute (FLOPs):**
Each of the $N^2$ elements requires 1 Multiply and 1 Accumulate (2 FLOPs per MAC).
* **Dense FLOPs** = $2N^2$

**(b) Dense memory bytes:**
$N^2$ elements at 4 bytes each (FP32).
* **Dense Memory** = $4N^2$ bytes

**(c) Sparse compute (FLOPs as a function of $s$):**
Compute is only performed on the non-zero elements.
* **Sparse FLOPs** = $2(1 - s)N^2$

**(d) Sparse memory bytes (as a function of $s$):**
CSR format requires storage for three arrays:
* Values array (FP32): $4 \times (1 - s)N^2$ bytes
* Column index array (INT32): $4 \times (1 - s)N^2$ bytes
* Row pointer array (INT32): $4 \times (N + 1)$ bytes
* **Sparse Memory** = $8(1 - s)N^2 + 4(N + 1)$ bytes

---

### 2. Theoretical Compute Speedup

**Theoretical speedup of sparse vs. dense MVM (FLOPs ratio):**
$$Speedup_{FLOPs} = \frac{\text{Dense FLOPs}}{\text{Sparse FLOPs}} = \frac{2N^2}{2(1 - s)N^2} = \frac{1}{1 - s}$$

**Sparsity $s$ for a $2\times$ speedup:**
$$2 = \frac{1}{1 - s}$$
$$1 - s = 0.5$$
$$s = 0.5$$  
*(A 50% sparsity is required for a 2x compute speedup).*

---

### 3. Memory Breakeven Sparsity

To find the sparsity level $s$ where Sparse Memory Bytes = Dense Memory Bytes, we set the two expressions equal to each other:
$$8(1 - s)N^2 + 4(N + 1) = 4N^2$$

**Derivation:**
1. Divide the entire equation by 4:
   $$2(1 - s)N^2 + (N + 1) = N^2$$
2. Expand the terms:
   $$2N^2 - 2sN^2 + N + 1 = N^2$$
3. Isolate $s$:
   $$2N^2 - N^2 + N + 1 = 2sN^2$$
   $$N^2 + N + 1 = 2sN^2$$
   $$s = \frac{N^2 + N + 1}{2N^2}$$
4. Simplify the fraction:
   $$s = 0.5 + \frac{1}{2N} + \frac{1}{2N^2}$$

**For $N = 512$:**
$$s = 0.5 + \frac{1}{1024} + \frac{1}{524288} \approx 0.500978$$
*(The matrix must be strictly greater than ~50.10% sparse for the CSR format to use less memory than the dense format).*

---

### 4. End-to-End Speedup (Memory-Bound System at $s = 0.9$)

For a strictly memory-bandwidth-limited system, the execution time is directly proportional to the amount of memory transferred. Therefore, the speedup is the ratio of dense memory bytes to sparse memory bytes.

**Dense Memory Transfer ($N=512$):**
$$4(512)^2 = 1,048,576 \text{ bytes}$$

**Sparse Memory Transfer ($N=512, s=0.9$):**
$$8(1 - 0.9)(512)^2 + 4(512 + 1)$$
$$= 8(0.1)(262,144) + 4(513)$$
$$= 209,715.2 + 2052$$
$$= 211,767.2 \text{ bytes}$$

**End-to-End Speedup:**
$$Speedup_{Time} = \frac{\text{Dense Memory Bytes}}{\text{Sparse Memory Bytes}} = \frac{1,048,576}{211,767.2} \approx 4.95\times$$

*(In a memory-bound system, jumping to 90% sparsity yields approximately a 4.95x end-to-end execution speedup).*