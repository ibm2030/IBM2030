-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- -------------------------------------------------------------------------------
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

-- MODULE VLNV: amd.com:blockdesign:zybo2030:1.0

-- The following code must appear in the VHDL architecture header.

-- COMP_TAG     ------ Begin cut for COMPONENT Declaration ------
COMPONENT zybo2030
  PORT (
    DDR_cas_n : INOUT STD_LOGIC;
    DDR_cke : INOUT STD_LOGIC;
    DDR_ck_n : INOUT STD_LOGIC;
    DDR_ck_p : INOUT STD_LOGIC;
    DDR_cs_n : INOUT STD_LOGIC;
    DDR_reset_n : INOUT STD_LOGIC;
    DDR_odt : INOUT STD_LOGIC;
    DDR_ras_n : INOUT STD_LOGIC;
    DDR_we_n : INOUT STD_LOGIC;
    DDR_ba : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    DDR_addr : INOUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    DDR_dm : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    DDR_dq : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    DDR_dqs_n : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    DDR_dqs_p : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    FIXED_IO_mio : INOUT STD_LOGIC_VECTOR(53 DOWNTO 0);
    FIXED_IO_ddr_vrn : INOUT STD_LOGIC;
    FIXED_IO_ddr_vrp : INOUT STD_LOGIC;
    FIXED_IO_ps_srstb : INOUT STD_LOGIC;
    FIXED_IO_ps_clk : INOUT STD_LOGIC;
    FIXED_IO_ps_porb : INOUT STD_LOGIC;
    hdmi_tx_clk_p : OUT STD_LOGIC;
    hdmi_tx_clk_n : OUT STD_LOGIC;
    hdmi_tx_data_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    hdmi_tx_data_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    pb : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    sw : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    vga_hs : OUT STD_LOGIC;
    vga_vs : OUT STD_LOGIC;
    MAX7318_SCL : OUT STD_LOGIC;
    MAX7219_CLK : OUT STD_LOGIC;
    MAX7318_SDA : INOUT STD_LOGIC;
    MAX7219_LOAD : OUT STD_LOGIC;
    MAX7219_DIN : OUT STD_LOGIC;
    MAX6951_CLK : OUT STD_LOGIC;
    MAX6951_CS0 : OUT STD_LOGIC;
    MAX6951_CS1 : OUT STD_LOGIC;
    MAX6951_CS2 : OUT STD_LOGIC;
    MAX6951_CS3 : OUT STD_LOGIC;
    MAX6951_DIN : OUT STD_LOGIC;
    sysclk : IN STD_LOGIC;
    vga_b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    vga_r : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    vga_g : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    serialRx : IN STD_LOGIC;
    serialTx : OUT STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------  End cut for COMPONENT Declaration  ------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

-- INST_TAG     ------ Begin cut for INSTANTIATION Template ------
your_instance_name : zybo2030
  PORT MAP (
    DDR_cas_n => DDR_cas_n,
    DDR_cke => DDR_cke,
    DDR_ck_n => DDR_ck_n,
    DDR_ck_p => DDR_ck_p,
    DDR_cs_n => DDR_cs_n,
    DDR_reset_n => DDR_reset_n,
    DDR_odt => DDR_odt,
    DDR_ras_n => DDR_ras_n,
    DDR_we_n => DDR_we_n,
    DDR_ba => DDR_ba,
    DDR_addr => DDR_addr,
    DDR_dm => DDR_dm,
    DDR_dq => DDR_dq,
    DDR_dqs_n => DDR_dqs_n,
    DDR_dqs_p => DDR_dqs_p,
    FIXED_IO_mio => FIXED_IO_mio,
    FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
    FIXED_IO_ps_clk => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb => FIXED_IO_ps_porb,
    hdmi_tx_clk_p => hdmi_tx_clk_p,
    hdmi_tx_clk_n => hdmi_tx_clk_n,
    hdmi_tx_data_p => hdmi_tx_data_p,
    hdmi_tx_data_n => hdmi_tx_data_n,
    pb => pb,
    sw => sw,
    led => led,
    vga_hs => vga_hs,
    vga_vs => vga_vs,
    MAX7318_SCL => MAX7318_SCL,
    MAX7219_CLK => MAX7219_CLK,
    MAX7318_SDA => MAX7318_SDA,
    MAX7219_LOAD => MAX7219_LOAD,
    MAX7219_DIN => MAX7219_DIN,
    MAX6951_CLK => MAX6951_CLK,
    MAX6951_CS0 => MAX6951_CS0,
    MAX6951_CS1 => MAX6951_CS1,
    MAX6951_CS2 => MAX6951_CS2,
    MAX6951_CS3 => MAX6951_CS3,
    MAX6951_DIN => MAX6951_DIN,
    sysclk => sysclk,
    vga_b => vga_b,
    vga_r => vga_r,
    vga_g => vga_g,
    serialRx => serialRx,
    serialTx => serialTx
  );
-- INST_TAG_END ------  End cut for INSTANTIATION Template  ------

-- You must compile the wrapper file zybo2030.vhd when simulating
-- the module, zybo2030. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.
