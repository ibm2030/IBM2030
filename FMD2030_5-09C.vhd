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
--    File: FMD2030_5-09C.vhd
--    Creation Date: 
--    Description:
--    1050 Typewriter Console input and output translation circuitry and
--		Control Character detection
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
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY n1050_TRANSLATE IS
	port
	(
		-- Inputs        
		DATA_REG_BUS : IN STD_LOGIC_VECTOR(0 to 7); -- 10C
		RDR_ON_LCH : IN STD_LOGIC; -- 10BD3
		PUNCH_1_CLUTCH_1050 : IN STD_LOGIC; -- 10DD5 aka PCH_1_CLUTCH_1050
		HOME_RDR_STT_LCH : IN STD_LOGIC; -- 10BB3
		CLOCK_STT_RST : IN STD_LOGIC; -- 10AC2
		RST_ATTACH : IN STD_LOGIC; -- 10BC2
		W_TIME, X_TIME, Y_TIME, Z_TIME : IN STD_LOGIC; -- 10AXX
		n1050_RST : IN STD_LOGIC; -- 10BA3
		ALLOW_STROBE : IN STD_LOGIC; -- 10CB6
		PROCEED_LCH : IN STD_LOGIC; -- 10BC3
		SHARE_REQ_RST : IN STD_LOGIC; -- 10BB6
		CE_RUN_MODE : IN STD_LOGIC; -- 10DB2
		CE_TI_DECODE : IN STD_LOGIC; -- 10DB2
		SET_LOWER_CASE : IN STD_LOGIC; -- 10CC5
		n1050_RST_LCH : IN STD_LOGIC; -- 10BA3
		READY_SHARE : IN STD_LOGIC; -- 10CE6

		-- Outputs
		TT2_POS_END : OUT STD_LOGIC; -- 10BD3
		XLATE_UC : OUT STD_LOGIC; -- 10C
		RD_SHARE_REQ_LCH : OUT STD_LOGIC; -- 10CD4 10BC3 10BD4
		READ_SHARE_REQ : OUT STD_LOGIC; -- 10BD3
		WRITE_UC : OUT STD_LOGIC; -- 10DD2
		SET_SHIFT_LCH : OUT STD_LOGIC; -- 10CC4
		PCH_1_HOME : OUT STD_LOGIC; -- 10DC5
		RUN : OUT STD_LOGIC; -- 10BB3 10CC3 10BD1 10CE4 10CD2
		UNGATED_RUN : OUT STD_LOGIC; -- 10BC4
		READ : OUT STD_LOGIC; -- 10CD4
		READ_INQ : OUT STD_LOGIC; -- 10CD4
		LC_CHARACTER, UC_CHARACTER : OUT STD_LOGIC; -- 10CC5
		WRITE_LCH : OUT STD_LOGIC; -- 10BD3 10AC1 10AA2 10BB1 10CA5 10CC3
		WRITE_MODE : OUT STD_LOGIC; -- 10CD4
		WRITE_STROBE : OUT STD_LOGIC; -- 10DC5
		WRITE_LCH_RST : OUT STD_LOGIC; -- 10BA1
		RD_OR_RD_INQ : OUT STD_LOGIC;
		
		DEBUG : INOUT DEBUG_BUS;
        
		-- Clocks
--		T1,T2,T3,T4 : IN STD_LOGIC;
--		P1,P2,P3,P4 : IN STD_LOGIC
		clk : IN STD_LOGIC
	);
END n1050_TRANSLATE;

ARCHITECTURE FMD OF n1050_TRANSLATE IS 
signal	sLC_CHARACTER, sUC_CHARACTER : STD_LOGIC;
signal	DataReg4511, DataReg23not00 : STD_LOGIC;
signal	EndCode : STD_LOGIC;
signal	DataRegSpecial1, DataRegSpecial2, DataRegSpecial3, DataRegSpecial : STD_LOGIC;
signal	XLATE_UC_SET, XLATE_UC_RESET : STD_LOGIC;
signal	RD_SHARE_REQ_SET, RD_SHARE_REQ_RESET : STD_LOGIC;
signal	PREFIX_SET,PREFIX_RESET,PREFIX : STD_LOGIC;
signal	BLOCK_SHIFT_SET,BLOCK_SHIFT : STD_LOGIC;
signal	sWRITE_LCH : STD_LOGIC;
signal	UPPER_CASE_DECODE, LOWER_CASE_DECODE : STD_LOGIC;
signal	sRD_SHARE_REQ_LCH : STD_LOGIC;
signal	sREAD, sREAD_INQ, sRD_OR_RD_INQ : STD_LOGIC;
signal	DataReg01xxxxxx, DataRegLCA, DataRegLCB, DataRegLCC, DataRegLCD, DataRegLCE : STD_LOGIC;
signal	DataRegLC, DataRegUC : STD_LOGIC;
signal	PRT_IN_UC_SET, PRT_IN_UC_RESET, PRT_IN_UC : STD_LOGIC;
signal	WRITE_SET, WRITE_RESET : STD_LOGIC;
signal	sUNGATED_RUN : STD_LOGIC;

BEGIN
-- Fig 5-09C
-- Incoming character handling (keyboard codes AB8421 = 234567)
DataReg4511 <= DATA_REG_BUS(4) and DATA_REG_BUS(5); -- AC3F4 AC3D4 XX11XX
DataReg23not00 <= DATA_REG_BUS(2) or DATA_REG_BUS(3); -- AC3B6 01XXXX 10XXXX 11XXXX
-- EndCode <= DATA_REG_BUS(1) and DataReg4511 and not DATA_REG_BUS(2) and DATA_REG_BUS(6); -- 10x111x = EOB
-- EndCode <= '1' when DATA_REG_BUS="0000100" else '0'; -- End is 04=Ctrl+D
EndCode <= '1' when DATA_REG_BUS="0001101" else '0'; -- End is 04=Ctrl+M (return)
TT2_POS_END <= (EndCode and sRD_SHARE_REQ_LCH) or READY_SHARE; -- AC3F7 AC3F2 AC3C7 ?? *or* READY_SHARE ??
-- UPPER_CASE_DECODE <= not DATA_REG_BUS(7) and DATA_REG_BUS(6) and DataReg4511 and not DataReg23not00; -- AC3E2 AB8421=001110=Upshift
UPPER_CASE_DECODE <= '0';
-- LOWER_CASE_DECODE <= DATA_REG_BUS(6) and not DATA_REG_BUS(7) and DATA_REG_BUS(2)	and DATA_REG_BUS(3) and DataReg4511; -- AC3F7 AB8421=111110=Downshift
LOWER_CASE_DECODE <= '0';
-- The following three lines are probably wrong
DataRegSpecial1 <= DataReg23not00 and DataReg4511 and DATA_REG_BUS(6) and DATA_REG_BUS(7); -- AC3E2 "xx1111" but not "111111"
DataRegSpecial2 <= DataReg4511 and DATA_REG_BUS(7) and not DataReg23not00 and not DATA_REG_BUS(6); -- AC3E2 "101101" = Return
DataRegSpecial3 <= DataReg4511 and not DATA_REG_BUS(6) and not DATA_REG_BUS(7); -- AC3B6 "xx1100"
-- DataRegSpecial <= DataRegSpecial1 or DataRegSpecial2 or DataRegSpecial3;
DataRegSpecial <= '0'; -- Ignore for now

XLATE_UC_SET <= UPPER_CASE_DECODE and X_TIME; -- AC3F2
XLATE_UC_RESET <= SET_LOWER_CASE or (X_TIME and LOWER_CASE_DECODE); -- AC3F2
XLATE_UC_FL: FLSRC port map (S=>XLATE_UC_SET, R=>XLATE_UC_RESET, C=>clk, Q=>XLATE_UC); -- ?????

RD_SHARE_REQ_SET <= not DataRegSpecial and not UPPER_CASE_DECODE and not LOWER_CASE_DECODE and sRD_OR_RD_INQ and Y_TIME;
RD_SHARE_REQ_RESET <= SHARE_REQ_RST or RST_ATTACH or (CE_RUN_MODE and CE_TI_DECODE);
RD_SHARE_REQ_FL: FLSRC port map(S=>RD_SHARE_REQ_SET, R=>RD_SHARE_REQ_RESET, C=>clk, Q=>sRD_SHARE_REQ_LCH); -- AC3F5 AC3C7
RD_SHARE_REQ_LCH <= sRD_SHARE_REQ_LCH;
READ_SHARE_REQ <= sRD_SHARE_REQ_LCH and not Y_TIME; -- AC3E3

sREAD <= HOME_RDR_STT_LCH and RDR_ON_LCH and not sWRITE_LCH; -- AC2G7
READ <= sREAD;
sREAD_INQ <= not sWRITE_LCH and RDR_ON_LCH and PROCEED_LCH; -- AC2G7
READ_INQ <= sREAD_INQ;
sRD_OR_RD_INQ <= sREAD or sREAD_INQ;
RD_OR_RD_INQ <= sRD_OR_RD_INQ;
PCH_1_HOME <= PUNCH_1_CLUTCH_1050 or sREAD or sREAD_INQ; -- AC2G3

-- Outgoing character handling
-- Prefix is 0x100111 i.e. 27 or 67
PREFIX_SET <= not DATA_REG_BUS(0) and DATA_REG_BUS(2) and not DATA_REG_BUS(3)
	and not DATA_REG_BUS(4) and DATA_REG_BUS(5) and DATA_REG_BUS(6) and DATA_REG_BUS(7) and Z_TIME; -- AC3B7 AC3F2 AC3D6
PREFIX_FL: FLSRC port map(S=>PREFIX_SET,R=>Y_TIME,C=>clk,Q=>PREFIX); -- AC3F2 AC3G5
-- Block Shift prevents the shift mechanism from being triggered
BLOCK_SHIFT_SET <= PREFIX and X_TIME;
BLOCK_SHIFT_FL: FLSRC port map(S=>BLOCK_SHIFT_SET,R=>W_TIME,C=>clk,Q=>BLOCK_SHIFT); -- AC3F2 AC3C6

DataReg01xxxxxx <= not DATA_REG_BUS(0) and DATA_REG_BUS(1); -- AC3D5 AC3B4
DataRegLCA <= not DATA_REG_BUS(5) and DATA_REG_BUS(7) and DataReg01xxxxxx; -- 01xxx0x1 = 01xx0001 "/" 01xx0011 01xx1001 01xx1011 ".$,#"
DataRegLCB <= not DATA_REG_BUS(4) and not DATA_REG_BUS(6) and DataReg01xxxxxx; -- 01xx0x0x = 01xx0000 "-&" 01xx0001 "/" 01xx0100 01xx0101
DataRegLCC <= DATA_REG_BUS(0) and DATA_REG_BUS(1) and DATA_REG_BUS(2) and DATA_REG_BUS(3); -- AC3F5 1111xxxx = 0-9 = LC
DataRegLCD <= DATA_REG_BUS(2) and DATA_REG_BUS(3) and not DATA_REG_BUS(6) and not DATA_REG_BUS(7)
	and DataReg01xxxxxx; -- AC3B7 0111xx00 = 01110000 01110100 01111000 01111100 "@"
DataRegLCE <= DATA_REG_BUS(0) and not DATA_REG_BUS(1); -- AC3E5 10xxxxxx = LC
DataRegLC <= DataRegLCA or DataRegLCB or DataRegLCC or DataRegLCD or DataRegLCE;
DataRegUC <= not DataRegLC and DATA_REG_BUS(1);
sLC_CHARACTER <= DataRegLC and not BLOCK_SHIFT;
LC_CHARACTER <= sLC_CHARACTER;
sUC_CHARACTER <= DataRegUC and not BLOCK_SHIFT;
UC_CHARACTER <= sUC_CHARACTER;

-- PRT_IN_UC remembers whether the printer is already in UC mode
PRT_IN_UC_SET <= sUC_CHARACTER and Z_TIME and ALLOW_STROBE;
PRT_IN_UC_RESET <= (sLC_CHARACTER and Z_TIME and ALLOW_STROBE) or SET_LOWER_CASE; -- AC3F4
PRINT_IN_UC_FL: FLSRC port map(S=>PRT_IN_UC_SET,R=>PRT_IN_UC_RESET,C=>clk,Q=>PRT_IN_UC); -- ?????
WRITE_UC <= PRT_IN_UC;
-- For now the SHIFT function is disabled as it is not required for ASCII output
-- SET_SHIFT_LCH <= not ((PRT_IN_UC and sLC_CHARACTER and sWRITE_LCH) or (sUC_CHARACTER and sWRITE_LCH and not PRT_IN_UC)); -- AC2E5 AC3D4
SET_SHIFT_LCH <= '0';

WRITE_SET <= not RDR_ON_LCH and not PUNCH_1_CLUTCH_1050 and HOME_RDR_STT_LCH; -- AC2G7
WRITE_RESET <= CLOCK_STT_RST or RST_ATTACH;
WRITE_FL : FLSRC port map(S=>WRITE_SET,R=>WRITE_RESET,C=>clk,Q=>sWRITE_LCH); -- AC2J5 AC2H6
WRITE_LCH <= sWRITE_LCH;
WRITE_LCH_RST <= sWRITE_LCH;
WRITE_MODE <= WRITE_SET and not n1050_RST; -- AC2D7
WRITE_STROBE <= Z_TIME and ALLOW_STROBE and sWRITE_LCH; -- AC2K6

-- Stuff common to input and output
sUNGATED_RUN <= sREAD_INQ or sREAD or sWRITE_LCH; -- AC2G3
UNGATED_RUN <= sUNGATED_RUN;
RUN <= sUNGATED_RUN and not n1050_RST_LCH; -- AC2K5 AC2H6

END FMD; 

