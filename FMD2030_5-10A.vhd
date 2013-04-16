---------------------------------------------------------------------------
--    Copyright  2012 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: FMD2030_5-10A.vhd
--    Creation Date: 
--    Description:
--    1050 Typewriter Console clock control and generation
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2012-04-07
--		Initial release
---------------------------------------------------------------------------
LIBRARY ieee;
Library UNISIM;
use UNISIM.vcomponents.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY n1050_CLOCK IS
	port
	(
		-- Inputs        
		WRITE_LCH : IN STD_LOGIC; -- 09CD2
		READ_OR_READ_INQ : IN STD_LOGIC; -- 09CC5
		RST_ATTACH : IN STD_LOGIC; -- 10BC2
		PUNCH_1_CLUTCH : IN STD_LOGIC; -- 10DD5
		READ_CLK_INTLK_LCH : IN STD_LOGIC; -- 10BA2
		RDR_1_CLUTCH : IN STD_LOGIC; -- 10DD5
		CRLF : IN STD_LOGIC; -- ?
		
		-- Outputs
		CLOCK_1 : OUT STD_LOGIC; -- 10CD1 10CA4
		W_TIME, X_TIME, Y_TIME, Z_TIME : OUT STD_LOGIC;
		CLK_STT_RST : OUT STD_LOGIC; -- 09CE1
		
		-- Temp
--		POSTRIG, NEGTRIG : OUT STD_LOGIC;
--		OSCOut,C1,C2 : OUT STD_LOGIC;
--		OSCOut,C1,C2 : OUT STD_LOGIC;
        
		-- Clocks
		clk : IN STD_LOGIC -- 50MHz clock
	);
END n1050_CLOCK;

ARCHITECTURE FMD OF n1050_CLOCK IS 
-- Output rate is 9600bps or 960chars/sec or 1.04ms/char.  We set the clock to run at 1.2ms/4 or 300us (300 * 50 = 15000 cycles)
-- constant ClockDivider : integer := 15000;
constant	ClockDivider : integer := 250; -- Gives 5us OSC rate

	signal	OSC : STD_LOGIC; -- Inverted signal
	signal	CLK_START : STD_LOGIC;
	signal	TRIGER : STD_LOGIC;
	signal	nTRIG : STD_LOGIC;
	signal	BIN_CNTR : STD_LOGIC_VECTOR(1 to 2);
	signal	Counter : integer;
	signal	sCLK_STT_RST : STD_LOGIC;
	signal	CLK_START_SET, CLK_START_RESET : STD_LOGIC;
	signal	W_SET, X_SET, Y_SET, Z_SET : STD_LOGIC;
	signal	W_RESET, X_RESET, Y_RESET, Z_RESET : STD_LOGIC;
	signal	sW_TIME, sX_TIME, sY_TIME, sZ_TIME : STD_LOGIC;

BEGIN
-- Fig 5-10A
	sCLK_STT_RST <= OSC and not BIN_CNTR(1) and sZ_TIME and not sW_TIME; -- AC2H4
	CLK_STT_RST <= sCLK_STT_RST;
	CLK_START_SET <= (PUNCH_1_CLUTCH and not READ_CLK_INTLK_LCH and READ_OR_READ_INQ)
		or (RDR_1_CLUTCH and WRITE_LCH and not CRLF);
	CLK_START_RESET <= RST_ATTACH or sCLK_STT_RST;
	CLK_START_FL : FLL port map(CLK_START_SET,CLK_START_RESET,CLK_START); -- AC2G6 AC2F6
	
	BIN_CNTR_P: process(OSC,RST_ATTACH) is
	begin
		if RST_ATTACH='1' then
			BIN_CNTR <= "01";
			else if rising_edge(OSC) then
				BIN_CNTR <= BIN_CNTR + "01";
			end if;
		end if;
	end process;

	OSC_P : process(CLK_START,clk) is
	begin
		if falling_edge(clk) then
			if (CLK_START='0') then
				OSC <= '1';
				Counter <= 0;
			else
				Counter <= Counter + 1;
				if Counter=ClockDivider then
					Counter <= 0;
				end if;
				if (Counter > (ClockDivider/2)) then
					OSC <= '1';
				else
					OSC <= '0';
				end if;
			end if;
		end if;
	end process;
	
	TRIGER <= (not BIN_CNTR(1) and WRITE_LCH) or (READ_OR_READ_INQ and BIN_CNTR(2)); -- AC2G7
	nTRIG  <= (not BIN_CNTR(2) and not WRITE_LCH) or (BIN_CNTR(1) and WRITE_LCH); -- AC2F7 AC2M2
--	POSTRIG <= TRIGER;
--	NEGTRIG <= nTRIG;
--	OSCOut <= OSC;
--	C1 <= BIN_CNTR(1);
--	C2 <= BIN_CNTR(2);
	
	W_SET <=  not sY_TIME and sZ_TIME and (TRIGER and CLK_START); -- AC2E7 AC2F6 ?? 'not' gate ignored
	X_SET <=  not sZ_TIME and sW_TIME and nTRIG;
	Y_SET <=  not sW_TIME and sX_TIME and TRIGER; -- AC2G2
	Z_SET <= (not sX_TIME and sY_TIME and nTRIG) or RST_ATTACH or (OSC and not CLK_START); -- AC2E7 ?? RST_ATTACH or (OSC and not CLK_START) ??
	W_RESET <= (sX_TIME and TRIGER) or RST_ATTACH; -- AC2D7
	X_RESET <= (sY_TIME and nTRIG) or RST_ATTACH; -- AC2G3
	Y_RESET <= (sZ_TIME and TRIGER) or RST_ATTACH or (OSC and not CLK_START); -- AC2F7
	Z_RESET <= (sW_TIME and nTRIG); -- AC2G3
	
	W_JK: FDRSE port map(C=>clk,Q=>sW_TIME,R=>W_RESET,S=>W_SET,CE=>'0',D=>'0');
--	W_FL : FLL port map(W_SET,W_RESET,sW_TIME); -- AC2G2
	W_TIME <= sW_TIME;
	X_JK: FDRSE port map(C=>clk,Q=>sX_TIME,R=>X_RESET,S=>X_SET,CE=>'0',D=>'0');
--	X_FL : FLL port map(X_SET,X_RESET,sX_TIME); -- AC2G2
	X_TIME <= sX_TIME;
	Y_JK: FDRSE port map(C=>clk,Q=>sY_TIME,R=>Y_RESET,S=>Y_SET,CE=>'0',D=>'0');
--	Y_FL : FLL port map(Y_SET,Y_RESET,sY_TIME); -- AC2G2
	Y_TIME <= sY_TIME;
	Z_JK: FDRSE port map(C=>clk,Q=>sZ_TIME,R=>Z_RESET,S=>Z_SET,CE=>'0',D=>'0');
--	Z_FL : FLL port map(Z_SET,Z_RESET,sZ_TIME); -- AC2F5
	Z_TIME <= sZ_TIME;

	CLOCK1_FL : FLL port map(W_SET,X_RESET,CLOCK_1); -- ?? CLOCK_1 isn't defined in the diagrams
																	 -- This is a guess at CLOCK_1 being W_TIME OR X_TIME, but can't do that directly without possible glitches
	
END FMD; 

