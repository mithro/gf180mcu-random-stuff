#!/usr/bin/env python3
"""
Store Element Generator

This script generates Verilog code for store elements with an arbitrary number of rows and columns.
The generated modules provide a configurable storage array using GF180MCU latches.

Usage:
    python3 generate_store.py [rows] [cols]

    If no arguments are provided, the script will prompt for rows and columns.

Example:
    python3 generate_store.py 3 2     # Generates store_3x2.v (same as store6.v)
    python3 generate_store.py 2 2     # Generates store_2x2.v (same as store4.v)
"""

import sys
import os

def generate_store_module(rows, cols):
    """Generate a store module with the specified number of rows and columns."""
    
    # Calculate total number of storage elements
    total_elements = rows * cols
    
    # File path
    module_name = f"store_{rows}x{cols}"
    file_path = f"modules/store/{module_name}.v"
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    verilog_code = f"""\
// Description: {total_elements} bits of storage.
//
// Contains {total_elements} latches in a row/column configuration.
//
"""
    
    # Generate the ASCII diagram header
    verilog_code += "//         "
    for c in range(cols):
        verilog_code += f"col{c}     "
    verilog_code += "\n//      +"
    
    for c in range(cols):
        verilog_code += "========+"
    verilog_code += "\n"
    
    # Generate the ASCII diagram rows
    for r in range(rows):
        verilog_code += f"// row{r} |"
        for c in range(cols):
            verilog_code += " latq_1 |"
        verilog_code += "\n//      +"
        for c in range(cols):
            verilog_code += "--------+"
        verilog_code += "\n"
    
    # Replace the last row of dashes with equal signs for better formatting
    lines = verilog_code.split('\n')
    last_row = lines[-2]
    last_row = last_row.replace("--", "==")
    lines[-2] = last_row
    verilog_code = '\n'.join(lines)
    
    # Module declaration
    verilog_code += "//\n"
    verilog_code += f"module {module_name} (\n"
    
    # Input ports
    for r in range(rows):
        verilog_code += f"    input  wire dat{r},     // Data input for row {r}\n"
    for c in range(cols):
        verilog_code += f"    input  wire cap{c},     // Capture data for column {c}\n"
    
    # Output port
    verilog_code += f"    output wire [0:{total_elements-1}] out  // Stored data output\n"
    verilog_code += ");\n\n"
    
    # Generate the latches
    index = 0
    for r in range(rows):
        for c in range(cols):
            verilog_code += f"    gf180mcu_fd_sc_mcu7t5v0__latq_1 dff_r{r}c{c} (\n"
            verilog_code += f"        .D(dat{r}),\n"
            verilog_code += f"        .E(cap{c}),\n"
            verilog_code += f"        .Q(out[{index}])\n"
            verilog_code += "    );\n\n"
            index += 1
    
    # End module
    verilog_code += "endmodule\n"
    
    # Write the generated Verilog code to a file
    with open(file_path, 'w') as f:
        f.write(verilog_code)
    
    print(f"Generated {file_path} successfully.")
    return file_path

def main():
    """Main function to handle command line arguments and generate the store module."""
    
    # Get rows and columns from command line arguments or user input
    if len(sys.argv) == 3:
        try:
            rows = int(sys.argv[1])
            cols = int(sys.argv[2])
        except ValueError:
            print("Error: Rows and columns must be integers.")
            return
    else:
        try:
            rows = int(input("Enter number of rows: "))
            cols = int(input("Enter number of columns: "))
        except ValueError:
            print("Error: Rows and columns must be integers.")
            return
    
    # Validate input
    if rows <= 0 or cols <= 0:
        print("Error: Rows and columns must be positive integers.")
        return
    
    # Generate the store module
    file_path = generate_store_module(rows, cols)
    
    # Print usage example for the generated module
    print(f"\nUsage example for {os.path.basename(file_path)}:")
    module_name = f"store_{rows}x{cols}"
    total_elements = rows * cols
    
    print(f"""
    // Instantiation example:
    {module_name} storage (
        // Data inputs
        {', '.join([f'.dat{r}(prog_dat{r})' for r in range(rows)])},
        // Capture signals
        {', '.join([f'.cap{c}(prog_cap{c})' for c in range(cols)])},
        // Output
        .out(q)
    );
    
    // Where q is declared as:
    wire [0:{total_elements-1}] q;
    """)

if __name__ == "__main__":
    main()
