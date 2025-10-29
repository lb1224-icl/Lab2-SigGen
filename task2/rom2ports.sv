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
