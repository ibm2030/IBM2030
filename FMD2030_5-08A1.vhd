---------------------------------------------------------------------------
--    Copyright © 2010 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: FMD2030_5-08A1.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Clock generator - 4 phase (T1,T2,T3,T4 and P1,P2,P3,P4)
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-13
--    Initial Release
--    
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Gates_package.all;

entity Clock is Port (
				-- Clock stuff
				CLOCK_IN : in std_logic;
         	T1,T2,T3,T4 : out std_logic;
         	P1,P2,P3,P4 : out std_logic;
         	OSC_T_LINE : out std_logic; -- 12A
         	M_CONV_OSC : out std_logic; -- 03C
				P_CONV_OSC : out std_logic; -- 03D,03C
				M_CONV_OSC_2 : out std_logic; -- 03C
				CLOCK_ON : out std_logic; -- 03D,04A,03C,13B,12A,11B
        		CLOCK_OFF : out std_logic; -- 04B,06C,09B,03D
       		CLOCK_START : in std_logic; -- 03C
				MACH_RST_3 : in std_logic; -- 03D
				Sw_Slow : in std_logic -- '1' to run slow
			  );
end Clock;

architecture FMD of Clock is
-- Following 2 lines to run clock at 5.33MHz (standard)
-- subtype DividerSize is STD_LOGIC_VECTOR(5 downto 0);
subtype DividerSize is STD_LOGIC_VECTOR(25 downto 0);
constant RATIOFast : DividerSize := "00000000000000000000001000"; -- 5 gives 10MHz => 720ns cycle
-- Following 2 lines to run clock at 5Hz
constant RATIOSlow : DividerSize := "00100010010101010001000000"; -- 5M gives 10Hz => 720ms cycle
constant ZERO : DividerSize := (others=>'0');
constant ONE : DividerSize := (0=>'1',others=>'0');

signal DIVIDER : DividerSize := (others=>'0');
signal DIVIDER_MAX : DividerSize;
signal OSC2,OSC,M_DLYD_OSC,DLYN_OSC,T1A,T2A,T3A,T4A,OSC2_DLYD : STD_LOGIC := '0';
-- signal SETS,RSTS : STD_LOGIC_VECTOR(1 to 4);
signal CLK : STD_LOGIC_VECTOR(1 to 4) := "0001";

begin
-- Divide the 50MHz FPGA clock down
-- 1.5us storage cycle means T1-4 takes 750ns, or 1.33MHz
-- The clock to generate the four phases is therefore 2.66MHz
-- OSC2 is actually double the original oscillator (5.33MHz) as only one edge is used
DIVIDER_MAX <= RatioSlow when Sw_Slow='1' else RATIOFast;
OSC2 <= '1' when DIVIDER > '0' & DIVIDER_MAX(DIVIDER_MAX'left downto 1) else '0';

process (CLOCK_IN)
	begin
	if CLOCK_IN'event and CLOCK_IN='1' then
		if DIVIDER>=DIVIDER_MAX then
			DIVIDER <= ZERO;
		else
			DIVIDER <= DIVIDER + ONE;
		end if;
	end if;
end process;

-- AC1K6,AC1C6 Probably have to re-do this lot to get it work
--SETS(1) <= not DLYD_OSC and CLOCK_START and not CLK(3) and CLK(4);
--SETS(2) <= DLYD_OSC not CLK(4) and CLK(1);
--SETS(3) <= not DLYD_OSC and not CLK(1) and CLK(2);
--SETS(4) <= (DLYD_OSC and not CLK(2) and CLK(3)) or MACH_RST_3='1';
--RSTS(1) <= (not DLYD_OSC and CLK(2)) or MACH_RST_3='1';
--RSTS(2) <= (OSC and CLK(3)) or MACH_RST_3='1';
--RSTS(3) <= (not DLYD_OSC and CLK(4)) or MACH_RST_3='1';
--RSTS(4) <= OSC and CLK(1);
--FLV(SETS,RSTS,CLK); -- AC1C6

-- The following process forms a ring counter
-- MACH_RST_3 forces the counter to 0001
-- If CLOCK_START is false, the counter stays at 0001
-- When CLOCK_START goes true, the counter cycles through
-- 0001 0001 0001 1001 1100 0110 0011 1001 1100 ....
-- When CLOCK_START subsequently goes false, the sequence continues
-- until reaching 0011, after which it stays at 0001
-- ... 1001 1100 0110 0011 0001 0001 0001 ...

-- The original counter used a level-triggered implementation, driven by
-- both levels of the OSC signal.  Here it is easier to make it edge triggered
-- which requires a clock of twice the frequency, hence OSC2
process (OSC2, MACH_RST_3, CLOCK_START)
	begin
	if OSC2'event and OSC2='1' then
	   if OSC='0' then	-- OSC Rising edge: +P1 (P4=1 & START) -P3 (P4=1) or -P1 +P3 (P2=1)
			OSC <= '1';
		  	if CLK(2)='1' or MACH_RST_3='1' then
				CLK(1) <= '0';
			elsif CLOCK_START='1' and CLK(4)='1' then
				CLK(1) <= '1';
			end if;
			if CLK(4)='1' or MACH_RST_3='1' then
				CLK(3) <= '0';
			elsif CLK(2)='1' then
				CLK(3) <= '1';
			end if;
		else			  		-- OSC Falling edge: +P2 -P4 (P1=1) or -P2 +P4 (P3=1)
			OSC <= '0';
			if CLK(3)='1' or MACH_RST_3='1' then
				CLK(2) <= '0';
			elsif CLK(1)='1' then
				CLK(2) <= '1';
			end if;
			if CLK(3)='1' or MACH_RST_3='1' then
				CLK(4) <= '1';
			elsif CLK(1)='1' then
				CLK(4) <= '0';
			end if;
		end if;
	end if;
end process;

OSC_T_LINE <= OSC; -- AC1B6
M_CONV_OSC <= not OSC; -- AC1C6
M_DLYD_OSC <= not OSC; -- AC1C6
DLYN_OSC <= OSC; -- AC1C6

P1 <= CLK(1);
P2 <= CLK(2);
P3 <= CLK(3);
P4 <= CLK(4);

T1 <= CLK(4) and CLK(1);
T2 <= CLK(1) and CLK(2);
T3 <= CLK(2) and CLK(3);
T4 <= CLK(3) and CLK(4);

CLOCK_ON <= CLK(1) or CLK(2) or CLK(3);
CLOCK_OFF <= not (CLK(1) or CLK(2) or CLK(3));
P_CONV_OSC <= OSC and not (CLK(1) or CLK(2) or CLK(3));
M_CONV_OSC_2 <= not(OSC and not (CLK(1) or CLK(2) or CLK(3)));

end FMD;
