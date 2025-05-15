// Description: "Programmable" tristate buffer array.
//
// Contains 6 "programmable" tristate buffers.
//
// +========+========+ +======================+
// | bufz_4 | dffq_1 | | 12.32 um |  12.32 um |
// +--------+--------+ +----------+-+---------+
// | dffq_1 | bufz_4 | | 16.24 um   |16.24 um |
// +--------+--------+ +----------+-+---------+
// | bufz_4 | dffq_1 | | 12.32 um |  12.32 um |
// +--------+--------+ +----------+-+---------+
// | dffq_1 | bufz_4 | | 16.24 um   |16.24 um |
// +--------+--------+ +----------+-+---------+
// | bufz_4 | dffq_1 | | 12.32 um |  12.32 um |
// +--------+--------+ +----------+-+---------+
// | dffq_1 | bufz_1 | | 16.24 um   |16.24 um |
// +========+========+ +======================+
//
module pbuf6 (
    // Buffered lines
    input  wire [5:0] in,
    output wire [5:0] out,
    // Programmable control
    input  wire prog_in,
    output wire prog_out,
    input  wire prog_clk0,
    input  wire prog_clk1
);

    // Internal wires to connect flip-flop outputs
    wire q0, q1, q2, q3, q4, q5;

    // 6 D flip-flops connected as a shift register
    // Even-numbered flip-flops (dff0, dff2, dff4) use prog_clk0
    // Odd-numbered flip-flops (dff1, dff3, dff5) use prog_clk1

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

    // Even-numbered flip-flops (dff0, dff2, dff4) use prog_clk0
    gf180mcu_fd_sc_mcu7t5v0__dffq_1 dff4 (
        .D(q3),
        .CLK(prog_clk0),
        .Q(q4)
    );

    // Odd-numbered flip-flops (dff1, dff3, dff5) use prog_clk1
    gf180mcu_fd_sc_mcu7t5v0__dffq_1 dff5 (
        .D(q4),
        .CLK(prog_clk1),
        .Q(q5)
    );

    // Connect the last flip-flop output to prog_out
    assign prog_out = q5;

    // 6 tristate buffers, each enabled by a flip-flop output
    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf0 (
        .I(in[0]),
        .EN(q0),
        .Z(out[0])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf1 (
        .I(in[1]),
        .EN(q1),
        .Z(out[1])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf2 (
        .I(in[2]),
        .EN(q2),
        .Z(out[2])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf3 (
        .I(in[3]),
        .EN(q3),
        .Z(out[3])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf4 (
        .I(in[4]),
        .EN(q4),
        .Z(out[4])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf5 (
        .I(in[5]),
        .EN(q5),
        .Z(out[5])
    );

endmodule
