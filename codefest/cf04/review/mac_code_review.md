# MAC Module Code Review

## Task 1 & 2: Generation and Compilation
* **LLM A (`mac_llm_A.v`):** Gemini
  * **Result:** Compiled cleanly with 0 errors. Followed all constraints.
* **LLM B (`mac_llm_B.v`):** ChatGPT
  * **Result:** Failed to compile (Syntax error near '(' due to non-breaking spaces). Even if spaces are cleaned, the code contains non-synthesizable/unsafe constructs.

---

## Task 4: Review of LLM B (ChatGPT)

### Issue 1: Blocking Assignment in Sequential Block
* **Offending Line:** `prod = a * b; // combinational within clocked block`
* **Explanation:** The model used a blocking assignment (`=`) inside an `always_ff` block. `always_ff` is meant strictly for modeling sequential logic (flip-flops), which requires non-blocking assignments (`<=`). Mixing these creates simulation-synthesis mismatches.
* **Correction:** Move the math outside the sequential block using an `assign` statement, or use a non-blocking assignment (`<=`).

### Issue 2: Accumulator Width Mismatch
* **Offending Line:** `out  <= out + prod; // accumulate`
* **Explanation:** The model is adding a 16-bit signed vector (`prod`) to a 32-bit signed vector (`out`) without explicitly casting the 16-bit value to 32 bits first. Relying on implicit sign extension throws strict linting errors and risks the synthesizer padding the bits incorrectly.
* **Correction:** Use explicit casting: `out <= out + 32'(prod);

## Task 3: Simulation Results
The `mac_correct.v` file was simulated using QuestaSim with `mac_tb.v`. 
The output perfectly matches the expected accumulated values:

```text
# --- STARTING TEST ---
# Phase 1: a=3, b=4 | out=12
# Phase 1: a=3, b=4 | out=24
# Phase 1: a=3, b=4 | out=36
# --- RESET APPLIED --- | out=0
# Phase 2: a=-5, b=2 | out=-10
# Phase 2: a=-5, b=2 | out=-20
# --- TEST COMPLETE ---