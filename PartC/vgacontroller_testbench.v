`timescale 1ns/1ps

module vgacontroller_testbench;

reg reset, clk;
wire VGA_RED, VGA_GREEN, VGA_BLUE;
wire VGA_HSYNC, VGA_VSYNC;

/*Unit under test*/
vgacontroller vgacontroller_u(.reset(reset), .clk(clk), .VGA_RED(VGA_RED), .VGA_GREEN(VGA_GREEN), .VGA_BLUE(VGA_BLUE), .VGA_HSYNC(VGA_HSYNC), .VGA_VSYNC(VGA_VSYNC));

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	reset = 1'b1;
	#375 reset = 1'b0;
end

endmodule