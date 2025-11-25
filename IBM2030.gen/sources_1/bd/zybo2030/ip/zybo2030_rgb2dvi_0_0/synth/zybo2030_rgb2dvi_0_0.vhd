-- (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- (c) Copyright 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: digilentinc.com:ip:rgb2dvi:1.4
-- IP Revision: 7

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY zybo2030_rgb2dvi_0_0 IS
  PORT (
    TMDS_Clk_p : OUT STD_LOGIC;
    TMDS_Clk_n : OUT STD_LOGIC;
    TMDS_Data_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    TMDS_Data_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    aRst : IN STD_LOGIC;
    vid_pData : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    vid_pVDE : IN STD_LOGIC;
    vid_pHSync : IN STD_LOGIC;
    vid_pVSync : IN STD_LOGIC;
    PixelClk : IN STD_LOGIC
  );
END zybo2030_rgb2dvi_0_0;

ARCHITECTURE zybo2030_rgb2dvi_0_0_arch OF zybo2030_rgb2dvi_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF zybo2030_rgb2dvi_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT rgb2dvi IS
    GENERIC (
      kGenerateSerialClk : BOOLEAN;
      kClkPrimitive : STRING;
      kRstActiveHigh : BOOLEAN;
      kClkRange : INTEGER;
      kD0Swap : BOOLEAN;
      kD1Swap : BOOLEAN;
      kD2Swap : BOOLEAN;
      kClkSwap : BOOLEAN
    );
    PORT (
      TMDS_Clk_p : OUT STD_LOGIC;
      TMDS_Clk_n : OUT STD_LOGIC;
      TMDS_Data_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      TMDS_Data_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      aRst : IN STD_LOGIC;
      aRst_n : IN STD_LOGIC;
      vid_pData : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      vid_pVDE : IN STD_LOGIC;
      vid_pHSync : IN STD_LOGIC;
      vid_pVSync : IN STD_LOGIC;
      PixelClk : IN STD_LOGIC;
      SerialClk : IN STD_LOGIC
    );
  END COMPONENT rgb2dvi;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF zybo2030_rgb2dvi_0_0_arch: ARCHITECTURE IS "rgb2dvi,Vivado 2025.1.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF zybo2030_rgb2dvi_0_0_arch : ARCHITECTURE IS "zybo2030_rgb2dvi_0_0,rgb2dvi,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_MODE : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF PixelClk: SIGNAL IS "xilinx.com:signal:clock:1.0 PixelClk CLK";
  ATTRIBUTE X_INTERFACE_MODE OF PixelClk: SIGNAL IS "slave PixelClk";
  ATTRIBUTE X_INTERFACE_PARAMETER OF PixelClk: SIGNAL IS "XIL_INTERFACENAME PixelClk, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_clk_wiz_0_0_clk_out1, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF TMDS_Clk_n: SIGNAL IS "digilentinc.com:interface:tmds:1.0 TMDS CLK_N, xilinx.com:signal:clock:1.0 TMDS_Clk_n CLK";
  ATTRIBUTE X_INTERFACE_MODE OF TMDS_Clk_n: SIGNAL IS "master TMDS_Clk_n";
  ATTRIBUTE X_INTERFACE_PARAMETER OF TMDS_Clk_n: SIGNAL IS "XIL_INTERFACENAME TMDS_Clk_n, ASSOCIATED_RESET aRst_n, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF TMDS_Clk_p: SIGNAL IS "digilentinc.com:interface:tmds:1.0 TMDS CLK_P, xilinx.com:signal:clock:1.0 TMDS_Clk_p CLK";
  ATTRIBUTE X_INTERFACE_MODE OF TMDS_Clk_p: SIGNAL IS "master TMDS_Clk_p";
  ATTRIBUTE X_INTERFACE_PARAMETER OF TMDS_Clk_p: SIGNAL IS "XIL_INTERFACENAME TMDS, BOARD.ASSOCIATED_PARAM TMDS_BOARD_INTERFACE, XIL_INTERFACENAME TMDS_Clk_p, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF TMDS_Data_n: SIGNAL IS "digilentinc.com:interface:tmds:1.0 TMDS DATA_N";
  ATTRIBUTE X_INTERFACE_INFO OF TMDS_Data_p: SIGNAL IS "digilentinc.com:interface:tmds:1.0 TMDS DATA_P";
  ATTRIBUTE X_INTERFACE_INFO OF aRst: SIGNAL IS "xilinx.com:signal:reset:1.0 AsyncRst RST";
  ATTRIBUTE X_INTERFACE_MODE OF aRst: SIGNAL IS "slave AsyncRst";
  ATTRIBUTE X_INTERFACE_PARAMETER OF aRst: SIGNAL IS "XIL_INTERFACENAME AsyncRst, POLARITY ACTIVE_HIGH, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF vid_pData: SIGNAL IS "xilinx.com:interface:vid_io:1.0 RGB DATA";
  ATTRIBUTE X_INTERFACE_MODE OF vid_pData: SIGNAL IS "slave RGB";
  ATTRIBUTE X_INTERFACE_INFO OF vid_pHSync: SIGNAL IS "xilinx.com:interface:vid_io:1.0 RGB HSYNC";
  ATTRIBUTE X_INTERFACE_INFO OF vid_pVDE: SIGNAL IS "xilinx.com:interface:vid_io:1.0 RGB ACTIVE_VIDEO";
  ATTRIBUTE X_INTERFACE_INFO OF vid_pVSync: SIGNAL IS "xilinx.com:interface:vid_io:1.0 RGB VSYNC";
BEGIN
  U0 : rgb2dvi
    GENERIC MAP (
      kGenerateSerialClk => true,
      kClkPrimitive => "PLL",
      kRstActiveHigh => true,
      kClkRange => 1,
      kD0Swap => false,
      kD1Swap => false,
      kD2Swap => false,
      kClkSwap => false
    )
    PORT MAP (
      TMDS_Clk_p => TMDS_Clk_p,
      TMDS_Clk_n => TMDS_Clk_n,
      TMDS_Data_p => TMDS_Data_p,
      TMDS_Data_n => TMDS_Data_n,
      aRst => aRst,
      aRst_n => '1',
      vid_pData => vid_pData,
      vid_pVDE => vid_pVDE,
      vid_pHSync => vid_pHSync,
      vid_pVSync => vid_pVSync,
      PixelClk => PixelClk,
      SerialClk => '0'
    );
END zybo2030_rgb2dvi_0_0_arch;
