// Description: 4 bits of storage.
//
// Contains 4 latches in a row/column configuration.
//
//         col0     col1     
//      +========+========+
// row0 | latq_1 | latq_1 |
//      +--------+--------+
// row1 | latq_1 | latq_1 |
//      +========+========+
//
module store_2x2 (
    input  wire dat0,     // Data input for row 0
    input  wire dat1,     // Data input for row 1
    input  wire cap0,     // Capture data for column 0
    input  wire cap1,     // Capture data for column 1
    output wire [0:3] out  // Stored data output
);

    gf180mcu_fd_sc_mcu7t5v0__latq_1 dff_r0c0 (
        .D(dat0),
        .E(cap0),
        .Q(out[0])
    );

    gf180mcu_fd_sc_mcu7t5v0__latq_1 dff_r0c1 (
        .D(dat0),
        .E(cap1),
        .Q(out[1])
    );

    gf180mcu_fd_sc_mcu7t5v0__latq_1 dff_r1c0 (
        .D(dat1),
        .E(cap0),
        .Q(out[2])
    );

    gf180mcu_fd_sc_mcu7t5v0__latq_1 dff_r1c1 (
        .D(dat1),
        .E(cap1),
        .Q(out[3])
    );

endmodule
