#!/usr/bin/env python3
"""
dense_via_array.py

Creates the densest possible array of vias connecting to the top metal layer (MT/Metal6)
in the GF180MCU process while respecting design rules.
"""

import gdsfactory as gf
import numpy as np
from pathlib import Path
import uuid
import gf180  # Import the GF180MCU PDK

# Define layer numbers for GF180MCU
LAYER_M5 = (51, 0)    # Metal 5 layer
LAYER_MT = (81, 0)    # Top metal (Metal 6/MT) layer
LAYER_VIA5 = (82, 0)  # Via between Metal 5 and Metal 6

# Design rules for GF180MCU
# These values are based on the GF180MCU design rules
VIA5_SIZE = 0.26      # Minimum via5 size in μm
VIA5_SPACING = 0.28   # Minimum spacing between vias in μm
MT_WIDTH = 0.44       # Minimum Metal 6/MT width in μm
MT_SPACING = 0.46     # Minimum Metal 6/MT spacing in μm
M5_WIDTH = 0.44       # Minimum Metal 5 width in μm
M5_SPACING = 0.46     # Minimum Metal 5 spacing in μm
VIA5_ENCLOSURE = 0.09 # Minimum metal enclosure of via5 in μm

def create_dense_via_array(
    size: float = 100.0,       # Size of the array in μm
    via_size: float = VIA5_SIZE,
    via_spacing: float = VIA5_SPACING,
    m5_width: float = M5_WIDTH,
    mt_width: float = MT_WIDTH,
    name: str = None
) -> gf.Component:
    """
    Creates the densest possible array of vias connecting Metal 5 to Metal 6/MT
    while respecting GF180MCU design rules.
    
    Args:
        size: Size of the via array in μm (square)
        via_size: Size of via5 in μm
        via_spacing: Minimum spacing between vias in μm
        m5_width: Width of Metal 5 traces in μm
        mt_width: Width of Metal 6/MT traces in μm
        name: Name of the component (auto-generated if None)
        
    Returns:
        gdsfactory Component with the dense via array
    """
    # Generate a unique name if none provided
    if name is None:
        name = f"dense_via_array_{str(uuid.uuid4())[:8]}"
    
    c = gf.Component(name)
    
    # Calculate the pitch for the vias (center-to-center distance)
    via_pitch = via_size + via_spacing
    
    # Calculate how many vias can fit in each direction
    num_vias_per_row = int(size / via_pitch)
    
    # Create a via component with a unique name
    via = gf.Component(f"via5_simple_{str(uuid.uuid4())[:8]}")
    via.add_polygon([
        (0, 0), 
        (via_size, 0), 
        (via_size, via_size), 
        (0, via_size)
    ], layer=LAYER_VIA5)
    
    # Create continuous Metal 5 and Metal 6/MT layers covering the entire area
    # This ensures proper metal enclosure around all vias
    c.add_polygon([
        (0, 0),
        (size, 0),
        (size, size),
        (0, size)
    ], layer=LAYER_M5)
    
    c.add_polygon([
        (0, 0),
        (size, 0),
        (size, size),
        (0, size)
    ], layer=LAYER_MT)
    
    # Place vias in a grid pattern
    for i in range(num_vias_per_row):
        x = i * via_pitch + via_pitch/2  # Center in the available space
        for j in range(num_vias_per_row):
            y = j * via_pitch + via_pitch/2  # Center in the available space
            
            # Place via at this position, centered
            via_ref = c << via
            via_ref.move((x - via_size/2, y - via_size/2))
    
    return c

def create_dense_via_array_with_stripes(
    size: float = 100.0,          # Size of the array in μm
    via_size: float = VIA5_SIZE,
    via_spacing: float = VIA5_SPACING,
    m5_width: float = M5_WIDTH,
    m5_spacing: float = M5_SPACING,
    mt_width: float = MT_WIDTH,
    mt_spacing: float = MT_SPACING,
    via_enclosure: float = VIA5_ENCLOSURE,
    name: str = None
) -> gf.Component:
    """
    Creates the densest possible array of vias connecting Metal 5 to Metal 6/MT
    using arrays of stripes with vias at allowed positions.
    
    Args:
        size: Size of the via array in μm (square)
        via_size: Size of via5 in μm
        via_spacing: Minimum spacing between vias in μm
        m5_width: Width of Metal 5 traces in μm
        m5_spacing: Minimum spacing between Metal 5 traces in μm
        mt_width: Width of Metal 6/MT traces in μm
        mt_spacing: Minimum spacing between Metal 6/MT traces in μm
        via_enclosure: Minimum metal enclosure of via5 in μm
        name: Name of the component (auto-generated if None)
        
    Returns:
        gdsfactory Component with the dense via array
    """
    # Generate a unique name if none provided
    if name is None:
        name = f"dense_via_array_stripes_{str(uuid.uuid4())[:8]}"
    
    c = gf.Component(name)
    
    # Calculate the minimum metal width needed to support a via with proper enclosure
    min_metal_width = via_size + 2 * via_enclosure
    
    # Use the larger of min_metal_width and the specified metal widths
    effective_m5_width = max(min_metal_width, m5_width)
    effective_mt_width = max(min_metal_width, mt_width)
    
    # Calculate the pitch for Metal 5 and Metal 6/MT stripes
    m5_pitch = effective_m5_width + m5_spacing
    mt_pitch = effective_mt_width + mt_spacing
    
    # Calculate how many stripes can fit in each direction
    num_m5_stripes = int(size / m5_pitch)
    num_mt_stripes = int(size / mt_pitch)
    
    # Create horizontal Metal 5 stripes
    for i in range(num_m5_stripes):
        y_pos = i * m5_pitch + effective_m5_width/2
        c.add_polygon([
            (0, y_pos - effective_m5_width/2),
            (size, y_pos - effective_m5_width/2),
            (size, y_pos + effective_m5_width/2),
            (0, y_pos + effective_m5_width/2)
        ], layer=LAYER_M5)
    
    # Create vertical Metal 6/MT stripes
    for i in range(num_mt_stripes):
        x_pos = i * mt_pitch + effective_mt_width/2
        c.add_polygon([
            (x_pos - effective_mt_width/2, 0),
            (x_pos + effective_mt_width/2, 0),
            (x_pos + effective_mt_width/2, size),
            (x_pos - effective_mt_width/2, size)
        ], layer=LAYER_MT)
    
    # Create a single via template to be referenced at intersections
    via_template = gf.Component(f"via5_stripe_{str(uuid.uuid4())[:8]}")
    via_template.add_polygon([
        (0, 0),
        (via_size, 0),
        (via_size, via_size),
        (0, via_size)
    ], layer=LAYER_VIA5)
    
    # Create via instances at each intersection
    for i in range(num_mt_stripes):
        x_pos = i * mt_pitch + effective_mt_width/2
        for j in range(num_m5_stripes):
            y_pos = j * m5_pitch + effective_m5_width/2
            
            # Reference the via template at this intersection
            via_ref = c << via_template
            via_ref.move((x_pos - via_size/2, y_pos - via_size/2))
    
    return c

def create_optimized_via_array(
    size: float = 100.0,
    via_size: float = VIA5_SIZE, 
    via_spacing: float = VIA5_SPACING,
    via_enclosure: float = VIA5_ENCLOSURE,
    name: str = None
) -> gf.Component:
    """
    Creates the absolute densest possible array of vias connecting Metal 5 to Metal 6/MT
    by optimizing the metal and via patterns based on GF180MCU design rules.
    
    Args:
        size: Size of the via array in μm (square)
        via_size: Size of via5 in μm
        via_spacing: Minimum spacing between vias in μm
        via_enclosure: Minimum metal enclosure of via5 in μm
        name: Name of the component (auto-generated if None)
        
    Returns:
        gdsfactory Component with the optimized via array
    """
    # Generate a unique name if none provided
    if name is None:
        name = f"optimized_via_array_{str(uuid.uuid4())[:8]}"
    
    c = gf.Component(name)
    
    # Calculate via pitch (center-to-center distance)
    via_pitch = via_size + via_spacing
    
    # Calculate number of vias that can fit
    num_vias = int(size / via_pitch)
    
    # Create solid metal layers to ensure via enclosure
    # The solid metal layers will be the size of the array plus enclosure on all sides
    metal_size = size + 2 * via_enclosure
    
    c.add_polygon([
        (-via_enclosure, -via_enclosure),
        (size + via_enclosure, -via_enclosure),
        (size + via_enclosure, size + via_enclosure),
        (-via_enclosure, size + via_enclosure)
    ], layer=LAYER_M5)
    
    c.add_polygon([
        (-via_enclosure, -via_enclosure),
        (size + via_enclosure, -via_enclosure),
        (size + via_enclosure, size + via_enclosure),
        (-via_enclosure, size + via_enclosure)
    ], layer=LAYER_MT)
    
    # Create a single via cell that we'll reuse with a unique name
    via_cell = gf.Component(f"via5_opt_{str(uuid.uuid4())[:8]}")
    via_cell.add_polygon([
        (0, 0),
        (via_size, 0),
        (via_size, via_size),
        (0, via_size)
    ], layer=LAYER_VIA5)
    
    # Place vias in a staggered pattern to maximize density
    # This can fit more vias than a simple grid in some cases
    row_offset = 0.0
    for i in range(num_vias + 1):  # +1 to fill the entire area
        # Alternate the offset for each row to create a staggered pattern
        if i % 2 == 1:
            row_offset = via_pitch / 2
        else:
            row_offset = 0.0
            
        y = i * via_pitch
        if y < size:  # Ensure we're still within bounds
            for j in range(num_vias + 1):  # +1 to fill the entire area
                x = j * via_pitch + row_offset
                if x < size:  # Ensure we're still within bounds
                    # Reference the single via cell instead of creating new components
                    via_ref = c << via_cell
                    via_ref.move((x, y))
    
    return c

def main():
    """Main function to create and save the dense via arrays."""
    # Create dense via arrays with different approaches
    simple_array = create_dense_via_array(
        size=100.0,
        via_size=VIA5_SIZE,
        via_spacing=VIA5_SPACING
    )
    
    stripe_array = create_dense_via_array_with_stripes(
        size=100.0,
        via_size=VIA5_SIZE,
        via_spacing=VIA5_SPACING,
        m5_width=M5_WIDTH,
        mt_width=MT_WIDTH
    )
    
    optimized_array = create_optimized_via_array(
        size=100.0,
        via_size=VIA5_SIZE,
        via_spacing=VIA5_SPACING
    )
    
    # Save the GDS files
    output_dir = Path("build/gds")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    simple_array.write_gds(output_dir / "dense_via_array_simple.gds")
    print(f"Written simple via array to {output_dir / 'dense_via_array_simple.gds'}")
    
    stripe_array.write_gds(output_dir / "dense_via_array_stripes.gds")
    print(f"Written striped via array to {output_dir / 'dense_via_array_stripes.gds'}")
    
    optimized_array.write_gds(output_dir / "dense_via_array_optimized.gds")
    print(f"Written optimized via array to {output_dir / 'dense_via_array_optimized.gds'}")
    
    # Create OASIS files for better compatibility with the GF180MCU PDK
    try:
        simple_array.write_oas(output_dir / "dense_via_array_simple.oas")
        stripe_array.write_oas(output_dir / "dense_via_array_stripes.oas")
        optimized_array.write_oas(output_dir / "dense_via_array_optimized.oas")
        print("Written OASIS files")
    except AttributeError:
        # Fall back to write_gds if write_oas is not available in this gdsfactory version
        print("write_oas method not available, OASIS files not created")
    
    # Return the most optimized array for further analysis
    return optimized_array

if __name__ == "__main__":
    main()