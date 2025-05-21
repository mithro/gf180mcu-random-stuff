// Description: LUTU - Universal Look-Up Table with 4-input selects and 3 outputs
//
// Architecture:
// This module implements a universal LUT structure with:
// - 4-bit input (in[3:0])
// - 3-bit output (out[2:0])
// - Programmable configuration with prog_dat and prog_cap
//
// ## Implementation
// - Three store_2x2 modules (each storing 4 bits) controlled by programmable
//   inputs
// - Three 4-to-1 multiplexers arranged in a hierarchical structure:
//   * mux1: takes in[1:0] as select signals, output drives out[0]
//   * mux2: takes in[3:2] as select signals, output drives out[1]
//   * mux3: takes out[0:1] as select signals, output drives out[2]
//
// ## Programmable Logic Functions
//
// The LUT can implement various 4-input logic functions through programmed
// patterns.
// 
// 1. Logic functions with 4 inputs:
//    - 4-input AND:  Pattern 4'b1000 in all three LUTs
//    - 4-input OR:   Pattern 4'b1110 in all three LUTs
//    - 4-input XOR:  Pattern 4'b0110 in all three LUTs
//    - 4-input NAND: Patterns 4'b1000, 4'b1000, 4'b0111
//    - 4-input NOR:  Patterns 4'b1110, 4'b1110, 4'b0001
//
// 2. Two logic functions with 2 inputs (and 1 constant):
//    - out[1] = in[0] XX in[1] (XX is the logic function).
//    - out[2] = in[2] XX in[3] (XX is the logic function).
//    - out[0] can be any constant (0 or 1)
//
// 3. Logic functions with 3 inputs (and 1 passthrough):
//    - out[0] = in[0] XX in[1] XX in[2] (XX is the logic function).
//    - out[1] = in[3]
//
// 3. Complex Functions:
//    - Any function expressible as a combination of two 2-input functions
//      followed by another 2-input function of their results including:
//       * AOI21 - AND-OR-Invert: Pattern 4'b1110, 4'b1110, 4'b0001
//       * OAI21 - OR-AND-Invert: Pattern 4'b1110, 4'b1110, 4'b0001
//
//    - Majority Function (outputs 1 when more than half inputs are 1):
//      * LUT1: 4'b1110 (OR of in[1:0])
//      * LUT2: 4'b1110 (OR of in[3:2])
//      * LUT3: 4'b1000 (AND of the two OR results)
//
//    - 2-to-1 Multiplexer with control:
//          - in[0] and in[3] are data inputs
//          - in[2] is the select signal
//          - in[1] is ignored
//          - Function: IF in[2]=0 THEN out[2]=in[0]&in[1] ELSE out[2]=in[3]
//      * LUT1: 4'b1000 (AND of in[1:0])
//      * LUT2: 4'b0100 (AND of in[3] with NOT in[2])
//      * LUT3: 4'b1110 (OR of the two AND results)
//
//    - Can implement 16^3 = 4096 different functions through pattern
//      combinations
//    
// 3. Advanced Example Patterns:
//    - Priority Encoder:
//      * LUT1: 4'b0100 (in[1] AND NOT in[0])
//      * LUT2: 4'b1100 (in[3] OR (in[2] AND NOT in[3]))
//      * LUT3: Custom pattern based on priority rules
//
//    - Full Adder (Sum of 3 inputs):
//          - in[0] and in[1] are the first two addends
//          - in[2] is the third addend (or carry-in)
//          - in[3] is tied to 1 or 0 depending on configuration
//          - Function: out[2] = in[0] XOR in[1] XOR in[2] (sum output)
//      * LUT1: 4'b0110 (XOR of in[1:0])
//      * LUT2: 4'b1000 (AND of in[2:3])
//      * LUT3: 4'b0110 (XOR of the two results)
//      * Can also generate carry-out via out[0] or out[1] with appropriate patterns
//
// Programming:
// The LUT is programmed by loading 4-bit patterns into each of the three muxes
// using the prog_dat and prog_cap signals
module lutu (
    // Multipled lines
    input  wire [3:0] in,
    output wire [2:0] out,
    // Programmable control
    input  wire [3:0] prog_dat,
    input  wire [3:0] prog_cap,
);
    
    wire [0:3] q1; // Wire to store the 4 bits from store_2x2
    store_2x2 storage1 (
        .dat0(prog_dat[0]),
        .dat1(prog_dat[1]),
        .cap0(prog_cap[0]),
        .cap1(prog_cap[1]),
        .out(q1)
    );

    wire [0:3] q2;
    store_2x2 storage2 (
        .dat0(prog_dat[2]),
        .dat1(prog_dat[3]),
        .cap0(prog_cap[0]),
        .cap1(prog_cap[1]),
        .out(q2)
    );

    wire [0:3] q3;
    store_2x2 storage3 (
        .dat0(prog_dat[0]),
        .dat1(prog_dat[1]),
        .cap0(prog_cap[2]),
        .cap1(prog_cap[3]),
        .out(q3)
    );

    // 4-to-1 multiplexer
    gf180mcu_fd_sc_mcu7t5v0__mux4_1 mux1 (
        .I0(q1[0]),
        .I1(q1[1]),
        .I2(q1[2]),
        .I3(q1[3]),
        .S0(in[0]),
        .S1(in[1]),
        .Z(out[0])
    );

    gf180mcu_fd_sc_mcu7t5v0__mux4_1 mux2 (
        .I0(q2[0]),
        .I1(q2[1]),
        .I2(q2[2]),
        .I3(q2[3]),
        .S0(in[2]),
        .S1(in[3]),
        .Z(out[1])
    );
    
    gf180mcu_fd_sc_mcu7t5v0__mux4_1 mux3 (
        .I0(q3[0]),
        .I1(q3[1]),
        .I2(q3[2]),
        .I3(q3[3]),
        .S0(out[0]),
        .S1(out[1]),
        .Z(out[2])
    );

endmodule
