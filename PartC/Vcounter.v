`timescale 1ns/1ps

module Vcounter(clk, reset, hcount, VGA_VSYNC, VPIXEL, VRGB_EN);

input clk, reset;
input [9:0] hcount;/*counter from Hcounter module that helps us check when a row ends, by checking its value*/
output reg VGA_VSYNC;/*Vertical synchronization signal*/
output [6:0] VPIXEL;/*counter that gives the vertical value for the pixel*/
output reg VRGB_EN;/*Enable signal for RGB, it gets enabled only in stateR*/

reg [2:0] state, state_next;/*state logic transition registers*/
reg [9:0] vcount, vcount_next;/*counter that counts throughout all the states of combinational logic always block*/
reg [6:0] vcount_ins, vcount_ins_next;/*Register which only counts in stateR, to give its value to VPIXEL*/
reg [2:0] flag, flag_next;/*variable that is used to divide the cycles of stateD by 5, so that hcount_ins can get the proper values from (0->95)*/

parameter 	stateO = 0,
			stateP = 1,
			stateQ = 2,
			stateR = 3,
			stateS = 4;

/*Sequential logic always block*/
always@ (posedge clk or posedge reset) begin
	if(reset) begin
		state <= stateO;
		vcount <= 0;
		vcount_ins <= 0;
		flag <= 0;
	end
	else begin
		state <= state_next;
		vcount <= vcount_next;
		vcount_ins <= vcount_ins_next;
		flag <= flag_next;
	end
end

/*Combinational logic always block*/
always@(state or hcount or vcount or flag or vcount_ins) begin
	state_next = state;
	vcount_next = vcount;
	vcount_ins_next = vcount_ins;
	flag_next = flag;
	VGA_VSYNC = 0;
	VRGB_EN = 0;
	case(state)
		/*(1 cycle) stateO*/
		stateO: begin
			VRGB_EN = 0;
			VGA_VSYNC = 1'b1;
			vcount_next = 0;
			state_next = stateP;
		end
		/*(2 lines) stateP*/
		stateP: begin
			flag_next = 0;
			VRGB_EN = 0;
			VGA_VSYNC = 1'b0;
			vcount_ins_next = 0;
			if(vcount < 2) begin
				if(hcount == (795))
					vcount_next = vcount_next + 1;
			end
			else
				state_next = stateQ;
		end
		/*(29 lines) stateQ*/
		stateQ: begin
			flag_next = 0;
			VRGB_EN = 0;
			VGA_VSYNC = 1'b1;
			vcount_ins_next = 0;
			if(vcount < 31) begin
				if(hcount == 795)
					vcount_next = vcount_next + 1;
			end
			else
				state_next = stateR;
		end
		/*(480 lines) stateR*/
		stateR: begin
			VGA_VSYNC = 1'b1;
			VRGB_EN = 1;
			if(vcount < 511) begin
				if(hcount == 795) begin
					vcount_next = vcount_next + 1;
					flag_next = flag_next + 1;
					if(flag == 4) begin/*Here we check the value of the flag every 5 cycles to increament vcount*/
						if(vcount_ins < 95)/*Here we make sure that vcount_ins doesn't exceed 95*/
							vcount_ins_next = vcount_ins_next + 1;
						else
							vcount_ins_next = 0;
						flag_next = 0;
					end
				end
			end
			else
				state_next = stateS;
		end
		/*(10 lines - 1 cycle) stateS*/
		stateS: begin
			flag_next = 0;
			VRGB_EN = 0;
			VGA_VSYNC = 1'b1;
			vcount_ins_next = 0;
			if(vcount < 521) begin
				if(hcount == 794)//795 - 1 cycle because the stateO has the extra cycle 
					vcount_next = vcount_next + 1;
			end
			else begin
				state_next = stateO;
				vcount_next = 0;
			end
		end
	endcase
end

assign VPIXEL = vcount_ins;

endmodule