// Description: LUT2 (2-input lookup table)
// 
//
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
