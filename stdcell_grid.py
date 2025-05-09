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

    base_name = re.sub(r'_(?:[1-9]|1[0-9]|2[0-9]|3[0-2]|64)$', '', cell_name)
    name_lower = base_name.lower()

    # Define categories
    categories = [
        ('clock',       ['clk', 'icgt']),
        ('aoi_oai',     ['aoi', 'oai']),
        ('arithmetic',  ['add', 'addf', 'addh']),
        ('buffers',     ['inv', 'buf']),
        ('logic_gates', ['and', 'or', 'nand', 'nor', 'xor', 'xnor']),
        ('flip_flops',  ['dff', 'sdff']),
        ('latches',     ['lat']),
        ('mux',         ['mux']),
        ('delay',       ['dly']),
        ('special',     ['fill', 'tie', 'endcap', 'antenna']),
    ]

    # Find matching category
    for category, patterns in categories:
        if any(pattern in name_lower for pattern in patterns):
            return category

    return 'other'

def group_cells_by_base_and_size(cells):
    """Group cells by their base name and size."""
    cell_groups = defaultdict(list)

    for cell in cells:
        # Try to extract the base name (without the size suffix if present)
        cell_name = cell.name
        match = re.match(r'(.+?)_(?:([1-9]|1[0-9]|2[0-9]|3[0-2]|64))$', cell_name)

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

    # First, group cells by their base name and size
    print("\nGrouping cells by base name and size...")
    cell_groups = group_cells_by_base_and_size(std_cells)

    # Also group by functional category
    print("\nGrouping cells by functional category...")
    functional_groups = create_functional_groups(std_cells)

    # Find maximum cell dimensions
    max_width = max(cell.size_info.width for cell in std_cells)
    max_height = max(cell.size_info.height for cell in std_cells)
    padding = 10  # μm
    vertical_cell_spacing = 1  # μm - spacing between different sizes of the same cell

    # Now create a grid where each functional category gets its own section
    # Using negative y-values to make sure things flow from top to bottom
    y_offset = 0

    for category, category_cells in functional_groups.items():
        # Create a dict to hold grouped cells in this category
        category_groups = {}

        # Find all base cell types in this category
        for cell in category_cells:
            cell_name = cell.name
            match = re.match(r'(.+?)_(?:[1-9]|1[0-9]|2[0-9]|3[0-2]|64)$', cell_name)

            if match:
                base_name = match.group(1)
                if base_name in cell_groups:
                    category_groups[base_name] = cell_groups[base_name]
            else:
                # Cells without size suffix
                if cell_name in cell_groups:
                    category_groups[cell_name] = cell_groups[cell_name]

        # Organize cells by name prefix (e.g., "and", "or", "xor")
        # Extract the prefixes from cell base names
        name_prefixes = {}
        for base_name in category_groups.keys():
            # First, strip away the standard cell library prefix (if present)
            # Cell names are typically like "gf180mcu_fd_sc_mcu7t5v0__and2"
            actual_cell_name = base_name
            if "__" in base_name:
                actual_cell_name = base_name.split("__")[-1]

            # Extract the common prefix (e.g., "and" from "and2", "and3")
            # This regex finds the alphabetic prefix at the start of the actual cell name
            prefix_match = re.match(r'^([a-zA-Z]+)', actual_cell_name)
            if prefix_match:
                prefix = prefix_match.group(1).lower()
                if prefix not in name_prefixes:
                    name_prefixes[prefix] = []
                name_prefixes[prefix].append(base_name)
            else:
                # If no alphabetic prefix found, use the whole cell name
                if actual_cell_name not in name_prefixes:
                    name_prefixes[actual_cell_name] = []
                name_prefixes[actual_cell_name].append(base_name)

        # Calculate grid dimensions for this category
        n_rows = len(name_prefixes)  # One row per prefix group

        # Add category header
        category_width = (max_width + padding) * 3 * 5  # Assuming up to 5 variations per prefix
        c.add_label(text=f"================ {category.upper()} ================",
                   position=(0, y_offset),  # Left-align the header
                   layer=(66, 0))

        # Move y_offset down for cell placement (after the header)
        y_offset -= padding * 3  # Space after category header - NEGATIVE to go down

        # Place each prefix group in its own row
        for i, (prefix, base_names) in enumerate(name_prefixes.items()):
            # Calculate position for this row
            y_row = y_offset  # Vertical position for this row
            
            # Add prefix label at the start of the row
            c.add_label(text=f"{prefix.upper()}",
                       position=(0, y_row),
                       layer=(66, 0))
            
            # Track the maximum height for any column in this row
            max_column_height = 0
            
            # Place each cell type with this prefix in this row
            for j, base_name in enumerate(base_names):
                group = category_groups[base_name]
                
                # Calculate x position for this cell type
                x_base = padding + j * (max_width + padding) * 3  # Horizontal spacing
                
                # Add base name label
                c.add_label(text=f"{base_name}",
                           position=(x_base, y_row),
                           layer=(66, 0))
                
                # Calculate the height of this column (all sizes of this cell)
                column_height = len(group) * (max_height + vertical_cell_spacing) + padding
                max_column_height = max(max_column_height, column_height)
                
                # Start placing cells below the base name label
                y_cell = y_row - padding * 2
                
                # Stack different sizes of this cell type vertically downward
                for k, (size, cell) in enumerate(group):
                    # Position each cell precisely under its base name label
                    x = x_base
                    y = y_cell - k * (max_height + vertical_cell_spacing)
                    
                    ref = c << cell
                    ref.move((x, y))
                    
                    # Add label with size
                    c.add_label(text=f"size: {size}",
                               position=(x - padding/2, y),
                               layer=(66, 0))
            
            # Move y_offset down for the next row
            y_offset -= (max_column_height + padding * 2)
        
        # Add extra space between categories
        y_offset -= padding * 4

    return c

if __name__ == "__main__":
    # Create the grid layout
    grid = create_stdcell_grid()

    # Write the output GDS file
    gds_filename = "gf180mcu_stdcell_grid.gds"
    grid.write_gds(gds_filename)
    print(f"\nWritten grid to {gds_filename}")