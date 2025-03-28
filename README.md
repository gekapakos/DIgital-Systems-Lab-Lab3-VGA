# Lab03: Implementation of a Video Graphics Array (VGA) Driver Controller

## Overview
This lab focuses on implementing a VGA (Video Graphics Array) driver controller using Verilog on the Nexys A7-100T FPGA board. The goal is to drive a 640x480 resolution image with a 60 Hz refresh rate onto a screen, reproducing a specific color pattern using a VRAM (Video RAM) composed of 3 BRAMs (Block RAMs) to support 8 colors (RGB).

## Hardware
- **Board**: Nexys A7-100T
- **Clock**: 100 MHz (adjusted to 25 MHz via MMCME)
- **Resolution**: 640 x 480 pixels
- **Refresh Rate**: 60 Hz
- **VGA Pins**: 5 used (3 for RGB, 2 for HSYNC/VSYNC)

## Project Description
The VGA controller drives an image stored in VRAM, mapped as 128 x 96 pixels with 8 colors, using digital HSYNC and VSYNC signals for timing. The pattern includes line-wise alternations of red/white, green/white, blue/white, and column-wise alternations of red/green/blue/black and red/green/blue/white.

## Parts

### Part A: Implementation of VRAM
- **Description**: Creates a VRAM to store a 128 x 96 pixel image with 8 colors.
- **Implementation**: Uses 3 BRAMs (16K x 1 each) initialized via `.INIT_xx` parameters in Vivado. Colors are mapped in reverse order (end-to-start) for correct display. The pattern uses 48 lines (256 bits each, totaling 12,288 bits).
- **Verification**: Testbench checks `VGA_RED`, `VGA_GREEN`, and `VGA_BLUE` outputs for various `vga_addr` values, confirming the expected color pattern.

### Part B: Implementation of HSYNC and Horizontal Pixel Counter
- **Description**: Implements the HSYNC signal and horizontal pixel counter (HPIXEL) for 640 x 480 resolution.
- **Implementation**: An FSM with 5 states (A-E) controls timing: sync pulse (800 clocks), display (640 clocks), pulse width (96 clocks), front porch (16 clocks), and back porch (48 clocks). `HPIXEL` (6 bits) updates every 5 clocks to match the 128-pixel VRAM width.
- **Verification**: Testbench confirms correct HSYNC and HRGB_EN signal timings per the timing table.

### Part C: Implementation of VSYNC and Vertical Pixel Counter - Completion of VGA Controller/Driver
- **Description**: Completes the VGA driver with VSYNC, vertical pixel counter, and full integration.
- **Implementation**: 
  - **VSYNC and Vertical Pixel Counter**: An FSM with 5 states (O-S) manages sync pulse (416,800 clocks, 521 lines), display (384,000 clocks, 480 lines), pulse width (1,600 clocks, 2 lines), front porch (8,000 clocks, 10 lines), and back porch (23,200 clocks, 29 lines). `VPIXEL` (6 bits) updates every 5 clocks to match the 96-pixel VRAM height.
  - **VGA Controller (vga_controller)**: Connects VRAM, HSYNC, and VSYNC modules. An MMCME unit converts the 100 MHz clock to 25 MHz (40 ns period) using `CLFBOUT_MULT_F = 12`, `CLKIN1_PERIOD = 10`, `CLKOUT1_DIVIDE = 48`, and `DIVCLK_DIVIDE = 1`.
- **Verification**: 
  - **VSYNC and Vertical Pixel Counter**: Testbench verifies timings and `VPIXEL` values (0-95), ensuring proper synchronization.
  - **VGA Controller**: Testbench confirms RGB colors activate in the correct order, with deactivation when `HRGB_EN` or `VRGB_EN` is zero.
- **Final Implementation**: Bitstream applied to the board. Initial attempt showed correct pattern but wrong colors; fixed by setting RGB to zero when `HRGB_EN` and `VRGB_EN` are inactive, achieving the correct display.

## Setup
1. Clone this repository.
2. Open in Vivado.
3. Add constraints file to map Verilog signals to FPGA pins.
4. Synthesize, implement, and generate the bitstream.
5. Program the Nexys A7-100T and connect a VGA screen.
