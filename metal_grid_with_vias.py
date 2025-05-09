#!/usr/bin/env python3
"""
metal_grid_with_vias.py

Creates a grid of metal traces with vias at intersection points for the GF180MCU process.
Uses the top metal layer (MT/Metal6) for vertical traces and Metal5 for horizontal traces.
Places vias (via5) at each crossing point.
"""

import gdsfactory as gf
import numpy as np
from pathlib import Path
import os
import uuid

# Define layer numbers for GF180MCU
# These are the standard layer numbers used in the GF180MCU PDK
LAYER_M5 = (51, 0)   # Metal 5 layer
LAYER_MT = (81, 0)   # Top metal (Metal 6) layer
LAYER_VIA5 = (82, 0) # Via between Metal 5 and Metal 6

# Counter for unique via names
_via_counter = 0

def create_via(via_size=0.26):
    """Create a via between Metal 5 and Metal 6"""
    global _via_counter
    _via_counter += 1
    c = gf.Component(f"via5_{via_size}_{_via_counter}")
    c.add_polygon([(0, 0), (via_size, 0), (via_size, via_size), (0, via_size)], layer=LAYER_VIA5)
    return c

def create_metal_grid(
    name: str = None,  # Name of the component (will be auto-generated if None)
    grid_size: float = 100.0,      # Total grid size in μm
    num_lines: int = 10,           # Number of lines in each direction
    m5_width: float = 0.44,        # Width of Metal 5 lines (μm)
    mt_width: float = 0.44,        # Width of Metal 6/MT lines (μm)
    via_size: float = 0.26,        # Size of via5 (μm)
    min_spacing: float = 0.46,     # Minimum spacing between metal lines (μm)
) -> gf.Component:
    """
    Create a grid of metal traces with vias at intersection points.
    
    Args:
        name: Name of the component (auto-generated if None)
        grid_size: Total size of the grid in μm
        num_lines: Number of lines in each direction
        m5_width: Width of Metal 5 lines in μm
        mt_width: Width of Metal 6/MT lines in μm
        via_size: Size of via5 in μm
        min_spacing: Minimum spacing between metal lines in μm
        
    Returns:
        gdsfactory Component with the metal grid
    """
    # Generate a unique name if none provided
    if name is None:
        name = f"metal_grid_with_vias_{str(uuid.uuid4())[:8]}"
    
    c = gf.Component(name)
    
    # Calculate pitch based on grid size and number of lines
    pitch = max(grid_size / (num_lines - 1), m5_width + mt_width + min_spacing)
    
    # Create a via component
    via = create_via(via_size=via_size)
    
    # Create horizontal Metal 5 lines
    for i in range(num_lines):
        y_pos = i * pitch
        # Create horizontal line
        horiz_line = c.add_polygon([
            (0, y_pos - m5_width/2),
            (grid_size, y_pos - m5_width/2),
            (grid_size, y_pos + m5_width/2),
            (0, y_pos + m5_width/2)
        ], layer=LAYER_M5)
        
    # Create vertical Metal 6/MT lines
    for i in range(num_lines):
        x_pos = i * pitch
        # Create vertical line
        vert_line = c.add_polygon([
            (x_pos - mt_width/2, 0),
            (x_pos + mt_width/2, 0),
            (x_pos + mt_width/2, grid_size),
            (x_pos - mt_width/2, grid_size)
        ], layer=LAYER_MT)
        
    # Add vias at each intersection
    for i in range(num_lines):
        for j in range(num_lines):
            x_pos = i * pitch
            y_pos = j * pitch
            # Place via at intersection, centered on the crossing point
            via_ref = c << via
            via_ref.move((x_pos - via_size/2, y_pos - via_size/2))
    
    return c

def main():
    """Main function to create and save the metal grid with vias."""
    # Create metal grid with default parameters
    # These values respect the GF180MCU DRC rules for top metal
    metal_grid = create_metal_grid(
        name="metal_grid_with_vias_standard",
        grid_size=100.0,   # 100μm x 100μm grid
        num_lines=20,      # 20 lines in each direction
        m5_width=0.45,     # 0.45μm for Metal 5 width (>= min 0.44μm)
        mt_width=0.45,     # 0.45μm for Metal 6/MT width (>= min 0.44μm)
        via_size=0.26,     # 0.26μm via size
        min_spacing=0.5,   # 0.5μm spacing (> min 0.46μm)
    )
    
    # Create versions with different parameters
    # A denser grid with more lines
    dense_grid = create_metal_grid(
        name="metal_grid_with_vias_dense",
        grid_size=100.0,
        num_lines=40,
        m5_width=0.45,
        mt_width=0.45,
        via_size=0.26,
        min_spacing=0.5,
    )
    
    # A grid with wider metal traces
    wide_metal_grid = create_metal_grid(
        name="metal_grid_with_vias_wide",
        grid_size=100.0,
        num_lines=15,
        m5_width=0.8,
        mt_width=0.8,
        via_size=0.26,
        min_spacing=0.5,
    )
    
    # Save the GDS files
    output_dir = Path("build/gds")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    metal_grid.write_gds(output_dir / "metal_grid_with_vias.gds")
    print(f"Written metal grid to {output_dir / 'metal_grid_with_vias.gds'}")
    
    dense_grid.write_gds(output_dir / "metal_grid_dense.gds")
    print(f"Written dense grid to {output_dir / 'metal_grid_dense.gds'}")
    
    wide_metal_grid.write_gds(output_dir / "metal_grid_wide.gds")
    print(f"Written wide metal grid to {output_dir / 'metal_grid_wide.gds'}")
    
    # Also create an OASIS file for better compatibility with gf180
    try:
        metal_grid.write_oas(output_dir / "metal_grid_with_vias.oas")
        print(f"Written metal grid to {output_dir / 'metal_grid_with_vias.oas'}")
    except AttributeError:
        # Fall back to write_gds if write_oas is not available
        print("write_oas method not available, using write_gds for OASIS format")
        metal_grid.write_gds(output_dir / "metal_grid_with_vias.oas")
        print(f"Written metal grid to {output_dir / 'metal_grid_with_vias.oas'}")

if __name__ == "__main__":
    main()