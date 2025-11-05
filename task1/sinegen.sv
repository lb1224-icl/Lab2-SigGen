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
