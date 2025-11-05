# Task 1

## Overview

In Task 1 we had to generate a rom, feed it with values from a sin wave, and display it on the vbuddy. We then tested ourselves by adjusting the frequency through `vbdValue()`

## Process

### Creating and loading ROM

A rom is read-only memory and so it gets pre loaded with values that can be read using addresses. To store the values for sin wave, we needed to create a 256 x 8-bit rom.

This is how we made it in SystemVerilog

```SV
module rom #(
    parameter ADDRESS_WIDTH = 8, DATA_WIDTH = 8

)(
    input logic clk,
    input logic [ADDRESS_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);

logic [DATA_WIDTH-1:0] rom_array [2**ADDRESS_WIDTH-1:0];

initial begin
    $display("Loading ROM");
    $readmemh("sinerom.mem", rom_array);
end;

always_ff @(posedge clk)
    dout <= rom_array[addr];

endmodule
```

The `rom_array` is created first with `[DATA_WIDTH-1:0]` bits (8-bit) and there are `[2**ADDRESS_WIDTH-1:0]` different addresses (256)

We initilialise the memory through `initial` and this reads from hte `sinerom.mem` file which is pre filled with sin wave values

## Create the top sinegen.sv

To initialise a rom module and a counter module and connect them, we needed a top level module. We called this `sinegen`. It is needed to connect the count of the counter to the address of the rom.

```SV
module sinegen #(
    parameter A_WIDTH = 8,
              D_WIDTH = 8
)(
    input  logic             clk,    
    input  logic             rst,    
    input  logic             en, 
    input  logic [A_WIDTH-1:0] step, 
    output logic [D_WIDTH-1:0] dout  
);

logic [A_WIDTH-1:0] address;     // interconnect wire as can't go straight between modules

counter addrCounter (
    .clk   (clk),
    .rst   (rst),
    .en    (en),
    .step  (step),
    .count (address)
);

rom #(A_WIDTH, D_WIDTH) sineRom (
    .clk  (clk),
    .addr (address),
    .dout (dout)
);

endmodule
```

As you can see, an interconnecting wire `address` is used to connect the output of `counter` to the input of `rom`. They are also initialised with the correct values from the top file, i.e. created with `rom #(A_WIDTH, D_WIDTH)` so a change in `A_WIDTH` will trickle down correctly.

`step` is created to be the same width as `dout` so the maximum step value does not exceed the number of addresses we have in memory. 

## Creating the testbench

The testbench has to link to the SV file:

```SV
Vsinegen* sinegen = new Vsinegen;
```

The tracer:

```cpp
Verilated::traceEverOn(true);
VerilatedVcdC* tfp = new VerilatedVcdC;
sinegen->trace(tfp, 99);
tfp->open("sinegen.vcd");
```

And start the vbuddy:
```cpp
if(vbdOpen()!=1) return(-1);
```

We then loop over the clock as usual and update the `vbdPlot()` with `sinegen->dout` mapping it between 0 and 255:

```cpp
for (i = 0; i < 10000000; i++) {
    sinegen->step = vbdValue();

    for (clk = 0; clk < 2; clk++) {
        tfp->dump (2*i + clk);
        sinegen->clk = !sinegen->clk;
        sinegen->eval ();
    }

    vbdPlot(int(sinegen->dout), 0, 255);

    vbdCycle(i+1);

    if (Verilated::gotFinish()|| (vbdGetkey()=='q')) exit(0);
}
```

As you can see, we also check for the `q` key to be pressed to finish the cycle early due to large cycle count of `10_000_000`.

To change the frequency, we changed the step count by `vbdValue()` so frequency doubles if `vbdValue()` doubles and so on.






