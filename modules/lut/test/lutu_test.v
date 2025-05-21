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
    // First mux (out[0]) control patterns
    localparam [3:0] PATTERN_MUX1_AND  = 4'b1000; // AND of in[0] and in[1]
    localparam [3:0] PATTERN_MUX1_OR   = 4'b1110; // OR of in[0] and in[1]
    localparam [3:0] PATTERN_MUX1_XOR  = 4'b0110; // XOR of in[0] and in[1]
    
    // Second mux (out[1]) control patterns
    localparam [3:0] PATTERN_MUX2_AND  = 4'b1000; // AND of in[2] and in[3]
    localparam [3:0] PATTERN_MUX2_OR   = 4'b1110; // OR of in[2] and in[3]
    localparam [3:0] PATTERN_MUX2_XOR  = 4'b0110; // XOR of in[2] and in[3]
    
    // Third mux (out[2]) control patterns
    localparam [3:0] PATTERN_MUX3_AND  = 4'b1000; // AND of out[0] and out[1]
    localparam [3:0] PATTERN_MUX3_OR   = 4'b1110; // OR of out[0] and out[1]
    localparam [3:0] PATTERN_MUX3_XOR  = 4'b0110; // XOR of out[0] and out[1]
    
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
            PATTERN_MUX1_AND, PATTERN_MUX2_AND, PATTERN_MUX3_AND,
            EXPECTED_TRIPLE_AND
        );
        
        // Configuration 2: All OR gates
        test_configuration(
            "Triple OR",
            PATTERN_MUX1_OR, PATTERN_MUX2_OR, PATTERN_MUX3_OR,
            EXPECTED_TRIPLE_OR
        );
        
        // Configuration 3: All XOR gates
        test_configuration(
            "Triple XOR",
            PATTERN_MUX1_XOR, PATTERN_MUX2_XOR, PATTERN_MUX3_XOR,
            EXPECTED_TRIPLE_XOR
        );
        
        // Configuration 4: Mixed operations (AND-OR-XOR)
        test_configuration(
            "AND-OR-XOR",
            PATTERN_MUX1_AND, PATTERN_MUX2_OR, PATTERN_MUX3_XOR,
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
