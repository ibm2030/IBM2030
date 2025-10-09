-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
-- Date        : Tue Oct  7 16:56:18 2025
-- Host        : lznb204 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/lwilkinson/Xilinx/IBM2030/IBM2030.gen/sources_1/bd/zybo2030/ip/zybo2030_ibm2030_0_0/zybo2030_ibm2030_0_0_stub.vhdl
-- Design      : zybo2030_ibm2030_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zybo2030_ibm2030_0_0 is
  Port ( 
    rgbled : out STD_LOGIC_VECTOR ( 5 downto 0 );
    led : out STD_LOGIC_VECTOR ( 4 downto 0 );
    pb : in STD_LOGIC_VECTOR ( 5 downto 0 );
    sw : in STD_LOGIC_VECTOR ( 3 downto 0 );
    MAX7318_SCL : out STD_LOGIC;
    MAX7318_SDA : inout STD_LOGIC;
    MAX7219_CLK : out STD_LOGIC;
    MAX7219_LOAD : out STD_LOGIC;
    MAX7219_DIN : out STD_LOGIC;
    MAX6951_CLK : out STD_LOGIC;
    MAX6951_CS0 : out STD_LOGIC;
    MAX6951_CS1 : out STD_LOGIC;
    MAX6951_CS2 : out STD_LOGIC;
    MAX6951_CS3 : out STD_LOGIC;
    MAX6951_DIN : out STD_LOGIC;
    red0 : out STD_LOGIC;
    red1 : out STD_LOGIC;
    red2 : out STD_LOGIC;
    red3 : out STD_LOGIC;
    blue0 : out STD_LOGIC;
    blue1 : out STD_LOGIC;
    blue2 : out STD_LOGIC;
    blue3 : out STD_LOGIC;
    green0 : out STD_LOGIC;
    green1 : out STD_LOGIC;
    green2 : out STD_LOGIC;
    green3 : out STD_LOGIC;
    vga_hs : out STD_LOGIC;
    vga_vs : out STD_LOGIC;
    d_p : out STD_LOGIC_VECTOR ( 2 downto 0 );
    d_n : out STD_LOGIC_VECTOR ( 2 downto 0 );
    clk_p : out STD_LOGIC;
    clk_n : out STD_LOGIC;
    serialRx : in STD_LOGIC;
    serialTx : out STD_LOGIC;
    serialRTS : out STD_LOGIC;
    serialDTR : out STD_LOGIC;
    bram1_addr : in STD_LOGIC_VECTOR ( 13 downto 0 );
    bram1_clk : in STD_LOGIC;
    bram1_wrdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram1_en : in STD_LOGIC;
    bram1_rst : in STD_LOGIC;
    bram1_we : in STD_LOGIC_VECTOR ( 3 downto 0 );
    bram1_rddata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram2_addr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    bram2_clk : in STD_LOGIC;
    bram2_wrdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram2_en : in STD_LOGIC;
    bram2_rst : in STD_LOGIC;
    bram2_we : in STD_LOGIC_VECTOR ( 3 downto 0 );
    bram2_rddata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    sysclk : in STD_LOGIC
  );

  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of zybo2030_ibm2030_0_0 : entity is "zybo2030_ibm2030_0_0,ibm2030,{}";
  attribute core_generation_info : string;
  attribute core_generation_info of zybo2030_ibm2030_0_0 : entity is "zybo2030_ibm2030_0_0,ibm2030,{x_ipProduct=Vivado 2025.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=ibm2030,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,ClockFrequency=125}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of zybo2030_ibm2030_0_0 : entity is "yes";
  attribute ip_definition_source : string;
  attribute ip_definition_source of zybo2030_ibm2030_0_0 : entity is "module_ref";
end zybo2030_ibm2030_0_0;

architecture stub of zybo2030_ibm2030_0_0 is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "rgbled[5:0],led[4:0],pb[5:0],sw[3:0],MAX7318_SCL,MAX7318_SDA,MAX7219_CLK,MAX7219_LOAD,MAX7219_DIN,MAX6951_CLK,MAX6951_CS0,MAX6951_CS1,MAX6951_CS2,MAX6951_CS3,MAX6951_DIN,red0,red1,red2,red3,blue0,blue1,blue2,blue3,green0,green1,green2,green3,vga_hs,vga_vs,d_p[2:0],d_n[2:0],clk_p,clk_n,serialRx,serialTx,serialRTS,serialDTR,bram1_addr[13:0],bram1_clk,bram1_wrdata[31:0],bram1_en,bram1_rst,bram1_we[3:0],bram1_rddata[31:0],bram2_addr[8:0],bram2_clk,bram2_wrdata[31:0],bram2_en,bram2_rst,bram2_we[3:0],bram2_rddata[31:0],sysclk";
  attribute x_interface_info : string;
  attribute x_interface_info of MAX7219_CLK : signal is "xilinx.com:signal:clock:1.0 MAX7219_CLK CLK";
  attribute x_interface_mode : string;
  attribute x_interface_mode of MAX7219_CLK : signal is "master MAX7219_CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of MAX7219_CLK : signal is "XIL_INTERFACENAME MAX7219_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_MAX7219_CLK, INSERT_VIP 0";
  attribute x_interface_info of MAX6951_CLK : signal is "xilinx.com:signal:clock:1.0 MAX6951_CLK CLK";
  attribute x_interface_mode of MAX6951_CLK : signal is "master MAX6951_CLK";
  attribute x_interface_parameter of MAX6951_CLK : signal is "XIL_INTERFACENAME MAX6951_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_MAX6951_CLK, INSERT_VIP 0";
  attribute x_interface_info of clk_p : signal is "xilinx.com:signal:clock:1.0 clk_p CLK";
  attribute x_interface_mode of clk_p : signal is "master clk_p";
  attribute x_interface_parameter of clk_p : signal is "XIL_INTERFACENAME clk_p, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_clk_p, INSERT_VIP 0";
  attribute x_interface_info of clk_n : signal is "xilinx.com:signal:clock:1.0 clk_n CLK";
  attribute x_interface_mode of clk_n : signal is "master clk_n";
  attribute x_interface_parameter of clk_n : signal is "XIL_INTERFACENAME clk_n, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN zybo2030_ibm2030_0_0_clk_n, INSERT_VIP 0";
  attribute x_interface_info of bram1_clk : signal is "xilinx.com:signal:clock:1.0 bram1_clk CLK";
  attribute x_interface_mode of bram1_clk : signal is "slave bram1_clk";
  attribute x_interface_parameter of bram1_clk : signal is "XIL_INTERFACENAME bram1_clk, ASSOCIATED_RESET bram1_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  attribute x_interface_info of bram1_rst : signal is "xilinx.com:signal:reset:1.0 bram1_rst RST";
  attribute x_interface_mode of bram1_rst : signal is "slave bram1_rst";
  attribute x_interface_parameter of bram1_rst : signal is "XIL_INTERFACENAME bram1_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute x_interface_info of bram2_clk : signal is "xilinx.com:signal:clock:1.0 bram2_clk CLK";
  attribute x_interface_mode of bram2_clk : signal is "slave bram2_clk";
  attribute x_interface_parameter of bram2_clk : signal is "XIL_INTERFACENAME bram2_clk, ASSOCIATED_RESET bram2_rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  attribute x_interface_info of bram2_rst : signal is "xilinx.com:signal:reset:1.0 bram2_rst RST";
  attribute x_interface_mode of bram2_rst : signal is "slave bram2_rst";
  attribute x_interface_parameter of bram2_rst : signal is "XIL_INTERFACENAME bram2_rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute x_core_info : string;
  attribute x_core_info of stub : architecture is "ibm2030,Vivado 2025.1";
begin
end;
