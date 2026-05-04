# Overflow Behavior Report

**Test Case:** `test_mac_overflow`
**Observation:** The accumulator was allowed to reach the signed 32-bit maximum (2,147,483,647). 
**Result:** Upon the next clock cycle, the value became -2,146,600,625.
**Conclusion:** The design **wraps** around using standard two's-complement arithmetic. It does not saturate at the maximum value.

