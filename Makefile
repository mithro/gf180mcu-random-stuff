.PHONY: setup clean run shell metal-grid dense-via-array

VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
REQ_STAMP := $(VENV)/.requirements.txt.stamp
SHELL := /bin/bash

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

shell: setup
	@echo "Starting shell with activated Python virtual environment..."
	@bash --init-file <(echo '. "$(VENV)/bin/activate"')

run: setup
	$(PYTHON) stdcell_grid.py

metal-grid: setup
	@mkdir -p build/gds
	$(PYTHON) metal_grid_with_vias.py

dense-via-array: setup
	@mkdir -p build/gds
	$(PYTHON) dense_via_array.py
	@echo "Dense via array files generated in build/gds/"

all: run metal-grid dense-via-array