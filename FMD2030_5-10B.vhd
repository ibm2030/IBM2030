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
--    File: FMD2030_5-10B.vhd
--    Creation Date: 
--    Description:
--    1050 Typewriter Console tag signal generation
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

ENTITY n1050_TAGS IS
	port
	(
		-- Inputs
		RD_OR_RD_INQ : IN STD_LOGIC; -- 09CC5
		Y_TIME : IN STD_LOGIC; -- 10AXX
		RD_INLK_RST : IN STD_LOGIC; -- 10DC5
		WRITE_LCH_RST : IN STD_LOGIC; -- 09CE2
		PCH_1_CLUTCH : IN STD_LOGIC; -- 10DD5
		TT2_POS_END : IN STD_LOGIC; -- 09CB5
		WRITE_LCH : IN STD_LOGIC; -- 09CD2
		Z_TIME : IN STD_LOGIC; -- 10AXX
		CE_DATA_ENTER_GT : IN STD_LOGIC; -- 10DA2
		CE_TA_DECODE : IN STD_LOGIC;  -- 10DA1
		GT_1050_TAGS_OUT : IN STD_LOGIC; -- 10CE2
		RECYCLE_RESET : IN STD_LOGIC; -- 04CA5
--		CE_MODE : IN STD_LOGIC; -- ---A6
		CE_RESET : IN STD_LOGIC; -- 10DC2
		RUN : IN STD_LOGIC; -- 09CE6
		TT3_POS_1050_OPER : IN STD_LOGIC; -- 10DD4
		TAGS_OUT_BUS : IN STD_LOGIC_VECTOR(0 to 7); -- 10CD1
		n1050_CE_MODE : IN STD_LOGIC; -- 10DB3
		P_1050_SEL_IN : IN STD_LOGIC; -- 08DC1 SELECT IN from external Mpx devices to 1050 = TAGS_IN.SEL_IN
		P_1050_SEL_OUT : IN STD_LOGIC; -- 08DD6 SELECT OUT from Channel
		MPX_OPN_LCH_GT : IN STD_LOGIC; -- 08CE3
		CK_SAL_P_BIT : IN STD_LOGIC; -- 01CXX
		EXIT_MPLX_SHARE : IN STD_LOGIC; -- 10DB3
		ADDR_OUT : IN STD_LOGIC; -- 08DA5
		RD_SHARE_REQ : IN STD_LOGIC; -- 09CC6
		RD_SHARE_REQ_LCH : IN STD_LOGIC; -- 09CC6
		SUPPRESS_OUT : IN STD_LOGIC; -- 08DD6
		WR_SHARE_REQ : IN STD_LOGIC; -- 10CA6
		CE_SEL_O : IN STD_LOGIC; -- 10DB2
		INTRV_REQ : IN STD_LOGIC; -- 10CD6
		RDY_SHARE : IN STD_LOGIC; -- 10CE6
		UNGATED_RUN : IN STD_LOGIC; -- 09CE6
		REQUEST_KEY : IN STD_LOGIC; -- 10DE5
		
		-- Outputs
		n1050_RST_LCH : OUT STD_LOGIC; -- 10DF2 09CD1 10CA5 09CE5
		HOME_RDR_START_LCH : OUT STD_LOGIC; -- 09CE4 09CE1 10DE2
		HOME_RDR_STOP : OUT STD_LOGIC; -- 10DC5
		PROCEED_LCH : OUT STD_LOGIC; -- 09CE4 10CC2 10DE2
		MICRO_SHARE_LCH : OUT STD_LOGIC; -- 10DE2
		RDR_ON_LCH : OUT STD_LOGIC; -- 09CE4 10DE2 09CE1
		TA_REG_POS_4 : OUT STD_LOGIC; -- 10DE2
		AUDIBLE_ALARM : OUT STD_LOGIC; -- 14AXX
		CR_LF : OUT STD_LOGIC; -- 10AC1 10DE2
		TA_REG_POS_6_ATTENTION_RST : OUT STD_LOGIC; -- ---D4 10DE2 10CE5
		CPU_LINES_TO_1050 : OUT CONN_1050; -- 10DE3
		SHARE_REQ_RST : OUT STD_LOGIC; -- 09CC5 10CE4 10CA5
		T_REQUEST : OUT STD_LOGIC; -- 07BD3 06BA3 07BB3
		CPU_REQUEST_IN : OUT STD_LOGIC; -- 10DE3
		n1050_OP_IN : OUT STD_LOGIC; -- 08DD4 10CA4
		n1050_REQ_IN : OUT STD_LOGIC; -- 08DD2
		TT6_POS_ATTN : OUT STD_LOGIC; -- 10DC4 04AB6
		n1050_INSTALLED : OUT STD_LOGIC; -- 08DC1
		n1050_SEL_O : OUT STD_LOGIC; -- 08DD5 SELECT OUT to external Mpx devices
		n1050_SEL_IN : OUT STD_LOGIC; -- SELECT IN to Channel
		TA_REG_SET : OUT STD_LOGIC; -- 10CB4
		RD_CLK_INLK_LCH : OUT STD_LOGIC; -- 10AC1
		RESTORE : OUT STD_LOGIC; -- 10CD4
		RST_ATTACH : OUT STD_LOGIC; -- 09C 10A 10C
		DEBUG : INOUT DEBUG_BUS;
		
		-- Clocks
		clk : IN STD_LOGIC;
		Clock1ms : IN STD_LOGIC;
		Clock60Hz : IN STD_LOGIC;
		T1,T2,T3,T4 : IN STD_LOGIC;
		P1,P2,P3,P4 : IN STD_LOGIC
		
	);
END n1050_TAGS;

ARCHITECTURE FMD OF n1050_TAGS IS 
signal	RD_CLK_INLK_SET, sRD_CLK_INLK_LCH : STD_LOGIC;
signal	n1050_RST_RESET, n1050_RST_SET, s1050_RST_LCH : STD_LOGIC;
signal	sRST_ATTACH : STD_LOGIC;
signal	sTA_REG_SET, TA_REG_RST : STD_LOGIC;
signal	SET_HOME_RDR_STT : STD_LOGIC;
signal	sHOME_RDR_START_LCH : STD_LOGIC;
signal	SET_PROCEED : STD_LOGIC;
signal	sPROCEED_LCH : STD_LOGIC;
signal	MICRO_SHARE_REQ : STD_LOGIC;
signal	SET_MICRO_SHARE : STD_LOGIC;
signal	sMICRO_SHARE_LCH : STD_LOGIC;
signal	SET_RDR_2 : STD_LOGIC;
signal	sRDR_ON_LCH : STD_LOGIC;
signal	MS5000_IN : STD_LOGIC;
signal	sTA_REG_POS_4 : STD_LOGIC;
signal	MS1000_IN : STD_LOGIC;
signal	sCR_LF : STD_LOGIC;
signal	sTA_REG_POS_6_ATTENTION_RST : STD_LOGIC;
signal	n1050_SEL_OUT : STD_LOGIC;
signal	sn1050_SEL_IN : STD_LOGIC;
signal	SEL_O_DLY : STD_LOGIC;
signal	SET_SEL_O_DET, RESET_SEL_O_DET : STD_LOGIC;
signal	SEL_O_DET : STD_LOGIC;
signal	SET_1050_OP_IN, RESET_1050_OP_IN : STD_LOGIC;
signal	sn1050_OP_IN : STD_LOGIC;
signal	SET_SEL_O_DLY, RESET_SEL_O_DLY : STD_LOGIC;
signal	MPX_LCH_OFF : STD_LOGIC;
signal	CPU_SEL_O_OR_SEL_IN : STD_LOGIC;
signal	SET_1050_EXIT_SHARE_REQ : STD_LOGIC;
signal	n1050_EXIT_SHARE_REQ : STD_LOGIC;
signal	sCPU_REQUEST_IN : STD_LOGIC;
signal	SET_PREPARE_TO_SHARE, RESET_PREPARE_TO_SHARE : STD_LOGIC;
signal	PREPARE_TO_SHARE : STD_LOGIC;
signal	SET_ATTN_INTLK, RESET_ATTN_INTLK : STD_LOGIC;
signal	ATTN_INTLK : STD_LOGIC := '1';
signal	SS20_IN, SS20 : STD_LOGIC;
signal	SET_ATTN,RESET_ATTN : STD_LOGIC;
signal	sTT6_POS_ATTN : STD_LOGIC := '0';
signal	sRESTORE : STD_LOGIC;

BEGIN
-- Fig 5-10B
RD_CLK_INLK_SET <= RD_OR_RD_INQ and Y_TIME; -- AC3E3
RD_CLK_INLK: FLSRC port map(RD_CLK_INLK_SET,RD_INLK_RST,clk,sRD_CLK_INLK_LCH); -- AC3E3, AC3F2
RD_CLK_INLK_LCH <= sRD_CLK_INLK_LCH;
n1050_RST_RESET <= not sRD_CLK_INLK_LCH and not WRITE_LCH_RST; -- AC2J5
n1050_RST_SET <= TAGS_OUT_BUS(7) and sTA_REG_SET; -- AC2K5
n1050_RST : FLSRC port map(n1050_RST_SET, n1050_RST_RESET, clk, s1050_RST_LCH); -- AC2K5 AC2E2
n1050_RST_LCH <= s1050_RST_LCH;
CPU_LINES_TO_1050.n1050_RST_LCH <= s1050_RST_LCH;
CPU_LINES_TO_1050.n1050_RESET <= ((((sRD_CLK_INLK_LCH and not PCH_1_CLUTCH) or (WRITE_LCH and Z_TIME)) and s1050_RST_LCH) or sRST_ATTACH) and TT3_POS_1050_OPER; -- AC2H4 AC2G3 AC2K3 AC2K6
sTA_REG_SET <= (CE_DATA_ENTER_GT and CE_TA_DECODE) or (P3 and GT_1050_TAGS_OUT); -- AC2K3
TA_REG_SET <= sTA_REG_SET;
TA_REG_RST <= (CE_DATA_ENTER_GT and CE_TA_DECODE) or (T3 and GT_1050_TAGS_OUT) or sRST_ATTACH; -- AC2J2
sRST_ATTACH <= (RECYCLE_RESET and not n1050_CE_MODE) or CE_RESET; -- AC2H3 AC2H5 AC2K2
RST_ATTACH <= sRST_ATTACH;
MS16: SS port map(Clock1ms,16,RUN,sRESTORE); -- 16ms Single-shot AC2L2
CPU_LINES_TO_1050.RESTORE <= sRESTORE;
RESTORE <= sRESTORE;

SET_HOME_RDR_STT <= TAGS_OUT_BUS(0) and sTA_REG_SET;
HOME_RDR_STT_FL: FLSRC port map(SET_HOME_RDR_STT,TA_REG_RST,clk,sHOME_RDR_START_LCH); -- AC2H3 AC2K4
HOME_RDR_START_LCH <= sHOME_RDR_START_LCH;

CPU_LINES_TO_1050.HOME_RDR_START <= sHOME_RDR_START_LCH and TT3_POS_1050_OPER and not sPROCEED_LCH; -- AC2L6
HOME_RDR_STOP <= TT3_POS_1050_OPER and not RUN; -- AC2K6

SET_PROCEED <= TAGS_OUT_BUS(3) and sTA_REG_SET;
PROCEED_FL: FLSRC port map(SET_PROCEED,TA_REG_RST,clk,sPROCEED_LCH); -- AC2D6 AC2K7
PROCEED_LCH <= sPROCEED_LCH;
CPU_LINES_TO_1050.PROCEED <= sPROCEED_LCH and not RD_SHARE_REQ_LCH and not MICRO_SHARE_REQ; -- AC2K6

MICRO_SHARE_REQ <= (not SUPPRESS_OUT and sMICRO_SHARE_LCH) or (sPROCEED_LCH and sMICRO_SHARE_LCH); -- AC2K7
SET_MICRO_SHARE <= TAGS_OUT_BUS(2) and sTA_REG_SET;
MICRO_SHARE_FL: FLSRC port map(SET_MICRO_SHARE,TA_REG_RST,clk,sMICRO_SHARE_LCH); -- AC2H3 AC2K4
MICRO_SHARE_LCH <= sMICRO_SHARE_LCH;

SET_RDR_2 <= TAGS_OUT_BUS(1) and sTA_REG_SET;
RDR_2_FL: FLSRC port map(SET_RDR_2,TA_REG_RST,clk,sRDR_ON_LCH); -- AC2H3 AC2K4
RDR_ON_LCH <= sRDR_ON_LCH;

CPU_LINES_TO_1050.RDR_2_HOLD <= ((sRDR_ON_LCH or not RD_SHARE_REQ) and TT3_POS_1050_OPER) -- AC2J5 AC2K6
	or (sRDR_ON_LCH and TT2_POS_END) or not WRITE_LCH; -- AC2L6 AC2H4

MS5000_IN <= sTA_REG_SET and TAGS_OUT_BUS(4);
MS5000: SS port map(Clock60Hz,300,MS5000_IN, sTA_REG_POS_4); -- AC2G3 AC3G6 AC3F2 5s single-shot
TA_REG_POS_4 <= sTA_REG_POS_4;
AUDIBLE_ALARM <= sTA_REG_POS_4; -- AC3H5

MS1000_IN <= (sRST_ATTACH and TT3_POS_1050_OPER) or (sTA_REG_SET and TAGS_OUT_BUS(5)); -- AC2K7
MS1000: SS port map(clk,5000000,MS1000_IN, sCR_LF); -- AC2L2 AC2D6 1s single-shot : 100ms (5000000) is enough
CR_LF <= sCR_LF;
CPU_LINES_TO_1050.CARR_RETURN_AND_LINE_FEED <= sCR_LF; -- AC2L6

sTA_REG_POS_6_ATTENTION_RST <= sTA_REG_SET and TAGS_OUT_BUS(6); -- AC2H4
TA_REG_POS_6_ATTENTION_RST <= sTA_REG_POS_6_ATTENTION_RST;

-- Select one group of these lines depending on whether 1050 is high priority (on SEL OUT) or low priority (on SEL IN)
-- Low priority (AC3E7) :
n1050_SEL_O <= P_1050_SEL_OUT; -- AC3E7 Pass SEL OUT through
sn1050_SEL_IN <= not (n1050_CE_MODE and not sn1050_OP_IN) and not (CPU_SEL_O_OR_SEL_IN and SEL_O_DLY); -- AC3E7
CPU_SEL_O_OR_SEL_IN <= P_1050_SEL_IN; -- AC3E7 AC3B6
-- High priority (AC3D7) :
-- n1050_SEL_O <= not (n1050_CE_MODE and not sn1050_OP_IN) and not (CPU_SEL_O_OR_SEL_IN and SEL_O_DLY); -- AC3D7
-- sn1050_SEL_IN <= P_1050_SEL_IN; -- AC3D7 Pass SEL IN through
-- CPU_SEL_O_OR_SEL_IN <= P_1050_SEL_OUT; -- AC3D7 AC3B6
n1050_SEL_IN <= sn1050_SEL_IN;

-- Here's what it looks like in the FMD, but the dots are probably significant! :
-- n1050_SEL_OUT <= not P_1050_SEL_IN or (n1050_CE_MODE and not sn1050_OP_IN) or (CPU_SEL_O_OR_SEL_IN and SEL_O_DLY); -- AC3E7 AC3D7
-- n1050_SEL_IN <= not P_1050_SEL_OUT or (n1050_CE_MODE and not sn1050_OP_IN) or (CPU_SEL_O_OR_SEL_IN and SEL_O_DLY); -- AC3D7 AC3E7
-- CPU_SEL_O_OR_SEL_IN <= n1050_SEL_OUT or n1050_SEL_IN; -- AC3D7 AC3E7 AC3B6

SET_SEL_O_DET <= T1 and CPU_SEL_O_OR_SEL_IN;
RESET_SEL_O_DET <= not CPU_SEL_O_OR_SEL_IN or sRST_ATTACH;
SEL_O_DET_FL: FLSRC port map(SET_SEL_O_DET,RESET_SEL_O_DET,clk,SEL_O_DET); -- AC3E6

SET_SEL_O_DLY <= T3 and SEL_O_DET and not sn1050_OP_IN;
RESET_SEL_O_DLY <= sRST_ATTACH or not CPU_SEL_O_OR_SEL_IN;
SEL_O_DLY_FL: FLSRC port map(SET_SEL_O_DLY,RESET_SEL_O_DLY,clk,SEL_O_DLY); -- AC3E6

SET_1050_OP_IN <= (CPU_SEL_O_OR_SEL_IN and PREPARE_TO_SHARE) or (n1050_CE_MODE and PREPARE_TO_SHARE);
RESET_1050_OP_IN <= MPX_LCH_OFF or sRST_ATTACH; -- ??
n1050_OP_IN_FL: FLSRC port map(SET_1050_OP_IN,RESET_1050_OP_IN,clk,sn1050_OP_IN);
n1050_OP_IN <= sn1050_OP_IN;

SET_1050_EXIT_SHARE_REQ <= MPX_OPN_LCH_GT and not CK_SAL_P_BIT; -- AC3C7
n1050_EXIT_SHARE_REQ_FL : FLSRC port map(SET_1050_EXIT_SHARE_REQ,T1,clk,n1050_EXIT_SHARE_REQ); -- AC3C6 AC3E4

SHARE_REQ_RST <= (n1050_EXIT_SHARE_REQ and not n1050_CE_MODE and T4) or EXIT_MPLX_SHARE; -- AC3E4
MPX_LCH_OFF <= EXIT_MPLX_SHARE or (n1050_EXIT_SHARE_REQ and not n1050_CE_MODE and T4); -- AC3E4
T_REQUEST <= not n1050_CE_MODE and sCPU_REQUEST_IN; -- AC3D6 ?? Not sure about sCPU_REQUEST_IN - diagram is missing this!

sCPU_REQUEST_IN <= MICRO_SHARE_REQ or RD_SHARE_REQ_LCH or WR_SHARE_REQ or INTRV_REQ or RDY_SHARE
	or (not sMICRO_SHARE_LCH and UNGATED_RUN and sTT6_POS_ATTN); -- AC3F7 AC3D6
CPU_REQUEST_IN <= sCPU_REQUEST_IN;

	
SET_PREPARE_TO_SHARE <= (not CPU_SEL_O_OR_SEL_IN and n1050_CE_MODE and not ADDR_OUT and sCPU_REQUEST_IN) or (sCPU_REQUEST_IN and CE_SEL_O); -- AC3C7 AC3E2
RESET_PREPARE_TO_SHARE <= not sCPU_REQUEST_IN or sRST_ATTACH;
PREPARE_TO_SHARE_FL: FLSRC port map(SET_PREPARE_TO_SHARE,RESET_PREPARE_TO_SHARE,clk,PREPARE_TO_SHARE); -- AC3E6

n1050_REQ_IN <= sCPU_REQUEST_IN and not n1050_CE_MODE;

RESET_ATTN <= sTA_REG_POS_6_ATTENTION_RST or sRST_ATTACH; -- AC3B7 AC3B4
SS20_IN <= TT3_POS_1050_OPER and REQUEST_KEY; -- AC3D6
SS20_SS: SS port map(Clock1ms,20,SS20_IN,SS20); -- 20ms single-shot AC3G6
SET_ATTN_INTLK <= RESET_ATTN or sTT6_POS_ATTN;
RESET_ATTN_INTLK <= SS20 and REQUEST_KEY; -- AC3B6 AC3C7 - Typo, AC3C7 should be N?
ATTN_INTLK_FL: FLSRC port map(SET_ATTN_INTLK,RESET_ATTN_INTLK,clk,ATTN_INTLK); -- AC3C6 AC3D6 - ?? Not sure about this

SET_ATTN <= ATTN_INTLK and RESET_ATTN_INTLK;
-- ATTN_FL: FLSRC port map(SET_ATTN,RESET_ATTN,clk,sTT6_POS_ATTN); -- AC3C6 AC3C7
sTT6_POS_ATTN <= '0'; -- ?? Temporarily disable 1050 REQ function
TT6_POS_ATTN <= sTT6_POS_ATTN;

n1050_INSTALLED <= '1'; -- AC3D7, AC3E7

with DEBUG.Selection select
	DEBUG.Probe <=
		sCPU_REQUEST_IN when 0,
		MICRO_SHARE_REQ when 1,
		RD_SHARE_REQ_LCH when 2,
		WR_SHARE_REQ when 3,
		INTRV_REQ when 4,
		RDY_SHARE when 5,
		sMICRO_SHARE_LCH when 6,
		UNGATED_RUN when 7,
		RD_OR_RD_INQ when 8,
		sRD_CLK_INLK_LCH when 9,
  		WRITE_LCH when 10,
		TT2_POS_END WHEN 11,
		sCR_LF when 12,
		Z_TIME when 13,
		sRDR_ON_LCH when 14,
		sPROCEED_LCH when 15,
		'1' when others;

END FMD; 
