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
--    File: FMD2030_5-10D.vhd
--    Creation Date: 
--    Description:
--    1050 Typewriter Console attachment and CE section
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

library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;
use work.all;

ENTITY n1050_ATTACH IS

	port
	(
		-- Inputs        
		-- CE Cable
		CE_CABLE_IN : IN CE_IN := ("00000000",'0','0','0','0','0','0','0','0','0','0');
		-- CE DATA BUS From 1050 DATA section
		PTT_BITS : IN STD_LOGIC_VECTOR(0 to 6);
		DATA_REG : IN STD_LOGIC_VECTOR(0 to 7);
		NPL_BITS : IN STD_LOGIC_VECTOR(0 to 7);
		-- Other stuff
		TE_LCH : IN STD_LOGIC; -- 10CB5
		WRITE_UC : IN STD_LOGIC; -- 09CD6
		XLATE_UC : IN STD_LOGIC; -- 09CB6
		CPU_REQUEST_IN : IN STD_LOGIC; -- 10BD6
		n1050_OP_IN : IN STD_LOGIC; -- 10BB5
		HOME_RDR_STT_LCH : IN STD_LOGIC; -- 10BB3
		RDR_ON_LCH : IN STD_LOGIC; -- 10BD3
		MICRO_SHARE_LCH : IN STD_LOGIC; -- 10BC3
		PROCEED_LCH : IN STD_LOGIC; -- 10BC3
		TA_REG_POS_4 : IN STD_LOGIC; -- 10BE3
		CR_LF : IN STD_LOGIC; -- 10BE3
		TA_REG_POS_6 : IN STD_LOGIC; -- 10BE3
		n1050_RST : IN STD_LOGIC; -- 10BE2
		GT_WR_REG : IN STD_LOGIC; -- 10CB6
		FORCE_LC_SHIFT : IN STD_LOGIC; -- 10CC6
		FORCE_SHIFT_CHAR : IN STD_LOGIC; -- 10CC6
		WR_STROBE : IN STD_LOGIC; -- 09CD2
		PCH_1_HOME : IN STD_LOGIC; -- 09CD6
		HOME_RDR_STOP : IN STD_LOGIC; -- 10BB3
		TT2_POS_END : IN STD_LOGIC; -- 09CB5 - NOT IN FMD
		TT5_POS_INTRV_REQ : IN STD_LOGIC; -- 10CD5
		TT6_POS_ATTN : IN STD_LOGIC; -- 10BD6
		CPU_LINES_ENTRY : IN CONN_1050; -- 10BE3
		
		-- Outputs
		-- CE Cable
		CE_CABLE_OUT : OUT CE_OUT;
		-- CE DATA BUS to 10C (1050 DATA)
		CE_GT_TA_OR_TE : OUT STD_LOGIC; -- 10C
		CE_DATA_ENTER_GT : OUT STD_LOGIC; -- 10BB1 10CA4 10C
		CE_TE_DECODE : OUT STD_LOGIC; -- 10CA4 10C
		CE_MODE_AND_TE_LCH : OUT STD_LOGIC;
		n1050_CE_MODE : OUT STD_LOGIC; -- 10CB3 10BD5
		-- Other stuff
		CE_SEL_OUT : OUT STD_LOGIC; -- 10BD5
		CE_TI_DECODE : OUT STD_LOGIC; -- 09CC5
		CE_RUN_MODE : OUT STD_LOGIC; -- 09CC5
		CE_TA_DECODE : OUT STD_LOGIC; -- 10BB1
		CE_BUS : OUT STD_LOGIC_VECTOR(0 to 7); -- 10C
		EXIT_MPLX_SHARE : OUT STD_LOGIC; -- 10BB5
		CE_DATA_ENTER_NC : OUT STD_LOGIC;
--		TT3_POS_1050_OPER : OUT STD_LOGIC; -- 10BE2 10BB2 10BE2 10CE5 Moved to TT_BUS(3)
--		TT4_POS_HOME_STT : OUT STD_LOGIC; -- 10CD2 Moved to TT_BUS(4)
		OUTPUT_SEL_AND_RDY : OUT STD_LOGIC; -- 10CD4
		n1050_OPER : OUT STD_LOGIC; -- 10CC4 10CE4
		PUNCH_BITS : OUT STD_LOGIC_VECTOR(0 to 6); -- 10CE1
		READ_INTLK_RST : OUT STD_LOGIC; -- 10BA1
		PUNCH_1_CLUTCH : OUT STD_LOGIC; -- 10CE1 10AC1
--		PCH_1_CLUTCH_1050 : OUT STD_LOGIC; -- 09CE1 10BA1 09CD5
		REQUEST_KEY : OUT STD_LOGIC; -- 10BE4
		RDR_1_CLUTCH : OUT STD_LOGIC;
		
		-- In/Out TT bus
		TT_BUS : INOUT STD_LOGIC_VECTOR(0 to 7);
		GTD_TT3 : IN STD_LOGIC;
        
		-- Hardware Serial Port
		serialInput : in Serial_Input_Lines;
		serialOutput : out Serial_Output_Lines;
		
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		P1,P2,P3,P4 : IN STD_LOGIC;
		clk : IN STD_LOGIC		
	);
END n1050_ATTACH;

ARCHITECTURE FMD OF n1050_ATTACH IS 

signal	sCE_TA_DECODE, sCE_TE_DECODE : STD_LOGIC;
signal	sCE_DATA_ENTER_GT : STD_LOGIC;
signal	sn1050_CE_MODE : STD_LOGIC;
signal	sPUNCH_1_CLUTCH : STD_LOGIC;
signal	sRDR_1_CLUTCH : STD_LOGIC;
signal	sOUTPUT_SEL_AND_RDY : STD_LOGIC;
signal	TT1_POS_RDR_2_RDY, sTT3_POS_1050_OPER, sTT4_POS_HOME_STT : STD_LOGIC;
signal	PCH_CONN_ENTRY : PCH_CONN;
signal	RDR_1_CONN_EXIT : RDR_CONN;
signal	CPU_LINES_EXIT : CONN_1050;

BEGIN
-- Fig 5-10D
sCE_TA_DECODE <= CE_CABLE_IN.CE_TA_DECODE;
CE_TA_DECODE <= sCE_TA_DECODE;
CE_GT_TA_OR_TE <= (CE_CABLE_IN.CE_TA_DECODE and sCE_DATA_ENTER_GT) or (sCE_TE_DECODE and sCE_DATA_ENTER_GT); -- AC2G5
sCE_DATA_ENTER_GT <= CE_CABLE_IN.CE_TI_OR_TE_RUN_MODE;
CE_DATA_ENTER_GT <= sCE_DATA_ENTER_GT;

-- CE cable entry
CE_BUS <= CE_CABLE_IN.CE_BIT; -- AC2M3
sCE_TE_DECODE <= CE_CABLE_IN.CE_TE_DECODE; -- AC2M2
CE_TE_DECODE <= sCE_TE_DECODE;
CE_SEL_OUT <= CE_CABLE_IN.CE_SEL_OUT; -- AC2M2
CE_TI_DECODE <= CE_CABLE_IN.CE_TI_DECODE; -- AC2M2
CE_RUN_MODE <= not CE_CABLE_IN.CE_MODE; -- AC2M2

CE_MODE_AND_TE_LCH <= (TE_LCH and sn1050_CE_MODE) or CE_CABLE_IN.CE_SEL_OUT; -- AC2E7
sn1050_CE_MODE <= CE_CABLE_IN.CE_MODE;
n1050_CE_MODE <= sn1050_CE_MODE;
EXIT_MPLX_SHARE <= CE_CABLE_IN.CE_EXIT_MPLX_SHARE;
CE_DATA_ENTER_NC <= CE_CABLE_IN.CE_DATA_ENTER_NC;

-- CE cable exit
CE_CABLE_OUT.PTT_BITS <= PTT_BITS;
CE_CABLE_OUT.DATA_REG <= DATA_REG;
CE_CABLE_OUT.RDR_1_CLUTCH <= sRDR_1_CLUTCH;
CE_CABLE_OUT.WRITE_UC <= WRITE_UC;
CE_CABLE_OUT.XLATE_UC <= XLATE_UC;
CE_CABLE_OUT.PUNCH_1_CLUTCH <= sPUNCH_1_CLUTCH;
CE_CABLE_OUT.NPL <= NPL_BITS;
CE_CABLE_OUT.OUTPUT_SEL_AND_RDY <= sOUTPUT_SEL_AND_RDY;
CE_CABLE_OUT.TT <= TT_BUS(0 to 2) & GTD_TT3 & TT_BUS(4 to 7);
CE_CABLE_OUT.CPU_REQUEST_IN <= CPU_REQUEST_IN;
CE_CABLE_OUT.n1050_OP_IN <= n1050_OP_IN;
CE_CABLE_OUT.HOME_RDR_STT_LCH <= HOME_RDR_STT_LCH;
CE_CABLE_OUT.RDR_ON_LCH <= RDR_ON_LCH;
CE_CABLE_OUT.MICRO_SHARE_LCH <= MICRO_SHARE_LCH;
CE_CABLE_OUT.PROCEED_LCH <= PROCEED_LCH;
CE_CABLE_OUT.TA_REG_POS_4 <= TA_REG_POS_4;
CE_CABLE_OUT.CR_LF <= CR_LF;
CE_CABLE_OUT.TA_REG_POS_6 <= TA_REG_POS_6;
CE_CABLE_OUT.n1050_RST <= n1050_RST;

-- RDR connection (output)
-- FORCE_LC_SHIFT and FORCE_SHIFT_CHAR makes 0111110 (downshift)
-- FORCE_SHIFT_CHAR makes 0001110 (upshift)
-- We remove this in favour of simple ASCII on the output
-- RDR_1_CONN_EXIT.RDR_BITS <= (PTT_BITS(0) and GT_WR_REG) -- C
-- 	& ((PTT_BITS(1) and GT_WR_REG) or FORCE_LC_SHIFT) -- B
-- 	& ((PTT_BITS(2) and GT_WR_REG) or FORCE_LC_SHIFT) -- A
-- 	& ((PTT_BITS(3) and GT_WR_REG) or FORCE_SHIFT_CHAR) -- 8
-- 	& ((PTT_BITS(4) and GT_WR_REG) or FORCE_SHIFT_CHAR) -- 4
-- 	& ((PTT_BITS(5) and GT_WR_REG) or FORCE_SHIFT_CHAR) -- 2
-- 	& (PTT_BITS(6) and GT_WR_REG); -- 1
RDR_1_CONN_EXIT.RDR_BITS <= PTT_BITS;
RDR_1_CONN_EXIT.RD_STROBE <= WR_STROBE;
CPU_LINES_EXIT <= CPU_LINES_ENTRY;

-- TT Bus
TT_BUS(1) <= TT1_POS_RDR_2_RDY;
TT_BUS(2) <= TT2_POS_END;
TT_BUS(3) <= sTT3_POS_1050_OPER;
-- TT3_POS_1050_OPER <= sTT3_POS_1050_OPER;
TT_BUS(4) <= sTT4_POS_HOME_STT;
-- TT4_POS_HOME_STT <= sTT4_POS_HOME_STT;
TT_BUS(5) <= TT5_POS_INTRV_REQ;
TT_BUS(6) <= TT6_POS_ATTN;

-- PCH connections (input)
PUNCH_BITS <= PCH_CONN_ENTRY.PCH_BITS; -- AC2L4
READ_INTLK_RST <= '1' when PCH_CONN_ENTRY.PCH_BITS="0000000" else '0'; -- AC2E3
sPUNCH_1_CLUTCH <= PCH_CONN_ENTRY.PCH_1_CLUTCH_1050; -- AC2M2 AC2J7
PUNCH_1_CLUTCH <= sPUNCH_1_CLUTCH;
-- PCH_1_CLUTCH_1050 <= sPUNCH_1_CLUTCH;
TT1_POS_RDR_2_RDY <= PCH_CONN_ENTRY.RDR_2_READY; -- AC2M5 AC2L5
sTT3_POS_1050_OPER <= PCH_CONN_ENTRY.CPU_CONNECTED; -- AC2J5
sTT4_POS_HOME_STT <= PCH_CONN_ENTRY.HOME_RDR_STT_LCH; -- AC2M5 AC2L5
-- TT4_POS_HOME_STT <= sTT4_POS_HOME_STT;
sOUTPUT_SEL_AND_RDY <= PCH_CONN_ENTRY.HOME_OUTPUT_DEV_RDY;
OUTPUT_SEL_AND_RDY <= sOUTPUT_SEL_AND_RDY;
sRDR_1_CLUTCH <= PCH_CONN_ENTRY.RDR_1_CLUTCH_1050; -- AC2M4
RDR_1_CLUTCH <= sRDR_1_CLUTCH;
n1050_OPER <= PCH_CONN_ENTRY.CPU_CONNECTED; -- FA1D4
REQUEST_KEY <=PCH_CONN_ENTRY.REQ_KEY; -- FA1D4

		console : entity ibm1050 port map(
				SerialIn => PCH_CONN_ENTRY,
				SerialOut => RDR_1_CONN_EXIT,
				SerialControl => CPU_LINES_EXIT,
				serialInput => serialInput,
				serialOutput => serialOutput,
				clk => clk);

END FMD; 

