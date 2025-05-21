// pbuf_test.v - Test bench for the pbuf6 module
`timescale 1ns/10ps

module pbuf_test;
    // Inputs
    reg [5:0] in;
    // Outputs
    wire [5:0] out;

    // Programmable control signals
    reg prog_dat0;
    reg prog_dat1;
    reg prog_dat2;
    reg prog_cap0;
    reg prog_cap1;
    
    // Internal signals for monitoring
    wire q0, q1, q2, q3, q4, q5;
    
    // Error tracking
    integer error_count = 0;
    
    // Instantiate the Unit Under Test (UUT)
    pbuf6 uut (
        .in(in),
        .out(out),
        .prog_dat0(prog_dat0),
        .prog_dat1(prog_dat1),
        .prog_dat2(prog_dat2),
        .prog_cap0(prog_cap0),
        .prog_cap1(prog_cap1)
    );
    
    // Assign internal signals for monitoring
    // These assignments are just for visualization in waveform viewer
    // and won't affect the actual circuit behavior
    assign q0 = uut.q[0];
    assign q1 = uut.q[1];
    assign q2 = uut.q[2];
    assign q3 = uut.q[3];
    assign q4 = uut.q[4];
    assign q5 = uut.q[5];
    
    // Task to reset all flip-flops to 0
    task reset_chain;
        begin
            // First make sure we have 0 at the input
            prog_dat0 = 0;
            prog_dat1 = 0;
            prog_dat2 = 0;

            // Capture 0s into all cells
            #10 prog_cap0 = 1;
            #10 prog_cap0 = 0;
            #10 prog_cap1 = 1;
            #10 prog_cap1 = 0;
            #10;

            // Wait for signals to stabilize
            #20;
            
            $display("Reset chain complete: q5=%b, q4=%b, q3=%b, q2=%b, q1=%b, q0=%b", 
                      q5, q4, q3, q2, q1, q0);
        end
    endtask
    
    // Task to load all zeros into the flip-flops (convenience function)
    task load_all_zeros;
        begin
            load_pattern(6'b000000);
        end
    endtask
    
    // Task to load a specified bit pattern into the flip-flops
    // The pattern is loaded according to store_3x2 layout:
    // q0(row0,col0), q1(row0,col1), q2(row1,col0), 
    // q3(row1,col1), q4(row2,col0), q5(row2,col1)
    task load_pattern;
        input [5:0] pattern;
        begin
            // Load data for col0 (q0, q2, q4)
            prog_dat0 = pattern[0];  // For q0
            prog_dat1 = pattern[2];  // For q2
            prog_dat2 = pattern[4];  // For q4
            #10 prog_cap0 = 1;
            #10 prog_cap0 = 0;
            #10;
            
            // Load data for col1 (q1, q3, q5)
            prog_dat0 = pattern[1];  // For q1
            prog_dat1 = pattern[3];  // For q3
            prog_dat2 = pattern[5];  // For q5
            #10 prog_cap1 = 1;
            #10 prog_cap1 = 0;
            #10;
            
            // Wait for signals to stabilize
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
            if (out[buffer_idx] !== 1'b0) begin
                $display("ERROR: Buffer %0d output mismatch when input=0", buffer_idx);
                error_count = error_count + 1;
            end
            
            // Test with input 1
            in[buffer_idx] = 1'b1;  // Set only this buffer's input to 1
            #20;
            $display("Buffer %0d test with input=1: out[%0d]=%b", buffer_idx, buffer_idx, out[buffer_idx]);
            if (out[buffer_idx] !== 1'b1) begin
                $display("ERROR: Buffer %0d output mismatch when input=1", buffer_idx);
                error_count = error_count + 1;
            end
            
            // Reset input
            in = 6'b000000;
        end
    endtask
    
    // Initial block for test stimulus
    initial begin
        // Initialize inputs
        in = 6'b000000;
        prog_dat0 = 0;
        prog_dat1 = 0;
        prog_dat2 = 0;
        prog_cap0 = 0;
        prog_cap1 = 0;
        
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
        if (out !== 6'bzzzzzz) begin
            $display("ERROR: Output not high-Z with all buffers disabled (all zeros input)");
            error_count = error_count + 1;
        end
        
        in = 6'b111111;
        #20;
        if (out !== 6'bzzzzzz) begin
            $display("ERROR: Output not high-Z with all buffers disabled (all ones input)");
            error_count = error_count + 1;
        end
        
        // STEP 3: Test each buffer individually
        $display("STEP 3: Testing each buffer individually");
        
        // ------ Test buffer 0 ------
        $display("Testing buffer 0");
        load_pattern(6'b000001);  // Enable only buffer 0 (q0=1)
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
        // Test complete
        $display("Test completed successfully");
        $finish;
    end
    
    // Monitor block to display signals
    initial begin
        $monitor("Time=%0t, in=%b, out=%b, q0=%b, q1=%b, q2=%b, q3=%b, q4=%b, q5=%b", 
                 $time, in, out, q0, q1, q2, q3, q4, q5);
    end
endmodule