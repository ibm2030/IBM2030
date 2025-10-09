--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
--Date        : Tue Oct  7 16:54:19 2025
--Host        : lznb204 running 64-bit major release  (build 9200)
--Command     : generate_target zybo2030_wrapper.bd
--Design      : zybo2030_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity zybo2030_wrapper is
  port (
    MAX6951_CLK : out STD_LOGIC;
    MAX6951_CS0 : out STD_LOGIC;
    MAX6951_CS1 : out STD_LOGIC;
    MAX6951_CS2 : out STD_LOGIC;
    MAX6951_CS3 : out STD_LOGIC;
    MAX7219_CLK : out STD_LOGIC;
    MAX7219_DIN : out STD_LOGIC;
    MAX7219_LOAD : out STD_LOGIC;
    MAX7318_SCL : out STD_LOGIC;
    MAX7318_SDA : inout STD_LOGIC;
    SerialRx : in STD_LOGIC;
    led : out STD_LOGIC_VECTOR ( 4 downto 0 );
    pb : in STD_LOGIC_VECTOR ( 5 downto 0 );
    reset_rtl_0 : in STD_LOGIC;
    rgbled : out STD_LOGIC_VECTOR ( 5 downto 0 );
    sw : in STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_b : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_g : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_hs : out STD_LOGIC;
    vga_r : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_vs : out STD_LOGIC
  );
end zybo2030_wrapper;

architecture STRUCTURE of zybo2030_wrapper is
  component zybo2030 is
  port (
    reset_rtl_0 : in STD_LOGIC;
    pb : in STD_LOGIC_VECTOR ( 5 downto 0 );
    sw : in STD_LOGIC_VECTOR ( 3 downto 0 );
    SerialRx : in STD_LOGIC;
    rgbled : out STD_LOGIC_VECTOR ( 5 downto 0 );
    led : out STD_LOGIC_VECTOR ( 4 downto 0 );
    vga_r : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_g : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_b : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_hs : out STD_LOGIC;
    vga_vs : out STD_LOGIC;
    MAX7318_SCL : out STD_LOGIC;
    MAX7219_CLK : out STD_LOGIC;
    MAX7318_SDA : inout STD_LOGIC;
    MAX7219_LOAD : out STD_LOGIC;
    MAX7219_DIN : out STD_LOGIC;
    MAX6951_CLK : out STD_LOGIC;
    MAX6951_CS0 : out STD_LOGIC;
    MAX6951_CS1 : out STD_LOGIC;
    MAX6951_CS2 : out STD_LOGIC;
    MAX6951_CS3 : out STD_LOGIC
  );
  end component zybo2030;
begin
zybo2030_i: component zybo2030
     port map (
      MAX6951_CLK => MAX6951_CLK,
      MAX6951_CS0 => MAX6951_CS0,
      MAX6951_CS1 => MAX6951_CS1,
      MAX6951_CS2 => MAX6951_CS2,
      MAX6951_CS3 => MAX6951_CS3,
      MAX7219_CLK => MAX7219_CLK,
      MAX7219_DIN => MAX7219_DIN,
      MAX7219_LOAD => MAX7219_LOAD,
      MAX7318_SCL => MAX7318_SCL,
      MAX7318_SDA => MAX7318_SDA,
      SerialRx => SerialRx,
      led(4 downto 0) => led(4 downto 0),
      pb(5 downto 0) => pb(5 downto 0),
      reset_rtl_0 => reset_rtl_0,
      rgbled(5 downto 0) => rgbled(5 downto 0),
      sw(3 downto 0) => sw(3 downto 0),
      vga_b(3 downto 0) => vga_b(3 downto 0),
      vga_g(3 downto 0) => vga_g(3 downto 0),
      vga_hs => vga_hs,
      vga_r(3 downto 0) => vga_r(3 downto 0),
      vga_vs => vga_vs
    );
end STRUCTURE;
