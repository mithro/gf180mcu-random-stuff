.PHONY: setup clean run shell metal-grid dense-via-array drc drc-metal-grid drc-dense-via-array all

VENV := $(realpath .venv)
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
REQ_STAMP := $(VENV)/.requirements.txt.stamp
SHELL := /bin/bash

# Directory where GDS files are stored
GDS_DIR := build/gds
# Directory for DRC reports
DRC_DIR := build/drc
# Path to the GF180MCU PDK
PDK_PATH := $(PWD)/gf180mcu-pdk
# Path to the DRC script
DRC_SCRIPT := $(PDK_PATH)/libraries/gf180mcu_fd_pr/latest/rules/klayout/drc/run_drc_parallel.py
# DRC metal stack option (A, B, or C)
# A: metal_top=30K, mim_option=A, metal_level=3LM
# B: metal_top=11K, mim_option=B, metal_level=4LM
# C: metal_top=9K, mim_option=B, metal_level=5LM
GF180MCU_OPTION := C

# Define DRC parameters based on option C
DRC_PARAMS := -rd metal_top=9K -rd mim_option=B -rd metal_level=5LM

setup: $(REQ_STAMP)

$(VENV)/bin/activate:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip

$(REQ_STAMP): requirements.txt | $(VENV)/bin/activate
	$(PIP) install -r requirements.txt
		touch $(REQ_STAMP)

clean:
	rm -rf $(VENV)
	rm -f *.gds
	rm -rf build/gds
	rm -rf build/drc

shell: setup
	@echo "Starting shell with activated Python virtual environment..."
	@bash --init-file <(echo '. "$(VENV)/bin/activate"')

run: setup
	$(PYTHON) stdcell_grid.py

metal-grid: setup
	@mkdir -p $(GDS_DIR)
	$(PYTHON) metal_grid_with_vias.py

dense-via-array: setup
	@mkdir -p $(GDS_DIR)
	$(PYTHON) dense_via_array.py
	@echo "Dense via array files generated in $(GDS_DIR)/"

# Create DRC directory 
$(DRC_DIR):
	@mkdir -p $(DRC_DIR)

# Pattern rule for DRC checking of any GDS file
# Usage: make drc-file FILE=path/to/your_design.gds
$(DRC_DIR)/%.lyrdb: $(GDS_DIR)/%.gds | $(DRC_DIR)
	@echo "Running DRC check on $<..."
	@mkdir -p $(dir $@)
	klayout -b -r $(PDK_PATH)/libraries/gf180mcu_fd_pr/latest/rules/klayout/drc/gf180mcu.drc \
		-rd input=$(PWD)/$< \
		-rd report=$(PWD)/$@ \
		$(DRC_PARAMS)
	@echo "DRC report generated: $@"

# Run DRC on a specific file
drc-file: $(DRC_DIR)/$(basename $(notdir $(FILE))).lyrdb

# Run DRC on all metal grid files
drc-metal-grid: metal-grid | $(DRC_DIR)
	@mkdir -p $(DRC_DIR)/metal_grid
	@echo "Running DRC checks on metal grid GDS files..."
	@$(MAKE) $(DRC_DIR)/metal_grid/metal_grid_with_vias_drc.lyrdb FILE=$(GDS_DIR)/metal_grid_with_vias.gds
	@$(MAKE) $(DRC_DIR)/metal_grid/metal_grid_dense_drc.lyrdb FILE=$(GDS_DIR)/metal_grid_dense.gds
	@$(MAKE) $(DRC_DIR)/metal_grid/metal_grid_wide_drc.lyrdb FILE=$(GDS_DIR)/metal_grid_wide.gds
	@echo "DRC reports generated in $(DRC_DIR)/metal_grid/"

# Run DRC on all dense via array files
drc-dense-via-array: dense-via-array | $(DRC_DIR)
	@mkdir -p $(DRC_DIR)/via_array
	@echo "Running DRC checks on dense via array GDS files..."
	@$(MAKE) $(DRC_DIR)/via_array/dense_via_array_simple_drc.lyrdb FILE=$(GDS_DIR)/dense_via_array_simple.gds
	@$(MAKE) $(DRC_DIR)/via_array/dense_via_array_stripes_drc.lyrdb FILE=$(GDS_DIR)/dense_via_array_stripes.gds
	@$(MAKE) $(DRC_DIR)/via_array/dense_via_array_optimized_drc.lyrdb FILE=$(GDS_DIR)/dense_via_array_optimized.gds
	@echo "DRC reports generated in $(DRC_DIR)/via_array/"

# Run DRC checks on all GDS files
drc: drc-metal-grid drc-dense-via-array
	@echo "All DRC checks completed."

# Automatic DRC rule for any GDS file in build/gds (alternative approach)
# This will automatically create output directories based on file patterns
METAL_GRID_FILES := $(wildcard $(GDS_DIR)/metal_grid_*.gds)
VIA_ARRAY_FILES := $(wildcard $(GDS_DIR)/dense_via_array_*.gds)
METAL_GRID_DRC := $(patsubst $(GDS_DIR)/%.gds,$(DRC_DIR)/metal_grid/%_drc.lyrdb,$(notdir $(METAL_GRID_FILES)))
VIA_ARRAY_DRC := $(patsubst $(GDS_DIR)/%.gds,$(DRC_DIR)/via_array/%_drc.lyrdb,$(notdir $(VIA_ARRAY_FILES)))

# Auto-DRC for any GDS file (just run "make auto-drc")
auto-drc: $(METAL_GRID_DRC) $(VIA_ARRAY_DRC)
	@echo "Automatic DRC checks completed for all GDS files."

# Pattern rules for different file types
$(DRC_DIR)/metal_grid/%_drc.lyrdb: $(GDS_DIR)/%.gds | $(DRC_DIR)
	@mkdir -p $(dir $@)
	@echo "Running DRC check on $<..."
	klayout -b -r $(PDK_PATH)/libraries/gf180mcu_fd_pr/latest/rules/klayout/drc/gf180mcu.drc \
		-rd input=$(PWD)/$< \
		-rd report=$(PWD)/$@ \
		$(DRC_PARAMS)
	@echo "DRC report generated: $@"

$(DRC_DIR)/via_array/%_drc.lyrdb: $(GDS_DIR)/%.gds | $(DRC_DIR)
	@mkdir -p $(dir $@)
	@echo "Running DRC check on $<..."
	klayout -b -r $(PDK_PATH)/libraries/gf180mcu_fd_pr/latest/rules/klayout/drc/gf180mcu.drc \
		-rd input=$(PWD)/$< \
		-rd report=$(PWD)/$@ \
		$(DRC_PARAMS)
	@echo "DRC report generated: $@"

all: run metal-grid dense-via-array