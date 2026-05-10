# CMAN: Sneak Paths in a Resistive Crossbar

**Given Resistances:**
* R[0][0] = 1 kΩ (on)
* R[0][1] = 2 kΩ (off)
* R[1][0] = 2 kΩ (off)
* R[1][1] = 1 kΩ (on)

---

### Task 1: Ideal Read
**Setup:** V_row0 = 1 V, Col 0 = 0 V (virtual ground). Row 1 and Col 1 are explicitly grounded (0 V).
**Calculation:**
Because Row 1 and Col 1 are held at 0 V, any current attempting to leak through R[0][1] goes directly to ground and does not return to Col 0. Therefore, the only current entering Col 0 comes directly through R[0][0].
* I_col0 = (V_row0 - V_col0) / R[0][0]
* I_col0 = (1 V - 0 V) / 1 kΩ 
* **I_col0 = 1 mA**

---

### Task 2: Sneak Path Read
**Setup:** V_row0 = 1 V, Col 0 = 0 V. Row 1 and Col 1 are floating (undriven). 
We must use Kirchhoff's Current Law (KCL) to find the floating voltages V_row1 and V_col1.

**KCL at Node V_col1:**
Sum of currents leaving the node = 0
(V_col1 - V_row0) / R[0][1] + (V_col1 - V_row1) / R[1][1] = 0
(V_col1 - 1) / 2 + (V_col1 - V_row1) / 1 = 0
V_col1 - 1 + 2(V_col1) - 2(V_row1) = 0
3(V_col1) - 2(V_row1) = 1  --> [Equation 1]

**KCL at Node V_row1:**
Sum of currents leaving the node = 0
(V_row1 - V_col1) / R[1][1] + (V_row1 - V_col0) / R[1][0] = 0
(V_row1 - V_col1) / 1 + (V_row1 - 0) / 2 = 0
2(V_row1) - 2(V_col1) + V_row1 = 0
3(V_row1) = 2(V_col1)
V_col1 = 1.5(V_row1)  --> [Equation 2]

**Solving for Floating Voltages:**
Substitute [Equation 2] into [Equation 1]:
3(1.5 * V_row1) - 2(V_row1) = 1
4.5(V_row1) - 2(V_row1) = 1
2.5(V_row1) = 1
* **V_row1 = 0.4 V**

Substitute V_row1 back into Equation 2:
* **V_col1 = 0.6 V**

**Actual I_col0 Calculation:**
The total current entering Col 0 is the sum of the direct current from Row 0 and the sneak path current returning from Row 1.
* I_direct = (V_row0 - V_col0) / R[0][0] = (1 - 0) / 1 = 1.0 mA
* I_sneak = (V_row1 - V_col0) / R[1][0] = (0.4 - 0) / 2 = 0.2 mA
* **Actual I_col0 = 1.0 mA + 0.2 mA = 1.2 mA**

---

### Task 3: Explanation
The sneak path current corrupts the intended MVM result by artificially inflating the output reading (adding a 20% error of 0.2 mA) because extra current from Row 0 leaks through unselected R[0][1], travels "backwards" through R[1][1], and finally leaks into our target Column 0. In large crossbar arrays with thousands of unselected cells, millions of these parallel sneak paths will form and create massive leakage currents that completely overwhelm the actual intended signal. This implies that large resistive crossbars cannot function accurately without explicit isolation mechanisms, such as placing an access transistor (1T1R) or nonlinear selector device at every cell to physically cut off unselected paths.