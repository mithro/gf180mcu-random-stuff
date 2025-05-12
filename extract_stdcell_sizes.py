#!/usr/bin/env python3
"""
Extract standard cell sizes from GF180MCU PDK and generate a CSV report.

This script traverses the GF180MCU PDK standard cell libraries, extracts 
cell dimensions from LEF files, and creates a CSV table with cell names
and their physical dimensions in microns.
"""

import os
import re
import csv
import glob
from pathlib import Path

# PDK path
PDK_PATH = os.path.join(os.getcwd(), "gf180mcu-pdk")

# Standard cell libraries to process
STDCELL_LIBS = [
    "gf180mcu_fd_sc_mcu7t5v0",  # 7 track
    "gf180mcu_fd_sc_mcu9t5v0",  # 9 track
]

# Regular expression to extract cell size from LEF files
SIZE_PATTERN = re.compile(r'SIZE\s+(\d+\.\d+)\s+BY\s+(\d+\.\d+)\s*;')

def extract_cell_size(lef_file):
    """Extract cell width and height from a LEF file."""
    try:
        with open(lef_file, 'r') as file:
            content = file.read()
            match = SIZE_PATTERN.search(content)
            if match:
                width = float(match.group(1))
                height = float(match.group(2))
                return width, height
            else:
                print(f"Warning: Could not find size in {lef_file}")
                return None, None
    except Exception as e:
        print(f"Error reading {lef_file}: {e}")
        return None, None

def extract_cell_name_from_path(path):
    """Extract the cell name from the file path."""
    # Extract the basename without extension
    basename = os.path.basename(path)
    return basename.split('.')[0]

def main():
    # List to store cell data
    cell_data = []
    
    # Dictionary to track unique cells (to avoid duplicates)
    unique_cells = {}
    
    print("Extracting standard cell sizes from GF180MCU PDK...")
    
    # Process each standard cell library
    for lib in STDCELL_LIBS:
        lib_path = os.path.join(PDK_PATH, "libraries", lib, "latest", "docs", "cells")
        
        # Skip if library doesn't exist
        if not os.path.exists(lib_path):
            print(f"Library path not found: {lib_path}")
            continue
        
        print(f"Processing library: {lib}")
        
        # Get all cell type directories
        cell_types = [d for d in os.listdir(lib_path) if os.path.isdir(os.path.join(lib_path, d))]
        
        for cell_type in cell_types:
            cell_dir = os.path.join(lib_path, cell_type)
            
            # Find all LEF files in the cell directory
            lef_files = glob.glob(os.path.join(cell_dir, "*.lef"))
            
            for lef_file in lef_files:
                # Extract cell name from file path
                cell_name = extract_cell_name_from_path(lef_file)
                
                # Skip if we've already processed this cell
                if cell_name in unique_cells:
                    continue
                
                # Extract cell size
                width, height = extract_cell_size(lef_file)
                
                if width is not None and height is not None:
                    # Calculate cell area
                    area = width * height
                    
                    # Store cell data
                    cell_info = {
                        'library': lib,
                        'type': cell_type,
                        'name': cell_name,
                        'width_um': width,
                        'height_um': height,
                        'area_um2': area
                    }
                    
                    cell_data.append(cell_info)
                    unique_cells[cell_name] = True
    
    # Sort data by library and cell name
    cell_data.sort(key=lambda x: (x['library'], x['name']))
    
    # Write CSV file
    csv_file = "gf180mcu_stdcell_sizes.csv"
    with open(csv_file, 'w', newline='') as file:
        fieldnames = ['library', 'type', 'name', 'width_um', 'height_um', 'area_um2']
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        
        writer.writeheader()
        for cell in cell_data:
            writer.writerow(cell)
    
    print(f"Successfully extracted {len(cell_data)} cell sizes.")
    print(f"CSV report written to: {csv_file}")

if __name__ == "__main__":
    main()