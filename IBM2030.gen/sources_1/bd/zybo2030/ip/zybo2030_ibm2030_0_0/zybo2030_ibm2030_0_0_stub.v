// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Tue Oct  7 16:56:18 2025
// Host        : lznb204 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/lwilkinson/Xilinx/IBM2030/IBM2030.gen/sources_1/bd/zybo2030/ip/zybo2030_ibm2030_0_0/zybo2030_ibm2030_0_0_stub.v
// Design      : zybo2030_ibm2030_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "zybo2030_ibm2030_0_0,ibm2030,{}" *) (* core_generation_info = "zybo2030_ibm2030_0_0,ibm2030,{x_ipProduct=Vivado 2025.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=ibm2030,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,ClockFrequency=125}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* ip_definition_source = "module_ref" *) (* x_core_info = "ibm2030,Vivado 2025.1" *) 
module zybo2030_ibm2030_0_0(rgbled, led, pb, sw, MAX7318_SCL, MAX7318_SDA, 
  MAX7219_CLK, MAX7219_LOAD, MAX7219_DIN, MAX6951_CLK, MAX6951_CS0, MAX6951_CS1, MAX6951_CS2, 
  MAX6951_CS3, MAX6951_DIN, red0, red1, red2, red3, blue0, blue1, blue2, blue3, green0, green1, green2, 
  green3, vga_hs, vga_vs, d_p, d_n, clk_p, clk_n, serialRx, serialTx, serialRTS, serialDTR, bram1_addr, 
  bram1_clk, bram1_wrdata, bram1_en, bram1_rst, bram1_we, bram1_rddata, bram2_addr, bram2_clk, 
  bram2_wrdata, bram2_en, bram2_rst, bram2_we, bram2_rddata, sysclk)
/* synthesis syn_black_box black_box_pad_pin="rgbled[5:0],led[4:0],pb[5:0],sw[3:0],MAX7318_SCL,MAX7318_SDA,MAX7219_LOAD,MAX7219_DIN,MAX6951_CS0,MAX6951_CS1,MAX6951_CS2,MAX6951_CS3,MAX6951_DIN,red0,red1,red2,red3,blue0,blue1,blue2,blue3,green0,green1,green2,green3,vga_hs,vga_vs,d_p[2:0],d_n[2:0],clk_p,clk_n,serialRx,serialTx,serialRTS,serialDTR,bram1_addr[13:0],bram1_clk,bram1_wrdata[31:0],bram1_en,bram1_rst,bram1_we[3:0],bram1_rddata[31:0],bram2_addr[8:0],bram2_clk,bram2_wrdata[31:0],bram2_en,bram2_rst,bram2_we[3:0],bram2_rddata[31:0]" */
/* synthesis syn_force_seq_prim="MAX7219_CLK" */
/* synthesis syn_force_seq_prim="MAX6951_CLK" */
/* synthesis syn_force_seq_prim="sysclk" */;
  output [5:0]rgbled;
  output [4:0]led;
  input [5:0]pb;
  input [3:0]sw;
  output MAX7318_SCL;
  inout MAX7318_SDA;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 MAX7219_CLK CLK" *) (* x_interface_mode = "master MAX7219_CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME MAX7219_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_MAX7219_CLK, INSERT_VIP 0" *) output MAX7219_CLK /* synthesis syn_isclock = 1 */;
  output MAX7219_LOAD;
  output MAX7219_DIN;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 MAX6951_CLK CLK" *) (* x_interface_mode = "master MAX6951_CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME MAX6951_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_MAX6951_CLK, INSERT_VIP 0" *) output MAX6951_CLK /* synthesis syn_isclock = 1 */;
  output MAX6951_CS0;
  output MAX6951_CS1;
  output MAX6951_CS2;
  output MAX6951_CS3;
  output MAX6951_DIN;
  output red0;
  output red1;
  output red2;
  output red3;
  output blue0;
  output blue1;
  output blue2;
  output blue3;
  output green0;
  output green1;
  output green2;
  output green3;
  output vga_hs;
  output vga_vs;
  output [2:0]d_p;
  output [2:0]d_n;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_p CLK" *) (* x_interface_mode = "master clk_p" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_p, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_clk_p, INSERT_VIP 0" *) output clk_p;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_n CLK" *) (* x_interface_mode = "master clk_n" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_n, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_clk_n, INSERT_VIP 0" *) output clk_n;
  input serialRx;
  output serialTx;
  output serialRTS;
  output serialDTR;
  input [13:0]bram1_addr;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 bram1_clk CLK" *) (* x_interface_mode = "slave bram1_clk" *) (* x_interface_parameter = "XIL_INTERFACENAME bram1_clk, ASSOCIATED_RESET bram1_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input bram1_clk;
  input [31:0]bram1_wrdata;
  input bram1_en;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 bram1_rst RST" *) (* x_interface_mode = "slave bram1_rst" *) (* x_interface_parameter = "XIL_INTERFACENAME bram1_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input bram1_rst;
  input [3:0]bram1_we;
  output [31:0]bram1_rddata;
  input [8:0]bram2_addr;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 bram2_clk CLK" *) (* x_interface_mode = "slave bram2_clk" *) (* x_interface_parameter = "XIL_INTERFACENAME bram2_clk, ASSOCIATED_RESET bram2_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input bram2_clk;
  input [31:0]bram2_wrdata;
  input bram2_en;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 bram2_rst RST" *) (* x_interface_mode = "slave bram2_rst" *) (* x_interface_parameter = "XIL_INTERFACENAME bram2_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input bram2_rst;
  input [3:0]bram2_we;
  output [31:0]bram2_rddata;
  input sysclk /* synthesis syn_isclock = 1 */;
endmodule
