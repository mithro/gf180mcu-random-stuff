// Description: "Programmable" 4-to-1 multiplexer
// 
//                     <--------- 32.48 um ----->
// +========+========+ +========================+
// | mux4_1 | inv_12 | | 17.92 um    | 14.56 um |
// +--------+--------+ +------------++----------+
// | dffq_1 | dffq_1 | | 16.24 um   | 16.24 um  |
// +--------+--------+ +------------++----------+
// | dffq_1 | dffq_1 | | 16.24 um   | 16.24 um  |
// +========+========+ +========================+
//
// LUT4 Usage Guide:
// This module can act as a 2-input lookup table (LUT4) to implement various logic functions.
// Input values 'in[1:0]' are used as select lines for the 4-to-1 multiplexer.
// The store4 module holds the programmable LUT values.
// 
// Truth table for input combinations (in[1:0]) and which store4 bit is selected:
// +--------+--------+-----------------+
// | in[1]  | in[0]  | Selected Value  |
// +--------+--------+-----------------+
// |   0    |   0    |      q[0]       |
// |   0    |   1    |      q[1]       |
// |   1    |   0    |      q[2]       |
// |   1    |   1    |      q[3]       |
// +--------+--------+-----------------+
//
// Common 2-input Logic Functions:
// 1. AND (A & B):
//    - Set q = 4'b0001 (0x1)
//    - Truth table: output = 1 only when in[1]=1 AND in[0]=1
//
// 2. OR (A | B):
//    - Set q = 4'b0111 (0x7)
//    - Truth table: output = 1 when either in[1]=1 OR in[0]=1 (or both)
//
// 3. XOR (A ^ B):
//    - Set q = 4'b0110 (0x6)
//    - Truth table: output = 1 when in[1] XOR in[0] = 1
//
// 4. NAND (!(A & B)):
//    - Set q = 4'b1110 (0xE)
//    - Truth table: output = 0 only when in[1]=1 AND in[0]=1
//
// 5. NOR (!(A | B)):
//    - Set q = 4'b1000 (0x8)
//    - Truth table: output = 1 only when in[1]=0 AND in[0]=0
//
// 6. XNOR (!(A ^ B)):
//    - Set q = 4'b1001 (0x9)
//    - Truth table: output = 1 when in[1] equals in[0]
//
// 7. Buffer (A):
//    - Set q = 4'b0101 (0x5)
//    - Truth table: output = in[0] regardless of in[1]
//
// 8. Inverted Buffer (!A):
//    - Set q = 4'b1010 (0xA)
//    - Truth table: output = !in[0] regardless of in[1]
//
// Programming sequence:
// To program the LUT, load the 4-bit pattern through prog_dat0/prog_dat1 and 
// capture using prog_cap0/prog_cap1 according to the store4 documentation.
//
module pmux4 (
    // Multipled lines
    input  wire [1:0] in,
    output wire out,
    // Programmable control
    input  wire prog_dat0,
    output wire prog_dat1,
    input  wire prog_cap0,
    input  wire prog_cap1
);
    
    wire [0:3] q; // Wire to store the 4 bits from store4
    store4 storage (
        .dat0(prog_dat0),
        .dat1(prog_dat1),
        .cap0(prog_cap0),
        .cap1(prog_cap1),
        .out(q)
    );
    
    // 4-to-1 multiplexer
    wire mux_out; // Output driver
    gf180mcu_fd_sc_mcu7t5v0__mux4_1 mux (
        .I0(q[0]),
        .I1(q[1]),
        .I2(q[2]),
        .I3(q[3]),
        .S0(in[0]),
        .S1(in[1]),
        .Z(mux_out)
    );
    
    gf180mcu_fd_sc_mcu7t5v0__inv_12 inv (
        .I(mux_out),
        .O(out)
    );

endmodule