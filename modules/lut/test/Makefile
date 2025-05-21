# Makefile for lut2 module tests

# Default target
all: test

# Define variables
IVERILOG = iverilog
VVP = vvp
WAVEFORM_VIEWER = gtkwave

# PDK variables
PDK_PATH = /home/tim/.volare/volare/gf180mcu/versions/18dbe6102a36303bb8942b490efb0f33d2815bdb/gf180mcuA
PDK_LIBRARY = $(PDK_PATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog

# Source files
SRC = ../lut2.v ../../store/store_2x2.v
TEST_SRC = lut2_test.v
PDK_CELLS = $(PDK_LIBRARY)/primitives.v $(PDK_LIBRARY)/gf180mcu_fd_sc_mcu7t5v0.v

# Output files
OUTPUT = lut2_test
VCD = lut2_test.vcd

# Compile the test
$(OUTPUT): $(SRC) $(TEST_SRC) $(PDK_CELLS)
	$(IVERILOG) -DFUNCTIONAL -I$(PDK_LIBRARY) -o $(OUTPUT) $(TEST_SRC) $(SRC) $(PDK_CELLS)

# Run the test
test: $(OUTPUT)
	@echo "Running lut2 tests..."
	@$(VVP) $(OUTPUT) || (echo "ERROR: lut2 tests failed!" && exit 1)

# View waveform (if test generated a VCD file)
wave: $(VCD)
	$(WAVEFORM_VIEWER) $(VCD) &

# Clean targets
clean:
	rm -f $(OUTPUT) $(VCD) *.log

.PHONY: all test wave clean
