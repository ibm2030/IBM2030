---------------------------------------------------------------------------
--    Copyright © 2015 Lawrence Wilkinson lawrence@ljw.me.uk
--
--    This file is part of LJW2030, a VHDL implementation of the IBM
--    System/360 Model 30.
--
--    LJW2030 is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    LJW2030 is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with LJW2030 .  If not, see <http://www.gnu.org/licenses/>.
--
---------------------------------------------------------------------------
--
--    File: panel_LEDs.vhd
--    Creation Date: 16:08:00 16/06/2015
--    Description:
--    360/30 Front Panel LED lamp drivers
--    This drives 256 front panel LEDs via Maxim SPI/I2C multiplexed drivers
--    There are two options:
--    MAX7219 8 x 8 multiplexed LEDs
--    MAX7951 Charlieplexed LEDs
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-09
--    Initial Release
--    
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Buses_package.all;
use work.Gates_package.EvenParity;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity panel_LEDs is
	 Generic (
				Clock_divider : integer := 25; -- Default for 50MHz clock is 2, for 25MHz = 40ns = 20ns + 20ns. 25 gives 2MHz.
				Number_LEDs : integer := 256
				);
    Port ( -- Lamp input vector
           LEDs : in std_logic_vector(0 to Number_LEDs-1);
			  -- Other inputs
			  clk : in STD_LOGIC; -- 50MHz
			  
           -- Driver outputs
           MAX7219_CLK : out std_logic;
			  MAX7219_DIN : out std_logic;	-- LEDs 00-3F
			  MAX7219_LOAD : out std_logic;	-- Data latched on rising edge
			  
			  MAX6951_CLK : out std_logic;
			  MAX6951_DIN : out std_logic;	-- 
			  MAX6951_CS0 : out std_logic;	-- LEDs 00-3F Data latched on rising edge
			  MAX6951_CS1 : out std_logic;	-- LEDs 40-7F Data latched on rising edge
			  MAX6951_CS2 : out std_logic;	-- LEDs 80-BF Data latched on rising edge
			  MAX6951_CS3 : out std_logic 	-- LEDs C0-FF Data latched on rising edge
			  );
end panel_LEDs;

architecture Behavioral of panel_LEDs is
signal clk_out : std_logic := '0';
signal shift_reg64 : std_logic_vector(63 downto 0);
signal reg_counter : integer range 0 to 11 := 0;
signal bit_counter16 : integer range 0 to 16 := 0;
signal bit_counter64 : integer range 0 to 64 := 0;

-- MAX7219 data is 8b address and 8b data
-- Address is:
-- 00 No-op (unused)
-- 01 Digit 0 (in position 0)
-- ...
-- 08 Digit 7 (in position 7)
-- 09 Decode mode (fixed 00 in position 8)
-- 0A Intensity (fixed at 0F in position 9)
-- 0B Scan limit (fixed at 07 in position 10)
-- 0C Shutdown (fixed at 01 in position 11)
-- 0F Display test (fixed at 00 in position 12)

type registers7219 is array(0 to 3,0 to 12) of std_logic_vector(15 downto 0);
signal max7219_vector : registers7219 :=
(
0 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"

),
1 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"
),
2 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"
),
3 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"
)
);


-- MAX6951 data is 8b Address and 8b Data
-- Address is:
-- 00 No-op (unused)
-- 01 Decode mode (fixed at default)
-- 02 Intensity (fixed at 0F in position 8)
-- 03 Scan limit (fixed at 07 in position 9)
-- 04 Configuration (fixed at 01 in position 10)
-- 07 Display test (fixed at 00 in position 11)
-- 60 Digit 0 (in position 0)
-- ...
-- 67 Digit 7 (in position 0)
type registers6951 is array(0 to 3,0 to 11) of std_logic_vector(15 downto 0);
signal max6951_vector : registers6951 :=
(
0 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"

),
1 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"
),
2 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"
),
3 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"
)
);
begin
gen_clk : process (clk) is
	variable divider : integer := Clock_divider;
	begin
		if rising_edge(clk) then
			if (divider=0) then
				divider := Clock_divider;
				clk_out <= not clk_out;
				MAX7219_CLK <= not clk_out;
				MAX6951_CLK <= not clk_out;
			else
				divider := divider - 1;
			end if;
		end if;
	end process;


max7219 : process (clk_out) is
	begin
	if falling_edge(clk_out) then
		if bit_counter64=0 then
			bit_counter64 <= 64;
			case reg_counter is
				when 0 to 7 =>
					-- Mapping is:
					-- b7 = DP = XX7
					-- b6 =  A = XX0
					-- b5 =  B = XX1
					-- b4 =  C = XX2
					-- b3 =  D = XX3
					-- b2 =  E = XX4
					-- b1 =  F = XX5
					-- b0 =  G = XX6
					shift_reg64 <= 
						max7219_vector(3,reg_counter)(15 downto 8) & LEDs(reg_counter*8+192+7) & LEDs(reg_counter*8+192 to reg_counter*8+192+6) &
						max7219_vector(2,reg_counter)(15 downto 8) & LEDs(reg_counter*8+128+7) & LEDs(reg_counter*8+128 to reg_counter*8+128+6) &
						max7219_vector(1,reg_counter)(15 downto 8) & LEDs(reg_counter*8+ 64+7) & LEDs(reg_counter*8+ 64 to reg_counter*8+ 64+6) &
						max7219_vector(0,reg_counter)(15 downto 8) & LEDs(reg_counter*8+  0+7) & LEDs(reg_counter*8+  0 to reg_counter*8+  0+6);
				when others =>
					shift_reg64 <= 
						max7219_vector(3,reg_counter) &
						max7219_vector(2,reg_counter) &
						max7219_vector(1,reg_counter) &
						max7219_vector(0,reg_counter);	
			end case;
			if reg_counter=12 then
				reg_counter <= 0;
			else
				reg_counter <= reg_counter + 1;
			end if;
			MAX7219_DIN <= '0';
			MAX7219_Load <= '1';
		else
			bit_counter64 <= bit_counter64 - 1;
			shift_reg64 <= shift_reg64(62 downto 0) & '0';
			MAX7219_DIN <= shift_reg64(63);
			MAX7219_Load <= '0';
		end if;
	end if;
	end process;
	
max6951 : process (clk_out) is
	variable dev_counter : integer range 0 to 3 := 3;
	variable reg_counter : integer range 0 to 11 := 0;
	variable bit_counter : integer range 0 to 16 := 16;
	variable shift_reg : std_logic_vector(16 downto 0);
	begin
	if falling_edge(clk_out) then
		if bit_counter=0 then
			bit_counter := 16;
			case reg_counter is
				when 0 to 7 =>
					shift_reg := '0' & max6951_vector(dev_counter,reg_counter)(15 downto 8) & LEDs(dev_counter*64+reg_counter*8 to dev_counter*64+reg_counter*8+7);
				when others =>
					shift_reg := '0' & max6951_vector(dev_counter,reg_counter);
			end case;
			if reg_counter=11 then
				if dev_counter=0 then
					dev_counter := 3;
				else
					dev_counter := dev_counter - 1;
				end if;
				reg_counter := 0;
			else
				reg_counter := reg_counter + 1;
			end if;
		else
			bit_counter := bit_counter - 1;
			shift_reg := shift_reg(15 downto 0) & '0';
		end if;
		if bit_counter=16 then
			MAX6951_CS0 <= '1';
			MAX6951_CS1 <= '1';
			MAX6951_CS2 <= '1';
			MAX6951_CS3 <= '1';
		else
			if dev_counter=0 then
				MAX6951_CS0 <= '0';
			else
				MAX6951_CS0 <= '1';
			end if;
			if dev_counter=1 then
				MAX6951_CS1 <= '0';
			else
				MAX6951_CS1 <= '1';
			end if;
			if dev_counter=2 then
				MAX6951_CS2 <= '0';
			else
				MAX6951_CS2 <= '1';
			end if;
			if dev_counter=3 then
				MAX6951_CS3 <= '0';
			else
				MAX6951_CS3 <= '1';
			end if;
		end if;
		MAX6951_DIN <= shift_reg(16);
	end if;
	end process;

end behavioral;

