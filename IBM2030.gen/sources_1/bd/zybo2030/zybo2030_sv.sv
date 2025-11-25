// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
// DO NOT MODIFY THIS FILE.

// MODULE VLNV: amd.com:blockdesign:zybo2030:1.0

`timescale 1ps / 1ps

`include "vivado_interfaces.svh"

module zybo2030_sv (
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_cas_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_cke,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_ck_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_ck_p,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_cs_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_reset_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_odt,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_ras_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire DDR_we_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [2:0] DDR_ba,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [14:0] DDR_addr,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [3:0] DDR_dm,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [31:0] DDR_dq,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [3:0] DDR_dqs_n,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [3:0] DDR_dqs_p,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire [53:0] FIXED_IO_mio,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire FIXED_IO_ddr_vrn,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire FIXED_IO_ddr_vrp,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire FIXED_IO_ps_srstb,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire FIXED_IO_ps_clk,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire FIXED_IO_ps_porb,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire hdmi_tx_clk_p,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire hdmi_tx_clk_n,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] hdmi_tx_data_p,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] hdmi_tx_data_n,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [5:0] pb,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [3:0] sw,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] led,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire vga_hs,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire vga_vs,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX7318_SCL,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX7219_CLK,
  (* X_INTERFACE_IGNORE = "true" *)
  inout wire MAX7318_SDA,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX7219_LOAD,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX7219_DIN,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX6951_CLK,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX6951_CS0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX6951_CS1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX6951_CS2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX6951_CS3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire MAX6951_DIN,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire sysclk,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] vga_b,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] vga_r,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] vga_g,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire serialRx,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire serialTx
);

  zybo2030 inst (
    .DDR_cas_n(DDR_cas_n),
    .DDR_cke(DDR_cke),
    .DDR_ck_n(DDR_ck_n),
    .DDR_ck_p(DDR_ck_p),
    .DDR_cs_n(DDR_cs_n),
    .DDR_reset_n(DDR_reset_n),
    .DDR_odt(DDR_odt),
    .DDR_ras_n(DDR_ras_n),
    .DDR_we_n(DDR_we_n),
    .DDR_ba(DDR_ba),
    .DDR_addr(DDR_addr),
    .DDR_dm(DDR_dm),
    .DDR_dq(DDR_dq),
    .DDR_dqs_n(DDR_dqs_n),
    .DDR_dqs_p(DDR_dqs_p),
    .FIXED_IO_mio(FIXED_IO_mio),
    .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
    .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
    .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
    .hdmi_tx_clk_p(hdmi_tx_clk_p),
    .hdmi_tx_clk_n(hdmi_tx_clk_n),
    .hdmi_tx_data_p(hdmi_tx_data_p),
    .hdmi_tx_data_n(hdmi_tx_data_n),
    .pb(pb),
    .sw(sw),
    .led(led),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .MAX7318_SCL(MAX7318_SCL),
    .MAX7219_CLK(MAX7219_CLK),
    .MAX7318_SDA(MAX7318_SDA),
    .MAX7219_LOAD(MAX7219_LOAD),
    .MAX7219_DIN(MAX7219_DIN),
    .MAX6951_CLK(MAX6951_CLK),
    .MAX6951_CS0(MAX6951_CS0),
    .MAX6951_CS1(MAX6951_CS1),
    .MAX6951_CS2(MAX6951_CS2),
    .MAX6951_CS3(MAX6951_CS3),
    .MAX6951_DIN(MAX6951_DIN),
    .sysclk(sysclk),
    .vga_b(vga_b),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .serialRx(serialRx),
    .serialTx(serialTx)
  );

endmodule
