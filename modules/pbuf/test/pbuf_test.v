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
    
    // Internal signals for monitoring
    wire q0, q1, q2, q3, q4, q5;
    
    // Instantiate the Unit Under Test (UUT)
    pbuf6 uut (
        .in(in),
        .out(out),
        .prog_in(prog_in),
        .prog_out(prog_out),
        .prog_clk0(prog_clk0),
        .prog_clk1(prog_clk1)
    );
    
    // Assign internal signals for monitoring
    // These assignments are just for visualization in waveform viewer
    // and won't affect the actual circuit behavior
    assign q0 = uut.q0;
    assign q1 = uut.q1;
    assign q2 = uut.q2;
    assign q3 = uut.q3;
    assign q4 = uut.q4;
    assign q5 = uut.q5;
    
    // Task to reset all flip-flops to 0
    task reset_chain;
        begin
            // First make sure we have 0 at the input
            prog_in = 0;

            // First flip-flop
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;

            #10;

            // Second flip-flop
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;

            #10;

            // Third flip-flop
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;

            #10;

            // Fourth flip-flop
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;

            #10;

            // Fifth flip-flop
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;

            #10;

            // Sixth flip-flop
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;

            #10;

            if (prog_out != 1'b0) 
                $display("ERROR: Prog out was not reset");
        end
    endtask
    
    // Task to load all zeros into the flip-flops (convenience function)
    task load_all_zeros;
        begin
            load_pattern(6'b000000);
        end
    endtask
    
    // Task to load a specified bit pattern into the flip-flops
    // The pattern is loaded with LSB (q0) first
    task load_pattern;
        input [5:0] pattern;
        begin
            // Now load the pattern starting from q0 (LSB)
            prog_in = 1;
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("0 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);

            // Now load the pattern starting from q0 (LSB)
            prog_in = pattern[5];
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("0 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);
            
            prog_in = pattern[4];
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("1 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);
            
            prog_in = pattern[3];
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("2 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);
            
            prog_in = pattern[2];
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("3 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);
            
            prog_in = pattern[1];
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("4 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);
            
            prog_in = pattern[0];
            #10 prog_clk0 = 1;
            #10 prog_clk0 = 0;
            #10;
            #10 prog_clk1 = 1;
            #10 prog_clk1 = 0;
            #10;
            $display("5 prog_in=%b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      prog_in, q5, q4, q3, q2, q1, q0);
            
            // Reset prog_in to 0 after pattern is loaded
            prog_in = 0;
            
            // Give time for signals to stabilize
            #20;
            
            // Display the loaded pattern
            $display("Loaded pattern: %b (q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b)", 
                      pattern, q5, q4, q3, q2, q1, q0);
        end
    endtask
    
    // Test a single buffer
    task test_buffer;
        input integer buffer_idx;
        begin
            // Test with input 0
            in = 6'b000000;
            #20;
            $display("Buffer %0d test with input=0: out[%0d]=%b", buffer_idx, buffer_idx, out[buffer_idx]);
            if (out[buffer_idx] !== 1'b0) 
                $display("ERROR: Buffer %0d output mismatch when input=0", buffer_idx);
            
            // Test with input 1
            in[buffer_idx] = 1'b1;  // Set only this buffer's input to 1
            #20;
            $display("Buffer %0d test with input=1: out[%0d]=%b", buffer_idx, buffer_idx, out[buffer_idx]);
            if (out[buffer_idx] !== 1'b1) 
                $display("ERROR: Buffer %0d output mismatch when input=1", buffer_idx);
            
            // Reset input
            in = 6'b000000;
        end
    endtask
    
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
        
        // STEP 1: Load all zeros into flip flops
        $display("STEP 1: Loading all zeros into flip flops");
        reset_chain();
        
        // STEP 2: Verify output doesn't change with input (all buffers disabled)
        $display("STEP 2: Verifying all buffers are disabled with all zeros loaded");
        in = 6'b000000;
        #20;
        if (out !== 6'bzzzzzz) $display("ERROR: Output not high-Z with all buffers disabled (all zeros input)");
        
        in = 6'b111111;
        #20;
        if (out !== 6'bzzzzzz) $display("ERROR: Output not high-Z with all buffers disabled (all ones input)");
        
        // STEP 3: Test each buffer individually
        $display("STEP 3: Testing each buffer individually");
        
        // ------ Test buffer 0 ------
        $display("Testing buffer 0");
        load_pattern(6'b000001);  // Enable only buffer 0 (q0=1)
       /* 
        // Verify q0 is set correctly
        $display("Buffer 0 test: q0=%b", q0);
        test_buffer(0);
        
        // ------ Test buffer 1 ------
        $display("Testing buffer 1");
        load_pattern(6'b000010);  // Enable only buffer 1 (q1=1)
        
        // Verify q1 is set correctly
        $display("Buffer 1 test: q1=%b", q1);
        test_buffer(1);
        
        // ------ Test buffer 2 ------
        $display("Testing buffer 2");
        load_pattern(6'b000100);  // Enable only buffer 2 (q2=1)
        
        // Verify q2 is set correctly
        $display("Buffer 2 test: q2=%b", q2);
        test_buffer(2);
        
        // ------ Test buffer 3 ------
        $display("Testing buffer 3");
        load_pattern(6'b001000);  // Enable only buffer 3 (q3=1)
        
        // Verify q3 is set correctly
        $display("Buffer 3 test: q3=%b", q3);
        test_buffer(3);
        
        // ------ Test buffer 4 ------
        $display("Testing buffer 4");
        load_pattern(6'b010000);  // Enable only buffer 4 (q4=1)
        
        // Verify q4 is set correctly
        $display("Buffer 4 test: q4=%b", q4);
        test_buffer(4);
        
        // ------ Test buffer 5 ------
        $display("Testing buffer 5");
        load_pattern(6'b100000);  // Enable only buffer 5 (q5=1)
        
        // Verify q5 is set correctly
        $display("Buffer 5 test: q5=%b", q5);
        test_buffer(5);
        
        // STEP 4: Final verification - disable all buffers and verify isolation
        $display("STEP 4: Final verification - all buffers disabled");
        reset_chain();
        
        // Try different input patterns, output should remain high-Z
        in = 6'b000000;
        #20;
        if (out !== 6'bzzzzzz) $display("ERROR: Output not high-Z with all buffers disabled");
        
        in = 6'b111111;
        #20;
        if (out !== 6'bzzzzzz) $display("ERROR: Output not high-Z with all buffers disabled");
        
        in = 6'b101010;
        #20;
        if (out !== 6'bzzzzzz) $display("ERROR: Output not high-Z with all buffers disabled");
    */    
        // Test complete
        $display("Test completed successfully");
        $finish;
    end
    
    // Monitor block to display signals
    initial begin
        $monitor("Time=%0t, in=%b, out=%b, prog_out=%b, q0=%b, q1=%b, q2=%b, q3=%b, q4=%b, q5=%b", 
                 $time, in, out, prog_out, q0, q1, q2, q3, q4, q5);
    end
endmodule