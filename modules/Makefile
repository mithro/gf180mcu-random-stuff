#####################################################################
# Digital Implementation Flow for ASIC modules
#####################################################################

# Directory for digital implementation files
DIGITAL_DIR := ../build/digital
SYNTH_DIR := $(DIGITAL_DIR)/synth
PNR_DIR := $(DIGITAL_DIR)/pnr
DIGITAL_GDS_DIR := $(DIGITAL_DIR)/gds

# Path to the GF180MCU PDK
PDK_PATH := $(realpath ..)/gf180mcu-pdk

# PDK configuration for OpenLane2
PDK := gf180mcu
PDK_VARIANTS := 3.3V
STD_CELL_LIBRARY := gf180mcu_fd_sc_mcu7t5v0

# Define DRC parameters based on option C
DRC_PARAMS := -rd metal_top=9K -rd mim_option=B -rd metal_level=5LM

# Tools
YOSYS := yosys
OPENROAD := openroad
OPENLANE := openlane
DRC_DIR := ../build/drc

#####################################################################
# pbuf6 module implementation
#####################################################################

# Source files
PBUF_VERILOG_SRC := pbuf/pbuf.v
PBUF_DESIGN_NAME := pbuf6

# Yosys synthesis configuration for pbuf6
PBUF_SYNTH_SCRIPT := $(SYNTH_DIR)/pbuf_synth.tcl

# OpenLane2 configuration for pbuf6
PBUF_OPENLANE_CONFIG := $(SYNTH_DIR)/pbuf_config.json

# Create digital directories
$(DIGITAL_DIR) $(SYNTH_DIR) $(PNR_DIR) $(DIGITAL_GDS_DIR):
	@mkdir -p $@

# Create Yosys synthesis script for pbuf6
$(PBUF_SYNTH_SCRIPT): | $(DIGITAL_DIR)
	@mkdir -p $(dir $@)
	@echo "# Synthesis script for $(PBUF_DESIGN_NAME)" > $@
	@echo "read_verilog $(PBUF_VERILOG_SRC)" >> $@
	@echo "hierarchy -check -top $(PBUF_DESIGN_NAME)" >> $@
	@echo "proc; opt; fsm; opt; memory; opt" >> $@
	@echo "techmap; opt" >> $@
	@echo "dfflibmap -liberty $(PDK_PATH)/libraries/$(STD_CELL_LIBRARY)/latest/liberty/$(STD_CELL_LIBRARY)__tt_025C_3v30.lib" >> $@
	@echo "abc -liberty $(PDK_PATH)/libraries/$(STD_CELL_LIBRARY)/latest/liberty/$(STD_CELL_LIBRARY)__tt_025C_3v30.lib" >> $@
	@echo "clean" >> $@
	@echo "write_verilog -noattr $(SYNTH_DIR)/$(PBUF_DESIGN_NAME)_synth.v" >> $@

# Create OpenLane2 configuration file for pbuf6
$(PBUF_OPENLANE_CONFIG): | $(DIGITAL_DIR)
	@mkdir -p $(dir $@)
	@echo '{' > $@
	@echo '  "DESIGN_NAME": "$(PBUF_DESIGN_NAME)",' >> $@
	@echo '  "VERILOG_FILES": ["$(SYNTH_DIR)/$(PBUF_DESIGN_NAME)_synth.v"],' >> $@
	@echo '  "CLOCK_PORT": "prog_clk0",' >> $@
	@echo '  "CLOCK_PERIOD": 10,' >> $@
	@echo '  "PDK": "$(PDK)",' >> $@
	@echo '  "PDK_VARIANT": "$(PDK_VARIANTS)",' >> $@
	@echo '  "CELL_LIBRARY": "$(STD_CELL_LIBRARY)",' >> $@
	@echo '  "PL_TARGET_DENSITY": 0.6,' >> $@
	@echo '  "FP_CORE_UTIL": 50,' >> $@
	@echo '  "SYNTH_ELABORATE_ONLY": false,' >> $@
	@echo '  "SYNTH_NO_FLAT": true,' >> $@
	@echo '  "DESIGN_IS_CORE": false' >> $@
	@echo '}' >> $@

# Synthesis target for pbuf6
synth-pbuf: $(PBUF_VERILOG_SRC) $(PBUF_SYNTH_SCRIPT) | $(SYNTH_DIR)
	@echo "Synthesizing $(PBUF_DESIGN_NAME) using Yosys..."
	$(YOSYS) -c $(PBUF_SYNTH_SCRIPT)
	@echo "Synthesis completed. Output at $(SYNTH_DIR)/$(PBUF_DESIGN_NAME)_synth.v"

# OpenLane2 implementation target for pbuf6
openlane-pbuf: synth-pbuf $(PBUF_OPENLANE_CONFIG) | $(PNR_DIR) $(DIGITAL_GDS_DIR)
	@echo "Running OpenLane2 flow for $(PBUF_DESIGN_NAME)..."
	$(OPENLANE) --flow=hardening --config=$(PBUF_OPENLANE_CONFIG) --run-dir=$(PNR_DIR)
	@cp $(PNR_DIR)/runs/$(PBUF_DESIGN_NAME)/final/gds/$(PBUF_DESIGN_NAME).gds $(DIGITAL_GDS_DIR)/
	@echo "OpenLane2 flow completed. GDS available at $(DIGITAL_GDS_DIR)/$(PBUF_DESIGN_NAME).gds"

# DRC check for the generated GDS of pbuf6
drc-pbuf: openlane-pbuf | $(DRC_DIR)
	@mkdir -p $(DRC_DIR)/digital
	@echo "Running DRC check on $(PBUF_DESIGN_NAME).gds..."
	klayout -b -r $(PDK_PATH)/libraries/gf180mcu_fd_pr/latest/rules/klayout/drc/gf180mcu.drc \
		-rd input=$(realpath $(DIGITAL_GDS_DIR))/$(PBUF_DESIGN_NAME).gds \
		-rd report=$(realpath $(DRC_DIR))/digital/$(PBUF_DESIGN_NAME)_drc.lyrdb \
		$(DRC_PARAMS)
	@echo "DRC report generated: $(DRC_DIR)/digital/$(PBUF_DESIGN_NAME)_drc.lyrdb"

# View GDS in KLayout for pbuf6
view-pbuf-gds: openlane-pbuf
	klayout $(DIGITAL_GDS_DIR)/$(PBUF_DESIGN_NAME).gds &

# Full digital flow target for pbuf6
pbuf-flow: synth-pbuf openlane-pbuf drc-pbuf
	@echo "Complete digital flow for $(PBUF_DESIGN_NAME) finished successfully."

#####################################################################
# Add additional module implementations below
#####################################################################

# Default target
all: pbuf-flow

.PHONY: all synth-pbuf openlane-pbuf drc-pbuf view-pbuf-gds pbuf-flow