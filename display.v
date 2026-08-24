`timescale 1ns/1ps
module display(
    input clk, reset, in_blink,             
    input [3:0] disp_min, disp_sec10, disp_sec, disp_msec,
    output reg [6:0] seg,
    output reg [3:0] an,
    output reg dp
);
    wire [6:0] seg_min, seg_sec10, seg_sec, seg_msec;
    reg [16:0] digit_counter;  
    reg [25:0] blink_counter;
    reg blink_on;
    
    sevensegdecoder d0(.HexVal(disp_msec),  .seg(seg_msec)); 
    sevensegdecoder d1(.HexVal(disp_sec),   .seg(seg_sec));
    sevensegdecoder d2(.HexVal(disp_sec10), .seg(seg_sec10));
    sevensegdecoder d3(.HexVal(disp_min),   .seg(seg_min));

    always @(posedge clk) begin
      if(reset) begin
        blink_counter <= 0;
        blink_on <= 1;
      end else begin
        blink_counter <= blink_counter +1;
        if(blink_counter == 26'd50_000_000) begin
            blink_counter <= 0;
            blink_on <= ~blink_on;
            end
        end
    end
    
    always @(posedge clk)
        if(reset) digit_counter <= 0;
        else digit_counter <= digit_counter + 1;

    always @(*) begin
        if(in_blink && !blink_on)begin
            an = 4'b0000;
            seg = 7'b111_1111;
        end else begin
        case(digit_counter[16:15])
            2'b00: begin an = 4'b1110; seg = seg_msec; dp = 1;  end
            2'b01: begin an = 4'b1101; seg = seg_sec; dp = 0;  end
            2'b10: begin an = 4'b1011; seg = seg_sec10; dp = 1; end
            2'b11: begin an = 4'b0111; seg = seg_min; dp = 0;  end
        endcase
        end
    end

endmodule


	
	