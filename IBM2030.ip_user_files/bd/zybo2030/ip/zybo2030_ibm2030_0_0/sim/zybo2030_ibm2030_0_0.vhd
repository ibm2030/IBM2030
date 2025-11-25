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

-- IP VLNV: xilinx.com:module_ref:ibm2030:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY zybo2030_ibm2030_0_0 IS
  PORT (
    rgbled : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
    led : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    pb : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    sw : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    MAX7318_SCL : OUT STD_LOGIC;
    MAX7318_SDA : INOUT STD_LOGIC;
    MAX7219_CLK : OUT STD_LOGIC;
    MAX7219_LOAD : OUT STD_LOGIC;
    MAX7219_DIN : OUT STD_LOGIC;
    MAX6951_CLK : OUT STD_LOGIC;
    MAX6951_CS0 : OUT STD_LOGIC;
    MAX6951_CS1 : OUT STD_LOGIC;
    MAX6951_CS2 : OUT STD_LOGIC;
    MAX6951_CS3 : OUT STD_LOGIC;
    MAX6951_DIN : OUT STD_LOGIC;
    red0 : OUT STD_LOGIC;
    red1 : OUT STD_LOGIC;
    red2 : OUT STD_LOGIC;
    red3 : OUT STD_LOGIC;
    blue0 : OUT STD_LOGIC;
    blue1 : OUT STD_LOGIC;
    blue2 : OUT STD_LOGIC;
    blue3 : OUT STD_LOGIC;
    green0 : OUT STD_LOGIC;
    green1 : OUT STD_LOGIC;
    green2 : OUT STD_LOGIC;
    green3 : OUT STD_LOGIC;
    vga_hs : OUT STD_LOGIC;
    vga_vs : OUT STD_LOGIC;
    d_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    d_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    clk_p : OUT STD_LOGIC;
    clk_n : OUT STD_LOGIC;
    SerialRx : IN STD_LOGIC;
    SerialTx : OUT STD_LOGIC;
    SerialRTS : OUT STD_LOGIC;
    SerialDTR : OUT STD_LOGIC;
    bram1_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 2);
    bram1_clk : IN STD_LOGIC;
    bram1_wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram1_en : IN STD_LOGIC;
    bram1_rst : IN STD_LOGIC;
    bram1_we : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    bram1_rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram2_addr : IN STD_LOGIC_VECTOR(10 DOWNTO 2);
    bram2_clk : IN STD_LOGIC;
    bram2_wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram2_en : IN STD_LOGIC;
    bram2_rst : IN STD_LOGIC;
    bram2_we : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    bram2_rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    sysclk : IN STD_LOGIC;
    clk50M : IN STD_LOGIC;
    clk40M : IN STD_LOGIC
  );
END zybo2030_ibm2030_0_0;

ARCHITECTURE zybo2030_ibm2030_0_0_arch OF zybo2030_ibm2030_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF zybo2030_ibm2030_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT ibm2030 IS
    GENERIC (
      ClockFrequency : INTEGER
    );
    PORT (
      rgbled : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      led : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      pb : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      sw : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      MAX7318_SCL : OUT STD_LOGIC;
      MAX7318_SDA : INOUT STD_LOGIC;
      MAX7219_CLK : OUT STD_LOGIC;
      MAX7219_LOAD : OUT STD_LOGIC;
      MAX7219_DIN : OUT STD_LOGIC;
      MAX6951_CLK : OUT STD_LOGIC;
      MAX6951_CS0 : OUT STD_LOGIC;
      MAX6951_CS1 : OUT STD_LOGIC;
      MAX6951_CS2 : OUT STD_LOGIC;
      MAX6951_CS3 : OUT STD_LOGIC;
      MAX6951_DIN : OUT STD_LOGIC;
      red0 : OUT STD_LOGIC;
      red1 : OUT STD_LOGIC;
      red2 : OUT STD_LOGIC;
      red3 : OUT STD_LOGIC;
      blue0 : OUT STD_LOGIC;
      blue1 : OUT STD_LOGIC;
      blue2 : OUT STD_LOGIC;
      blue3 : OUT STD_LOGIC;
      green0 : OUT STD_LOGIC;
      green1 : OUT STD_LOGIC;
      green2 : OUT STD_LOGIC;
      green3 : OUT STD_LOGIC;
      vga_hs : OUT STD_LOGIC;
      vga_vs : OUT STD_LOGIC;
      d_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      d_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      clk_p : OUT STD_LOGIC;
      clk_n : OUT STD_LOGIC;
      SerialRx : IN STD_LOGIC;
      SerialTx : OUT STD_LOGIC;
      SerialRTS : OUT STD_LOGIC;
      SerialDTR : OUT STD_LOGIC;
      bram1_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 2);
      bram1_clk : IN STD_LOGIC;
      bram1_wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram1_en : IN STD_LOGIC;
      bram1_rst : IN STD_LOGIC;
      bram1_we : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      bram1_rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram2_addr : IN STD_LOGIC_VECTOR(10 DOWNTO 2);
      bram2_clk : IN STD_LOGIC;
      bram2_wrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram2_en : IN STD_LOGIC;
      bram2_rst : IN STD_LOGIC;
      bram2_we : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      bram2_rddata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      sysclk : IN STD_LOGIC;
      clk50M : IN STD_LOGIC;
      clk40M : IN STD_LOGIC
    );
  END COMPONENT ibm2030;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_MODE : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF MAX6951_CLK: SIGNAL IS "xilinx.com:signal:clock:1.0 MAX6951_CLK CLK";
  ATTRIBUTE X_INTERFACE_MODE OF MAX6951_CLK: SIGNAL IS "master MAX6951_CLK";
  ATTRIBUTE X_INTERFACE_PARAMETER OF MAX6951_CLK: SIGNAL IS "XIL_INTERFACENAME MAX6951_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_MAX6951_CLK, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF MAX7219_CLK: SIGNAL IS "xilinx.com:signal:clock:1.0 MAX7219_CLK CLK";
  ATTRIBUTE X_INTERFACE_MODE OF MAX7219_CLK: SIGNAL IS "master MAX7219_CLK";
  ATTRIBUTE X_INTERFACE_PARAMETER OF MAX7219_CLK: SIGNAL IS "XIL_INTERFACENAME MAX7219_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_MAX7219_CLK, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF bram1_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 bram1_clk CLK";
  ATTRIBUTE X_INTERFACE_MODE OF bram1_clk: SIGNAL IS "slave bram1_clk";
  ATTRIBUTE X_INTERFACE_PARAMETER OF bram1_clk: SIGNAL IS "XIL_INTERFACENAME bram1_clk, ASSOCIATED_RESET bram1_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF bram1_rst: SIGNAL IS "xilinx.com:signal:reset:1.0 bram1_rst RST";
  ATTRIBUTE X_INTERFACE_MODE OF bram1_rst: SIGNAL IS "slave bram1_rst";
  ATTRIBUTE X_INTERFACE_PARAMETER OF bram1_rst: SIGNAL IS "XIL_INTERFACENAME bram1_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF bram2_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 bram2_clk CLK";
  ATTRIBUTE X_INTERFACE_MODE OF bram2_clk: SIGNAL IS "slave bram2_clk";
  ATTRIBUTE X_INTERFACE_PARAMETER OF bram2_clk: SIGNAL IS "XIL_INTERFACENAME bram2_clk, ASSOCIATED_RESET bram2_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF bram2_rst: SIGNAL IS "xilinx.com:signal:reset:1.0 bram2_rst RST";
  ATTRIBUTE X_INTERFACE_MODE OF bram2_rst: SIGNAL IS "slave bram2_rst";
  ATTRIBUTE X_INTERFACE_PARAMETER OF bram2_rst: SIGNAL IS "XIL_INTERFACENAME bram2_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk_n: SIGNAL IS "digilentinc.com:interface:tmds:1.0 interface_tmds CLK_N";
  ATTRIBUTE X_INTERFACE_INFO OF clk_p: SIGNAL IS "digilentinc.com:interface:tmds:1.0 interface_tmds CLK_P";
  ATTRIBUTE X_INTERFACE_MODE OF clk_p: SIGNAL IS "slave interface_tmds";
BEGIN
  U0 : ibm2030
    GENERIC MAP (
      ClockFrequency => 125
    )
    PORT MAP (
      rgbled => rgbled,
      led => led,
      pb => pb,
      sw => sw,
      MAX7318_SCL => MAX7318_SCL,
      MAX7318_SDA => MAX7318_SDA,
      MAX7219_CLK => MAX7219_CLK,
      MAX7219_LOAD => MAX7219_LOAD,
      MAX7219_DIN => MAX7219_DIN,
      MAX6951_CLK => MAX6951_CLK,
      MAX6951_CS0 => MAX6951_CS0,
      MAX6951_CS1 => MAX6951_CS1,
      MAX6951_CS2 => MAX6951_CS2,
      MAX6951_CS3 => MAX6951_CS3,
      MAX6951_DIN => MAX6951_DIN,
      red0 => red0,
      red1 => red1,
      red2 => red2,
      red3 => red3,
      blue0 => blue0,
      blue1 => blue1,
      blue2 => blue2,
      blue3 => blue3,
      green0 => green0,
      green1 => green1,
      green2 => green2,
      green3 => green3,
      vga_hs => vga_hs,
      vga_vs => vga_vs,
      d_p => d_p,
      d_n => d_n,
      clk_p => clk_p,
      clk_n => clk_n,
      SerialRx => SerialRx,
      SerialTx => SerialTx,
      SerialRTS => SerialRTS,
      SerialDTR => SerialDTR,
      bram1_addr => bram1_addr,
      bram1_clk => bram1_clk,
      bram1_wrdata => bram1_wrdata,
      bram1_en => bram1_en,
      bram1_rst => bram1_rst,
      bram1_we => bram1_we,
      bram1_rddata => bram1_rddata,
      bram2_addr => bram2_addr,
      bram2_clk => bram2_clk,
      bram2_wrdata => bram2_wrdata,
      bram2_en => bram2_en,
      bram2_rst => bram2_rst,
      bram2_we => bram2_we,
      bram2_rddata => bram2_rddata,
      sysclk => sysclk,
      clk50M => clk50M,
      clk40M => clk40M
    );
END zybo2030_ibm2030_0_0_arch;
