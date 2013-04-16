--------------------------------------------------------------------------------
-- Company: 
-- Engineer:       LJW
--
-- Create Date:    22:26:31 04/18/05
-- Design Name:    
-- Module Name:    Clock+MpxInd - Behavioral
-- Project Name:   IBM2030
-- Target Device:  XC3S1000
-- Tool versions:  ISE V7.1
-- Description:    Four-phase clock generation and Multiplexor channel indicators
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockMpxInd is Port (
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

			  -- Mpx Indicator stuff
				TEST_LAMP : in std_Logic; -- 04A
				OPNL_IN,ADDR_IN,STATUS_IN,SERVICE_IN,
				SELECT_OUT,ADDR_OUT,COMMAND_OUT,SERVICE_OUT,
				SUPPRESS_OUT : in std_logic; -- 08D
				FO_P : in std_logic; -- 08C
				FO : in std_logic_vector(0 to 7); -- 08C
				IND_OPNL_IN, IND_ADDR_IN,IND_STATUS_IN,IND_SERV_IN,
				IND_SEL_OUT,IND_ADDR_OUT,IND_CMMD_OUT,IND_SERV_OUT,
				IND_SUPPR_OUT,IND_FO_P : out std_logic;
				IND_FO : out std_logic_vector(0 to 7)
			  );
end ClockMpxInd;

architecture slt of ClockMpxInd is
-- subtype DividerSize is STD_LOGIC_VECTOR(5 downto 0);
-- constant RATIO : DividerSize := "001111"; -- 16 gives 3.125MHz
-- subtype DividerSize is STD_LOGIC_VECTOR(25 downto 0);
-- constant RATIO : DividerSize := "00111100000000000000000000"; -- 16M gives 3.125Hz
subtype DividerSize is STD_LOGIC_VECTOR(25 downto 0);
constant RATIO : DividerSize := "00010011000100101101000000"; -- 5M gives 10Hz
constant ZERO : DividerSize := (others=>'0');
constant ONE : DividerSize := (0=>'1',others=>'0');

signal DIVIDER : DividerSize;
signal OSC2,OSC,DLYD_OSC : STD_LOGIC;
-- signal SETS,RSTS : STD_LOGIC_VECTOR(1 to 4);
signal CLK : STD_LOGIC_VECTOR(1 to 4);

begin
-- Divide the 50MHz FPGA clock down
-- 1.5us storage cycle means T1-4 takes 750ns, or 3MHz
-- OSC2 is actually double the original oscillator as only one edge is used
process (CLOCK_IN)
	begin
	if CLOCK_IN'event and CLOCK_IN='1' then
		if DIVIDER=RATIO then
			DIVIDER <= ZERO;
			OSC2 <= not OSC2;
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
process (OSC2, MACH_RST_3)
	begin
	if OSC2'event and OSC2='1' then
	   if OSC='0' then	-- Rising edge
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
		else			  		-- Falling edge
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

OSC_T_LINE <= not OSC;
M_CONV_OSC <= OSC;
DLYD_OSC <= OSC; -- AC1C6

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
M_CONV_OSC_2 <= OSC and not (CLK(1) or CLK(2) or CLK(3)); -- Note: Not inverted, despite the name


-- The indicator drivers for the Multiplexor channel are here
IND_OPNL_IN <= OPNL_IN or TEST_LAMP;
IND_ADDR_IN <= ADDR_IN or TEST_LAMP;
IND_STATUS_IN <= STATUS_IN or TEST_LAMP;
IND_SERV_IN <= SERVICE_IN or TEST_LAMP;
IND_SEL_OUT <= SELECT_OUT or TEST_LAMP;
IND_ADDR_OUT <= ADDR_OUT or TEST_LAMP;
IND_CMMD_OUT <= COMMAND_OUT or TEST_LAMP;
IND_SERV_OUT <= SERVICE_OUT or TEST_LAMP;
IND_SUPPR_OUT <= SUPPRESS_OUT or TEST_LAMP;
IND_FO_P <= FO_P or TEST_LAMP;
IND_FO <= FO or (FO'range => TEST_LAMP);

end slt;
