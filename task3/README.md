# Task 3

## Overview

In Task 2 we had to generate a dual-port ram and use this to display an audio signal and then the RAMs signal with a delay. The delay is done in the same way as with the dual-port rom. We now also need the ability to write to the RAM.

## Process

### Creating dual-port RAM

To read and write to the RAM, we need a lot more inputs and enabled signals to know when we are and aren't reading and/or writing.

This is done like this:

```SV
module ram2ports #(
    parameter ADDRESS_WIDTH = 8,
              DATA_WIDTH    = 8
)(
    input  logic                     clk,
    input  logic                     wr_en,
    input  logic                     rd_en,
    input  logic [ADDRESS_WIDTH-1:0] wr_addr,
    input  logic [ADDRESS_WIDTH-1:0] rd_addr,
    input  logic [DATA_WIDTH-1:0]    din,
    output logic [DATA_WIDTH-1:0]    dout
);

logic [DATA_WIDTH-1:0] ram_array [2**ADDRESS_WIDTH-1:0];

always_ff @(posedge clk) begin
    if (wr_en == 1'b1)
        ram_array[wr_addr] <= din;

    if (rd_en == 1'b1)
        // output is synchronous
        dout <= ram_array[rd_addr];
end

endmodule
```

As you can see, the `ram_array` has not changed. The logic in the `always_ff` just writes at the write address if `wr_en` is high, and reads at the read address if `rd_en` is high.

### Connecting with new top

The top module now needs all these new input and outputs and will use an offset to always read a bit behind where we are writing to.

```SV
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
```

### Testbench

The testbench was provided for us but it uses the following functions to initialise the on board microphone and to return the mic signals:

```cpp
// intialize variables for analogue output
  vbdInitMicIn(RAM_SZ);
  
  // ask Vbuddy to return the next audio sample
  top->mic_signal = vbdMicValue();
```