.PHONY: setup clean run

VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
REQ_STAMP := $(VENV)/.requirements.txt.stamp

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

run: setup
	$(PYTHON) stdcell_grid.py