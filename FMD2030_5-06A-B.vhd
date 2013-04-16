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
--    File: FMD2030_5-06A-B.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    ALU, A & B registers
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

ENTITY ABALU IS
	port
	(
		-- Inputs
		LAMP_TEST : IN STD_LOGIC; -- 04A
		SALS : IN SALS_Bus; -- 01C
		MANUAL_STORE : IN STD_LOGIC; -- 03D
		RECYCLE_RST : IN STD_LOGIC; -- 04A
		S_REG_3 : IN STD_LOGIC; -- 07B
		SERV_IN_SIG,STAT_IN_SIG,OPNL_IN,ADDR_IN : IN STD_LOGIC; -- 08D
		T_REQUEST : IN STD_LOGIC; -- 10B
		A_BUS, B_BUS : IN STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		MAN_STOR_OR_DSPLY : IN STD_LOGIC; -- 03D
		MACH_RST_SET_LCH : IN STD_LOGIC; -- 04B
		S_REG_0 : IN STD_LOGIC; -- 07B
		CTRL : IN CTRL_REG; -- 01C
		DIAG_SW : IN STD_LOGIC; -- 04A
		S_REG_RST : IN STD_LOGIC; -- 07B
		GT_Z_BUS_TO_S_REG : IN STD_LOGIC; -- 07B
		ROS_SCAN : IN STD_LOGIC; -- 03C
		GT_SWS_TO_WX_PWR : IN STD_LOGIC; -- 04A
		RST_LOAD : IN STD_LOGIC; -- 03C
		SYSTEM_RST_PRIORITY_LCH : IN STD_LOGIC; -- 03A

		-- Outputs
		IND_A,IND_B,IND_ALU : OUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		A_REG_PC,B_REG_PC : OUT STD_LOGIC; -- 11A,07A,13A
		OPNL_IN_LCHD,STATUS_IN_LCHD,Z0_BUS_0,SERV_IN_LCHD,ADDR_IN_LCHD : OUT STD_LOGIC; -- 02A
		CARRY_1_LCHD : OUT STD_LOGIC; -- 05A
		CARRY_0_LATCHED : OUT STD_LOGIC; -- 01B,02A
		CARRY_0 : OUT STD_LOGIC; -- 07B
		ALU_CHK : OUT STD_LOGIC; -- 03C,01A,07A
		NTRUE,COMPLEMENT : OUT STD_LOGIC; -- 03B
		P_CONNECT : OUT STD_LOGIC; -- 02A
		P_CTRL_N : OUT STD_LOGIC; -- 02A,03A
		N_CTRL_N : OUT STD_LOGIC; -- 04A
		N_CTRL_LM : OUT STD_LOGIC; -- 02A
		P_Z_BUS,N_Z_BUS : OUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		Z_HI_0,Z_LO_0,Z_0,Z_BUS_LO_DIGIT_PARITY : OUT STD_LOGIC;
		MACH_RST_2A,MACH_RST_2B,MACH_RST_2C : OUT STD_LOGIC;
		ODD : OUT STD_LOGIC; -- 04A
		ALU_CHK_LCH : OUT STD_LOGIC; -- 01B,08D
		GT_CARRY_TO_S3 : OUT STD_LOGIC; -- 07B
		INTRODUCE_ALU_CHK : OUT STD_LOGIC; -- 04A
		DECIMAL : OUT STD_LOGIC; -- 02A

		-- Debug
		DBG_P_ALU_A_IN, DBG_P_ALU_B_IN, DBG_P_ALU_CARRY, DBG_P_ALU_SUMS : OUT STD_LOGIC_VECTOR(0 to 7);
		DBG_N_ALU_A_IN, DBG_N_ALU_B_IN, DBG_N_ALU_CARRY, DBG_N_ALU_SUMS : OUT STD_LOGIC_VECTOR(0 to 7);
		DEBUG : OUT STD_LOGIC;
		
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		P1 : IN STD_LOGIC;
		Clk : IN STD_LOGIC -- 50MHz
		
	);
END ABALU;

ARCHITECTURE FMD OF ABALU IS 

alias CC : STD_LOGIC_VECTOR(0 to 2) is CTRL.CTRL_CC;
alias CV : STD_LOGIC_VECTOR(0 to 1) is CTRL.CTRL_CV;
alias CROSSED : STD_LOGIC is CTRL.CROSSED;
alias STRAIGHT : STD_LOGIC is CTRL.STRAIGHT;
alias GT_A_LO : STD_LOGIC is CTRL.GT_A_REG_LO;
alias GT_A_HI : STD_LOGIC is CTRL.GT_A_REG_HI;
alias GT_B_REG_LO : STD_LOGIC is CTRL.GT_B_REG_LO;
alias GT_B_REG_HI : STD_LOGIC is CTRL.GT_B_REG_HI;

signal P_CARRY_IN_7,N_CARRY_IN_7 : STD_LOGIC;
signal P_Z_ALU_BUS,N_Z_ALU_BUS : STD_LOGIC_VECTOR(0 to 7);
signal A_REG,B_REG : STD_LOGIC_VECTOR(0 to 8); -- 8 is P
signal CARRY_S3,INSERT_CARRY,INSERT_0_CARRY : STD_LOGIC;
signal NOT_S3 : STD_LOGIC;
signal HEX,sDECIMAL : STD_LOGIC;
-- signal N_CONNECT : std_logic;
-- signal P_CTRL_LM : STD_LOGIC;
signal P_ALU_A_IN,N_ALU_A_IN : STD_LOGIC_VECTOR(0 to 7);
signal P_ALU_B_IN,N_ALU_B_IN : STD_LOGIC_VECTOR(0 to 7);
signal P_SUMS,N_SUMS,P_CARRY,N_CARRY : STD_LOGIC_VECTOR(0 to 7);
signal HSEL,LSEL : STD_LOGIC_VECTOR(0 to 2);
signal sINTRODUCE_ALU_CHK : STD_LOGIC;
signal sODD,EVEN : STD_LOGIC;
signal DIAG_TEST_BIT : STD_LOGIC;
signal sNTRUE : STD_LOGIC;
signal sP_Z_BUS,sN_Z_BUS : STD_LOGIC_VECTOR(0 to 8);
signal sALU_CHK_LCH : STD_LOGIC;
signal sZ_HI_0, sZ_LO_0, sZ_0 : STD_LOGIC;
signal sMACH_RST_2, sMACH_RST_2A : STD_LOGIC;
signal sGT_CARRY_TO_S3 : STD_LOGIC;
signal SI_LCH_Set,STI_LCH_Set,Z0C1C0_LCH,PC7_LCH_Set,PC7_LCH_Reset,
		NC7_LCH_Set,A_LCH_L,B_LCH_L,NS3_LCH_Set,NS3_LCH_Reset,EVEN_LCH_Set,EVEN_LCH_Reset,AC_LCH_Set,AC_LCH_Reset : STD_LOGIC;
signal sCARRY_0_LATCHED, sALU_CHK : STD_LOGIC; -- Debug

BEGIN
-- Fig 5-06A
-- A REGISTER, B REGISTER INDICATORS
IND_A <= "111111111" when LAMP_TEST='1' else A_REG;
IND_B <= "111111111" when LAMP_TEST='1' else B_REG;
A_REG_PC <= EvenParity(A_REG); -- AB2H2
B_REG_PC <= EvenParity(B_REG); -- AB2J2

-- IMMED STAT REG
SI_LCH_Set <= SERV_IN_SIG and not T_REQUEST;
SI_LCH: PH port map(SI_LCH_Set,T3,SERV_IN_LCHD); -- AB2D6
STI_LCH_Set <= STAT_IN_SIG and not T_REQUEST;
STI_LCH: PH port map(STI_LCH_Set,T3,STATUS_IN_LCHD); -- AB2D6
OI_LCH: PH port map(OPNL_IN,T3,OPNL_IN_LCHD); -- AB2D6
AI_LCH: PH port map(ADDR_IN,T3,ADDR_IN_LCHD); -- AB2D6

Z0C1C0_LCH <= T4 or RECYCLE_RST;
Z0_LCH: PH port map(sZ_0,Z0C1C0_LCH,Z0_BUS_0); -- AB2D6
C1_LCH: PH port map(P_CARRY(1),Z0C1C0_LCH,CARRY_1_LCHD); -- AB2D6
C0_LCH: PH port map(P_CARRY(0),Z0C1C0_LCH,sCARRY_0_LATCHED); -- AB2D6
CARRY_0_LATCHED <= sCARRY_0_LATCHED;

-- ALU INDICATORS
IND_ALU <= "111111111" when LAMP_TEST='1' else sP_Z_BUS;

-- CARRY IN LATCHES
CARRY_S3 <= '1' when CC="110" else '0'; -- AB2E7
INSERT_CARRY <= '1' when (CC="001") or (CC="101") else '0'; -- AB2E6
INSERT_0_CARRY <= '1' when (CC="000") or (CC="010") or (CC="011") or (CC="100") or (CC="111") else '0'; -- AB2E7

PC7_LCH_Set <= (S_REG_3 and CARRY_S3 and P1) or (P1 and INSERT_CARRY);
PC7_LCH_Reset <= MANUAL_STORE or T1 or RECYCLE_RST;
PC7_LCH: FLL port map(PC7_LCH_Set,PC7_LCH_Reset,P_CARRY_IN_7); -- AB2F3,AB2E4
NC7_LCH_Set <= (NOT_S3 and CARRY_S3 and P1) or (P1 and INSERT_0_CARRY) or RECYCLE_RST or MANUAL_STORE;
NC7_LCH: FLL port map(NC7_LCH_Set,T1,N_CARRY_IN_7); -- AB2F3,AB2E4

-- ALU CHECK
sALU_CHK <= '1' when (P_Z_ALU_BUS xor N_Z_ALU_BUS)/="11111111" or (P_SUMS(0) = N_SUMS(0)) or (P_SUMS(4) = N_SUMS(4)) or (P_CARRY(0) = N_CARRY(0)) else '0'; -- AB2D3,AB2D4,AB2E4
ALU_CHK <= sALU_CHK;

-- Fig 5-06B
-- A REG and B REG
A_LCH_L <= MAN_STOR_OR_DSPLY or MACH_RST_SET_LCH or T1;
A_LCH: PHV9 port map(not A_BUS,A_LCH_L,A_REG); -- AB1J5,AB1K7
B_LCH_L <= MACH_RST_SET_LCH or T1 or MANUAL_STORE;
B_LCH: PHV9 port map(B_BUS,B_LCH_L,B_REG); -- AB1J5,AB1L5

-- ALU B entry
sNTRUE <= '1' when (CV(0)='1' and S_REG_0='0') or CV="00" else '0'; -- AB2K7
NTRUE <= sNTRUE;
COMPLEMENT <= '1' when (CV(0)='1' and S_REG_0='1') or CV="01" else '0'; -- AB2L7
HEX <= '1' when CV(0)='0' or CV(1)='0' else '0'; -- AB2J7
sDECIMAL <= '1' when CV="11" else '0'; -- AB2H7
DECIMAL <= sDECIMAL;

HSEL <= GT_B_REG_HI & sDECIMAL & sNTRUE;
with HSEL select P_ALU_B_IN(0 to 3) <= 
	B_REG(0 to 3) + "0110" when "111", -- Spec A1
	B_REG(0 to 3) when "101", -- Spec A2
	not B_REG(0 to 3) when "100"|"110", -- Spec A3
	"0110" when "011", -- Spec A4 ???
	"1111" when "000"|"010", -- Spec A5
	"0000" when others
	;

LSEL <= GT_B_REG_LO & sDECIMAL & sNTRUE;
with LSEL select P_ALU_B_IN(4 to 7) <= 
	B_REG(4 to 7) + "0110" when "111", -- Spec A1
	B_REG(4 to 7) when "101", -- Spec A2
	not B_REG(4 to 7) when "100"|"110", -- Spec A3
	"0110" when "011", -- Spec A4 ???
	"1111" when "000"|"010", -- Spec A5
	"0000" when others
	;
N_ALU_B_IN <= not P_ALU_B_IN;

-- ALU A entry
P_ALU_A_IN(0 to 3) <=
	((0 to 3 => not CROSSED) or A_REG(4 to 7)) and
	((0 to 3 => not STRAIGHT) or A_REG(0 to 3)) and
	(0 to 3 => GT_A_HI);
P_ALU_A_IN(4 to 7) <=
	((4 to 7 => not CROSSED) or A_REG(0 to 3)) and
	((4 to 7 => not STRAIGHT) or A_REG(4 to 7)) and
	(4 to 7 => GT_A_LO);
N_ALU_A_IN(0 to 3) <=
	not(((0 to 3 => GT_A_HI and STRAIGHT) and A_REG(0 to 3)) or
	((0 to 3 => GT_A_HI and CROSSED) and A_REG(4 to 7))); -- ?? GT_A_HI is missing in MDM
N_ALU_A_IN(4 to 7) <=
	not(((4 to 7 => GT_A_LO and STRAIGHT) and A_REG(4 to 7)) or
	((4 to 7 => GT_A_LO and CROSSED) and A_REG(0 to 3)));

-- ALU
P_CONNECT <= '1' when (CC(0)='0' and CC(1)='1') or (CC(1)='1' and CC(2)='1') else '0'; -- AB2D7,AB2F7 CC=01X or CC=X11 i.e. 010 011 111
-- N_CONNECT <= '1' when (CC(0)/='0' or CC(1)/='1') and (CC(1)/='1' or CC(2)/='1') else '0'; -- AB2G7 i.e. 000 001 100 101 110www.typeupsidedown.
P_CTRL_N <= '1' when CC(1)='0' or CC(0)='1' else '0'; -- AB2D7,AB2F7 CC=X0X or 1XX ie. 000 001 100 101 110 111
N_CTRL_N <= '1' when CC(0)/='1' and CC(1)/='0' else '0'; -- AB2G7 CC=1XX nor CC=X0X ==> CC\=1XX and CC\=X0X i.e. 010 or 011
N_CTRL_LM <= '1' when CC/="010" else '0'; -- AB2G7
-- P_CTRL_LM <= '1' when CC="010" else '0'; -- AB2H7

-- CC functions
-- 000 Add, Carry in 0, Ignore Carry out
-- 001 Add, Carry in 1, Ignore Carry out
-- 010 And, Ignore Carry out
-- 011 Or,  Ignore Carry out
-- 100 Add, Carry in 0, Set S3 to 1 on Carry out
-- 101 Add, Carry in 1, Set S3 to 1 on Carry out
-- 110 Add, Carry in from S3, Set S3 to 1 on Carry out
-- 111 Xor, Ignore Carry out

-- ALU P
with CC select P_SUMS <= -- AB2J6,AB2H6,AB2G6,AB2F6,AB2J5,AB2H5,AB2G5,AB2F5
	P_ALU_A_IN and P_ALU_B_IN when "010",
	P_ALU_A_IN or P_ALU_B_IN when "011",
	P_ALU_A_IN xor P_ALU_B_IN when "111",
	P_ALU_A_IN xor P_ALU_B_IN xor P_CARRY(1 to 7) & P_CARRY_IN_7 when others;

with CC select P_CARRY <=
	"00000000" when "010"|"011"|"111",
	(P_ALU_A_IN and P_ALU_B_IN) or
	(P_ALU_A_IN and P_CARRY(1 to 7) & P_CARRY_IN_7) or
	(P_ALU_B_IN and P_CARRY(1 to 7) & P_CARRY_IN_7) when others; -- Ripple carry
CARRY_0 <= P_CARRY(0);

sINTRODUCE_ALU_CHK <= DIAG_SW and sALU_CHK_LCH; -- AE3H5,AB3F6,AB3F7
INTRODUCE_ALU_CHK <= sINTRODUCE_ALU_CHK;

-- ALU N
with CC select N_SUMS <= -- AB2J6,AB2H6,AB2G6,AB2F6,AB2J5,AB2H5,AB2G5,AB2F5
	(N_ALU_A_IN or N_ALU_B_IN) or (0 to 7 => sINTRODUCE_ALU_CHK) when "010",
	(N_ALU_A_IN and N_ALU_B_IN) or (0 to 7 => sINTRODUCE_ALU_CHK) when "011",
	(N_ALU_A_IN xnor N_ALU_B_IN) or (0 to 7 => sINTRODUCE_ALU_CHK) when "111",
	(N_ALU_A_IN xor N_ALU_B_IN xor N_CARRY(1 to 7) & N_CARRY_IN_7) or (0 to 7 => sINTRODUCE_ALU_CHK) when others;
with CC select N_CARRY <=
	"11111111"  and (0 to 7 => not sINTRODUCE_ALU_CHK) when "010"|"011"|"111",
	((N_ALU_A_IN and N_ALU_B_IN) or
	(N_ALU_A_IN and N_CARRY(1 to 7) & N_CARRY_IN_7) or
	(N_ALU_B_IN and N_CARRY(1 to 7) & N_CARRY_IN_7)) and (0 to 7 => not sINTRODUCE_ALU_CHK) when others;

-- Debug
DBG_P_ALU_A_IN <= P_ALU_A_IN;
DBG_P_ALU_B_IN <= P_ALU_B_IN;
DBG_P_ALU_CARRY <= P_CARRY;
DBG_P_ALU_SUMS <= P_SUMS;
DBG_N_ALU_A_IN <= N_ALU_A_IN;
DBG_N_ALU_B_IN <= N_ALU_B_IN;
DBG_N_ALU_CARRY <= N_CARRY;
DBG_N_ALU_SUMS <= N_SUMS;

sGT_CARRY_TO_S3 <= '1' when CC="100" or CC="101" or CC="110" else '0'; -- AB2E6
GT_CARRY_TO_S3 <= sGT_CARRY_TO_S3;
-- Debug
NOT_S3 <= not S_REG_3;
-- NS3_LCH_Set <= (N_CARRY(0) and T4 and sGT_CARRY_TO_S3) or S_REG_RST;
-- NS3_LCH_Reset <= (sGT_CARRY_TO_S3 and T4 and P_CARRY(0)) or (GT_Z_BUS_TO_S_REG and sP_Z_BUS(3));
-- NS3_LCH: FLE port map(NS3_LCH_Set,NS3_LCH_Reset,clk,NOT_S3); -- AB2E3

-- Temp Debug
P_Z_ALU_BUS(0 to 3) <= ((0 => sODD and HEX, 1 to 3 => HEX) and P_SUMS(0 to 3)) or
	((0 to 3 => P_CARRY(0) and sDECIMAL) and P_SUMS(0 to 3)) or
	((0 to 3 => N_CARRY(0) and sDECIMAL) and (P_SUMS(0 to 3) - "0110"));
N_Z_ALU_BUS(0 to 3) <= ((0 to 3 => HEX) and N_SUMS(0 to 3)) or
	((0 to 3 => sDECIMAL and P_CARRY(0)) and N_SUMS(0 to 3)) or
	((0 to 3 => sDECIMAL and N_CARRY(0)) and (N_SUMS(0 to 3) + "0110"));
P_Z_ALU_BUS(4 to 7) <= ((4 => sODD and HEX, 5 to 7 => HEX) and P_SUMS(4 to 7)) or
	((4 to 7 => P_CARRY(4) and sDECIMAL) and P_SUMS(4 to 7)) or
	((4 to 7 => N_CARRY(4) and sDECIMAL) and (P_SUMS(4 to 7) - "0110"));
N_Z_ALU_BUS(4 to 7) <= ((4 to 7 => HEX) and N_SUMS(4 to 7)) or
	((4 to 7 => sDECIMAL and P_CARRY(4)) and N_SUMS(4 to 7)) or
	((4 to 7 => sDECIMAL and N_CARRY(4)) and (N_SUMS(4 to 7) + "0110"));

sP_Z_BUS <= P_Z_ALU_BUS & EvenParity(P_Z_ALU_BUS & EVEN); -- AB3C4
-- Note N_Z parity is not inverted, so is the same as P_Z
-- This may force a parity error when INTRODUCE_ALU_CHK is active, 
-- depending on the value of P_Z.  This parity error into R is required
-- for Diag B73 to work
sN_Z_BUS <= N_Z_ALU_BUS & EvenParity(P_Z_ALU_BUS & EVEN);
P_Z_BUS <= sP_Z_BUS;
N_Z_BUS <= sN_Z_BUS;
Z_BUS_LO_DIGIT_PARITY <= EvenParity(P_Z_ALU_BUS(4 to 7)); -- AB3C4
sZ_HI_0 <= '1' when sP_Z_BUS(0 to 3)="0000" else '0'; -- AB2E5
Z_HI_0 <= sZ_HI_0;
sZ_LO_0 <= '1' when sP_Z_BUS(4 to 7)="0000" else '0'; -- AB2E5
Z_LO_0 <= sZ_LO_0;
sZ_0 <= sZ_HI_0 and sZ_LO_0; -- AB2D5
Z_0 <= sZ_0;
sMACH_RST_2 <= sZ_0 and RECYCLE_RST; -- AB3C5
MACH_RST_2A_DELAY: AR port map(D=>sMACH_RST_2,Clk=>Clk,Q=>sMACH_RST_2A);
MACH_RST_2A <= sMACH_RST_2A;
MACH_RST_2B <= sMACH_RST_2A;
MACH_RST_2C <= sMACH_RST_2A;

DIAG_TEST_BIT <= '1' when SALS.SALS_CK="1000" and SALS.SALS_AK='1' else '0'; -- AB3E7
EVEN_LCH_Set <= T2 and DIAG_TEST_BIT and not sALU_CHK_LCH;
EVEN_LCH_Reset <= (T2 and sALU_CHK_LCH) or RST_LOAD or SYSTEM_RST_PRIORITY_LCH or RECYCLE_RST; -- ?? *not* SYSTEM_RST_PRIORITY_LCH ??
EVEN_LCH: FLL port map(EVEN_LCH_Set,EVEN_LCH_Reset,EVEN); -- AB3E5,AB3G2
sODD <= not EVEN;
ODD <= sODD;

AC_LCH_Set <= EVEN and DIAG_TEST_BIT and T1;
AC_LCH_Reset <= RECYCLE_RST or RST_LOAD or (ROS_SCAN and GT_SWS_TO_WX_PWR);
AC_LCH: FLL port map(AC_LCH_Set,AC_LCH_Reset,sALU_CHK_LCH); -- AG3G7,AB3G2
ALU_CHK_LCH <= sALU_CHK_LCH;

-- Debug
DEBUG <= '1' when NC7_LCH_Set='1' else '0';

END FMD; 
