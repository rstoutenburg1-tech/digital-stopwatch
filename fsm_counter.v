`timescale 1ns/1ps
module fsm_counter(
input clk, reset, tick, fast_tick, start, stop, clear, count_down, lap, set_time,
output reg [3:0] disp_min, disp_sec10, disp_sec, disp_msec,
output wire in_blink
	);

reg cnt;
reg [3:0] min, sec10, sec, msec;
reg [2:0] state;
parameter IDLE=3'b000, S_L=3'b001, RUN_UP=3'b010, RUN_DOWN=3'b011, BLINK=3'b100, SET=3'b101, SET_UP=3'b110, SET_DOWN=3'b111;
	
wire zero_detector_up = (msec == 0) && (sec == 0) && (sec10 == 0) && (min == 0);
wire zero_detector_down = (msec == 0) && (sec == 0) && (sec10 == 0) && (min == 0);
assign in_blink = (state == BLINK);

always @(posedge clk or posedge reset) begin
	if(reset)
		state <= IDLE;
	else 
		case(state)
		IDLE: begin cnt<=tick;
            if(set_time) begin
                state <= SET;
            end else begin		
                if(start)begin
                    if(count_down) state<=RUN_DOWN;
                    else state<=RUN_UP;
                    end
           end
		end
	    RUN_UP:begin cnt<=tick;	
	       if(tick && zero_detector_up) state <= BLINK;
	       else begin if(stop)       state <= IDLE; else if(lap) state<=S_L; end
		end	
        RUN_DOWN: begin cnt<=tick;
            if(tick && zero_detector_down) state <= BLINK;
			else if(stop)       state <= IDLE;
		end
        BLINK: begin
			if(start)      state <= count_down ? RUN_DOWN : RUN_UP;
			else if(stop)  state <= IDLE;
		end
		S_L: begin cnt<=tick;
		  if(start) state<=RUN_UP;
		  else if(stop) state<=IDLE;
		  end
        SET: begin
            if(~set_time)
                state <= IDLE;
            else begin
                if(start)begin
                    state <= count_down ? SET_DOWN : SET_UP;
                    end
                else
                    state<=IDLE;   
            end    
        end
        SET_UP: begin
            if(start)
                cnt<=fast_tick;
            else
                state<=IDLE; 
        end           
        SET_DOWN: begin
            if(start)
                cnt<=fast_tick;	
            else
                state<=IDLE;
        end            	  
		endcase
end

always @(posedge clk or posedge reset) begin //msec register
    if (reset)
        msec <= 0;
    else if(cnt) 
    case(state)
		IDLE: begin	
			if(clear)
				msec<=0;
		end
        RUN_UP, S_L, SET_UP: begin		
			if(msec == 9)
				msec <=0;
			else
				msec <= msec + 1;				
		end
        RUN_DOWN, SET_DOWN: begin
			if(msec == 0)
				msec <=9;
			else
				msec <= msec - 1;
		end
    endcase
end
	
always @(posedge clk or posedge reset) begin //sec register
    if (reset)
        sec <= 0;
    else if (cnt) case(state)
		IDLE: begin	
			if(clear)
				sec<=0;
		end
        RUN_UP, S_L, SET_UP: begin		
			if(msec == 9)
				if(sec == 9)
					sec <=0;
				else
					sec <= sec + 1;			
		end
        RUN_DOWN, SET_DOWN: begin
			if(msec == 0)
				if(sec == 0)
					sec <=9;
				else
					sec <= sec - 1;	
		end
    endcase
end
	
always @(posedge clk or posedge reset) begin //tens register
    if (reset)
        sec10 <= 0;
    else if (cnt) case(state)
		IDLE: begin	
			if(clear)
				sec10<=0;
		end	
        RUN_UP, S_L, SET_UP: begin		
			if(msec == 9)
				if(sec == 9)
					if(sec10 == 5)
						sec10 <= 0;
					else
						sec10 <= sec10 + 1;		
		end
        RUN_DOWN, SET_DOWN: begin
			if(msec == 0)
				if(sec == 0)
					if(sec10 == 0)
						sec10 <= 5;
					else
						sec10 <= sec10 - 1;	
		end
    endcase
end

always @(posedge clk or posedge reset) begin //minute register
    if (reset)
        min <= 0;
    else if (cnt) case(state)
		IDLE: begin	
			if(clear)
				min<=0;	
		end
        RUN_UP, S_L, SET_UP: begin		
		if(msec == 9)
			if(sec == 9)
				if(sec10 == 5)
					if(min == 9)
						min <=0;
					else
						min <= min + 1;
		end
        RUN_DOWN, SET_DOWN: begin
		if(msec == 0)
			if(sec == 0)
				if(sec10 == 0)
					if(min == 0)
						min <= 9;
					else
						min <= min - 1;
		end
    endcase
end	
always @(posedge clk or posedge reset) begin
    if(reset)
    begin
        disp_min <= 0; disp_sec10 <= 0;
        disp_sec <= 0; disp_msec <= 0;
    end
    else begin
        if(state == S_L) 
        begin 
            disp_min <= disp_min; disp_sec10 <= disp_sec10; 
            disp_sec <= disp_sec; disp_msec <= disp_msec; 
        end
        else begin 
            disp_min <= min; disp_sec10 <= sec10; 
            disp_sec <= sec; disp_msec <= msec;             	
        end    
   end
end	
endmodule
				
						