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
--    File: FMD2030_5-10C.vhd
--    Creation Date: 
--    Description:
--    1050 Typewriter Console data latches and gating
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
USE ieee.numeric_std.all;

library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;

ENTITY n1050_DATA IS
	port
	(
		-- Inputs        
		E_SW_SEL_BUS : IN E_SW_BUS_Type; -- 04CE1
		USE_MANUAL_DECODER : IN STD_LOGIC; -- 03DA3
		USE_ALT_CA_DECODER : IN STD_LOGIC; -- 02BA3
		USE_BASIC_CA_DECO : IN STD_LOGIC; -- 02AE6
		GTD_CA_BITS : IN STD_LOGIC_VECTOR(0 to 3); -- 05CA2
		XLATE_UC : IN STD_LOGIC; -- 09C
		WR_LCH : IN STD_LOGIC; -- 09CD2 aka WRITE_LCH
		RUN : IN STD_LOGIC; -- 09CE6
		PROCEED_LCH : IN STD_LOGIC; -- 10BC3
--		TT4_POS_HOME_STT : IN STD_LOGIC; -- 10DD5
		RD_OR_RD_INQ : IN STD_LOGIC; -- 09CC5
		W_TIME, X_TIME, Y_TIME, Z_TIME : IN STD_LOGIC; -- 10AXX
		Z_BUS : IN STD_LOGIC_VECTOR(0 to 8); -- 08BE3
		CLOCK_1 : IN STD_LOGIC; -- 10AA5
		PCH_1_CLUTCH : IN STD_LOGIC; -- 10DD5
		GT_1050_BUS_OUT, GT_1050_TAGS_OUT : IN STD_LOGIC; -- 04CE6
		n1050_OP_IN : IN STD_LOGIC; -- 10BC5
		SET_SHIFT_LCH : IN STD_LOGIC; -- 09CD6
		TA_REG_SET : IN STD_LOGIC; -- 10BB2
		RST_ATTACH : IN STD_LOGIC; -- 10BC2
		n1050_OPER : IN STD_LOGIC; -- 10DE4
		READ_INQ : IN STD_LOGIC; -- 09CE6
		RD_SHARE_REQ_LCH : IN STD_LOGIC; -- 09CC6
		READ : IN STD_LOGIC; -- 09CE6
		WRITE_MODE : IN STD_LOGIC; -- 09CFD2
		RESTORE : IN STD_LOGIC; -- 10BD2
		OUTPUT_SEL_AND_READY : IN STD_LOGIC; -- 10DD4
		SHARE_REQ_RST : IN STD_LOGIC; -- 10BB6
		n1050_RST_LCH : IN STD_LOGIC; -- 10BA3
		RDR_1_CLUTCH : IN STD_LOGIC; -- 10DD5
		UC_CHARACTER, LC_CHARACTER : IN STD_LOGIC; -- 09CD2
--		Z_BUS_0, Z_BUS_3 : IN STD_LOGIC; -- 06BDX
--		TT3_POS_1050_OPER : IN STD_LOGIC; -- 10DD4
		TA_REG_POS_6_ATTN_RST : IN STD_LOGIC; -- 10BE3
		PCH_BITS : IN STD_LOGIC_VECTOR(0 to 6);
				
		-- CE controls
		CE_GT_TA_OR_TE : IN STD_LOGIC;
		CE_DATA_ENTER_GT : IN STD_LOGIC;
		CE_TE_DECODE : IN STD_LOGIC;
		CE_RUN_MODE : IN STD_LOGIC; -- 10DB3
		n1050_CE_MODE : IN STD_LOGIC;
		CE_BITS : IN STD_LOGIC_VECTOR(0 to 7); -- 10DA1
		
		-- Outputs
      A_REG_BUS : OUT STD_LOGIC_VECTOR(0 to 8); -- 07CA6
		DATA_REG_BUS : OUT STD_LOGIC_VECTOR(0 to 7); -- 09C
		TAGS_OUT : OUT STD_LOGIC_VECTOR(0 to 7); -- 10BB1 11AA2
		NPL_BITS : OUT STD_LOGIC_VECTOR(0 to 7);
		PTT_BITS : OUT STD_LOGIC_VECTOR(0 to 6); -- Output to printer ("RDR")
		TE_LCH : OUT STD_LOGIC;
		WR_SHARE_REQ : OUT STD_LOGIC; -- 10BD5
		ALLOW_STROBE : OUT STD_LOGIC; -- 09CD4 09CE1
		GT_WRITE_REG : OUT STD_LOGIC; -- 10DB4
		FORCE_SHIFT_CHAR : OUT STD_LOGIC; -- 10DB4
		FORCE_LC_SHIFT : OUT STD_LOGIC; -- 10DB4
		SET_LOWER_CASE : OUT STD_LOGIC; -- 09CD4 09CB5
		n1050_INTRV_REQ : OUT STD_LOGIC; -- 10BD4 04AA4
		READY_SHARE : OUT STD_LOGIC; -- 10BD4 09CB4
		TT5_POS_INTRV_REQ : OUT STD_LOGIC; -- 10DC4
		
		-- Buses
		TT_BUS: INOUT STD_LOGIC_VECTOR(0 to 7);
		GTD_TT3: OUT STD_LOGIC;
		DEBUG : INOUT DEBUG_BUS;
		
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		P1,P2,P3,P4 : IN STD_LOGIC;
		CLK : IN STD_LOGIC
		
	);
END n1050_DATA;

ARCHITECTURE FMD OF n1050_DATA IS 
type ConversionAtoE is array(0 to 255) of STD_LOGIC_VECTOR(0 to 7);
signal	ASCII_TO_EBCDIC : ConversionAtoE :=
	(
	character'Pos(cr)  => "00010101",
	character'Pos(lf)  => "00100101",
	character'Pos(' ') => "01000000",
	character'Pos('.') => "01001011",
	character'Pos('<') => "01001100",
	character'Pos('(') => "01001101",
	character'Pos('+') => "01001110",
	character'Pos('&') => "01010000",
	character'Pos('$') => "01011011",
	character'Pos(')') => "01011101",
	character'Pos(';') => "01011110",
	character'Pos('-') => "01100000",
	character'Pos('/') => "01100001",
	character'Pos(',') => "01101011",
	character'Pos('%') => "01101100",
	character'Pos('>') => "01101110",
	character'Pos('?') => "01101111",
	character'Pos(':') => "01111010",
	character'Pos('#') => "01111011",
	character'Pos('@') => "01111100",
	character'Pos('0') => "11110000", character'Pos('1') => "11110001", character'Pos('2') => "11110010",
	character'Pos('3') => "11110011", character'Pos('4') => "11110100",
	character'Pos('5') => "11110101", character'Pos('6') => "11110110", character'Pos('7') => "11110111",
	character'Pos('8') => "11111000", character'Pos('9') => "11111001",
	character'Pos('A') => "11000001", character'Pos('B') => "11000010", character'Pos('C') => "11000011",
	character'Pos('D') => "11000100", character'Pos('E') => "11000101", character'Pos('F') => "11000110",
	character'Pos('G') => "11000111", character'Pos('H') => "11001000", character'Pos('I') => "11001001",
	character'Pos('J') => "11010001", character'Pos('K') => "11010010", character'Pos('L') => "11010011",
	character'Pos('M') => "11010100", character'Pos('N') => "11010101", character'Pos('O') => "11010110",
	character'Pos('P') => "11010111", character'Pos('Q') => "11011000", character'Pos('R') => "11011001",
	character'Pos('S') => "11100010", character'Pos('T') => "11100011", character'Pos('U') => "11100100",
	character'Pos('V') => "11100101", character'Pos('W') => "11100110", character'Pos('X') => "11100111",
	character'Pos('Y') => "11101000", character'Pos('Z') => "11101001",
	character'Pos('a') => "10000001", character'Pos('b') => "10000010", character'Pos('c') => "10000011",
	character'Pos('d') => "10000100", character'Pos('e') => "10000101", character'Pos('f') => "10000110",
	character'Pos('g') => "10000111", character'Pos('h') => "10001000", character'Pos('i') => "10001001",
	character'Pos('j') => "10010001", character'Pos('k') => "10010010", character'Pos('l') => "10010011",
	character'Pos('m') => "10010100", character'Pos('n') => "10010101", character'Pos('o') => "10010110",
	character'Pos('p') => "10010111", character'Pos('q') => "10011000", character'Pos('r') => "10011001",
	character'Pos('s') => "10100010", character'Pos('t') => "10100011", character'Pos('u') => "10100100",
	character'Pos('v') => "10100101", character'Pos('w') => "10100110", character'Pos('x') => "10100111",
	character'Pos('y') => "10101000", character'Pos('z') => "10101001",
	others => "01101111");
type ConversionEtoA is array(0 to 255) of character;
signal	EBCDIC_TO_ASCII : ConversionEtoA :=
	(
	2#00010101# => cr,
	2#00100101# => lf,
	2#01000000# => ' ',
	2#01001011# => '.',
	2#01001100# => '<',
	2#01001101# => '(',
	2#01001110# => '+',
	2#01001111# => '|',
	2#01010000# => '&',
	2#01011010# => '!',
	2#01011011# => '$',
	2#01011100# => '*',
	2#01011101# => ')',
	2#01011110# => ';',
	2#01011111# => '~',
	2#01100000# => '-',
	2#01100001# => '/',
	2#01101011# => ',',
	2#01101100# => '%',
	2#01101101# => '_',
	2#01101110# => '>',
	2#01101111# => '?',
	2#01111010# => ':',
	2#01111011# => '#',
	2#01111100# => '@',
	2#01111101# => ''',
	2#01111110# => '=',
	2#01111111# => '"',
	2#11110000# => '0', 2#11110001# => '1', 2#11110010# => '2', 2#11110011# => '3', 2#11110100# => '4',
	2#11110101# => '5', 2#11110110# => '6', 2#11110111# => '7', 2#11111000# => '8', 2#11111001# => '9',
	2#11000001# => 'A', 2#11000010# => 'B', 2#11000011# => 'C', 2#11000100# => 'D', 2#11000101# => 'E',
	2#11000110# => 'F', 2#11000111# => 'G', 2#11001000# => 'H', 2#11001001# => 'I',
	2#11010001# => 'J', 2#11010010# => 'K', 2#11010011# => 'L', 2#11010100# => 'M', 2#11010101# => 'N',
	2#11010110# => 'O', 2#11010111# => 'P', 2#11011000# => 'Q', 2#11011001# => 'R',
	2#11100010# => 'S', 2#11100011# => 'T', 2#11100100# => 'U', 2#11100101# => 'V', 2#11100110# => 'W',
	2#11100111# => 'X', 2#11101000# => 'Y', 2#11101001# => 'Z',
	2#10000001# => 'a', 2#10000010# => 'b', 2#10000011# => 'c', 2#10000100# => 'd', 2#10000101# => 'e',
	2#10000110# => 'f', 2#10000111# => 'g', 2#10001000# => 'h', 2#10001001# => 'i',
	2#10010001# => 'j', 2#10010010# => 'k', 2#10010011# => 'l', 2#10010100# => 'm', 2#10010101# => 'n',
	2#10010110# => 'o', 2#10010111# => 'p', 2#10011000# => 'q', 2#10011001# => 'r',
	2#10100010# => 's', 2#10100011# => 't', 2#10100100# => 'u', 2#10100101# => 'v', 2#10100110# => 'w',
	2#10100111# => 'x', 2#10101000# => 'y', 2#10101001# => 'z',
	others => '?');

signal	sGT_1050_BUS_OUT, sGT_1050_TAGS_OUT : STD_LOGIC;
signal	sSET_LOWER_CASE : STD_LOGIC;
signal	sTE_LCH : STD_LOGIC;
signal	sSET_LOW_CASE : STD_LOGIC;
signal	sDATA_REG : STD_LOGIC_VECTOR(0 to 7);
signal	sNPL_BITS : STD_LOGIC_VECTOR(0 to 7);
signal	GT_1050_BUS_TO_A, GT_1050_TAGS_TO_A : STD_LOGIC;
signal	sTAGS_OUT : STD_LOGIC_VECTOR(0 to 7);
signal	DATA_REG_LATCH : STD_LOGIC;
signal	DATA_REG_IN : STD_LOGIC_VECTOR(0 to 7);
signal	TI_P_BIT : STD_LOGIC;
signal	sPTT_BITS : STD_LOGIC_VECTOR(0 to 6);
signal	sGTD_TT3 : STD_LOGIC;
signal	CE_TE_LCH_SET : STD_LOGIC;
signal	TE_LCH_SET, TE_LCH_RESET : STD_LOGIC;
signal	sGT_WRITE_REG : STD_LOGIC;
signal	WR_SHARE_REQ_SET, WR_SHARE_REQ_RESET,sWR_SHARE_REQ : STD_LOGIC;
signal	ALLOW_STROBE_SET, ALLOW_STROBE_RESET, sALLOW_STROBE : STD_LOGIC;
signal	SHIFT_SET, SHIFT_RESET : STD_LOGIC;
signal	sSHIFT : STD_LOGIC := '0';
signal	INTRV_REQ_SET, INTRV_REQ_RESET, sINTRV_REQ : STD_LOGIC;
signal	n1050_INTRV_REQ_RESET : STD_LOGIC;
signal	NOT_OPER_RESET : STD_LOGIC;
signal	NOT_OPER : STD_LOGIC := '0';
signal	RDY_SHARE_SET, RDY_SHARE_RESET, sRDY_SHARE : STD_LOGIC;
signal	CancelCode : STD_LOGIC;
signal	NOT_n1050_OPER : STD_LOGIC;

BEGIN
-- Fig 5-10C
GT_1050_BUS_TO_A <= (E_SW_SEL_BUS.TI_SEL and USE_MANUAL_DECODER) or
	(USE_ALT_CA_DECODER and not GTD_CA_BITS(0) and GTD_CA_BITS(1) and GTD_CA_BITS(2) and GTD_CA_BITS(3)); -- AB3C7 AA=1 CA=0111
GT_1050_TAGS_TO_A <= (E_SW_SEL_BUS.TT_SEL and USE_MANUAL_DECODER) or
	(USE_BASIC_CA_DECO and not GTD_CA_BITS(0) and not GTD_CA_BITS(1) and not GTD_CA_BITS(2) and GTD_CA_BITS(3)); -- AA2C6 AA=0 CA=0001

A_REG_BUS <= not(((sNPL_BITS & TI_P_BIT) and (0 to 8=>GT_1050_BUS_TO_A)) or ((TT_BUS & '0') and (0 to 8=>GT_1050_TAGS_TO_A))); -- AC2E2 - Note: Inverted

DATA_REG_PH: PHV port map(D=>DATA_REG_IN,L=>DATA_REG_LATCH,Q=>sDATA_REG); -- AC3B2
DATA_REG_BUS <= sDATA_REG;
DATA_REG_LATCH <= (CE_DATA_ENTER_GT and CE_TE_DECODE) or (RD_OR_RD_INQ and W_TIME) or (T3 and sGT_1050_BUS_OUT) or not RUN; -- AC3P5
TAGS_OUT <= DATA_REG_IN; -- ?

sGT_1050_BUS_OUT <= GT_1050_BUS_OUT; -- AC2D6
sGT_1050_TAGS_OUT <= GT_1050_TAGS_OUT; -- AC2M4

DATA_REG_IN <= (Z_BUS(0 to 7) and (0 to 7=>(sGT_1050_BUS_OUT or sGT_1050_TAGS_OUT)))
	or (CE_BITS and (0 to 7=>CE_GT_TA_OR_TE))
	or (('0' & PCH_BITS) and (0 to 7=>(CLOCK_1 and PCH_1_CLUTCH))); -- AC2B4 AC2H6 AC2M6 AC2M2

sGTD_TT3 <= TT_BUS(3) and n1050_CE_MODE; -- AC2H5 AC2L4
GTD_TT3 <= sGTD_TT3;

TT_BUS(7) <= EVENPARITY(sDATA_REG(1 to 7)) and WR_LCH and RUN and not TT_BUS(0); -- AC2E4 AC2J2
-- CancelCode <= '1' when sDATA_REG(1 to 7)="1100000" else '0'; -- DATA_REG=X1100000
CancelCode <= '1' when sDATA_REG(1 to 7)="0010101" else '0'; -- DATA_REG (ASCII) = 15 = ^U
TT_BUS(0) <= CancelCode and PROCEED_LCH and TT_BUS(4); -- AL2F5 AC2D6

-- The following converts the card code CBA8421 on the DATA_REG bus to EBCDIC
-- C  P    P    P    P 
-- B  0    0    1    1
-- A  0    1    0    1
-- =====================
-- 0  =40 @=7C -=60 &=50
-- 1 1=F1 /=61 j=91 a=81
-- 2 2=F2 s=A2 k=92 b=82
-- 3 3=F3 t=A3 l=93 c=83
-- 4 4=F4 u=A4 m=94 d=84
-- 5 5=F5 v=A5 n=95 e=85
-- 6 6=F6 w=A6 o=96 f=86
-- 7 7=F7 x=A7 p=97 g=87
-- 8 8=F8 y=A8 q=98 h=88
-- 9 9=F9 z=A9 r=99 i=89
-- A 0=FA      CAN
-- B #=7B ,=6B $=5B .=4B
-- C
-- D           CR
-- E UC   EOB       LC
-- F
-- For the purposes of this project, this will convert ASCII on CBA8421 into EBCDIC in MPL

-- sNPL_BITS(0) <= 0; -- AC3J2
-- sNPL_BITS(1) <= 0; -- AC3J2
-- sNPL_BITS(2) <= 0; -- AC3K2
-- sNPL_BITS(3) <= 0; -- AC3H2
-- sNPL_BITS(4) <= 0; -- AC3H2
-- sNPL_BITS(5) <= 0; -- AC3K2
-- sNPL_BITS(6) <= 0; -- AC3J2
-- sNPL_BITS(7) <= 0; -- AC3J2
sNPL_BITS <= ASCII_TO_EBCDIC(Conv_Integer(sDATA_REG));
-- sNPL_BITS <= STD_LOGIC_VECTOR(to_unsigned(Conv_Integer(sDATA_REG),8)); -- * * Temporary debug - no translation
NPL_BITS <= sNPL_BITS;

TI_P_BIT <= EVENPARITY(sNPL_BITS(0 to 7)); -- AC2G4

-- The following converts EBCDIC on the DATA_REG bus to card code CBA8421
-- For the purposes of this project, this will convert EBCDIC in DATA_REG into ASCII in PTT
-- sPTT_BIT_C <= EVEN_PARITY(...); -- C AC3G4
-- sPTT_BIT_B <= 0; -- AC3H2
-- sPTT_BIT_A <= 0; -- AC3K2
-- sPTT_BIT_8 <= 0; -- AC3G2
-- sPTT_BIT_4 <= 0; -- AC3G2
-- sPTT_BIT_2 <= 0; -- AC3G2
-- sPTT_BIT_1 <= 0; -- AC3G2
sPTT_BITS <= STD_LOGIC_VECTOR(to_unsigned(Character'Pos(EBCDIC_TO_ASCII(Conv_Integer(sDATA_REG))),7));
PTT_BITS <= sPTT_BITS;

CE_TE_LCH_SET <= (CE_DATA_ENTER_GT and CE_TE_DECODE) and n1050_OP_IN and CLOCK_1; -- AC2D7 AC2L6 ?? Ignore NOT in AC2M4
TE_LCH_SET <= CE_TE_LCH_SET or (CE_RUN_MODE and CE_TE_DECODE) or (sGT_1050_BUS_OUT and T4); -- AC2J7
sGT_WRITE_REG <= (Z_TIME and sALLOW_STROBE and not sSHIFT); -- AC2C6
GT_WRITE_REG <= sGT_WRITE_REG; -- AC2M4 AC2H6

TE_LCH_RESET <= sSET_LOWER_CASE or sGT_WRITE_REG;

TE_LCH_FL: FLL port map(S=>TE_LCH_SET,R=>TE_LCH_RESET,Q=>sTE_LCH); -- AC2B6
TE_LCH <= sTE_LCH;

WR_SHARE_REQ_SET <= not n1050_RST_LCH and W_TIME and WR_LCH and not sTE_LCH;
WR_SHARE_REQ_RESET <= RST_ATTACH or SHARE_REQ_RST;
WR_SHARE_REQ_FL: FLL port map(S=>WR_SHARE_REQ_SET,R=>WR_SHARE_REQ_RESET,Q=>sWR_SHARE_REQ); -- AC2K5 AC2D6
WR_SHARE_REQ <= sWR_SHARE_REQ;

ALLOW_STROBE_SET <= RDR_1_CLUTCH and Y_TIME and sTE_LCH;
ALLOW_STROBE_RESET <= sSET_LOWER_CASE or (Y_TIME and not RDR_1_CLUTCH) or X_TIME;
ALLOW_STROBE_FL: FLL port map(S=>ALLOW_STROBE_SET,R=>ALLOW_STROBE_RESET,Q=>sALLOW_STROBE); -- AC2B6
ALLOW_STROBE <= sALLOW_STROBE;

SHIFT_SET <= (n1050_CE_MODE and SET_SHIFT_LCH) or (SET_SHIFT_LCH and sTE_LCH and Y_TIME);
SHIFT_RESET <= X_TIME or sSET_LOWER_CASE;
SHIFT_FL: FLL port map(S=>SHIFT_SET,R=>SHIFT_RESET,Q=>sSHIFT); -- AC2B6
FORCE_SHIFT_CHAR <= (UC_CHARACTER and Z_TIME and sSHIFT) or (sSHIFT and Z_TIME and LC_CHARACTER); -- AC2C6
FORCE_LC_SHIFT <= (sSHIFT and Z_TIME and LC_CHARACTER); -- AC2D6 ?? not?

sSET_LOWER_CASE <= TA_REG_SET or RST_ATTACH; -- AC2C6 AC2D6
SET_LOWER_CASE <= sSET_LOWER_CASE;

INTRV_REQ_SET <= (not n1050_OPER and READ_INQ and not RD_SHARE_REQ_LCH) 
	or (not RD_SHARE_REQ_LCH and READ and (not TT_BUS(1) or not TT_BUS(3))) -- AC2G6 AC2H5
	or (	WRITE_MODE 
			and not RESTORE
			and not Z_TIME
			and not TA_REG_SET
			and (not TT_BUS(3) or not OUTPUT_SEL_AND_READY)
			and (not CE_DATA_ENTER_GT or not n1050_CE_MODE)); -- AC2E5 AC2K7

INTRV_REQ_RESET <= SHARE_REQ_RST or RST_ATTACH; -- AC2H5 AC2H3

INTRV_REQ_FL: FLL port map(S=>INTRV_REQ_SET,R=>INTRV_REQ_RESET,Q=>sINTRV_REQ); -- AC2G6 AC2H3
TT5_POS_INTRV_REQ <= sINTRV_REQ;

n1050_INTRV_REQ_RESET <= n1050_CE_MODE or (Z_BUS(0) and GT_1050_TAGS_OUT) or (GT_1050_TAGS_OUT and Z_BUS(3)) or RST_ATTACH or sRDY_SHARE;
n1050_INTRV_REQ_FL: FLL port map(S=>sINTRV_REQ,R=>n1050_INTRV_REQ_RESET,Q=>n1050_INTRV_REQ); -- AC2K3 AC2H4

NOT_OPER_RESET <= RUN or sRDY_SHARE;
NOT_n1050_OPER <= not n1050_OPER;
NOT_OPER_FL: FLL port map(S=>NOT_n1050_OPER,R=>NOT_OPER_RESET,Q=>NOT_OPER); -- AC2G5 ?? Set input inverted

RDY_SHARE_SET <= not sINTRV_REQ and TT_BUS(3) and NOT_OPER; -- AC2J7
RDY_SHARE_RESET <= INTRV_REQ_RESET or RUN or TA_REG_POS_6_ATTN_RST;
RDY_SHARE_FL: FLL port map(S=>RDY_SHARE_SET,R=>RDY_SHARE_RESET,Q=>sRDY_SHARE); -- AC2F6 AC2E5
READY_SHARE <= sRDY_SHARE;

with DEBUG.Selection select
	DEBUG.Probe <=
		sDATA_REG(0) when 0,
		sDATA_REG(1) when 1,
		sDATA_REG(2) when 2,
		sDATA_REG(3) when 3,
		sDATA_REG(4) when 4,
		sDATA_REG(5) when 5,
		sDATA_REG(6) when 6,
		sDATA_REG(7) when 7,
		sNPL_BITS(0) when 8,
		sNPL_BITS(1) when 9,
		sNPL_BITS(2) when 10,
		sNPL_BITS(3) when 11,
		sNPL_BITS(4) when 12,
		sNPL_BITS(5) when 13,
		sNPL_BITS(6) when 14,
		sNPL_BITS(7) when 15;
END FMD; 

