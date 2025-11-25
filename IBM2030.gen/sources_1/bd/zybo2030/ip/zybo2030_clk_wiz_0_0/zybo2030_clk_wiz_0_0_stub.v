// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
// Date        : Tue Nov 25 21:37:48 2025
// Host        : synergy running 64-bit Linux Mint 22.2
// Command     : write_verilog -force -mode synth_stub
//               /home/ljw/Documents/IBM/IBM2030/IBM2030.gen/sources_1/bd/zybo2030/ip/zybo2030_clk_wiz_0_0/zybo2030_clk_wiz_0_0_stub.v
// Design      : zybo2030_clk_wiz_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CORE_GENERATION_INFO = "zybo2030_clk_wiz_0_0,clk_wiz_v6_0_17_0_0,{component_name=zybo2030_clk_wiz_0_0,use_phase_alignment=false,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=MMCM,num_out_clk=3,clkin1_period=8.000,clkin2_period=10.000,use_power_down=false,use_reset=true,use_locked=false,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}" *) 
module zybo2030_clk_wiz_0_0(clk_out1, clk_out2, clk_out3, reset, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="reset,clk_in1" */
/* synthesis syn_force_seq_prim="clk_out1" */
/* synthesis syn_force_seq_prim="clk_out2" */
/* synthesis syn_force_seq_prim="clk_out3" */;
  output clk_out1 /* synthesis syn_isclock = 1 */;
  output clk_out2 /* synthesis syn_isclock = 1 */;
  output clk_out3 /* synthesis syn_isclock = 1 */;
  input reset;
  input clk_in1;
endmodule
