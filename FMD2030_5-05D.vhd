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
--    
--
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

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
		DBG_TD1_1, DBG_TD1_2 : OUT STD_LOGIC_VECTOR(1 to 38);
		DBG_RD_OR_WR_SET1,DBG_RD_OR_WR_RST1 : OUT STD_LOGIC;
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		CLK : IN STD_LOGIC -- 50MHz / 20ns
	);
END RWStgClk1st32k;

ARCHITECTURE FMD OF RWStgClk1st32k IS 

signal START_RD,START_WR : STD_LOGIC;
signal START_1ST_32K : STD_LOGIC;
signal READ_CALL_TO_MEM,WRITE_CALL_TO_MEM : STD_LOGIC;
signal sREAD_CALL : STD_LOGIC;
signal sUSE_LOCAL_MAIN_MEM : STD_LOGIC;
signal USE_LOCAL_Set,USE_LOCAL_Reset : STD_LOGIC;
signal TD1 : STD_LOGIC_VECTOR(1 to 38) := (others=>'0'); -- 20ns steps 20 to 740ns
signal RD_OR_WR_RST1, RD_OR_WR_SET1, nRD_OR_WR_SET1, CTRL_R_WIDTH1, TD1IN : STD_LOGIC;
signal TD1_80, TD1_150, TD1_200, TD1_500, TD1_560, TD1_660, TD1_680, TD1_700 : STD_LOGIC;
signal RD_OR_WR_SET1_RESET, dRD_OR_WR_SET1_RESET, CTRL_R_WIDTH1_RESET : STD_LOGIC;
signal READ_ECHO_1_SET, READ_ECHO_1_RESET, READ_ECHO_2_RESET : STD_LOGIC;
signal WRITE_ECHO_1_SET : STD_LOGIC;
signal WRITE_ECHO_1_RESET : STD_LOGIC;
signal READ_RST_SET1, READ_RST_SET2 : STD_LOGIC;
signal READ_RST_RESET1, READ_RST_RESET2 : STD_LOGIC;
signal RD_RST_CTRL1 : STD_LOGIC;
signal WRITE_RST_SET1 : STD_LOGIC;
signal WRITE_RST_RESET1 : STD_LOGIC;
signal WR_RST_CTRL1 : STD_LOGIC;
signal SET_READ_LCHS1 : STD_LOGIC;
signal DATA_READY1_SET, DATA_READY1_RESET : STD_LOGIC;
signal SET_READ_LCHS1_RESET : STD_LOGIC;
signal dT1 : STD_LOGIC;
signal sDATA_READY_1 : STD_LOGIC;

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
USE_LOCAL: FLL port map(USE_LOCAL_Set,USE_LOCAL_Reset,sUSE_LOCAL_MAIN_MEM); -- CB1E2
USE_LOCAL_MAIN_MEM <= sUSE_LOCAL_MAIN_MEM;
USE_MAIN_MEMORY <= not sUSE_LOCAL_MAIN_MEM; -- CB1H2

START_1ST_32K <= (not EARLY_M_REG_0 and READ_CALL_TO_MEM) or (READ_CALL_TO_MEM and EARLY_LOCAL_STG) or (not M_REG_0 and WRITE_CALL_TO_MEM) or (WRITE_CALL_TO_MEM and sUSE_LOCAL_MAIN_MEM); -- CB1E2
-- START_2ND_32K <= (READ_CALL_TO_MEM and EARLY_M_REG_0 and not sUSE_LOCAL_MAIN_MEM) or (WRITE_CALL_TO_MEM and M_REG_0 and not sUSE_LOCAL_MAIN_MEM); -- CB1E2

-- Generate timing signals relative to START_xxx_32K
-- READ_ECHO_n ON at 150ns OFF at 720ns (or MACH_RST_SW)
-- WRITE_ECHO_n ON at 150ns OFF at 720ns (or MACH_RST_SW)
-- DATA_READY_n ON at 640ns OFF at 700ns (or MACH_RST_SW)

-- First 32K
TD1_80 <= TD1(4); -- 80ns
TD1_150 <= TD1(8); -- 160ns
TD1_200 <= TD1(10); -- 200ns
TD1_500 <= TD1(25); -- 500ns
TD1_560 <= TD1(28); -- 560ns
TD1_660 <= TD1(33); -- 660ns
TD1_680 <= TD1(34); -- 680ns
TD1_700 <= TD1(35); -- 700ns

nRD_OR_WR_SET1 <= not RD_OR_WR_SET1;
RD_OR_WR_RST1_FL: FLL port map(TD1_80, nRD_OR_WR_SET1, RD_OR_WR_RST1);
RD_OR_WR_SET1_RESET <= RD_OR_WR_RST1 or MACH_RST_SW;
-- The delay is to prevent a combinatorial loop:
Delay_RD_OR_WR_SET1_RESET: AR port map (D=>RD_OR_WR_SET1_RESET, clk=>Clk, Q=>dRD_OR_WR_SET1_RESET);
RD_OR_WR_SET1_FL: FLL port map(START_1ST_32K, dRD_OR_WR_SET1_RESET, RD_OR_WR_SET1);
TD1IN <= not RD_OR_WR_RST1 and RD_OR_WR_SET1;

-- READ CLOCK 0
READ_ECHO_1_SET <= TD1_150 and SET_READ_LCHS1;
READ_ECHO_1_RESET <= MACH_RST_SW or (TD1_680 and RD_RST_CTRL1);
READ_ECHO_1_FL: FLL port map(READ_ECHO_1_SET, READ_ECHO_1_RESET, READ_ECHO_1); -- 150 to 680ns
-- READ CLOCK 4
DATA_READY1_SET <= TD1_560 and SET_READ_LCHS1;
DATA_READY1_RESET <= MACH_RST_SW or (TD1_660 and RD_RST_CTRL1);
DATA_READY1_FL: FLL port map(DATA_READY1_SET, DATA_READY1_RESET, sDATA_READY_1); -- 560 to 660ns
DATA_READY_1 <= sDATA_READY_1;

-- READ CLOCK 5
READ_RST_SET1 <= TD1_500 and SET_READ_LCHS1;
READ_RST_RESET1 <= MACH_RST_SW or TD1_700;
READ_RST1_FL: FLL port map(READ_RST_SET1, READ_RST_RESET1, RD_RST_CTRL1); -- 500 to 700ns
-- WRITE CLOCK 0
WRITE_ECHO_1_SET <= TD1_150 and not SET_READ_LCHS1;
WRITE_ECHO_1_RESET <= MACH_RST_SW or (TD1_680 and WR_RST_CTRL1);
WRITE_ECHO_1_FL: FLL port map(WRITE_ECHO_1_SET, WRITE_ECHO_1_RESET, WRITE_ECHO_1); -- 150 to 680ns
-- WRITE CLOCK 4
SET_READ_LCHS1_RESET <= MACH_RST_SW or WRITE_CALL_TO_MEM; -- ??
SET_READ_LCHS1_FL: FLL port map(READ_CALL_TO_MEM, SET_READ_LCHS1_RESET, SET_READ_LCHS1); -- RD CALL to WR CALL
-- WRITE CLOCK 5
WRITE_RST_SET1 <= TD1_500 and not SET_READ_LCHS1;
WRITE_RST_RESET1 <= MACH_RST_SW or TD1_150; -- 150ns or 1050ns or 1500ns?
WRITE_RST1_FL: FLL port map(WRITE_RST_SET1, WRITE_RST_RESET1, WR_RST_CTRL1); -- 500 to 700ns??

-- Second 32K
READ_ECHO_2 <= '0';
DATA_READY_2 <= '0';
WRITE_ECHO_2 <= '0';

-- Debug
DEBUG <= START_RD;
DBG_TD1_1 <= TD1;
DBG_RD_OR_WR_SET1 <= RD_OR_WR_SET1;
DBG_RD_OR_WR_RST1 <= RD_OR_WR_RST1;

delayLine: process(CLK)
begin
	if (rising_edge(CLK)) then
		TD1 <= TD1IN & TD1(1 to TD1'right-1);
	end if;
end process;
-- Debug latch

R_DEBUG: process (clk,T1,TD1IN)
begin
	if rising_edge(clk) then
		if T1='1' and dT1='0' then
			DEBUG1 <= '0'; -- Reset on rising edge of T1
		else if (sDATA_READY_1 and T1)='1' then
			DEBUG1 <= '1'; -- Set on any DATA_READY
			end if;
		end if;
		if T1='1' and dT1='0' then
			DEBUG2 <= '0'; -- Reset on rising edge of T1
		else if (sDATA_READY_1 and T2)='1' then
			DEBUG2 <= '1'; -- Set on any DATA_READY
			end if;
		end if;
		if T1='1' and dT1='0' then
			DEBUG3 <= '0'; -- Reset on rising edge of T1
		else if (sDATA_READY_1 and T3)='1' then
			DEBUG3 <= '1'; -- Set on any DATA_READY
			end if;
		end if;
		if T1='1' and dT1='0' then
			DEBUG4 <= '0'; -- Reset on rising edge of T1
		else if (sDATA_READY_1 and T4)='1' then
			DEBUG4 <= '1'; -- Set on any DATA_READY
			end if;
		end if;
		dT1 <= T1;
	end if;
end process;

	
END FMD; 

