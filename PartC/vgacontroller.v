`timescale 1ns/1ps

module vgacontroller(reset, clk, VGA_RED, VGA_GREEN, VGA_BLUE, VGA_HSYNC, VGA_VSYNC);

input reset, clk;
output VGA_RED, VGA_GREEN, VGA_BLUE;/*Output colors we see in the screen*/
output VGA_HSYNC, VGA_VSYNC;/*Synchronization signals*/

wire clkf;/*buffer clk*/
wire clk_out;/*slow clock which works at 25MHz frequency*/
wire [13:0] vga_addr;/*adress of a pixel in VRAM, written as the compination of VPIXEL and HPIXEL*/
wire [6:0] HPIXEL;/*Horizontal value of a pixel*/
wire [6:0] VPIXEL;/*Vertical value of a pixel*/
wire [9:0] hcount;/*counter from Hcounter module that counts from the start to the end of a row*/
wire HRGB_EN, VRGB_EN;/*Enable signals for when the RGB is enabled horizontaly and verticaly*/
wire VGA_BLUE_o, VGA_RED_o, VGA_GREEN_o;/*variables used as the outputs of VRAM.*/

// MMCME2_BASE : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (MMCME2_BASE_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // MMCME2_BASE: Base Mixed Mode Clock Manager
   //              Artix-7
   // Xilinx HDL Language Template, version 2018.3

   MMCME2_BASE #(
      .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F(12.0),     // Multiply value for all CLKOUT (2.000-64.000).
      .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD(10.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT1_DIVIDE(48),
      .CLKOUT2_DIVIDE(1),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT0_DIVIDE_F(1.0),    // Divide amount for CLKOUT0 (1.000-128.000).
      // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLKOUT6_PHASE(0.0),
      .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .DIVCLK_DIVIDE(1),         // Master division value (1-106)
      .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
      .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   MMCME2_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(),     // 1-bit output: CLKOUT0
      .CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0
      .CLKOUT1(clk_out),     // 1-bit output: CLKOUT1
      .CLKOUT1B(),   // 1-bit output: Inverted CLKOUT1
      .CLKOUT2(),     // 1-bit output: CLKOUT2
      .CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2
      .CLKOUT3(),     // 1-bit output: CLKOUT3
      .CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3
      .CLKOUT4(),     // 1-bit output: CLKOUT4
      .CLKOUT5(),     // 1-bit output: CLKOUT5
      .CLKOUT6(),     // 1-bit output: CLKOUT6
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(clkf),   // 1-bit output: Feedback clock
      .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
      // Status Ports: 1-bit (each) output: MMCM status ports
      .LOCKED(),       // 1-bit output: LOCK
      // Clock Inputs: 1-bit (each) input: Clock input
      .CLKIN1(clk),       // 1-bit input: Clock
      // Control Ports: 1-bit (each) input: MMCM control ports
      .PWRDWN(1'b0),       // 1-bit input: Power-down
      .RST(reset),             // 1-bit input: Reset
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(clkf)      // 1-bit input: Feedback clock
   );

assign vga_addr = {VPIXEL, HPIXEL};/*vga_addr presented as the combination of the vertical and horizontal pixels*/

/*Assign the values of VRAM in the outputs of the top module only when both of the horizontal and vertical enable signals are on*/
assign VGA_RED = (HRGB_EN && VRGB_EN) ? VGA_RED_o : 0;
assign VGA_GREEN = (HRGB_EN && VRGB_EN) ? VGA_GREEN_o : 0;
assign VGA_BLUE = (HRGB_EN && VRGB_EN) ? VGA_BLUE_o : 0;

/*Instantiation of the modules used in the top module*/
VRAM VRAM_inst(.clk(clk_out), .reset(reset), .vga_addr(vga_addr), .VGA_RED(VGA_RED_o), .VGA_GREEN(VGA_GREEN_o), .VGA_BLUE(VGA_BLUE_o));
Hcounter Hcounter_inst(.clk(clk_out), .reset(reset), .VGA_HSYNC(VGA_HSYNC), .HPIXEL(HPIXEL), .hcount(hcount), .HRGB_EN(HRGB_EN));
Vcounter Vcounter_inst(.clk(clk_out), .reset(reset), .hcount(hcount), .VGA_VSYNC(VGA_VSYNC), .VPIXEL(VPIXEL), .VRGB_EN(VRGB_EN));

endmodule