# MAC Module Code Review

## Task 1 & 2: Generation and Compilation
* **LLM A (`mac_llm_A.v`):** Gemini
  * **Result:** Compiled cleanly but contained a hidden synthesis trap. By doing the multiplication inline via `32'(a * b)`, SystemVerilog contextually evaluates the operands at 32 bits, forcing a massive 32x32 multiplier in hardware. We fixed this in `mac_correct.v` by using a 16-bit intermediate wire to safely capture the 8x8 product before casting.
* **LLM B (`mac_llm_B.v`):** ChatGPT
  * **Result:** Failed to compile due to syntax errors. Contains non-synthesizable constructs and accumulator width warnings.

---

## Task 4: Review of LLM B (ChatGPT)

### Issue 1: Syntax Error in Module Declaration
* **Offending Line:** `module mac (`
* **Explanation:** The model generated invalid hidden web formatting characters immediately preceding the port list. This caused QuestaSim to instantly throw an `unexpected '('` syntax error and halt compilation.
* **Correction:** Manually delete the invalid characters and rewrite the standard `module mac (` declaration cleanly.

### Issue 2: Blocking Assignment in Sequential Block
* **Offending Line:** `prod = a * b; // combinational within clocked block`
* **Explanation:** The model used a blocking assignment (`=`) inside an `always_ff` block. In simulation, `=` executes sequentially (line-by-line), while `<=` (non-blocking) evaluates and updates concurrently at the clock edge, mimicking physical flip-flop behavior. Using `=` in sequential logic causes the simulation to behave like software, leading to a simulation-synthesis mismatch where the actual chip behaves differently than the simulator.
* **Correction:** Move the multiplication outside the sequential block into an `assign` statement, or use a non-blocking assignment (`<=`).

### Issue 3: Accumulator Width Mismatch (Implicit Casting)
* **Offending Line:** `out  <= out + prod; // accumulate`
* **Explanation:** The model adds a 16-bit signed vector (`prod`) directly to a 32-bit signed vector (`out`). While the compiler will implicitly sign-extend this, relying on implicit width resizing triggers strict linting warnings and obscures intent. 
* **Correction:** Use an explicit size cast to clearly match the 32-bit accumulator width: `out <= out + 32'(prod);`

---

## Note on Synthesizable vs. Non-Synthesizable Logic
Our testbench (`mac_tb.v`) heavily utilizes `initial` blocks and `$display` statements to drive stimuli and print outputs. It is important to note that these are strictly simulation-only constructs. Because they cannot be mapped to physical logic gates, putting these commands inside the actual design file (`mac_correct.v`) would cause synthesis errors.

---

## Task 3: Simulation Results
The corrected module (`mac_correct.v`) was simulated using QuestaSim with a standard SystemVerilog testbench (`mac_tb.v`). The output perfectly matches the expected accumulated values:

# --- STARTING TEST ---
# Phase 1: a=3, b=4 | out=12
# Phase 1: a=3, b=4 | out=24
# Phase 1: a=3, b=4 | out=36
# --- RESET APPLIED --- | out=0
# Phase 2: a=-5, b=2 | out=-10
# Phase 2: a=-5, b=2 | out=-20
# --- TEST COMPLETE ---
# Errors: 0, Warnings: 0