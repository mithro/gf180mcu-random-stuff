// store4_test.v - Test bench for the store4 module
`timescale 1ns/10ps

module store4_test;
    // Inputs
    reg dat0;
    reg dat1;
    reg cap0;
    reg cap1;
    
    // Outputs
    wire [0:3] out;
    
    // Error tracking
    integer error_count = 0;
    
    // Instantiate the Unit Under Test (UUT)
    store4 uut (
        .dat0(dat0),
        .dat1(dat1),
        .cap0(cap0),
        .cap1(cap1),
        .out(out)
    );
    
    // Task to capture data in latch r0c0 (out[0])
    task capture_r0c0;
        input data_value;
        begin
            // Set data to capture
            dat0 = data_value;
            
            // Activate capture line for column 0
            #10 cap0 = 1;
            #10 cap0 = 0;
            
            // Verify output matches captured value
            #10;
            if (out[0] !== data_value) begin
                $display("ERROR: out[0] = %b, expected %b", out[0], data_value);
                error_count = error_count + 1;
            end else
                $display("Successfully captured %b in out[0]", data_value);
        end
    endtask
    
    // Task to capture data in latch r0c1 (out[1])
    task capture_r0c1;
        input data_value;
        begin
            // Set data to capture
            dat0 = data_value;
            
            // Activate capture line for column 1
            #10 cap1 = 1;
            #10 cap1 = 0;
            
            // Verify output matches captured value
            #10;
            if (out[1] !== data_value) begin
                $display("ERROR: out[1] = %b, expected %b", out[1], data_value);
                error_count = error_count + 1;
            end else
                $display("Successfully captured %b in out[1]", data_value);
        end
    endtask
    
    // Task to capture data in latch r1c0 (out[2])
    task capture_r1c0;
        input data_value;
        begin
            // Set data to capture
            dat1 = data_value;
            
            // Activate capture line for column 0
            #10 cap0 = 1;
            #10 cap0 = 0;
            
            // Verify output matches captured value
            #10;
            if (out[2] !== data_value) begin
                $display("ERROR: out[2] = %b, expected %b", out[2], data_value);
                error_count = error_count + 1;
            end else
                $display("Successfully captured %b in out[2]", data_value);
        end
    endtask
    
    // Task to capture data in latch r1c1 (out[3])
    task capture_r1c1;
        input data_value;
        begin
            // Set data to capture
            dat1 = data_value;
            
            // Activate capture line for column 1
            #10 cap1 = 1;
            #10 cap1 = 0;
            
            // Verify output matches captured value
            #10;
            if (out[3] !== data_value) begin
                $display("ERROR: out[3] = %b, expected %b", out[3], data_value);
                error_count = error_count + 1;
            end else
                $display("Successfully captured %b in out[3]", data_value);
        end
    endtask
    
    // Task to verify output stability when capture lines are inactive
    task verify_output_stability;
        reg [0:3] expected_value;
        begin
            // Save current outputs
            expected_value = out;
            
            // Toggle data inputs
            dat0 = ~dat0;
            dat1 = ~dat1;
            #20;
            
            // Verify outputs remain unchanged
            if (out !== expected_value) begin
                $display("ERROR: Output changed when capture lines were inactive! Expected %b, got %b", expected_value, out);
                error_count = error_count + 1;
            end else
                $display("Output remains stable at %b when capture lines are inactive", out);
            
            // Toggle data inputs again
            dat0 = ~dat0;
            dat1 = ~dat1;
            #20;
            
            // Verify outputs still remain unchanged
            if (out !== expected_value) begin
                $display("ERROR: Output changed when capture lines were inactive! Expected %b, got %b", expected_value, out);
                error_count = error_count + 1;
            end else
                $display("Output remains stable at %b when capture lines are inactive", out);
        end
    endtask
    
    // Task to load a 4-bit pattern into all latches
    task load_pattern;
        input [0:3] pattern;
        begin
            // First, set row inputs for column 0 and capture
            dat0 = pattern[0]; // For r0c0 (out[0])
            dat1 = pattern[2]; // For r1c0 (out[2])
            #10;
            
            // Activate column 0 capture
            cap0 = 1;
            #10 cap0 = 0;
            #10;
            
            // Next, set row inputs for column 1 and capture
            dat0 = pattern[1]; // For r0c1 (out[1])
            dat1 = pattern[3]; // For r1c1 (out[3])
            #10;
            
            // Activate column 1 capture
            cap1 = 1;
            #10 cap1 = 0;
            #10;
            
            // Verify pattern was loaded correctly
            #10;
            if (out !== pattern) begin
                $display("ERROR: Failed to load pattern! Expected %b, got %b", pattern, out);
                error_count = error_count + 1;
            end else
                $display("Successfully loaded pattern %b", pattern);
        end
    endtask
    
    // Initial block for test stimulus
    initial begin
        // Initialize inputs
        dat0 = 0;
        dat1 = 0;
        cap0 = 0;
        cap1 = 0;
        
        // Wait for global reset
        #100;
        
        // Dump signals for waveform viewing
        $dumpfile("store4_test.vcd");
        $dumpvars(0, store4_test);
        
        // STEP 1: Test capturing data in each individual latch
        $display("STEP 1: Testing individual latches");
        
        // Test latch r0c0 (out[0])
        $display("Testing latch r0c0 (out[0])");
        capture_r0c0(1);
        verify_output_stability();
        capture_r0c0(0);
        verify_output_stability();
        
        // Test latch r0c1 (out[1])
        $display("Testing latch r0c1 (out[1])");
        capture_r0c1(1);
        verify_output_stability();
        capture_r0c1(0);
        verify_output_stability();
        
        // Test latch r1c0 (out[2])
        $display("Testing latch r1c0 (out[2])");
        capture_r1c0(1);
        verify_output_stability();
        capture_r1c0(0);
        verify_output_stability();
        
        // Test latch r1c1 (out[3])
        $display("Testing latch r1c1 (out[3])");
        capture_r1c1(1);
        verify_output_stability();
        capture_r1c1(0);
        verify_output_stability();
        
        // STEP 2: Load and verify different patterns
        $display("STEP 2: Testing pattern loading");
        
        // Load pattern 1010
        $display("Loading pattern 1010");
        load_pattern(4'b1010);
        verify_output_stability();
        
        // Load pattern 0101
        $display("Loading pattern 0101");
        load_pattern(4'b0101);
        verify_output_stability();
        
        // Load pattern 1111
        $display("Loading pattern 1111");
        load_pattern(4'b1111);
        verify_output_stability();
        
        // Load pattern 0000
        $display("Loading pattern 0000");
        load_pattern(4'b0000);
        verify_output_stability();
        
        // STEP 3: Test column-wise capturing
        $display("STEP 3: Testing column-wise capturing");
        
        // Set data inputs
        dat0 = 1;
        dat1 = 0;
        #10;
        
        // Capture column 0
        $display("Capturing column 0 (dat0=1, dat1=0)");
        cap0 = 1;
        #10 cap0 = 0;
        #10;
        
        // Check that out[0] and out[2] were updated
        if (out[0] !== 1'b1 || out[2] !== 1'b0) begin
            $display("ERROR: Column 0 capture failed! Expected out[0]=1, out[2]=0, got out[0]=%b, out[2]=%b", out[0], out[2]);
            error_count = error_count + 1;
        end else
            $display("Successfully captured column 0: out[0]=%b, out[2]=%b", out[0], out[2]);
        
        // Verify output stability
        verify_output_stability();
        
        // Set new data inputs
        dat0 = 0;
        dat1 = 1;
        #10;
        
        // Capture column 1
        $display("Capturing column 1 (dat0=0, dat1=1)");
        cap1 = 1;
        #10 cap1 = 0;
        #10;
        
        // Check that out[1] and out[3] were updated
        if (out[1] !== 1'b0 || out[3] !== 1'b1) begin
            $display("ERROR: Column 1 capture failed! Expected out[1]=0, out[3]=1, got out[1]=%b, out[3]=%b", out[1], out[3]);
            error_count = error_count + 1;
        end else
            $display("Successfully captured column 1: out[1]=%b, out[3]=%b", out[1], out[3]);
        
        // Verify output stability
        verify_output_stability();
        
        // Test complete
        $display("Test completed with %0d errors", error_count);
        
        // Exit with error code if errors were detected
        if (error_count > 0) begin
            $display("TEST FAILED");
            $finish(1); // Exit with error code 1
        end else begin
            $display("TEST PASSED");
            $finish(0); // Exit with success code 0
        end
    end
    
    // Monitor block to display signals
    initial begin
        $monitor("Time=%0t, dat0=%b, dat1=%b, cap0=%b, cap1=%b, out=%b", 
                 $time, dat0, dat1, cap0, cap1, out);
    end
endmodule
