import os
import sys
from pathlib import Path
import gdsfactory as gf
import numpy as np
from collections import defaultdict
import re

def find_gds_files(pdk_path):
    """Find standard cell GDS files in the PDK."""
    # Path pattern for standard cells in GF180MCU PDK
    std_cell_pattern = "libraries/gf180mcu_fd_sc_mcu*/latest/cells/*/*.gds"
    return list(pdk_path.glob(std_cell_pattern))

def categorize_cell(cell_name):
    """Categorize a cell based on its name."""
    # Extract the base name (remove size suffix)
    if not cell_name:
        return "other"

    base_name = re.sub(r'_[1248](?:6|2)?$', '', cell_name)

    # Define categories
    categories = {
        'logic_gates': ['and', 'or', 'nand', 'nor', 'xor', 'xnor', 'inv', 'buf'],
        'flip_flops': ['dff', 'sdff'],
        'latches': ['lat'],
        'mux': ['mux'],
        'arithmetic': ['add', 'addf', 'addh'],
        'aoi_oai': ['aoi', 'oai'],
        'clock': ['clk', 'icgt'],
        'delay': ['dly'],
        'special': ['fill', 'tie', 'endcap', 'antenna']
    }

    # Find matching category
    for category, patterns in categories.items():
        if any(pattern in base_name.lower() for pattern in patterns):
            return category

    return 'other'

def group_cells_by_base_and_size(cells):
    """Group cells by their base name and size."""
    cell_groups = defaultdict(list)

    for cell in cells:
        # Try to extract the base name (without the size suffix if present)
        cell_name = cell.name
        match = re.match(r'(.+?)_([1248]|(?:16|20|32|64))$', cell_name)

        if match:
            base_name = match.group(1)
            size = match.group(2)
            cell_groups[base_name].append((size, cell))
        else:
            # Cells without size suffix go to their own group
            cell_groups[cell_name].append(('1', cell))

    # Sort cells within each group by size
    for group in cell_groups.values():
        group.sort(key=lambda x: int(x[0]) if x[0].isdigit() else int(re.sub(r'\D', '', x[0])))

    # Print the grouping information
    print("\nCell groupings by size variation:")
    for base_name, group in cell_groups.items():
        sizes = [size for size, _ in group]
        print(f"  {base_name}: {len(group)} variations - sizes: {', '.join(sizes)}")

    return cell_groups

def create_functional_groups(cells):
    """Group cells by their functional category."""
    groups = defaultdict(list)
    for cell in cells:
        category = categorize_cell(cell.name)
        groups[category].append(cell)

    # Print the functional grouping information
    print("\nCell groupings by functional category:")
    for category, cells_list in groups.items():
        print(f"  {category}: {len(cells_list)} cells")
        # Print first few cell names as examples
        example_cells = [cell.name.rsplit('_', 1)[0] for cell in cells_list[:5]]
        if example_cells:
            print(f"    Examples: {', '.join(example_cells)}" +
                  (f" and {len(cells_list)-5} more..." if len(cells_list) > 5 else ""))

    return groups

def create_stdcell_grid() -> gf.Component:
    """Creates a grid layout of all standard cells from GF180MCU PDK."""
    # Create main component to hold the grid
    c = gf.Component("stdcell_grid")

    # Use the specified PDK path
    pdk_path = Path(os.path.expandvars("$HOME/github/google/gf180mcu-pdk"))
    if not pdk_path.exists():
        print(f"PDK path not found: {pdk_path}")
        sys.exit(1)

    print(f"Using PDK path: {pdk_path}")

    # Look for GDS files in the PDK standard cell directories only
    gds_files = find_gds_files(pdk_path)
    if not gds_files:
        print(f"No standard cell GDS files found in {pdk_path}")
        sys.exit(1)

    print(f"Found {len(gds_files)} standard cell GDS files")

    # Load cells from GDS files
    std_cells = []
    seen_cells = set()  # Track cell names we've already processed

    for i, gds_file in enumerate(sorted(gds_files)):
        try:
            # Only process files in standard cell directories to skip non-standard cell GDS files
            basename = os.path.basename(gds_file)

            # Skip if we've already processed this cell name (avoids duplicate name conflicts)
            if basename in seen_cells:
                continue

            # Get filename without extension to use as cell name
            filename_without_ext = os.path.splitext(basename)[0]
            
            # Import the cell from GDS
            cell = gf.import_gds(gds_file)

            if cell is not None:
                # Rename the cell to match the filename instead of using original name
                cell.name = filename_without_ext
                std_cells.append(cell)
                seen_cells.add(basename)
                # Print the actual cell name loaded from each GDS file
                print(f"Loaded cell: {cell.name} from: {gds_file.relative_to(pdk_path)}")
        except Exception as e:
            print(f"Failed to process GDS file {gds_file}: {str(e)}")

    if not std_cells:
        print("No standard cells could be loaded.")
        sys.exit(1)

    print(f"\nSuccessfully loaded {len(std_cells)} cells")

    # First, create a grid showing size variations
    print("\nCreating size variation grid...")
    cell_groups = group_cells_by_base_and_size(std_cells)

    # Calculate grid dimensions for size variations
    n_groups = len(cell_groups)
    n_cols_size = 8  # Number of columns for size variations
    n_rows_size = int(np.ceil(n_groups / n_cols_size))

    # Find maximum cell dimensions
    max_width = max(cell.size_info.width for cell in std_cells)
    max_height = max(cell.size_info.height for cell in std_cells)
    padding = 10  # μm

    # Place cells grouped by size
    for i, (base_name, group) in enumerate(cell_groups.items()):
        row = i // n_cols_size
        col = i % n_cols_size

        # Add base name label
        x_base = col * (max_width + padding) * 4
        y_base = row * (max_height + padding) * 6  # Increased vertical spacing to accommodate vertical cell arrangement
        c.add_label(text=f"=== {base_name} ===",
                   position=(x_base, y_base + max_height + padding*0.5))

        # Place cells in the same group vertically (instead of horizontally)
        for j, (size, cell) in enumerate(group):
            x = x_base
            y = y_base - j * (max_height + padding)  # Stack cells vertically with largest at top

            ref = c << cell
            ref.move((x, y))

            # Add label with size and cell name
            c.add_label(text=f"{cell.name} (size: {size})", position=(x, y - padding/2))

    # Create another grid below for functional groups
    print("\nCreating functional groups grid...")
    functional_groups = create_functional_groups(std_cells)

    # Calculate dimensions for functional groups section (adjusted for new vertical layout)
    y_offset_functional = (max_height + padding) * (n_rows_size * 6 + 2)  # Adjusted for increased vertical spacing

    # Add section divider
    c.add_label(text="============= FUNCTIONAL GROUPS =============",
               position=(0, y_offset_functional - padding*2),
               layer=(66, 0))

    # Place cells grouped by function
    group_idx = 0
    for category, cells in functional_groups.items():
        # Create grid arrangement per category
        n_cols_func = 8  # Cells per row in this category
        n_cells = len(cells)
        n_rows_func = int(np.ceil(n_cells / n_cols_func))

        # Category header
        x_cat = 0
        y_cat = y_offset_functional + group_idx * (max_height + padding) * (n_rows_func + 1.5)
        c.add_label(text=f"=== {category.upper()} ({n_cells} cells) ===",
                   position=(x_cat, y_cat),
                   layer=(66, 0))

        # Place cells in this category in a grid
        for j, cell in enumerate(cells):
            row = j // n_cols_func
            col = j % n_cols_func

            x = col * (max_width + padding)
            y = y_cat - (row + 1) * (max_height + padding)

            ref = c << cell
            ref.move((x, y))

            # Add label with original cell name (without the unique suffix)
            original_name = cell.name.rsplit('_', 1)[0]
            c.add_label(text=f"{original_name}", position=(x, y - padding/2))

        group_idx += 1

    return c

if __name__ == "__main__":
    # Create the grid layout
    grid = create_stdcell_grid()

    # Write the output GDS file
    gds_filename = "gf180mcu_stdcell_grid.gds"
    grid.write_gds(gds_filename)
    print(f"\nWritten grid to {gds_filename}")