`timescale 1ns/1ps

module VRAM_testbench;

reg clk, reset;
reg [13:0] vga_addr;
wire VGA_RED, VGA_GREEN, VGA_BLUE; 

VRAM VRAM_u(.clk(clk), .reset(reset), .vga_addr(vga_addr), .VGA_RED(VGA_RED), .VGA_GREEN(VGA_GREEN), .VGA_BLUE(VGA_BLUE));

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	reset = 1'b1;
	#105 reset = 1'b0;
end

initial begin
	#100 vga_addr = 0;
	forever #100 vga_addr = vga_addr + 1;
end

endmodule