`timescale 1ns/1ps
module clockdivider (input clk, reset, 
output reg tick
	);
	localparam LIMIT = 10_000_000-1;
	reg [23:0] count;
	
always @(posedge clk) begin
    if (reset) begin 
        count <= 0;
        tick <= 0;
    end else if (count == LIMIT) begin
        count <= 0;
        tick <= 1;
    end else begin
        count <= count + 1;
        tick <= 0;
    end
end
endmodule
