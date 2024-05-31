`timescale 1ns/1ps

module Hcounter_testbench;

reg clk, reset;
wire VGA_HSYNC;
wire [6:0] HPIXEL;
wire [9:0] hcount;
wire HRGB_EN;


Hcounter Hcounter_u(.clk(clk), .reset(reset), .VGA_HSYNC(VGA_HSYNC), .HPIXEL(HPIXEL), .hcount(hcount), .HRGB_EN(HRGB_EN));

initial begin
	clk = 0;
	forever #20 clk = ~clk;
end

initial begin
	reset = 1'b1;
	#20 reset = 1'b0;
end

endmodule