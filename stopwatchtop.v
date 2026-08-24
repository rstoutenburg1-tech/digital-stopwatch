`timescale 1ns/1ps
module stopwatch_top( 
	input wire clk, reset, start, stop, clear, count_down, lap, set_time,
	output wire [6:0] seg,
	output wire [3:0] an,
	output wire dp
);

	wire tick; 
	wire [3:0] disp_min, disp_sec10, disp_sec, disp_msec;
	
	clockdivider u_clk_div(
		.clk (clk),
		.reset (reset),
		.tick (tick)
	);
	
		clockdivider2 u_clk_div2(
		.clk (clk),
		.reset (reset),
		.fast_tick (fast_tick)
    );
	
	fsm_counter u_fsm(
		.clk	(clk),
		.reset	(reset),
		.tick	(tick),
		.fast_tick (fast_tick),
		.set_time (set_time),
		.start	(start),
		.stop   (stop),
		.clear  (clear),
		.count_down(count_down),
		.disp_min	(disp_min),
		.disp_sec10	(disp_sec10),
		.disp_sec	(disp_sec),
		.disp_msec	(disp_msec),
		.in_blink (in_blink),
		.lap  (lap)
	);
	display u_disp(
		.clk(clk),
		.reset(reset),
		.disp_min(disp_min),
		.disp_sec10(disp_sec10),
		.disp_sec(disp_sec),
		.disp_msec(disp_msec),
		.seg(seg),
		.an(an),
		.in_blink (in_blink),
		.dp   (dp)
		);
		
endmodule

		
	
	
	
	