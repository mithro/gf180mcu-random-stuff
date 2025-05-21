# Makefile for store4 module tests

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
SRC = ../store4.v
TEST_SRC = store4_test.v
PDK_CELLS = $(PDK_LIBRARY)/primitives.v $(PDK_LIBRARY)/gf180mcu_fd_sc_mcu7t5v0.v

# Output files
OUTPUT = store4_test
VCD = store4_test.vcd

# Compile the test
$(OUTPUT): $(SRC) $(TEST_SRC) $(PDK_CELLS)
	$(IVERILOG) -DFUNCTIONAL -I$(PDK_LIBRARY) -o $(OUTPUT) $(TEST_SRC) $(SRC) $(PDK_CELLS)

# Run the test
test: $(OUTPUT)
	@echo "Running store4 tests..."
	@$(VVP) $(OUTPUT) || (echo "ERROR: store4 tests failed!" && exit 1)
	@echo "store4 tests passed successfully!"
	
# View waveform
view: test
	$(WAVEFORM_VIEWER) $(VCD) &

# Clean up generated files
clean:
	rm -f $(OUTPUT) $(VCD)

.PHONY: all test view clean

# View waveform
wave: $(VCD)
	$(WAVEFORM_VIEWER) $(VCD) &

# Clean
clean:
	rm -f $(OUTPUT) $(VCD)

.PHONY: all test wave clean
