# Makefile for pbuf module tests

# Default target
all: test

# Define variables
IVERILOG = iverilog
VVP = vvp
WAVEFORM_VIEWER = gtkwave

# PDK variables
PDK_PATH = $(shell git rev-parse --show-toplevel)/gf180mcu-pdk
PDK_LIBRARY = $(PDK_PATH)/libraries/gf180mcu_fd_sc_mcu7t5v0/latest/cells

# Source files
SRC = ../pbuf.v
TEST_SRC = pbuf_test.v

# PDK standard cell models
PDK_DFFQ = $(PDK_LIBRARY)/dffq/gf180mcu_fd_sc_mcu7t5v0__dffq_1.functional.v
PDK_BUFZ = $(PDK_LIBRARY)/bufz/gf180mcu_fd_sc_mcu7t5v0__bufz_4.functional.v
PDK_CELLS = $(PDK_DFFQ) $(PDK_BUFZ)

# Output files
OUTPUT = pbuf_test
VCD = pbuf_test.vcd

# Compile the test
$(OUTPUT): $(SRC) $(TEST_SRC) $(PDK_CELLS)
	$(IVERILOG) -o $(OUTPUT) $(TEST_SRC) $(SRC) $(PDK_CELLS)

# Run the test
test: $(OUTPUT)
	$(VVP) $(OUTPUT)

# View waveform
wave: $(VCD)
	$(WAVEFORM_VIEWER) $(VCD) &

# Clean up
clean:
	rm -f $(OUTPUT) $(VCD)

.PHONY: all test wave clean