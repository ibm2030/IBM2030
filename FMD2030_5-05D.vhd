---------------------------------------------------------------------------
--    Copyright  2010 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: FMD2030_5-05D.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Read/Write Storage Clocks for 1st 32k
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
--    Revision 1.1 2012-04-07
--		Changed for 64k storage: START_1ST_32K triggered for 1st *and* 2nd 32k
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;

ENTITY RWStgClk1st32k IS
	port
	(
		-- Inputs        
		ALLOW_WRITE : IN STD_LOGIC; -- 03D
		CPU_READ_PWR : IN STD_LOGIC; -- 04D
		SEL_RD_CALL : IN STD_LOGIC; -- 12C
		MAN_RD_CALL : IN STD_LOGIC; -- 03D
		ROAR_RESTT_AND_STOR_BYPASS : IN STD_LOGIC; -- 04B
		SEL_WR_CALL : IN STD_LOGIC; -- 12C
		MAN_WR_CALL : IN STD_LOGIC; -- 03D
		CPU_WRITE_PWR : IN STD_LOGIC; -- 04D
		EARLY_LOCAL_STG : IN STD_LOGIC; -- 04D
		EARLY_M_REG_0 : IN STD_LOGIC; -- 07B
		M_REG_0 : IN STD_LOGIC; -- 07B
		MACH_RST_SW : IN STD_LOGIC; -- 03D


		-- Outputs
		READ_CALL : OUT STD_LOGIC; -- 03A,03B
		USE_LOCAL_MAIN_MEM : OUT STD_LOGIC; -- 06D
		USE_MAIN_MEMORY : OUT STD_LOGIC; -- 06D
		READ_ECHO_1, READ_ECHO_2 : OUT STD_LOGIC; -- 03D
		DATA_READY_1, DATA_READY_2 : OUT STD_LOGIC; -- 03A 03B
		WRITE_ECHO_1, WRITE_ECHO_2 : OUT STD_LOGIC; -- 03D
        
		-- Debug
		DEBUG1,DEBUG2,DEBUG3,DEBUG4 : OUT STD_LOGIC;
		DEBUG : OUT STD_LOGIC;
		DBG_TD1_1, DBG_TD1_2 : OUT STD_LOGIC_VECTOR(0 to 48);
		DBG_RD_OR_WR_SET1,DBG_RD_OR_WR_RST1 : OUT STD_LOGIC;
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		clk40M : IN STD_LOGIC; -- 40MHz / 25ns
		clk50M : IN STD_LOGIC; -- 50MHz / 20ns
		sysclk : IN STD_LOGIC -- Fast
	);
END RWStgClk1st32k;

ARCHITECTURE FMD OF RWStgClk1st32k IS 

attribute mark_debug : string;
attribute keep : string;

signal START_RD,START_WR : STD_LOGIC;
signal START_1ST_32K, START_2ND_32K : STD_LOGIC;
signal READ_CALL_TO_MEM,WRITE_CALL_TO_MEM : STD_LOGIC;
signal sREAD_CALL : STD_LOGIC;
signal sUSE_LOCAL_MAIN_MEM : STD_LOGIC;
signal USE_LOCAL_Set,USE_LOCAL_Reset : STD_LOGIC;
signal TD1 : STD_LOGIC_VECTOR(0 to 48) := (others=>'0'); -- 25ns steps 25 to 1200ns
signal RD_OR_WR_SET1, RD_OR_WR_RST1, TD1IN : STD_LOGIC := '0';
signal RD_OR_WR_SET1_RESET, RD_OR_WR_SET1_SET, RD_OR_WR_RST1_SET, nRD_OR_WR_SET1 : STD_LOGIC; 
signal CTRL_R_WIDTH1, nTD1_125 : STD_LOGIC;
-- signal TD1_80, TD1_150, TD1_200, TD1_500, TD1_560, TD1_660, TD1_680, TD1_700 : STD_LOGIC;
signal TD1_25, TD1_75, TD1_125, TD1_150, TD1_400, TD1_500, TD1_525, TD1_725, TD1_750, TD1_775, TD1_800, TD1_875, TD1_925, TD1_950, TD1_1050, TD1_1200 : STD_LOGIC;
signal dRD_OR_WR_SET1_RESET, CTRL_R_WIDTH1_RESET : STD_LOGIC;
signal READ_ECHO_1_SET, READ_ECHO_1_RESET, READ_ECHO_2_RESET : STD_LOGIC;
signal WRITE_ECHO_1_SET : STD_LOGIC;
signal WRITE_ECHO_1_RESET : STD_LOGIC;
signal READ_RST_SET1, READ_RST_SET2 : STD_LOGIC;
signal READ_RST_RESET1, READ_RST_RESET2 : STD_LOGIC;
signal RD_RST_CTRL1 : STD_LOGIC := '0';
signal WRITE_RST_SET1 : STD_LOGIC;
signal WRITE_RST_RESET1 : STD_LOGIC;
signal WR_RST_CTRL1 : STD_LOGIC := '0';
signal SET_READ_LCHS1 : STD_LOGIC := '0';
signal DATA_READY1_SET, DATA_READY1_RESET : STD_LOGIC;
signal SET_READ_LCHS1_RESET : STD_LOGIC;
signal dT1 : STD_LOGIC;
signal sDATA_READY_1 : STD_LOGIC := '0';

attribute mark_debug of READ_CALL_TO_MEM : signal is "true";
attribute keep of READ_CALL_TO_MEM : signal is "true";
attribute mark_debug of WRITE_CALL_TO_MEM : signal is "true";
attribute keep of WRITE_CALL_TO_MEM : signal is "true";
attribute mark_debug of DATA_READY_1 : signal is "true";
attribute keep of DATA_READY_1 : signal is "true";
attribute mark_debug of DATA_READY1_SET : signal is "true";
attribute keep of DATA_READY1_SET : signal is "true";
attribute mark_debug of DATA_READY1_RESET : signal is "true";
attribute keep of DATA_READY1_RESET : signal is "true";
attribute mark_debug of SET_READ_LCHS1 : signal is "true";
attribute keep of SET_READ_LCHS1 : signal is "true";
attribute mark_debug of RD_RST_CTRL1 : signal is "true";
attribute keep of RD_RST_CTRL1 : signal is "true";
attribute mark_debug of WR_RST_CTRL1 : signal is "true";
attribute keep of WR_RST_CTRL1 : signal is "true";
attribute mark_debug of TD1IN,TD1_500,TD1_750,TD1_925,TD1_1200 : signal is "true";
attribute keep of TD1IN,TD1_500,TD1_750,TD1_925,TD1_1200 : signal is "true";

BEGIN
-- Fig 5-05D
START_RD <= not ALLOW_WRITE and CPU_READ_PWR and T1; -- AA1K4
START_WR <= ALLOW_WRITE and CPU_WRITE_PWR and T1; -- AA1K4
sREAD_CALL <= START_RD or SEL_RD_CALL or MAN_RD_CALL; -- AA1J2
READ_CALL <= sREAD_CALL;
READ_CALL_TO_MEM <= sREAD_CALL and not ROAR_RESTT_AND_STOR_BYPASS; -- AA1J3,AA1C2
WRITE_CALL_TO_MEM <= (MAN_WR_CALL or SEL_WR_CALL or START_WR) and not ROAR_RESTT_AND_STOR_BYPASS; -- AA1J2,AA1J3

USE_LOCAL_Set <= EARLY_LOCAL_STG and READ_CALL_TO_MEM;
USE_LOCAL_Reset <= not EARLY_LOCAL_STG and READ_CALL_TO_MEM;
USE_LOCAL: FL port map(clk=>sysclk, S=>USE_LOCAL_Set, R=>USE_LOCAL_Reset, Q=>sUSE_LOCAL_MAIN_MEM); -- CB1E2
USE_LOCAL_MAIN_MEM <= sUSE_LOCAL_MAIN_MEM;
USE_MAIN_MEMORY <= not sUSE_LOCAL_MAIN_MEM; -- CB1H2

-- START_1ST_32K <= (not EARLY_M_REG_0 and READ_CALL_TO_MEM) or (READ_CALL_TO_MEM and EARLY_LOCAL_STG) or (not M_REG_0 and WRITE_CALL_TO_MEM) or (WRITE_CALL_TO_MEM and sUSE_LOCAL_MAIN_MEM); -- CB1E2
-- START_2ND_32K <= (READ_CALL_TO_MEM and EARLY_M_REG_0 and not sUSE_LOCAL_MAIN_MEM) or (WRITE_CALL_TO_MEM and M_REG_0 and not sUSE_LOCAL_MAIN_MEM); -- CB1E2
START_1ST_32K <= READ_CALL_TO_MEM or WRITE_CALL_TO_MEM; -- CB1E2 combined 1st & 2nd 32k

-- Generate timing signals relative to START_xxx_32K
-- READ_ECHO_n ON at 150ns OFF at 720ns (or MACH_RST_SW)
-- WRITE_ECHO_n ON at 150ns OFF at 720ns (or MACH_RST_SW)
-- DATA_READY_n ON at 640ns OFF at 700ns (or MACH_RST_SW)

-- First 32K 40MHz clk, 1000ns cycle
--TD1_25 <= TD1(0);   -- 25ns
--TD1_75 <= TD1(2);   -- 75ns
--TD1_125 <= TD1(4);  -- 125ns
--TD1_150 <= TD1(5);  -- 150ns
--TD1_400 <= TD1(15); -- 400ns
--TD1_500 <= TD1(19); -- 500ns
--TD1_525 <= TD1(20); -- 525ns
--TD1_725 <= TD1(28); -- 725ns
--TD1_750 <= TD1(29); -- 750ns
--TD1_775 <= TD1(30); -- 775ns
--TD1_800 <= TD1(31); -- 800ns
--TD1_875 <= TD1(34); -- 875ns
--TD1_925 <= TD1(36); -- 925ns
--TD1_950 <= TD1(37); -- 950ns
--TD1_1050 <= TD1(41); -- 1050ns
--TD1_1200 <= TD1(47); -- 1200ns

-- First 32K 50MHz (20ns) clk, 750ns cycle
TD1_25 <= TD1(0);   -- 25ns
TD1_75 <= TD1(2);   -- 75ns
TD1_125 <= TD1(5);  -- 125ns (has to be more than half a phase, 95ns)
TD1_150 <= TD1(6);  -- 150ns
TD1_400 <= TD1(15); -- 400ns
TD1_500 <= TD1(19); -- 500ns
TD1_525 <= TD1(20); -- 525ns
TD1_725 <= TD1(28); -- 725ns
TD1_750 <= TD1(29); -- 750ns
TD1_775 <= TD1(30); -- 775ns
TD1_800 <= TD1(31); -- 800ns
TD1_875 <= TD1(34); -- 875ns
TD1_925 <= TD1(36); -- 925ns
TD1_950 <= TD1(37); -- 950ns
TD1_1050 <= TD1(41); -- 1050ns
TD1_1200 <= TD1(47); -- 1200ns

RD_OR_WR_RST1_FL: FL port map(clk=>sysclk, S=>TD1_125, R=>nRD_OR_WR_SET1, Q=>RD_OR_WR_RST1);
RD_OR_WR_SET1_RESET <= RD_OR_WR_RST1 or MACH_RST_SW;
-- The delay is to prevent a combinatorial loop:
-- Delay_RD_OR_WR_SET1_RESET: AR port map (clk=>sysclk, D=>RD_OR_WR_SET1_RESET, Q=>dRD_OR_WR_SET1_RESET);
RD_OR_WR_SET1_FL: FLF port map(clk=>sysclk, S=>START_1ST_32K, R=>RD_OR_WR_SET1_RESET, Q=>RD_OR_WR_SET1);
nRD_OR_WR_SET1 <= not RD_OR_WR_SET1;
nTD1_125 <= not TD1_125;
-- RD_OR_WR_RST1 <= not nRD_OR_WR_RST1;
TD1IN <= not RD_OR_WR_RST1 and RD_OR_WR_SET1;

--RD_OR_WR_RST1_SET <= START_1ST_32K and not RD_OR_WR_SET1;
--RD_OR_WR_RST1_FL : FLF port map(clk=>sysclk, S=>RD_OR_WR_RST1_SET, R=>TD1_125, Q=>TD1IN);
--RD_OR_WR_SET1_SET <= TD1_125 and TD1IN;
--RD_OR_WR_SET1_RESET <= not START_1ST_32K;
--RD_OR_WR_SET1_FL : FLF port map(clk=>sysclk, S=>RD_OR_WR_SET1_SET, R=>RD_OR_WR_SET1_RESET, Q=>RD_OR_WR_SET1);

-- READ CLOCK 0 READ ECHO 25-1050ns
READ_ECHO_1_SET <= TD1_25 and SET_READ_LCHS1;
READ_ECHO_1_RESET <= MACH_RST_SW or (TD1_1050 and RD_RST_CTRL1);
READ_ECHO_1_FL: FLF port map(clk=>sysclk, S=>READ_ECHO_1_SET, R=>READ_ECHO_1_RESET, Q=>READ_ECHO_1); -- 25 to 1050ns
-- READ CLOCK 4 DATA READY 750-925ns
DATA_READY1_SET <= TD1_750 and SET_READ_LCHS1;
DATA_READY1_RESET <= MACH_RST_SW or (TD1_925 and RD_RST_CTRL1);
DATA_READY1_FL: FLF port map(clk=>sysclk, S=>DATA_READY1_SET, R=>DATA_READY1_RESET, Q=>sDATA_READY_1); -- 750 to 925ns
DATA_READY_1 <= sDATA_READY_1;
-- READ CLOCK 5 RD RST CTRL 500-1200ns
READ_RST_SET1 <= TD1_500 and SET_READ_LCHS1;
READ_RST_RESET1 <= MACH_RST_SW or TD1_1200;
READ_RST1_FL: FLF port map(clk=>sysclk, S=>READ_RST_SET1, R=>READ_RST_RESET1, Q=>RD_RST_CTRL1); -- 500 to 1200ns

-- WRITE CLOCK 0 WRITE ECHO 150-950ns
WRITE_ECHO_1_SET <= TD1_150 and not SET_READ_LCHS1;
WRITE_ECHO_1_RESET <= MACH_RST_SW or (TD1_950 and WR_RST_CTRL1);
WRITE_ECHO_1_FL: FLF port map(clk=>sysclk, S=>WRITE_ECHO_1_SET, R=>WRITE_ECHO_1_RESET, Q=>WRITE_ECHO_1); -- 150 to 950ns
-- WRITE CLOCK 4 SET READ LCHS
-- SET_READ_LCHS1_RESET <= MACH_RST_SW or (WRITE_CALL_TO_MEM and WR_RST_CTRL1); -- ??
SET_READ_LCHS1_RESET <= MACH_RST_SW or WRITE_CALL_TO_MEM; -- Remove WR_RST_CTRL
SET_READ_LCHS1_FL: FLF port map(clk=>sysclk, S=>READ_CALL_TO_MEM, R=>SET_READ_LCHS1_RESET, Q=>SET_READ_LCHS1); -- RD CALL to WR CALL
-- WRITE CLOCK 5 WR RST CTRL 500-1050ns
WRITE_RST_SET1 <= TD1_500 and not SET_READ_LCHS1;
WRITE_RST_RESET1 <= MACH_RST_SW or TD1_150; -- 150ns or 1050ns or 1500ns?
WRITE_RST1_FL: FLF port map(clk=>sysclk, S=>WRITE_RST_SET1, R=>WRITE_RST_RESET1, Q=>WR_RST_CTRL1); -- 500 to 150ns??

-- Second 32K
READ_ECHO_2 <= '0';
DATA_READY_2 <= '0';
WRITE_ECHO_2 <= '0';

-- Debug
--DEBUG <= START_RD;
--DBG_TD1_1 <= TD1;
--DBG_TD1_2 <= TD1;
--DBG_RD_OR_WR_SET1 <= RD_OR_WR_SET1;
--DBG_RD_OR_WR_RST1 <= RD_OR_WR_RST1;

delayLine: process(clk50M)
begin
	if (rising_edge(clk50M)) then
		TD1 <= TD1IN & TD1(0 to TD1'right-1);
	end if;
end process;
-- Debug latch

--R_DEBUG: process (sysclk,T1,TD1IN)
--begin
--	if rising_edge(sysclk) then
--		if T1='1' and dT1='0' then
--			DEBUG1 <= '0'; -- Reset on rising edge of T1
--		else if (sDATA_READY_1 and T1)='1' then
--			DEBUG1 <= '1'; -- Set on any DATA_READY
--			end if;
--		end if;
--		if T1='1' and dT1='0' then
--			DEBUG2 <= '0'; -- Reset on rising edge of T1
--		else if (sDATA_READY_1 and T2)='1' then
--			DEBUG2 <= '1'; -- Set on any DATA_READY
--			end if;
--		end if;
--		if T1='1' and dT1='0' then
--			DEBUG3 <= '0'; -- Reset on rising edge of T1
--		else if (sDATA_READY_1 and T3)='1' then
--			DEBUG3 <= '1'; -- Set on any DATA_READY
--			end if;
--		end if;
--		if T1='1' and dT1='0' then
--			DEBUG4 <= '0'; -- Reset on rising edge of T1
--		else if (sDATA_READY_1 and T4)='1' then
--			DEBUG4 <= '1'; -- Set on any DATA_READY
--			end if;
--		end if;
--		dT1 <= T1;
--	end if;
--end process;

	
END FMD; 

