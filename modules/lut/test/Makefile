# Makefile for lut module tests

# Default target
all: test-lut2 test-lutu

# Define variables
IVERILOG = iverilog
VVP = vvp
WAVEFORM_VIEWER = gtkwave

# PDK variables
PDK_PATH = /home/tim/.volare/volare/gf180mcu/versions/18dbe6102a36303bb8942b490efb0f33d2815bdb/gf180mcuA
PDK_LIBRARY = $(PDK_PATH)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog

# PDK cell files for both tests
PDK_CELLS = $(PDK_LIBRARY)/primitives.v $(PDK_LIBRARY)/gf180mcu_fd_sc_mcu7t5v0.v

# LUT2 test files
LUT2_SRC = ../lut2.v ../../store/store_2x2.v
LUT2_TEST_SRC = lut2_test.v
LUT2_OUTPUT = lut2_test
LUT2_VCD = lut2_test.vcd

# LUTU test files
LUTU_SRC = ../lutu.v ../../store/store_2x2.v
LUTU_TEST_SRC = lutu_test.v
LUTU_OUTPUT = lutu_test
LUTU_VCD = lutu_test.vcd

# Compile the LUT2 test
$(LUT2_OUTPUT): $(LUT2_SRC) $(LUT2_TEST_SRC) $(PDK_CELLS)
	$(IVERILOG) -DFUNCTIONAL -I$(PDK_LIBRARY) -o $(LUT2_OUTPUT) $(LUT2_TEST_SRC) $(LUT2_SRC) $(PDK_CELLS)

# Compile the LUTU test
$(LUTU_OUTPUT): $(LUTU_SRC) $(LUTU_TEST_SRC) $(PDK_CELLS)
	$(IVERILOG) -DFUNCTIONAL -I$(PDK_LIBRARY) -o $(LUTU_OUTPUT) $(LUTU_TEST_SRC) $(LUTU_SRC) $(PDK_CELLS)

# Run the LUT2 test
test-lut2: $(LUT2_OUTPUT)
	@echo "Running lut2 tests..."
	@$(VVP) $(LUT2_OUTPUT) || (echo "ERROR: lut2 tests failed!" && exit 1)

# Run the LUTU test
test-lutu: $(LUTU_OUTPUT)
	@echo "Running lutu tests..."
	@$(VVP) $(LUTU_OUTPUT) || (echo "ERROR: lutu tests failed!" && exit 1)

# View waveform for LUT2
wave-lut2: $(LUT2_VCD)
	$(WAVEFORM_VIEWER) $(LUT2_VCD) &

# View waveform for LUTU
wave-lutu: $(LUTU_VCD)
	$(WAVEFORM_VIEWER) $(LUTU_VCD) &

# Clean targets
clean:
	rm -f $(LUT2_OUTPUT) $(LUT2_VCD) $(LUTU_OUTPUT) $(LUTU_VCD) *.log

.PHONY: all test-lut2 test-lutu wave-lut2 wave-lutu clean
