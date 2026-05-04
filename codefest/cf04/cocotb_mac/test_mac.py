import cocotb 
from cocotb.clock import Clock 
from cocotb.triggers import RisingEdge, Timer 

@cocotb.test() 
async def test_mac_basic(dut): 
    # Start clock with 10ns period
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start()) 
    
    # 1. Reset Phase (Hold for 2 cycles to be safe)
    dut.rst.value = 1 
    await RisingEdge(dut.clk) 
    await RisingEdge(dut.clk) 
    dut.rst.value = 0 
    
    # 2. Input Phase: Set a=3, b=4 (Product is 12)
    dut.a.value = 3 
    dut.b.value = 4 
    
    # 3. Wait for the hardware to process the data
    # We wait 1 cycle for the multiplication to sample and 1 for the register to update
    await RisingEdge(dut.clk) 
    await RisingEdge(dut.clk) 

    # 4. Check outputs cycle-by-cycle
    expected_values = [12, 24, 36]
    for expected in expected_values: 
        current_val = dut.out.value.to_signed()
        dut._log.info(f"Checking Output: Expected {expected}, Got {current_val}")
        assert current_val == expected 
        await RisingEdge(dut.clk) # Move to next accumulation
        
    # 5. Check Reset functionality
    dut.rst.value = 1 
    await RisingEdge(dut.clk) 
    await Timer(1, unit="ns") # Tiny delay to let logic settle
    assert dut.out.value.to_signed() == 0 
    dut._log.info("Reset successful!")

@cocotb.test()
async def test_mac_overflow(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Max inputs (127 * 127 = 16,129 per cycle)
    dut.a.value = 127
    dut.b.value = 127
    
    # Fast-forward enough cycles to definitely cross 2,147,483,647
    # 133,200 cycles is the magic number for a 32-bit wrap
    dut._log.info("Running ~133,200 cycles to induce overflow...")
    for _ in range(133200):
        await RisingEdge(dut.clk)
        
    val_after = dut.out.value.to_signed()
    dut._log.info(f"Value after wrap: {val_after}")
    
    # In a signed 32-bit system, once you pass 2 billion, it MUST become negative
    assert val_after < 0, f"Design did not wrap to negative! Got {val_after}"
    dut._log.info("Overflow/Wrap-around test PASSED!")