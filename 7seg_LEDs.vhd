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
--    File: 7seg_LEDs.vhd
--    Creation Date: 19:50:00 30/11/2015
--    Description:
--    360/30 7-segment LED drivers
--    This drives the 7-segment display on the Digilent S3BOARD
--
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2015-11-30
--    
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity segment_LEDs is
	 Generic (
				Clock_divider : integer := 50000 -- Default for 50MHz clock is 1kHz
				);
    Port ( -- Input vector
           number : in std_logic_vector(15 downto 0) := (others=>'0');	-- 15-13=LHS 3-0=RHS
			  dp : in std_logic_vector(3 downto 0) := (others=>'0');		-- 1 for ON
			  -- Other inputs
			  clk : in STD_LOGIC; -- 50MHz
			  
           -- Driver outputs
           anodes : out std_logic_vector(3 downto 0);		-- 3=LHS 0=RHS
			  cathodes : out std_logic_vector(7 downto 0)	-- 7=dp 6=g 5=f 4=e 3=d 2=c 1=b 0=a
			  );
end segment_LEDS;

architecture Behavioral of segment_LEDS is
signal clk_out : std_logic := '0';

type segmentArrayType is array(0 to 15) of std_logic_vector(6 downto 0);
signal segments : segmentArrayType := (
	0	=> "1000000",
	1	=> "1111001",
	2	=> "0100100",
	3	=> "0110000",
	4	=> "0011001",
	5	=> "0010010",
	6	=> "0000010",
	7	=> "1111000",
	8	=> "0000000",
	9	=> "0010000",
	10	=> "0001000",
	11	=> "0000011",
	12	=> "1000110",
	13	=> "0100001",
	14	=> "0000110",
	15	=> "0001110"
	);

type digitArrayType is array(0 to 3) of std_logic_vector(3 downto 0);
signal digits : digitArrayType := (
	0	=> "1110",
	1	=> "1101",
	2	=> "1011",
	3	=> "0111"
	);

signal digit : integer range 0 to 3 := 0;

begin

gen_clk : process (clk) is
	variable divider : integer := Clock_divider;
	begin
		if rising_edge(clk) then
			if (divider=0) then
				divider := Clock_divider;
				clk_out <= not clk_out;
			else
				divider := divider - 1;
			end if;
		end if;
	end process;


scan : process (clk_out) is
	begin
	if rising_edge(clk_out) then
		if (digit=3) then
			digit <= 0;
		else
			digit <= digit + 1;
		end if;
		
	anodes <= digits(digit);
	cathodes <= not dp(digit) & segments(to_integer(unsigned(number(digit*4+3 downto digit*4))));
	
	end if;
	end process;

end behavioral;

