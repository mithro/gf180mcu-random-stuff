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
    input  wire prog_dat0,
    input  wire prog_dat1,
    input  wire prog_dat2,
    input  wire prog_cap0,
    input  wire prog_cap1
);

    // Storage elements that drive buffer enables
    wire [0:6] q;  // Output from store_3x2 modules
    
    // Using store_3x2 for the first chain
    store_3x2 prog0_store (
        .dat0(prog_dat0),   // Data input for row 0
        .dat1(prog_dat1),   // Data input for row 1
        .dat2(prog_dat2),   // Data input for row 2 
        .cap0(prog_cap0),   // Capture data for column 0
        .cap1(prog_cap1),   // Capture data for column 1
        .out({q[0], q[1], q[2], q[3], q[4], q[5]})  // Stored data output
    );

    // 6 tristate buffers, each enabled by an output from the store module
    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf0 (
        .I(in[0]),
        .EN(q[0]),
        .Z(out[0])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf1 (
        .I(in[1]),
        .EN(q[1]),
        .Z(out[1])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf2 (
        .I(in[2]),
        .EN(q[2]),
        .Z(out[2])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf3 (
        .I(in[3]),
        .EN(q[3]),
        .Z(out[3])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf4 (
        .I(in[4]),
        .EN(q[4]),
        .Z(out[4])
    );

    gf180mcu_fd_sc_mcu7t5v0__bufz_4 buf5 (
        .I(in[5]),
        .EN(q[5]),
        .Z(out[5])
    );

endmodule
