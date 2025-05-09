.PHONY: setup clean run shell metal-grid dense-via-array drc drc-metal-grid drc-dense-via-array

VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
REQ_STAMP := $(VENV)/.requirements.txt.stamp
SHELL := /bin/bash
KLAYOUT := klayout

# Directory where GDS files are stored
GDS_DIR := build/gds
# Directory for DRC reports
DRC_DIR := build/drc

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

# Run DRC checks on metal grid GDS files
drc-metal-grid: metal-grid $(DRC_DIR)
	@echo "Running DRC checks on metal grid GDS files..."
	$(KLAYOUT) -r $(VENV)/lib/python*/site-packages/gf180/klayout/drc/main.drc -rd input=$(GDS_DIR)/metal_grid_with_vias.gds -rd report=$(DRC_DIR)/metal_grid_with_vias_drc.txt
	$(KLAYOUT) -r $(VENV)/lib/python*/site-packages/gf180/klayout/drc/main.drc -rd input=$(GDS_DIR)/metal_grid_dense.gds -rd report=$(DRC_DIR)/metal_grid_dense_drc.txt
	$(KLAYOUT) -r $(VENV)/lib/python*/site-packages/gf180/klayout/drc/main.drc -rd input=$(GDS_DIR)/metal_grid_wide.gds -rd report=$(DRC_DIR)/metal_grid_wide_drc.txt
	@echo "DRC reports generated in $(DRC_DIR)/"

# Run DRC checks on dense via array GDS files
drc-dense-via-array: dense-via-array $(DRC_DIR)
	@echo "Running DRC checks on dense via array GDS files..."
	$(KLAYOUT) -r $(VENV)/lib/python*/site-packages/gf180/klayout/drc/main.drc -rd input=$(GDS_DIR)/dense_via_array_simple.gds -rd report=$(DRC_DIR)/dense_via_array_simple_drc.txt
	$(KLAYOUT) -r $(VENV)/lib/python*/site-packages/gf180/klayout/drc/main.drc -rd input=$(GDS_DIR)/dense_via_array_stripes.gds -rd report=$(DRC_DIR)/dense_via_array_stripes_drc.txt
	$(KLAYOUT) -r $(VENV)/lib/python*/site-packages/gf180/klayout/drc/main.drc -rd input=$(GDS_DIR)/dense_via_array_optimized.gds -rd report=$(DRC_DIR)/dense_via_array_optimized_drc.txt
	@echo "DRC reports generated in $(DRC_DIR)/"

# Run DRC checks on all GDS files
drc: drc-metal-grid drc-dense-via-array
	@echo "All DRC checks completed."

all: run metal-grid dense-via-array