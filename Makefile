.PHONY: setup clean run

VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

setup: $(VENV)/bin/activate

$(VENV)/bin/activate:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

clean:
	rm -rf $(VENV)
	rm -f *.gds

run: setup
	$(PYTHON) stdcell_grid.py