#!/usr/bin/env python3
"""
Common utilities for categorizing GF180MCU standard cells.

This module provides functions for categorizing standard cells based on their names,
allowing consistent classification across different scripts.
"""

import re

def categorize_cell(cell_name):
    """Categorize a cell based on its name.
    
    Args:
        cell_name (str): The name of the standard cell
        
    Returns:
        str: The category of the cell (e.g., 'logic_gates', 'flip_flops', etc.)
    """
    # Extract the base name (remove size suffix)
    if not cell_name:
        return "other"

    # For fully qualified names (with library prefix), extract just the cell part
    if "__" in cell_name:
        cell_name = cell_name.split("__")[-1]

    # Remove size suffix if present
    base_name = re.sub(r'_(?:[1-9]|1[0-9]|2[0-9]|3[0-2]|64)$', '', cell_name)
    name_lower = base_name.lower()

    # Define categories
    categories = [
        ('clock',       ['clk', 'icgt']),
        ('aoi_oai',     ['aoi', 'oai']),
        ('arithmetic',  ['add', 'addf', 'addh']),
        ('buffers',     ['inv', 'buf', 'bufz', 'clkbuf', 'clkinv']),
        ('logic_gates', ['and', 'or', 'nand', 'nor', 'xor', 'xnor']),
        ('flip_flops',  ['dff', 'sdff']),
        ('latches',     ['lat']),
        ('mux',         ['mux']),
        ('delay',       ['dly']),
        ('special',     ['fill', 'tie', 'endcap', 'antenna', 'hold']),
    ]

    # Find matching category
    for category, patterns in categories:
        if any(pattern in name_lower for pattern in patterns):
            return category

    return 'other'