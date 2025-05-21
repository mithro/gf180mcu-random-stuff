// Description: Testbench for lutu module testing various configurations
//              of the 3-output LUT with 4-input select.
`timescale 1ns/1ps

module lutu_test;
    // Inputs
    reg [3:0] in;
    reg [3:0] prog_dat;
    reg [3:0] prog_cap;
    
    // Outputs
    wire [2:0] out;
    
    // Instantiate the DUT (Device Under Test)
    lutu dut (
        .in(in),
        .out(out),
        .prog_dat(prog_dat),
        .prog_cap(prog_cap)
    );
    
    // Test parameters
    integer i;
    reg [2:0] expected_out;
    reg [15:0] mux_pattern; // 4-bit pattern for each of the 3 muxes + extra 4 bits
    
    // Test function patterns to be programmed into the mux
    // These are example patterns for different configurations
    localparam [3:0] PATTERN_AND  = 4'b1000;
    localparam [3:0] PATTERN_OR   = 4'b1110;
    localparam [3:0] PATTERN_XOR  = 4'b0110;
    
    // Additional pattern constants for NAND, NOR, and other functions
    localparam [3:0] PATTERN_NAND = 4'b0111;
    localparam [3:0] PATTERN_NOR  = 4'b0001;
    localparam [3:0] PATTERN_AOI21 = 4'b0001; // AND-OR-Invert
    localparam [3:0] PATTERN_OAI21 = 4'b0001; // OR-AND-Invert
    localparam [3:0] PATTERN_MUX_AND = 4'b1000; // For mux input A (AND)
    localparam [3:0] PATTERN_MUX_SEL = 4'b0100; // For mux select (AND with NOT)
    localparam [3:0] PATTERN_MUX_OR = 4'b1110;  // For mux output (OR)
    localparam [3:0] PATTERN_FULL_ADD_XOR = 4'b0110; // XOR for full adder
    localparam [3:0] PATTERN_FULL_ADD_AND = 4'b1000; // AND for full adder
    
    // Patterns for the two additional function types
    localparam [3:0] PATTERN_CONST_0 = 4'b0000; // Constant 0
    localparam [3:0] PATTERN_CONST_1 = 4'b1111; // Constant 1
    localparam [3:0] PATTERN_PASSTHROUGH = 4'b1010; // Pass input through
    
    // Expected output patterns for different configurations
    // 2D array format: [16 input combinations][3 outputs]
    localparam [0:15][2:0] EXPECTED_TRIPLE_AND = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b000,  3'b000,  3'b000,
        // in=0100  in=0101  in=0110  in=0111
           3'b000,  3'b000,  3'b000,  3'b000,
        // in=1000  in=1001  in=1010  in=1011
           3'b000,  3'b000,  3'b000,  3'b000,
        // in=1100  in=1101  in=1110  in=1111
           3'b000,  3'b000,  3'b000,  3'b111
    };
    
    localparam [0:15][2:0] EXPECTED_TRIPLE_OR = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b111,  3'b111,  3'b111,
        // in=0100  in=0101  in=0110  in=0111
           3'b111,  3'b111,  3'b111,  3'b111,
        // in=1000  in=1001  in=1010  in=1011
           3'b111,  3'b111,  3'b111,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b111,  3'b111,  3'b111,  3'b111
    };
    
    localparam [0:15][2:0] EXPECTED_TRIPLE_XOR = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b111,  3'b111,  3'b000,
        // in=0100  in=0101  in=0110  in=0111
           3'b111,  3'b000,  3'b000,  3'b111,
        // in=1000  in=1001  in=1010  in=1011
           3'b111,  3'b000,  3'b000,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b000,  3'b111,  3'b111,  3'b000
    };
    
    localparam [0:15][2:0] EXPECTED_AND_OR_XOR = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b001,  3'b010,  3'b011,
        // in=0100  in=0101  in=0110  in=0111
           3'b100,  3'b101,  3'b110,  3'b111,
        // in=1000  in=1001  in=1010  in=1011
           3'b100,  3'b101,  3'b110,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b100,  3'b101,  3'b110,  3'b111
    };
    
    // Additional expected output patterns
    localparam [0:15][2:0] EXPECTED_TRIPLE_NAND = {
        // in=0000  in=0001  in=0010  in=0011
           3'b111,  3'b111,  3'b111,  3'b111,
        // in=0100  in=0101  in=0110  in=0111
           3'b111,  3'b111,  3'b111,  3'b111,
        // in=1000  in=1001  in=1010  in=1011
           3'b111,  3'b111,  3'b111,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b111,  3'b111,  3'b111,  3'b000
    };
    
    localparam [0:15][2:0] EXPECTED_TRIPLE_NOR = {
        // in=0000  in=0001  in=0010  in=0011
           3'b111,  3'b000,  3'b000,  3'b000,
        // in=0100  in=0101  in=0110  in=0111
           3'b000,  3'b000,  3'b000,  3'b000,
        // in=1000  in=1001  in=1010  in=1011
           3'b000,  3'b000,  3'b000,  3'b000,
        // in=1100  in=1101  in=1110  in=1111
           3'b000,  3'b000,  3'b000,  3'b000
    };
    
    localparam [0:15][2:0] EXPECTED_MAJORITY = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b000,  3'b000,  3'b111,
        // in=0100  in=0101  in=0110  in=0111
           3'b000,  3'b111,  3'b111,  3'b111,
        // in=1000  in=1001  in=1010  in=1011
           3'b000,  3'b111,  3'b111,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b111,  3'b111,  3'b111,  3'b111
    };
    
    localparam [0:15][2:0] EXPECTED_MUX_2TO1 = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b000,  3'b000,  3'b000,
        // in=0100  in=0101  in=0110  in=0111
           3'b001,  3'b001,  3'b001,  3'b001,
        // in=1000  in=1001  in=1010  in=1011
           3'b100,  3'b100,  3'b100,  3'b100,
        // in=1100  in=1101  in=1110  in=1111
           3'b101,  3'b101,  3'b101,  3'b101
    };
    
    localparam [0:15][2:0] EXPECTED_FULL_ADDER = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b111,  3'b111,  3'b000,
        // in=0100  in=0101  in=0110  in=0111
           3'b111,  3'b000,  3'b000,  3'b111,
        // in=1000  in=1001  in=1010  in=1011
           3'b111,  3'b000,  3'b000,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b000,  3'b111,  3'b111,  3'b000
    };
    
    // Expected output for dual 2-input functions with constant
    localparam [0:15][2:0] EXPECTED_DUAL_2INPUT = {
        // in=0000  in=0001  in=0010  in=0011
           3'b010,  3'b011,  3'b010,  3'b011,
        // in=0100  in=0101  in=0110  in=0111
           3'b010,  3'b011,  3'b010,  3'b011,
        // in=1000  in=1001  in=1010  in=1011
           3'b110,  3'b111,  3'b110,  3'b111,
        // in=1100  in=1101  in=1110  in=1111
           3'b110,  3'b111,  3'b110,  3'b111
    };
    
    // Expected output for 3-input function with 1 passthrough
    localparam [0:15][2:0] EXPECTED_3INPUT_PASSTHROUGH = {
        // in=0000  in=0001  in=0010  in=0011
           3'b000,  3'b010,  3'b000,  3'b010,
        // in=0100  in=0101  in=0110  in=0111
           3'b001,  3'b011,  3'b001,  3'b011,
        // in=1000  in=1001  in=1010  in=1011
           3'b100,  3'b110,  3'b100,  3'b110,
        // in=1100  in=1101  in=1110  in=1111
           3'b101,  3'b111,  3'b101,  3'b111
    };
    
    // Task to test a specific LUT configuration
    task test_configuration;
        input [127:0] config_name;   // Configuration name (as a string)
        input [3:0] lut1_pattern;    // Pattern for LUT1 (out[0])
        input [3:0] lut2_pattern;    // Pattern for LUT2 (out[1])
        input [3:0] lut3_pattern;    // Pattern for LUT3 (out[2])
        input [0:15][2:0] expected;  // Expected outputs for all 16 input combinations [inputs][outputs]
        begin
            $display("Testing configuration: %s", config_name);
            
            // Program the LUT with the specified patterns
            program_store(lut1_pattern, lut2_pattern, lut3_pattern);
            #10; // Allow time for programming to complete
            
            // Test all 16 input combinations
            for (i = 0; i < 16; i = i + 1) begin
                in = i[3:0]; // Set input value
                #10; // Allow time for output to stabilize
                
                // Get expected output for this input from the 2D array
                expected_out = expected[i];
                
                // Check if output matches expected value
                if (out !== expected_out) begin
                    $display("ERROR: %s test failed for input %b", config_name, in);
                    $display("  Expected: %b, Got: %b", expected_out, out);
                    $finish;
                end
            end
            
            $display("%s configuration test PASSED", config_name);
            #10; // Delay between configurations
        end
    endtask
    
    // Function to program the lutu with a 3*4-bit patterns for the 3 muxes
    task program_store;
        input [3:0] lut1; // For mux1 (out[0])
        input [3:0] lut2; // For mux2 (out[1])
        input [3:0] lut3; // For mux3 (out[2])
        begin
            
            // Program column 0
            prog_cap = 4'b0000;
            #5;
            prog_dat = {lut1[0], lut1[2], lut2[0], lut2[2]};
            #5 prog_cap = 4'b0001;

            // Program column 1
            prog_cap = 4'b0000;
            #5;
            prog_dat = {lut1[1], lut1[3], lut2[1], lut2[3]};
            #5 prog_cap = 4'b0010;
            
            // Program column 3
            prog_cap = 4'b0000;
            #5;
            prog_dat = {lut3[0], lut3[1], 1'b0, 1'b0};
            #5 prog_cap = 4'b0100;

            // Program column 4
            prog_cap = 4'b0000;
            #5;
            prog_dat = {lut3[1], lut3[3], 1'b0, 1'b0};
            #5 prog_cap = 4'b1000;
        end
    endtask
    
    // Test sequence
    initial begin
        // Initialize inputs
        in = 4'b0000;
        prog_dat = 4'b0000;
        prog_cap = 4'b0000;
        
        // Wait for global reset
        #100;
        
        // 4-input AND function
        test_configuration(
            "Triple AND",
            PATTERN_AND, PATTERN_AND, PATTERN_AND,
            EXPECTED_TRIPLE_AND
        );
        
        // 4-input OR function
        test_configuration(
            "Triple OR",
            PATTERN_OR, PATTERN_OR, PATTERN_OR,
            EXPECTED_TRIPLE_OR
        );
        
        // 4-input XOR function
        test_configuration(
            "Triple XOR",
            PATTERN_XOR, PATTERN_XOR, PATTERN_XOR,
            EXPECTED_TRIPLE_XOR
        );
        
        // 4-input NAND function
        test_configuration(
            "Triple NAND",
            PATTERN_NAND, PATTERN_NAND, PATTERN_NAND,
            EXPECTED_TRIPLE_NAND
        );
        
        // 4-input NOR function
        test_configuration(
            "Triple NOR",
            PATTERN_NOR, PATTERN_NOR, PATTERN_NOR,
            EXPECTED_TRIPLE_NOR
        );
        
        // Mixed operations (AND-OR-XOR)
        test_configuration(
            "AND-OR-XOR",
            PATTERN_AND, PATTERN_OR, PATTERN_XOR,
            EXPECTED_AND_OR_XOR
        );
        
        // Majority function
        test_configuration(
            "Majority",
            PATTERN_OR, PATTERN_OR, PATTERN_AND,
            EXPECTED_MAJORITY
        );
        
        // 2-to-1 MUX
        test_configuration(
            "2-to-1 MUX",
            PATTERN_MUX_AND, PATTERN_MUX_SEL, PATTERN_MUX_OR,
            EXPECTED_MUX_2TO1
        );
        
        // Full adder
        test_configuration(
            "Full Adder",
            PATTERN_FULL_ADD_XOR, PATTERN_FULL_ADD_AND, PATTERN_FULL_ADD_XOR,
            EXPECTED_FULL_ADDER
        );
        
        // Two * 2-input OR and constant 1
        test_configuration(
            "Dual 2-input Functions",
            PATTERN_OR, PATTERN_OR, PATTERN_CONST_1,
            EXPECTED_DUAL_OR2_CONST1
        );

        // Two * 2-input AND and constant 0
        test_configuration(
            "Dual 2-input Functions",
            PATTERN_AND, PATTERN_AND, PATTERN_CONST_0,
            EXPECTED_DUAL_AND2_CONST1
        );
        
        // A 2-input NOR, A 2-input XOR and constant 1
        test_configuration(
            "Dual 2-input Functions",
            PATTERN_NOR, PATTERN_XOR, PATTERN_CONST_1,
            EXPECTED_DUAL_AND2_CONST1
        );
        
        // Logic function with 3 inputs and 1 passthrough
        test_configuration(
            "3-input with Passthrough",
            PATTERN_AND, PATTERN_AND, PATTERN_PASSTHROUGH,
            EXPECTED_3INPUT_PASSTHROUGH
        );
        
        // All tests passed
        $display("All LUTU functional tests PASSED!");
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("lutu_test.vcd");
        $dumpvars(0, lutu_test);
    end
    
endmodule
