// Description: Testbench for lut2 module testing all logic functions
//              described in the lut2 documentation.
//              Note: The lut2 includes an output inverter, so the expected
//              output is the inverse of what would be selected by the multiplexer.
`timescale 1ns/1ps

module lut2_test;
    // Inputs
    reg [1:0] in;
    reg prog_dat0;
    reg prog_dat1;
    reg prog_cap0;
    reg prog_cap1;
    
    // Outputs
    wire out;
    
    // Instantiate the DUT (Device Under Test)
    lut2 dut (
        .in(in),
        .out(out),
        .prog_dat0(prog_dat0),
        .prog_dat1(prog_dat1),
        .prog_cap0(prog_cap0),
        .prog_cap1(prog_cap1)
    );
    
    // Test parameters
    integer i;
    reg expected_out;
    reg [3:0] mux_pattern;
    reg [3:0] expected_outputs;
    
    // Test function patterns to be programmed into the mux
    // These are the actual bit patterns loaded into the LUT
    localparam [3:0] PATTERN_AND  = 4'b1110; // 0xE - AND implementation pattern
    localparam [3:0] PATTERN_OR   = 4'b1000; // 0x8 - OR implementation pattern
    localparam [3:0] PATTERN_XOR  = 4'b1001; // 0x9 - XOR implementation pattern
    localparam [3:0] PATTERN_NAND = 4'b0001; // 0x1 - NAND implementation pattern
    localparam [3:0] PATTERN_NOR  = 4'b0111; // 0x7 - NOR implementation pattern
    localparam [3:0] PATTERN_XNOR = 4'b0110; // 0x6 - XNOR implementation pattern
    localparam [3:0] PATTERN_BUF  = 4'b1010; // 0xA - Buffer implementation pattern
    localparam [3:0] PATTERN_NOT  = 4'b0101; // 0x5 - Inverted Buffer implementation pattern
    
    // Expected outputs after inversion for each function
    // (Indexed as: [in1,in0] => 00,01,10,11)
    localparam [3:0] EXPECT_AND   = 4'b0001; // Expected AND output (inverted from pattern)
    localparam [3:0] EXPECT_OR    = 4'b0111; // Expected OR output (inverted from pattern)
    localparam [3:0] EXPECT_XOR   = 4'b0110; // Expected XOR output (inverted from pattern)
    localparam [3:0] EXPECT_NAND  = 4'b1110; // Expected NAND output (inverted from pattern)
    localparam [3:0] EXPECT_NOR   = 4'b1000; // Expected NOR output (inverted from pattern)
    localparam [3:0] EXPECT_XNOR  = 4'b1001; // Expected XNOR output (inverted from pattern)
    localparam [3:0] EXPECT_BUF   = 4'b0101; // Expected Buffer output (inverted from pattern)
    localparam [3:0] EXPECT_NOT   = 4'b1010; // Expected NOT output (inverted from pattern)
    
    // Function to program the store_2x2 with a specific pattern
    task program_lut;
        input [3:0] pattern;
        integer j;
        begin
            for (j = 0; j < 4; j = j + 1) begin
                // Set data bits
                prog_dat0 = pattern[j];
                prog_dat1 = pattern[j];
                
                // Pulse capture signals for appropriate bit position
                case (j)
                    0: begin
                        prog_cap0 = 0;
                        prog_cap1 = 0;
                        #5 prog_cap0 = 1;
                        #5 prog_cap0 = 0;
                    end
                    1: begin
                        prog_cap0 = 0;
                        prog_cap1 = 0;
                        #5 prog_cap0 = 1; prog_cap1 = 1;
                        #5 prog_cap0 = 0; prog_cap1 = 0;
                    end
                    2: begin
                        prog_cap0 = 0;
                        prog_cap1 = 0;
                        #5 prog_cap1 = 1;
                        #5 prog_cap1 = 0;
                    end
                    3: begin
                        prog_cap0 = 0;
                        prog_cap1 = 0;
                        // No capture signals needed for position 3
                    end
                endcase
                
                #5; // Small delay between bits
            end
        end
    endtask
    
    // Function to test a specific logical function
    task test_function;
        input [3:0] pattern;      // Pattern to program into LUT
        input [3:0] expected;     // Expected output for inputs 00,01,10,11
        input [8*10:1] func_name; // Name of function for logging
        begin
            $display("Testing %s function", func_name);
            
            // Program the LUT with the specified pattern
            program_lut(pattern);
            #10; // Wait for programming to settle
            
            // Test all four input combinations
            for (i = 0; i < 4; i = i + 1) begin
                in = i[1:0]; // Set inputs based on test case
                #5; // Wait for output to stabilize
                
                // Check if output matches expected
                expected_out = expected[i];
                if (out !== expected_out) begin
                    $display("FAIL: %s with inputs %b - Expected: %b, Got: %b", 
                             func_name, in, expected_out, out);
                    $finish;
                end else begin
                    $display("PASS: %s with inputs %b - Got: %b", 
                             func_name, in, out);
                end
                #5; // Delay between test cases
            end
            
            $display("%s function test PASSED\n", func_name);
        end
    endtask
    
    // Test sequence
    initial begin
        // Initialize inputs
        in = 2'b00;
        prog_dat0 = 0;
        prog_dat1 = 0;
        prog_cap0 = 0;
        prog_cap1 = 0;
        
        // Wait for global reset
        #100;
        
        // Run tests for all logical functions
        test_function(PATTERN_AND,  EXPECT_AND,  "AND");
        test_function(PATTERN_OR,   EXPECT_OR,   "OR");
        test_function(PATTERN_XOR,  EXPECT_XOR,  "XOR");
        test_function(PATTERN_NAND, EXPECT_NAND, "NAND");
        test_function(PATTERN_NOR,  EXPECT_NOR,  "NOR");
        test_function(PATTERN_XNOR, EXPECT_XNOR, "XNOR");
        test_function(PATTERN_BUF,  EXPECT_BUF,  "BUFFER");
        test_function(PATTERN_NOT,  EXPECT_NOT,  "NOT");
        
        // All tests passed
        $display("All LUT2 functional tests PASSED!");
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("lut2_test.vcd");
        $dumpvars(0, lut2_test);
    end
    
endmodule
