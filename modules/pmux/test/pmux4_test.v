// Description: Testbench for pmux4 module testing all logic functions
//              described in the pmux4 documentation.
//              Note: The pmux4 includes an output inverter, so the expected
//              output is the inverse of what would be selected by the multiplexer.
`timescale 1ns/1ps

module pmux4_test;
    // Inputs
    reg [1:0] in;
    reg prog_dat0;
    reg prog_dat1;
    reg prog_cap0;
    reg prog_cap1;
    
    // Outputs
    wire out;
    
    // Instantiate the DUT (Device Under Test)
    pmux4 dut (
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
    localparam [3:0] EXPECT_NOT   = 4'b1010; // Expected Inverted Buffer output (inverted from pattern)
    
    // Function to program the pmux4 with a specific pattern
    task program_pmux4;
        input [3:0] pattern;
        begin
            // Program col0
            prog_dat0 = pattern[0];
            prog_dat1 = pattern[2];
            prog_cap0 = 1;
            #10 prog_cap0 = 0;
            #10;
            
            // Program col1
            prog_dat0 = pattern[1];
            prog_dat1 = pattern[3];
            prog_cap1 = 1;
            #10 prog_cap1 = 0;
            #10;
        end
    endtask
    
    // Function to check the output against expected value
    task check_output;
        input [1:0] input_val;
        input expected;
        begin
            in = input_val;
            #10;
            if (out == expected)
                $display("PASS: in=%b, out=%b, expected=%b", in, out, expected);
            else
                $display("FAIL: in=%b, out=%b, expected=%b", in, out, expected);
        end
    endtask
    
    // Function to test a specific logic function
    task test_function;
        input [3:0] mux_pattern;    // Pattern to program into the mux
        input [3:0] expected_bits;  // Expected output bits after inversion
        input [1023:0] function_name; // Wide enough for a string
        begin
            $display("\nTesting %s function:", function_name);
            $display("  MUX pattern=%b / 0x%h", mux_pattern, mux_pattern);
            $display("  Expected output=%b / 0x%h (after inversion)", expected_bits, expected_bits);
            
            program_pmux4(mux_pattern);
            
            // Test all input combinations with their expected outputs
            check_output(2'b00, expected_bits[0]);
            check_output(2'b01, expected_bits[1]);
            check_output(2'b10, expected_bits[2]);
            check_output(2'b11, expected_bits[3]);
        end
    endtask
    
    // Initial block
    initial begin
        // Initialize inputs
        in = 2'b00;
        prog_dat0 = 0;
        prog_dat1 = 0;
        prog_cap0 = 0;
        prog_cap1 = 0;
        
        // Wait for global reset
        #100;
        
        // Test all the logic functions described in the documentation
        // For each function, provide both the pattern to program and the expected outputs
        test_function(PATTERN_AND,  EXPECT_AND,  "AND");
        test_function(PATTERN_OR,   EXPECT_OR,   "OR");
        test_function(PATTERN_XOR,  EXPECT_XOR,  "XOR");
        test_function(PATTERN_NAND, EXPECT_NAND, "NAND");
        test_function(PATTERN_NOR,  EXPECT_NOR,  "NOR");
        test_function(PATTERN_XNOR, EXPECT_XNOR, "XNOR");
        test_function(PATTERN_BUF,  EXPECT_BUF,  "Buffer");
        test_function(PATTERN_NOT,  EXPECT_NOT,  "Inverted Buffer");
        
        // Additional demonstration: Custom logic function
        // Pattern 0x2 (0010) produces output 0xD (1101) after inversion
        test_function(4'b0010, 4'b1101, "Custom Function (0010 -> output 1101)");
        
        // Finish simulation
        #100;
        $display("\nAll tests completed");
        $finish;
    end
    
    // Optional: Generate VCD waveform file
    initial begin
        $dumpfile("pmux4_test.vcd");
        $dumpvars(0, pmux4_test);
    end
    
endmodule
