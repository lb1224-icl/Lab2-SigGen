module sigdelay #(
    parameter ADDRESS_WIDTH = 9,
              DATA_WIDTH    = 8
)(
    input  logic                     clk,
    input  logic                     rst,
    input  logic                     wr,
    input  logic                     rd,
    input  logic [DATA_WIDTH-1:0]    mic_signal,     // input audio sample
    input  logic [ADDRESS_WIDTH-1:0] offset,         // delay offset
    output logic [DATA_WIDTH-1:0]    delayed_signal  // delayed output
);

    // Internal wires
    logic [ADDRESS_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0]    ram_out;

    counter #(ADDRESS_WIDTH) addrCounter (
        .clk   (clk),
        .rst   (rst),
        .en    (1'b1),
        .count (address)
    );

    ram2ports #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) delayRAM (
        .clk     (clk),
        .wr_en   (wr),
        .rd_en   (rd),
        .wr_addr (address),
        .rd_addr (address - offset),  // delayed read address
        .din     (mic_signal),
        .dout    (ram_out)
    );

    // Connect delayed output
    assign delayed_signal = ram_out;

endmodule
