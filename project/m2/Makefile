# Default parameters
DATA_WIDTH ?= 8
ACC_WIDTH ?= 16

# Source files
RTL_SRC = rtl/compute_core.sv
TB_SRC = tb/tb_compute_core.sv

# Output executable
SIM_EXEC = sim/compute_core.vvp

# The default target
all: sim

# Compile and simulate
sim:
	mkdir -p sim
	iverilog -g2012 -Wall -pDATA_WIDTH=$(DATA_WIDTH) -pACC_WIDTH=$(ACC_WIDTH) -o $(SIM_EXEC) $(RTL_SRC) $(TB_SRC)
	vvp $(SIM_EXEC) > sim/compute_core_run.log
	cat sim/compute_core_run.log

# Clean up build files
clean:
	rm -rf sim/
	rm -f compute_core_waves.vcd

# Target for Interface simulation
sim_interface:
	mkdir -p sim
	iverilog -g2012 -Wall -o sim/interface.vvp rtl/interface.sv tb/tb_interface.sv
	vvp sim/interface.vvp > sim/interface_run.log
	cat sim/interface_run.log
