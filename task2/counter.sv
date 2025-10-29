module counter #(
    parameter WIDTH = 8
)(

    input  logic             clk,
    input  logic             rst,
    input  logic             en,
    input  logic [WIDTH-1:0] step,
    output logic [WIDTH-1:0] count
);

always_ff @ (posedge clk or posedge rst) // asynchronous reset
    if (rst) count <= {WIDTH{1'b0}};
    else     count <= count + {{WIDTH-1{1'b0}}, en};

endmodule
