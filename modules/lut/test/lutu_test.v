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
        
        // Configuration 1: All AND gates
        test_configuration(
            "Triple AND",
            PATTERN_AND, PATTERN_AND, PATTERN_AND,
            EXPECTED_TRIPLE_AND
        );
        
        // Configuration 2: All OR gates
        test_configuration(
            "Triple OR",
            PATTERN_OR, PATTERN_OR, PATTERN_OR,
            EXPECTED_TRIPLE_OR
        );
        
        // Configuration 3: All XOR gates
        test_configuration(
            "Triple XOR",
            PATTERN_XOR, PATTERN_XOR, PATTERN_XOR,
            EXPECTED_TRIPLE_XOR
        );
        
        // Configuration 4: Mixed operations (AND-OR-XOR)
        test_configuration(
            "AND-OR-XOR",
            PATTERN_AND, PATTERN_OR, PATTERN_XOR,
            EXPECTED_AND_OR_XOR
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
