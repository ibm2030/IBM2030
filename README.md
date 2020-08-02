IBM2030
=======

An IBM System/360 Model 30 in VHDL, modified for the Zynq SoC.

THIS IS A WORK IN PROGRESS

There are four main components to this release:
* VHDL for the CPU (with 64k storage) and Multiplexer channel
* The microcode image (4k x 55)
* The I/O support devices (Block Diagram)
* The processor configuration

I am not claiming copyright to the microcode image - this is based on IBM manuals from 1964-1965 which may or may not be copyrighted themselves.

The VHDL is based on the IBM Maintenance Diagram Manual (MDM), which can be found on Bitsavers.

As supplied, the compiled system is suitable for a Digilent Zybo Z7-20 board, see https://store.digilentinc.com/zybo-z7-zynq-7000-arm-fpga-soc-development-board/
It uses the following I/O:
* HDMI output
* SPI output for Front Panel LEDs
* SPI input for Front Panel Switches
* Parallel I/O for a subset of the switches and LEDs
If using an alternative board, it may be sufficient to modify the UCF file to reallocate inputs and outputs

These files can be compiled using Xilinx Vivado v2018.3 (and presumably later versions.)

Apologies for the varied quality of the VHDL.  This project has taken over 10 years and I have not necessarily re-visited code that was written early on.  So there is a variety of styles and conventions.  In my defence, it works (or seems to).

Lawrence Wilkinson
lawrence@ljw.me.uk
2020/08/01

