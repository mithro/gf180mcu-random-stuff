# Makefile for lutu module tests

# Define variables
IVERILOG = iverilog
VVP = vvp
WAVEFORM_VIEWER = gtkwave

# PDK variables
PDK_PATH = /home/tim/.volare/volare/gf180mcu/versions/18dbe6102a36303bb8942b490efb0f33d2815bdb/gf180mcuA
PDK_LIBRARY = $(PDK_PATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog

# Source files
SRC = ../lutu.v ../../store/store_2x2.v
TEST_SRC = lutu_test.v
PDK_CELLS = $(PDK_LIBRARY)/primitives.v $(PDK_LIBRARY)/gf180mcu_fd_sc_mcu7t5v0.v

# Output files
OUTPUT = lutu_test

# Default target
.PHONY: test clean view all

all: test

test: $(OUTPUT)
	$(VVP) $(OUTPUT)

# Compile the testbench
$(OUTPUT): $(TEST_SRC) $(SRC) $(PDK_CELLS)
	$(IVERILOG) -o $(OUTPUT) $(TEST_SRC) $(SRC) $(PDK_CELLS)

# View the waveform
view: $(OUTPUT).vcd
	$(WAVEFORM_VIEWER) $(OUTPUT).vcd &

# Clean up
clean:
	rm -f $(OUTPUT) *.vcd
