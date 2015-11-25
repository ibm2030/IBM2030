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
--    File: FMD2030_UDC3.vhd
--    Creation Date: 
--    Description:
--    1050 Typewriter Console interface section
--		Will also include Selector Channel(s) eventually
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

ENTITY udc3 IS
	port
	(
		-- Inputs        
		E_SW_SEL_BUS : IN E_SW_BUS_Type;
		USE_MANUAL_DECODER : IN STD_LOGIC;
		USE_ALT_CA_DECODER, USE_BASIC_CA_DECO : IN STD_LOGIC;
		GTD_CA_BITS : STD_LOGIC_VECTOR(0 to 3);
		Z_BUS : IN STD_LOGIC_VECTOR(0 to 8);
		GT_1050_TAGS_OUT : IN STD_LOGIC;
		GT_1050_BUS_OUT : IN STD_LOGIC;
--		PCH_CONN_ENTRY : IN PCH_CONN;
		P_1050_SEL_IN : IN STD_LOGIC;
		P_1050_SEL_OUT : IN STD_LOGIC;
		SUPPRESS_OUT : IN STD_LOGIC;
		CK_SAL_P_BIT : IN STD_LOGIC;
		RECYCLE_RESET : IN STD_LOGIC;
		MPX_OPN_LT_GATE : IN STD_LOGIC;
		ADDR_OUT : IN STD_LOGIC;
		
		-- Outputs
		A_BUS : OUT STD_LOGIC_VECTOR(0 to 8); -- 111111111 when inactive
		M_ASSM_BUS,N_ASSM_BUS : OUT STD_LOGIC_VECTOR(0 to 8);
		T_REQUEST : OUT STD_LOGIC;
		n1050_INTRV_REQ : OUT STD_LOGIC;
		TT6_POS_ATTN : OUT STD_LOGIC;
		n1050_INSTALLED : OUT STD_LOGIC;
      n1050_REQ_IN : OUT STD_LOGIC;
      n1050_OP_IN : OUT STD_LOGIC;
      n1050_CE_MODE : OUT STD_LOGIC;
		n1050_SEL_O : OUT STD_LOGIC;
		DEBUG : INOUT DEBUG_BUS;
        
		-- Hardware Serial Port
		serialInput : in Serial_Input_Lines;
		serialOutput : out Serial_Output_Lines;
		
		-- Clocks
		clk : IN STD_LOGIC;
		Clock1ms : IN STD_LOGIC;
		Clock60Hz : IN STD_LOGIC;
		T1,T2,T3,T4 : IN STD_LOGIC;
		P1,P2,P3,P4 : IN STD_LOGIC
		
	);
END udc3;

ARCHITECTURE FMD OF udc3 IS 

signal	WRITE_LCH : STD_LOGIC;
signal	RST_ATTACH : STD_LOGIC;
signal	PUNCH_1_CLUTCH, RDR_1_CLUTCH : STD_LOGIC;
signal	READ_CLK_INTLK_LCH : STD_LOGIC;
signal	CRLF : STD_LOGIC;
signal	CLOCK_1 : STD_LOGIC;
signal	CLK_STT_RST : STD_LOGIC;
signal	W_TIME,X_TIME,Y_TIME,Z_TIME : STD_LOGIC;
signal	RD_OR_RD_INQ : STD_LOGIC;
signal	RD_INLK_RST : STD_LOGIC;
signal	WRITE_LCH_RST : STD_LOGIC;
signal	TT2_POS_END : STD_LOGIC;
signal	CE_DATA_ENTER_GT : STD_LOGIC;
signal	CE_TA_DECODE : STD_LOGIC;
signal	CE_RESET : STD_LOGIC;
signal	RUN : STD_LOGIC;
signal	TAGS_OUT_BUS : STD_LOGIC_VECTOR(0 to 7);
signal	sn1050_CE_MODE : STD_LOGIC;
signal	EXIT_MPLX_SHARE : STD_LOGIC;
signal	RD_SHARE_REQ : STD_LOGIC;
signal	WR_SHARE_REQ : STD_LOGIC;
signal	CE_SEL_O : STD_LOGIC;
signal	sn1050_INTRV_REQ : STD_LOGIC;
signal	UNGATED_RUN : STD_LOGIC;
signal	REQUEST_KEY : STD_LOGIC;
signal	n1050_RST_LCH : STD_LOGIC;
signal	HOME_RDR_START_LCH : STD_LOGIC;
signal	HOME_RDR_STOP : STD_LOGIC;
signal	PROCEED_LCH : STD_LOGIC;
signal	MICRO_SHARE_LCH : STD_LOGIC;
signal	RDR_ON_LCH : STD_LOGIC;
signal	TA_REG_POS_4 : STD_LOGIC;
signal	AUDIBLE_ALARM : STD_LOGIC;
signal	TA_REG_POS_6_ATTENTION_RST : STD_LOGIC;
signal	SHARE_REQ_RST : STD_LOGIC;
signal	CPU_REQUEST_IN : STD_LOGIC;
signal	sTT6_POS_ATTN : STD_LOGIC;
signal	XLATE_UC : STD_LOGIC;
signal	sn1050_OP_IN : STD_LOGIC;
signal	SET_SHIFT_LCH : STD_LOGIC;
signal	TA_REG_SET : STD_LOGIC;
signal	n1050_OPER : STD_LOGIC;
signal	READ_INQ : STD_LOGIC;
signal	RD_SHARE_REQ_LCH : STD_LOGIC;
signal	READ : STD_LOGIC;
signal	RESTORE : STD_LOGIC;
signal	OUTPUT_SEL_AND_READY : STD_LOGIC;
signal	UC_CHARACTER, LC_CHARACTER : STD_LOGIC;
signal	PCH_BITS : STD_LOGIC_VECTOR(0 to 6);
signal	CE_GT_TA_OR_TE, CE_TE_DECODE : STD_LOGIC;
signal	CE_RUN_MODE : STD_LOGIC;
signal	CE_BITS : STD_LOGIC_VECTOR(0 to 7);
signal	DATA_REG_BUS : STD_LOGIC_VECTOR(0 to 7);
signal	TE_LCH : STD_LOGIC;
signal	ALLOW_STROBE : STD_LOGIC;
signal	GT_WRITE_REG : STD_LOGIC;
signal	FORCE_SHIFT_CHAR, FORCE_LC_SHIFT : STD_LOGIC;
signal	SET_LOWER_CASE : STD_LOGIC;
signal	READY_SHARE : STD_LOGIC;
signal	TT_BUS : STD_LOGIC_VECTOR(0 to 7);
signal	WRITE_MODE : STD_LOGIC;
signal	NPL_BITS : STD_LOGIC_VECTOR(0 to 7);
signal	PTT_BITS : STD_LOGIC_VECTOR(0 to 6);
signal	WRITE_UC : STD_LOGIC;
signal	WR_STROBE : STD_LOGIC;
signal	PCH_1_HOME : STD_LOGIC;
signal	TT5_POS_INTRV_REQ : STD_LOGIC;
signal	CPU_LINES_ENTRY : CONN_1050;
signal	CE_MODE_AND_TE_LCH : STD_LOGIC;
signal	CE_SEL_OUT : STD_LOGIC;
signal	CE_TI_DECODE : STD_LOGIC;
signal	CE_BUS : STD_LOGIC_VECTOR(0 to 7);
signal	CE_DATA_ENTER_NC : STD_LOGIC;
signal	GTD_TT3 : STD_LOGIC;

BEGIN
M_ASSM_BUS <= (others=>'0');
N_ASSM_BUS <= (others=>'0');

-- Fig 5-09C
n1050_TRANSLATE : entity work.n1050_TRANSLATE port map(
		-- Inputs        
		DATA_REG_BUS => DATA_REG_BUS,
		RDR_ON_LCH => RDR_ON_LCH,
		PUNCH_1_CLUTCH_1050 => PUNCH_1_CLUTCH,
		HOME_RDR_STT_LCH => HOME_RDR_START_LCH,
		CLOCK_STT_RST => CLK_STT_RST,
		RST_ATTACH => RST_ATTACH,
		W_TIME => W_TIME,
		X_TIME => X_TIME,
		Y_TIME => Y_TIME,
		Z_TIME => Z_TIME,
		n1050_RST => n1050_RST_LCH,
		ALLOW_STROBE => ALLOW_STROBE,
		PROCEED_LCH => PROCEED_LCH,
		SHARE_REQ_RST => SHARE_REQ_RST,
		CE_RUN_MODE => CE_RUN_MODE,
		CE_TI_DECODE => CE_TI_DECODE,
		SET_LOWER_CASE => SET_LOWER_CASE,
		n1050_RST_LCH => n1050_RST_LCH,
		READY_SHARE => READY_SHARE,

		-- Outputs
		TT2_POS_END => TT2_POS_END,
		XLATE_UC => XLATE_UC,
		RD_SHARE_REQ_LCH => RD_SHARE_REQ_LCH,
		READ_SHARE_REQ => RD_SHARE_REQ,
		WRITE_UC => WRITE_UC,
		SET_SHIFT_LCH => SET_SHIFT_LCH,
		PCH_1_HOME => PCH_1_HOME,
		RUN => RUN,
		UNGATED_RUN => UNGATED_RUN,
		READ => READ,
		READ_INQ => READ_INQ,
		RD_OR_RD_INQ => RD_OR_RD_INQ,
		LC_CHARACTER =>LC_CHARACTER,
		UC_CHARACTER => UC_CHARACTER,
		WRITE_LCH => WRITE_LCH,
		WRITE_MODE => WRITE_MODE,
		WRITE_STROBE => WR_STROBE,
		WRITE_LCH_RST => WRITE_LCH_RST,
		
		DEBUG => open
		);
		
-- Fig 5-10A
n1050_CLOCK : entity work.n1050_CLOCK port map (
		-- Inputs        
		WRITE_LCH => WRITE_LCH, -- 09CD2
		READ_OR_READ_INQ => RD_OR_RD_INQ, -- 09CC5
		RST_ATTACH => RST_ATTACH, -- 10BC2
		PUNCH_1_CLUTCH => PUNCH_1_CLUTCH, -- 10DD5
		READ_CLK_INTLK_LCH => READ_CLK_INTLK_LCH, -- 10BA2
		RDR_1_CLUTCH => RDR_1_CLUTCH, -- 10DD5
		CRLF => CRLF, -- ?
		
		-- Outputs
		CLOCK_1 => CLOCK_1, -- 10CD1 10CA4
		W_TIME => W_TIME,
		X_TIME => X_TIME,
		Y_TIME => Y_TIME,
		Z_TIME => Z_TIME,
		CLK_STT_RST => CLK_STT_RST, -- 09CE1
		clk => clk -- 50MHz
		);
		
-- Fig 5-10B
n1050_TAGS : entity work.n1050_TAGS port map (
		-- Inputs
		RD_OR_RD_INQ => RD_OR_RD_INQ, -- 09CC5
		Y_TIME => Y_TIME, -- 10AXX
		RD_INLK_RST => RD_INLK_RST, -- 10DC5
		WRITE_LCH_RST => WRITE_LCH_RST, -- 09CE2
		PCH_1_CLUTCH => PUNCH_1_CLUTCH, -- 10DD5
		TT2_POS_END => TT2_POS_END, -- 09CB5
		WRITE_LCH => WRITE_LCH, -- 09CD2
		Z_TIME => Z_TIME, -- 10AXX
		CE_DATA_ENTER_GT => CE_DATA_ENTER_GT, -- 10DA2
		CE_TA_DECODE => CE_TA_DECODE,  -- 10DA1
		GT_1050_TAGS_OUT => GT_1050_TAGS_OUT, -- 10CE2
		RECYCLE_RESET => RECYCLE_RESET, -- 04CA5
		CE_RESET => CE_RESET, -- 10DC2
		RUN => RUN, -- 09CE6
		TT3_POS_1050_OPER => TT_BUS(3), -- 10DD4
		TAGS_OUT_BUS => TAGS_OUT_BUS, -- 10CD1
		n1050_CE_MODE => sn1050_CE_MODE, -- 10DB3
		n1050_SEL_O => n1050_SEL_O, -- 08DD6
		P_1050_SEL_IN => P_1050_SEL_IN, -- 08DC1
		P_1050_SEL_OUT => P_1050_SEL_OUT, -- 08DD6
		MPX_OPN_LCH_GT => MPX_OPN_LT_GATE, -- 08CE3
		CK_SAL_P_BIT => CK_SAL_P_BIT, -- 01CXX
		EXIT_MPLX_SHARE => EXIT_MPLX_SHARE, -- 10DB3
		ADDR_OUT => ADDR_OUT, -- 08DA5
		RD_SHARE_REQ => RD_SHARE_REQ, -- 09CC6
		RD_SHARE_REQ_LCH => RD_SHARE_REQ_LCH, -- 09CC6
		SUPPRESS_OUT => SUPPRESS_OUT, -- 08DD6
		WR_SHARE_REQ => WR_SHARE_REQ, -- 10CA6
		CE_SEL_O => CE_SEL_O, -- 10DB2
		INTRV_REQ => sn1050_INTRV_REQ, -- 10CD6
		RDY_SHARE => READY_SHARE, -- 10CE6
		UNGATED_RUN => UNGATED_RUN, -- 09CE6
		REQUEST_KEY => REQUEST_KEY, -- 10DE5
		
		-- Outputs
		n1050_RST_LCH => n1050_RST_LCH, -- 10DF2 09CD1 10CA5 09CE5
		HOME_RDR_START_LCH => HOME_RDR_START_LCH, -- 09CE4 09CE1 10DE2
		HOME_RDR_STOP => HOME_RDR_STOP, -- 10DC5
		PROCEED_LCH => PROCEED_LCH, -- 09CE4 10CC2 10DE2
		MICRO_SHARE_LCH => MICRO_SHARE_LCH, -- 10DE2
		RDR_ON_LCH => RDR_ON_LCH, -- 09CE4 10DE2 09CE1
		TA_REG_POS_4 => TA_REG_POS_4, -- 10DE2
		AUDIBLE_ALARM => AUDIBLE_ALARM, -- 14AXX
		CR_LF => CRLF, -- 10AC1 10DE2
		TA_REG_POS_6_ATTENTION_RST => TA_REG_POS_6_ATTENTION_RST, -- ---D4 10DE2 10CE5
		CPU_LINES_TO_1050 => CPU_LINES_ENTRY, -- 10DE3
		SHARE_REQ_RST => SHARE_REQ_RST, -- 09CC5 10CE4 10CA5
		T_REQUEST => T_REQUEST, -- 07BD3 06BA3 07BB3
		CPU_REQUEST_IN => CPU_REQUEST_IN, -- 10DE3
		n1050_OP_IN => sn1050_OP_IN, -- 08DD4 10CA4
		n1050_REQ_IN => n1050_REQ_IN, -- 08DD2
		TT6_POS_ATTN => sTT6_POS_ATTN, -- 10DC4 04AB6
		n1050_INSTALLED => n1050_INSTALLED, -- 08DC1
		TA_REG_SET => TA_REG_SET,
		RD_CLK_INLK_LCH => READ_CLK_INTLK_LCH,
		RESTORE => RESTORE,
		RST_ATTACH => RST_ATTACH,
		
		DEBUG => DEBUG,
		
		-- Clocks
		clk => clk,
		Clock1ms => Clock1ms,
		Clock60Hz => Clock60Hz,

		P1 => P1,
		P2 => P2,
		P3 => P3,
		P4 => P4,
		T1 => T1,
		T2 => T2,
		T3 => T3,
		T4 => T4
);
TT6_POS_ATTN <= sTT6_POS_ATTN;
n1050_OP_IN <= sn1050_OP_IN;

-- Fig 5-10C
n1050_DATA : entity work.n1050_DATA port map (
		-- Inputs        
		E_SW_SEL_BUS => E_SW_SEL_BUS,
		USE_MANUAL_DECODER => USE_MANUAL_DECODER,
		USE_ALT_CA_DECODER => USE_ALT_CA_DECODER,
		USE_BASIC_CA_DECO => USE_BASIC_CA_DECO,
		GTD_CA_BITS => GTD_CA_BITS,
		XLATE_UC => XLATE_UC,
		WR_LCH => WRITE_LCH,
		RUN => RUN,
		PROCEED_LCH => PROCEED_LCH,
--		TT4_POS_HOME_STT => TT4_POS_HOME_STT,
		RD_OR_RD_INQ => RD_OR_RD_INQ,
		W_TIME => W_TIME,
		X_TIME => X_TIME,
		Y_TIME => Y_TIME,
		Z_TIME => Z_TIME,
		Z_BUS => Z_BUS,
		CLOCK_1 => CLOCK_1,
		PCH_1_CLUTCH => PUNCH_1_CLUTCH,
		GT_1050_BUS_OUT => GT_1050_BUS_OUT,
		GT_1050_TAGS_OUT => GT_1050_TAGS_OUT,
		n1050_OP_IN => sn1050_OP_IN,
		SET_SHIFT_LCH => SET_SHIFT_LCH,
		TA_REG_SET => TA_REG_SET,
		RST_ATTACH => RST_ATTACH,
		n1050_OPER => n1050_OPER,
		READ_INQ => READ_INQ,
		RD_SHARE_REQ_LCH => RD_SHARE_REQ_LCH,
		READ => READ,
		WRITE_MODE => WRITE_MODE,
		RESTORE => RESTORE,
		OUTPUT_SEL_AND_READY => OUTPUT_SEL_AND_READY,
		SHARE_REQ_RST => SHARE_REQ_RST,
		n1050_RST_LCH => n1050_RST_LCH,
		RDR_1_CLUTCH => RDR_1_CLUTCH,
		UC_CHARACTER => UC_CHARACTER,
		LC_CHARACTER => LC_CHARACTER,
--		Z_BUS_0 => Z_BUS(0),
--		Z_BUS_3 => Z_BUS(3),
--		TT3_POS_1050_OPER => TT3_POS_1050_OPER,
		TA_REG_POS_6_ATTN_RST => TA_REG_POS_6_ATTENTION_RST,
		PCH_BITS => PCH_BITS,
				
		-- CE controls
		CE_GT_TA_OR_TE => CE_GT_TA_OR_TE,
		CE_DATA_ENTER_GT => CE_DATA_ENTER_GT,
		CE_TE_DECODE => CE_TE_DECODE,
		CE_RUN_MODE => CE_RUN_MODE,
		n1050_CE_MODE => sn1050_CE_MODE,
		CE_BITS => CE_BITS,
		
		-- Outputs
      A_REG_BUS => A_BUS,
		DATA_REG_BUS => DATA_REG_BUS,
		TAGS_OUT => TAGS_OUT_BUS,
		NPL_BITS => NPL_BITS,
		PTT_BITS => PTT_BITS,
		TE_LCH => TE_LCH,
		WR_SHARE_REQ => WR_SHARE_REQ,
		ALLOW_STROBE => ALLOW_STROBE,
		GT_WRITE_REG => GT_WRITE_REG,
		FORCE_SHIFT_CHAR => FORCE_SHIFT_CHAR,
		FORCE_LC_SHIFT => FORCE_LC_SHIFT,
		SET_LOWER_CASE => SET_LOWER_CASE,
		n1050_INTRV_REQ => sn1050_INTRV_REQ,
		READY_SHARE => READY_SHARE,
		TT5_POS_INTRV_REQ => TT5_POS_INTRV_REQ,
		
		-- Buses
		TT_BUS => TT_BUS,
		GTD_TT3 => GTD_TT3,
		DEBUG => open,
		
		-- Clocks
		P1 => P1,
		P2 => P2,
		P3 => P3,
		P4 => P4,
		T1 => T1,
		T2 => T2,
		T3 => T3,
		T4 => T4
);
n1050_INTRV_REQ <= sn1050_INTRV_REQ;

-- Fig 5-10D
n1050_ATTACH : entity work.n1050_ATTACH port map (
		-- Inputs        
		-- CE Cable
		CE_CABLE_IN => open,
		-- CE DATA BUS From 1050 DATA section
		PTT_BITS => PTT_BITS,
		DATA_REG => DATA_REG_BUS,
		NPL_BITS => NPL_BITS,
		-- Other stuff
		TE_LCH => TE_LCH,
		WRITE_UC => WRITE_UC,
		XLATE_UC => XLATE_UC,
		CPU_REQUEST_IN => CPU_REQUEST_IN,
		n1050_OP_IN => sn1050_OP_IN,
		HOME_RDR_STT_LCH => HOME_RDR_START_LCH,
		RDR_ON_LCH => RDR_ON_LCH,
		MICRO_SHARE_LCH => MICRO_SHARE_LCH,
		PROCEED_LCH => PROCEED_LCH,
		TA_REG_POS_4 => TA_REG_POS_4,
		CR_LF => CRLF,
		TA_REG_POS_6 => TA_REG_POS_6_ATTENTION_RST,
		n1050_RST => n1050_RST_LCH,
		GT_WR_REG => GT_WRITE_REG,
		FORCE_LC_SHIFT => FORCE_LC_SHIFT,
		FORCE_SHIFT_CHAR => FORCE_SHIFT_CHAR,
		WR_STROBE => WR_STROBE,
		PCH_1_HOME => PCH_1_HOME,
		HOME_RDR_STOP => HOME_RDR_STOP,
		TT2_POS_END => TT2_POS_END,
		TT5_POS_INTRV_REQ => TT5_POS_INTRV_REQ,
		TT6_POS_ATTN => sTT6_POS_ATTN,
		CPU_LINES_ENTRY => CPU_LINES_ENTRY,
--		PCH_CONN_ENTRY => PCH_CONN_ENTRY,
		RDR_1_CLUTCH => RDR_1_CLUTCH,
		
		-- Outputs
		-- CE Cable
		CE_CABLE_OUT => open,
		-- CE DATA BUS to 10C (1050 DATA)
		CE_GT_TA_OR_TE => CE_GT_TA_OR_TE,
		CE_DATA_ENTER_GT => CE_DATA_ENTER_GT,
		CE_TE_DECODE => CE_TE_DECODE,
		CE_MODE_AND_TE_LCH => CE_MODE_AND_TE_LCH,
		n1050_CE_MODE => sn1050_CE_MODE,
		-- Other stuff
		CE_SEL_OUT => CE_SEL_OUT,
		CE_TI_DECODE => CE_TI_DECODE,
		CE_RUN_MODE => CE_RUN_MODE,
		CE_TA_DECODE => CE_TA_DECODE,
		CE_BUS => CE_BUS,
		EXIT_MPLX_SHARE => EXIT_MPLX_SHARE,
		CE_DATA_ENTER_NC => CE_DATA_ENTER_NC,
--		TT3_POS_1050_OPER => TT_BUS(3),
--		TT4_POS_HOME_STT => TT_BUS(4),
		OUTPUT_SEL_AND_RDY => OUTPUT_SEL_AND_READY,
		n1050_OPER => n1050_OPER,
		PUNCH_BITS => PCH_BITS,
		READ_INTLK_RST => RD_INLK_RST,
		PUNCH_1_CLUTCH => PUNCH_1_CLUTCH,
--		PCH_1_CLUTCH_1050 => PCH_1_CLUTCH_1050,
		REQUEST_KEY => REQUEST_KEY,
		
--		RDR_1_CONN_EXIT => RDR_1_CONN_EXIT,
--		CPU_LINES_EXIT => n1050_CONTROL,
		
		-- In/Out TT bus
		TT_BUS => TT_BUS,
		GTD_TT3 => GTD_TT3,
		
		SerialInput => SerialInput,
		SerialOutput => SerialOutput,
        
		-- Clocks
		P1 => P1,
		P2 => P2,
		P3 => P3,
		P4 => P4,
		T1 => T1,
		T2 => T2,
		T3 => T3,
		T4 => T4,
		clk => clk
);
n1050_CE_MODE <= sn1050_CE_MODE;
-- PCH_1_CLUTCH <= PCH_CONN_ENTRY.PCH_1_CLUTCH_1050;

END FMD; 

