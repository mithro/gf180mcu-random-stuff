import gdsfactory as gf
import numpy as np
from gdsfactory.component import Component
from typing import List

def create_stdcell_grid() -> Component:
    """Creates a grid layout of all standard cells from GF180MCU PDK."""
    
    # Get the GF180MCU PDK
    from gdsfactory.config import PATH

    try:
        import gf180
    except ImportError:
        gf.config.rich_output = False  # Disable rich output for installation
        gf.technology.load_technology(name="gf180")
        import gf180

    # Create main component to hold the grid
    c = gf.Component("stdcell_grid")
    
    # Get all standard cells from the PDK
    std_cells = []
    for cell_name in gf180.cells.keys():
        if cell_name.startswith("gf180mcu_sc_"):  # Filter for standard cells
            try:
                cell = gf180.cells[cell_name]()
                std_cells.append(cell)
            except Exception as e:
                print(f"Failed to create cell {cell_name}: {str(e)}")

    if not std_cells:
        raise ValueError("No standard cells found in the PDK")

    # Calculate grid dimensions
    n_cells = len(std_cells)
    n_cols = int(np.ceil(np.sqrt(n_cells)))  # Make a roughly square grid
    n_rows = int(np.ceil(n_cells / n_cols))

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
        
        # Add reference to the cell
        ref = c.add_ref(cell)
        ref.move((x, y))
        
        # Add label with cell name
        c.add_label(text=cell.name, position=(x, y - padding/2))

    return c

if __name__ == "__main__":
    # Create the grid
    grid = create_stdcell_grid()
    
    # Write to GDS file
    grid.write_gds("gf180mcu_stdcell_grid.gds")
    
    # Optionally view the layout
    grid.show()