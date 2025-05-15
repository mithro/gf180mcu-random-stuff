// pbuf_test.v - Test bench for the pbuf6 module
`timescale 1ns/10ps

module pbuf_test;
    // Inputs
    reg [5:0] in;
    reg prog_in;
    reg prog_clk0;
    reg prog_clk1;
    
    // Outputs
    wire [5:0] out;
    wire prog_out;
    
    // Instantiate the Unit Under Test (UUT)
    pbuf6 uut (
        .in(in),
        .out(out),
        .prog_in(prog_in),
        .prog_out(prog_out),
        .prog_clk0(prog_clk0),
        .prog_clk1(prog_clk1)
    );
    
    // Initial block for test stimulus
    initial begin
        // Initialize inputs
        in = 6'b000000;
        prog_in = 0;
        prog_clk0 = 0;
        prog_clk1 = 0;
        
        // Wait for global reset
        #100;
        
        // Dump signals for waveform viewing
        $dumpfile("pbuf_test.vcd");
        $dumpvars(0, pbuf_test);
        
        // Apply test vectors
        // Test 1: Program the shift register with 6'b101010
        // Meaning buffers 0, 2, and 4 will be enabled
        
        // First shift in a 1
        prog_in = 1;
        #10 prog_clk0 = 1;
        #10 prog_clk0 = 0;
        prog_in = 0;
        
        // Shift it through to q1
        #10 prog_clk1 = 1;
        #10 prog_clk1 = 0;
        
        // Shift in a 1 again for q2
        prog_in = 1;
        #10 prog_clk0 = 1;
        #10 prog_clk0 = 0;
        prog_in = 0;
        
        // Shift it through to q3
        #10 prog_clk1 = 1;
        #10 prog_clk1 = 0;
        
        // Shift in a 1 again for q4
        prog_in = 1;
        #10 prog_clk0 = 1;
        #10 prog_clk0 = 0;
        prog_in = 0;
        
        // Shift it through to q5
        #10 prog_clk1 = 1;
        #10 prog_clk1 = 0;
        
        // Now test the tristate buffers
        // Apply inputs
        in = 6'b111111;
        #20;
        
        // Change input pattern and check outputs
        in = 6'b010101;
        #20;
        
        // Another test pattern
        in = 6'b101010;
        #20;
        
        // Reset all inputs
        in = 6'b000000;
        #20;
        
        $display("Test completed");
        $finish;
    end
    
    // Monitor block to display signals
    initial begin
        $monitor("Time=%0t, in=%b, out=%b, prog_out=%b", 
                 $time, in, out, prog_out);
    end
endmodule