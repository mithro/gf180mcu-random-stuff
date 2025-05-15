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
module pmux4 (
    // Multipled lines
    input  wire [1:0] in,
    output wire out,
    // Programmable control
    input  wire prog_in,
    output wire prog_out,
    input  wire prog_clk0,
    input  wire prog_clk1
);

    // Internal wires to connect flip-flop outputs
    wire q0, q1, q2, q3;

    wire mux_out;

    // 4 D flip-flops connected as a shift register
    // Even-numbered flip-flops (dff0, dff2) use prog_clk0
    // Odd-numbered flip-flops (dff1, dff3) use prog_clk1

    gf180mcu_fd_sc_mcu7t5v0__dffq_1 dff0 (
        .D(prog_in),
        .CLK(prog_clk0),
        .Q(q0)
    );

    gf180mcu_fd_sc_mcu7t5v0__dffq_1 dff1 (
        .D(q0),
        .CLK(prog_clk1),
        .Q(q1)
    );

    // Even-numbered flip-flops (dff0, dff2) use prog_clk0
    gf180mcu_fd_sc_mcu7t5v0__dffq_1 dff2 (
        .D(q1),
        .CLK(prog_clk0),
        .Q(q2)
    );

    // Odd-numbered flip-flops (dff1, dff3) use prog_clk1
    gf180mcu_fd_sc_mcu7t5v0__dffq_1 dff3 (
        .D(q2),
        .CLK(prog_clk1),
        .Q(q3)
    );

    // Connect the last flip-flop output to prog_out
    assign prog_out = q3;

    // 4-to-1 multiplexer
    gf180mcu_fd_sc_mcu7t5v0__mux4_1 mux (
        .I0(q0),
        .I1(q1),
        .I2(q2),
        .I3(q3),
        .S0(in[0]),
        .S1(in[1]),
        .Z(mux_out)
    );

    // Output driver
    gf180mcu_fd_sc_mcu7t5v0__inv_12 inv (
        .I(mux_out),
        .O(out)
    );

endmodule