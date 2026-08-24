`timescale 1ns/1ps
module clockdivider2 (input clk, reset, 
output reg fast_tick
	);
	localparam LIMIT = 1_000_000-1;
	reg [23:0] count;
	
always @(posedge clk) begin
    if (reset) begin 
        count <= 0;
        fast_tick <= 0;
    end else if (count == LIMIT) begin
        count <= 0;
        fast_tick <= 1;
    end else begin
        count <= count + 1;
        fast_tick <= 0;
    end
end
endmodule
