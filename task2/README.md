# Task 2

## Overview

In Task 2 we had to generate a dual-port rom and use this to display two sin waves with a phase between them controlled by `vbdValue()`

## Process

### Creating dual-port ROM

In an identical manner to the single-port ROM, the dual-port ROM creates 2 rom arrays of address size `[2**ADDRESS_WIDTH-1:0]` each storing data of size `[DATA_WIDTH-1:0]`. The only difference is we require two outputs and 2 addresses.

The full SV file is shown below:

```SV
module rom2ports #(
    parameter ADDRESS_WIDTH = 8, DATA_WIDTH = 8

)(
    input logic clk,
    input logic [ADDRESS_WIDTH-1:0] addrA,
    input logic [ADDRESS_WIDTH-1:0] addrB,
    output logic [DATA_WIDTH-1:0] doutA,
    output logic [DATA_WIDTH-1:0] doutB
);

logic [DATA_WIDTH-1:0] rom_array [2**ADDRESS_WIDTH-1:0];

initial begin
    $display("Loading ROM");
    $readmemh("sinerom.mem", rom_array);
end;

always_ff @(posedge clk) begin
    doutA <= rom_array[addrA];
    doutB <= rom_array[addrB];
end
endmodule
```

### Editing the top file

The counter does not need to change. Instead the top `sinegen` file now needs to use the step as the phase between the two addresses. Therefore when one address is `count` the other is `count + step`. This will create the phase.

```SV
module sinegen #(
    parameter A_WIDTH = 8,
              D_WIDTH = 8
)(
    input  logic             clk,    
    input  logic             rst,    
    input  logic             en, 
    input  logic [D_WIDTH-1:0] step, 
    output logic [D_WIDTH-1:0] doutA,
    output logic [D_WIDTH-1:0] doutB 
);

logic [A_WIDTH-1:0] address;     // interconnect wire as can't go straight between modules

counter addrCounter (
    .clk   (clk),
    .rst   (rst),
    .en    (en),
    .count (address)
);

rom2ports #(8, 8) sineRom (
    .clk  (clk),
    .addrA (address),
    .addrB (address + step),
    .doutA (doutA),
    .doutB (doutB)
);

endmodule
```

### Changing the test bench

Similarly this now just needs to plot on `vbdPlot()` for both outputs:

```SV
vbdPlot(int(sinegen->doutA), 0, 255);
vbdPlot(int(sinegen->doutB), 0, 255);
```
