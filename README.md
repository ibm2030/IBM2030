IBM2030
=======

An IBM System/360 Model 30 in VHDL

There are two main components to this release:
* VHDL for the CPU (with 8k storage) and Multiplexer channel
* The microcode image (4k x 55)

I am not claiming copyright to the microcode image - this is based on IBM manuals from 1964-1965 which may or may not be copyrighted themselves.

The VHDL is based on the IBM Maintenance Diagram Manual (MDM), which can be found on Bitsavers.

As supplied, the compiled system is suitable for a Digilent Spartan 3 board with a 1000K device, see http://www.digilentinc.com/Products/Detail.cfm?Prod=S3BOARD
It uses the following I/O:
* VGA output (8-colour, 3-bit)
* Parallel I/O for switch scanning (10 out, 14 in)
* On-board pushbutton inputs (4)
* On-board slide switch inputs (8)
* On-board LED outputs (8)
If using an alternative board, it may be sufficient to modify the UCF file to reallocate inputs and outputs

These files can be compiled using the Xilinx ISE Webpack (and presumably other versions of the Xilinx suite).  I have not tried compiling them with other VHDL compilers.

Apologies for the varied quality of the VHDL.  This project has taken over 5 years and I have not necessarily re-visited code that was written early on.  So there is a variety of styles and conventions.  In my defence, it works (or seems to).

Lawrence Wilkinson
lawrence@ljw.me.uk
2010/07/16

