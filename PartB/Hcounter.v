`timescale 1ns/1ps

module Hcounter(clk, reset, VGA_HSYNC, HPIXEL, hcount, HRGB_EN);

input clk, reset;
output reg VGA_HSYNC;/*Horizontal synchronization signal*/
output [6:0] HPIXEL;/*counter that gives the horizontal value for the pixel*/
output reg [9:0] hcount;/*counter that counts throughout all the states of combinational logic always block*/
output reg HRGB_EN;/*Enable signal for RGB, it gets enabled only in stateD*/

reg [2:0] state, next_state;/*state logic transition registers*/
reg [9:0] hcount_next;
reg [6:0] hcount_ins, hcount_ins_next;/*Register which only counts in stateD, to give its value to HPIXEL*/
reg [2:0] flag, flag_next;/*variable that is used to divide the cycles of stateD by 5, so that hcount_ins can get the proper values from (0->127)*/

parameter 	stateA = 0,
			stateB = 1,
			stateC = 2,
			stateD = 3,
			stateE = 4;

/*Sequential logic always block*/
always@ (posedge clk or posedge reset) begin
	if(reset) begin
		state <= stateA;
		hcount <= 0;
		hcount_ins <= 0;
		flag <= 0;
	end
	else begin
		state <= next_state;
		hcount <= hcount_next;
		hcount_ins <= hcount_ins_next;
		flag <= flag_next;
	end
end

/*Combinational logic always block*/
always@(state or hcount or hcount_ins or flag) begin
	next_state = state;
	hcount_next = hcount;
	hcount_ins_next = hcount_ins;
	flag_next = flag;
	VGA_HSYNC = 0;
	HRGB_EN = 0;
	case(state)
		/*(1 cycle) stateA*/
		stateA: begin
			HRGB_EN = 0;
			VGA_HSYNC = 1'b1;
			hcount_next = 0;
			next_state = stateB;
		end
		/*(96 cycles) stateB*/
		stateB: begin
			HRGB_EN = 0;
			flag_next = 0;
			VGA_HSYNC = 1'b0;
			hcount_ins_next = 0;
			if(hcount == (95))
				next_state = stateC;
			else
				hcount_next = hcount_next + 1;
		end
		/*(48 cycles) stateC*/
		stateC: begin
			flag_next = 0;
			HRGB_EN = 0;
			VGA_HSYNC = 1'b1;
			hcount_ins_next = 0;
			if(hcount < (142))
				hcount_next = hcount_next + 1;
			else
				next_state = stateD;
		end
		/*(640 cycles) stateD*/
		stateD: begin
			VGA_HSYNC = 1'b1;
			HRGB_EN = 1;
			if(hcount < (781)) begin
				hcount_next = hcount_next + 1;
				flag_next = flag_next + 1;
				if(flag == 4) begin /*Here we check the value of the flag every 5 cycles to increament hcount*/
					hcount_ins_next = hcount_ins_next + 1;
					flag_next = 0;
				end
			end
			else
				next_state = stateE;
		end
		/*(15 cycles) stateE*/
		stateE: begin
			flag_next = 0;
			HRGB_EN = 0;
			VGA_HSYNC = 1'b1;
			hcount_ins_next = 127;
			if(hcount < (795))//796 -1 period because we add it up front in stateA
				hcount_next = hcount_next + 1;
			else begin
				next_state = stateA;
				hcount_next = 0;
				hcount_ins_next = 0	;
			end
		end
	endcase
end

assign HPIXEL = hcount_ins;

endmodule

/*`timescale 1ns/1ps

module Hcounter(clk, reset, VGA_HSYNC, HPIXEL, hcount, HRGB_EN);

input clk, reset;
output reg VGA_HSYNC;
output [6:0] HPIXEL;
output reg [9:0] hcount;
output reg HRGB_EN;

reg [2:0] state, next_state;
reg [9:0] hcount_next;
reg [6:0] hcount_ins, hcount_ins_next;
reg [2:0] flag, flag_next;

parameter 	stateA = 0,
			stateB = 1,
			stateC = 2,
			stateD = 3,
			stateE = 4;

always@ (posedge clk or posedge reset) begin
	if(reset) begin
		state <= stateA;
		hcount <= 0;
		hcount_ins <= 0;
		flag <= 0;
	end
	else begin
		state <= next_state;
		hcount <= hcount_next;
		hcount_ins <= hcount_ins_next;
		flag <= flag_next;
	end
end

always@(state or hcount or flag or hcount_ins) begin
	next_state = state;
	hcount_next = hcount;
	hcount_ins_next = hcount_ins;
	flag_next = flag;
	VGA_HSYNC = 0;
	HRGB_EN = 1'b0;
	case(state)
		stateA: begin
			HRGB_EN = 1'b0;
			VGA_HSYNC = 1'b1;
			hcount_next = 0;
			next_state = stateB;
		end
		stateB: begin
			HRGB_EN = 1'b0;
			VGA_HSYNC = 1'b0;
			hcount_ins_next = 0;
			flag_next = 0;
			if(hcount == (95))
				next_state = stateC;
			else
				hcount_next = hcount_next + 1;
		end
		stateC: begin
			HRGB_EN = 1'b0;
			VGA_HSYNC = 1'b1;
			hcount_ins_next = 0;
			flag_next = 0;
			if(hcount == (142))
				next_state = stateD;
			else
				hcount_next = hcount_next + 1;
		end
		stateD: begin
			HRGB_EN = 1'b1;
			VGA_HSYNC = 1'b1;
			if(hcount == (781))
				next_state = stateE;
			else begin
				hcount_next = hcount_next + 1;
				flag_next = flag_next + 1;
				if(flag == 4) begin
					hcount_ins_next = hcount_ins_next + 1;
					flag_next = 0;
				end
			end
		end
		stateE: begin
			HRGB_EN = 1'b0;
			VGA_HSYNC = 1'b1;
			hcount_ins_next = 127;
			flag_next = 0;
			if(hcount == (795)) begin
				next_state = stateA;
				hcount_next = 0;
			end
			else begin
				hcount_next = hcount_next + 1;
			end
		end
	endcase
end

assign HPIXEL = hcount_ins;

endmodule*/