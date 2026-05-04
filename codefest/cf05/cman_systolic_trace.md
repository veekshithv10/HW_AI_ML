# CMAN: Systolic Array Trace (Weight-Stationary)

## (a) 2x2 Processing Element (PE) Diagram

In this weight-stationary dataflow, weights from Matrix B are pre-loaded into the processing elements and stay fixed. Matrix A inputs stream in from the left, and partial sums accumulate downward.

**Pre-loaded Weights from Matrix B:**
* PE[0][0] = 5
* PE[0][1] = 6
* PE[1][0] = 7
* PE[1][1] = 8

**Array Diagram:**
```text
          [Input A columns]
              |       |
              v       v
      +-----------+-----------+
In0 ->|  PE[0][0] |  PE[0][1] | -> (Data shifts right)
      |   (W=5)   |   (W=6)   |
      +-----------+-----------+
              | psum      | psum
              v           v
      +-----------+-----------+
In1 ->|  PE[1][0] |  PE[1][1] | -> (Data shifts right)
      |   (W=7)   |   (W=8)   |
      +-----------+-----------+
              | psum      | psum
              v           v
           C[0][0]     C[0][1]
           C[1][0]     C[1][1]
   (Outputs emerge at different cycles:
    C[0][0] at cycle 2, C[1][0] at cycle 3, etc.)

## (b) Cycle-by-Cycle Trace Table

Matrix Multiplication: $C = A \times B$
* **A** = `[[1, 2], [3, 4]]`
* **B** = `[[5, 6], [7, 8]]`

**Input Skew:** Row 0 receives column 0 of A (1, then 3). Row 1 receives column 1 of A (2, then 4) delayed by 1 cycle. To model the pipeline registers between processing elements, input data propagates horizontally, shifting from `PE[i][0]` to `PE[i][1]` with a one-cycle delay.

| Cycle | Input Row 0 | Input Row 1 | PE[0][0] psum | PE[0][1] psum | PE[1][0] psum | PE[1][1] psum | Output C values |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | 1 | 0 | 5 | 0 | 0 | 0 | None |
| **2** | 3 | 2 | 15 | 6 | 19 | 0 | C[0][0] = 19 |
| **3** | 0 | 4 | 0 | 18 | 43 | 22 | C[1][0] = 43, C[0][1] = 22 |
| **4** | 0 | 0 | 0 | 0 | 0 | 50 | C[1][1] = 50 |

> **Note:** Final Matrix C = `[[19, 22], [43, 50]]`, which perfectly matches the expected mathematical result.

---

## (c) Metrics and Counts

* **Total MAC operations:** 8 
    *(The calculation of a 2x2 output matrix requires 4 dot products, and each dot product requires 2 multiplication-additions).*
* **Number of times each input value is reused:** 2 
    *(Each input data from Matrix A is used once in the first PE of a row and then passed right via pipeline registers to be reused in the second PE).*
* **Off-chip memory accesses:**
    * **Matrix A Reads:** 4
    * **Matrix B Reads:** 4 *(Pre-loading weights)*
    * **Matrix C Writes:** 4
    * **Total Accesses:** 12

---

## (d) Output-Stationary Alternative

If this were an **output-stationary** dataflow, the elements of the output Matrix C (the partial sums) would stay fixed inside the PEs until the calculation is complete, while the values of Matrix A and Matrix B would stream through the array.
