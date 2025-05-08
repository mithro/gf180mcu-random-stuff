import gdsfactory as gf
import numpy as np
from gdsfactory.component import Component
from pathlib import Path
import os
import sys
from typing import List, Optional

def find_gds_files(pdk_path: Path) -> List[Path]:
    """Find standard cell GDS files in the PDK."""
    # Standard cell GDS files are in the cells subdirectories
    search_path = pdk_path / "libraries" / "gf180mcu_fd_sc_mcu9t5v0" / "latest" / "cells"
    
    gds_files = []
    if search_path.exists():
        # Search in each cell type directory
        for cell_dir in search_path.iterdir():
            if cell_dir.is_dir():
                gds_files.extend(cell_dir.glob("*.gds"))
    
    return gds_files

def create_stdcell_grid() -> Component:
    """Creates a grid layout of all standard cells from GF180MCU PDK."""
    # Create main component to hold the grid
    c = gf.Component("stdcell_grid")
    
    # Use the specified PDK path
    pdk_path = Path(os.path.expandvars("$HOME/github/google/gf180mcu-pdk"))
    if not pdk_path.exists():
        print(f"PDK path not found: {pdk_path}")
        sys.exit(1)
    
    print(f"Using PDK path: {pdk_path}")
    
    # Look for GDS files in the PDK path
    gds_files = find_gds_files(pdk_path)
    if not gds_files:
        print(f"No GDS files found in {pdk_path}")
        sys.exit(1)
        
    print(f"Found {len(gds_files)} GDS files")
    
    # Load cells from GDS files
    std_cells = []
    cell_map = {}  # Map to track loaded cells by base name
    for gds_file in gds_files:
        try:
            cell = gf.import_gds(gds_file)
            if cell is not None:
                # Add a suffix if we have name conflicts
                base_name = cell.name
                if base_name in cell_map:
                    cell_map[base_name] += 1
                    cell.name = f"{base_name}_{cell_map[base_name]}"
                else:
                    cell_map[base_name] = 0
                
                std_cells.append(cell)
                print(f"Loaded cell from: {gds_file.relative_to(pdk_path)}")
        except Exception as e:
            print(f"Failed to process GDS file {gds_file}: {str(e)}")

    if not std_cells:
        print("No standard cells could be loaded.")
        sys.exit(1)

    print(f"\nSuccessfully loaded {len(std_cells)} cells")

    # Calculate grid dimensions
    n_cells = len(std_cells)
    n_cols = int(np.ceil(np.sqrt(n_cells)))  # Make a roughly square grid
    n_rows = int(np.ceil(n_cells / n_cols))

    print(f"Creating grid of {n_cells} cells ({n_rows} rows x {n_cols} columns)")

    # Find maximum cell dimensions for spacing
    max_width = max(cell.size_info.width for cell in std_cells)
    max_height = max(cell.size_info.height for cell in std_cells)
    
    # Add some padding between cells
    padding = 5  # μm
    
    # Place cells in a grid
    for i, cell in enumerate(std_cells):
        row = i // n_cols
        col = i % n_cols
        
        # Calculate position for this cell
        x = col * (max_width + padding)
        y = row * (max_height + padding)
        
        # Add reference
        ref = c.add_ref(cell)
        ref.move((x, y))
        
        # Add label with cell name
        c.add_label(text=cell.name, position=(x, y - padding/2))

    return c

if __name__ == "__main__":
    # Create the grid
    grid = create_stdcell_grid()
    
    # Write to GDS file
    output_file = "gf180mcu_stdcell_grid.gds"
    grid.write_gds(output_file)
    print(f"Written grid to {output_file}")
    
    # Optionally view the layout
    grid.show()