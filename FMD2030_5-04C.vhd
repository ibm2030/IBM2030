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
--    File: FMD2030_5-04C.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Manual Data (E switch) & C,F,H registers
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
--    Revision 1.01 2012-04-07
--		Fix typo in comment
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY ManualDataCFH IS
	port
	(
		-- Inputs
		MACH_RST_PROT : IN STD_LOGIC; -- 07B
		USE_MAN_DECO_PWR : IN STD_LOGIC; -- 03D
		N60_CY_TIMER_PULSE : IN STD_LOGIC; -- 14A
		L_REGISTER : IN STD_LOGIC_VECTOR(0 to 7); -- 05C
		MACH_RST_SW : IN STD_LOGIC; -- 03D
		EXT_TRAP_MASK_ON : IN STD_LOGIC; -- 08C
		USE_MAN_DECODER, USE_MAN_DECODER_PWR : IN STD_LOGIC; -- 03D
		USE_ALT_CA_DECODER : IN STD_LOGIC; -- 02B
		USE_BASIC_CA_DECODER : IN STD_LOGIC; -- 02A
		GTD_CA_BITS : IN STD_LOGIC_VECTOR(0 to 3); -- 05C
		CK_SALS : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		GT_CK_DECO : IN STD_LOGIC; -- 03B
		Z_BUS : IN STD_LOGIC_VECTOR(0 to 7);
		Z_BUS_P : IN STD_LOGIC;
		MACH_RST_2B : IN STD_LOGIC; -- 06B
		MAN_STOR_PWR : IN STD_LOGIC; -- 03D
		CD_CTRL_REG : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		RECYCLE_RST : IN STD_LOGIC; -- 04A

		-- Switches
		SW_INTRP_TIMER : IN STD_LOGIC;
		SW_CONS_INTRP : IN STD_LOGIC;
		SW_A,SW_B,SW_C,SW_D,SW_F,SW_G,SW_H,SW_J : IN STD_LOGIC_VECTOR(0 to 3);
		SW_AP,SW_BP,SW_CP,SW_DP,SW_FP,SW_GP,SW_HP,SW_JP : IN STD_LOGIC;

		-- Outputs
		ABCD_SW_BUS,FGHJ_SW_BUS : OUT STD_LOGIC_VECTOR(0 to 15);
		AB_SW_P,CD_SW_P,FG_SW_P,HJ_SW_P : OUT STD_LOGIC;
		IJ_SEL,UV_SEL : OUT STD_LOGIC;
		TIMER_UPDATE : OUT STD_LOGIC; -- 02A
		TIMER_UPDATE_OR_EXT_INT : OUT STD_LOGIC; -- 02A
		EXT_INTRP : OUT STD_LOGIC; -- 02A
		A_BUS : OUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		H_REG_BITS : OUT STD_LOGIC_VECTOR(0 to 7); -- 03B,03A
		H_REG_P : OUT STD_LOGIC; -- 03B,03A
		H_REG_6 : OUT STD_LOGIC;
		H_REG_5_PWR : OUT STD_LOGIC; -- 02A,08B
		GT_1050_TAGS : OUT STD_LOGIC; -- 10C
		GT_1050_BUS : OUT STD_LOGIC; -- 10C
		CD_REG_2 : OUT STD_LOGIC; -- 05C
		-- E switch
		E_SW : IN E_SW_BUS_Type;
		        
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END ManualDataCFH;

ARCHITECTURE FMD OF ManualDataCFH IS 

signal RST_COUNTER : STD_LOGIC;
signal N10MSPULSE : STD_LOGIC;
signal BIN_DRIVE : STD_LOGIC;
signal CTRL_TRG : STD_LOGIC;
signal CTRL_LCH : STD_LOGIC;
signal CNTR_FULL : STD_LOGIC;
signal C_BINARY_CNTR : STD_LOGIC_VECTOR(4 to 7);
signal EXT_INT : STD_LOGIC;
signal RESET_F_REG : STD_LOGIC;
signal F_REGISTER : STD_LOGIC_VECTOR(0 to 7);
signal F_REGISTER_1A : STD_LOGIC;
signal SET_F_REG_0 : STD_LOGIC;
signal GT_C_TO_A_BUS : STD_LOGIC;
signal GT_F_TO_A : STD_LOGIC;
signal GT_H_TO_A : STD_LOGIC;
signal C_EXT_INT : STD_LOGIC_VECTOR(2 to 7);
signal H_SET : STD_LOGIC;
signal sTIMER_UPDATE : STD_LOGIC;
signal sH_REG_BITS : STD_LOGIC_VECTOR(0 to 7);
signal sH_REG_P : STD_LOGIC;
signal CTL_LCH_Set,CTL_LCH_Reset,CT_FF_Set,BD_FF_Set,EI_LCH_Set,EI_LCH_Reset,F0_LCH_Reset,F1_LCH_Set,F1A_LCH_Reset : STD_LOGIC;
signal F07_LCH_Reset,F07_LCH_Set : STD_LOGIC_VECTOR(0 to 7);

BEGIN
-- Fig 5-04C

-- Rotary switches ABCD and FGHJ
ABCD_SW_BUS <= SW_A & SW_B & SW_C & SW_D;
AB_SW_P <= SW_AP xnor SW_BP; -- AC1D2,AC1E3
CD_SW_P <= SW_CP xnor SW_DP; -- AC1D4,AC1E3,AC1D2

FGHJ_SW_BUS <= SW_F & SW_G & SW_H & SW_J;
FG_SW_P <= SW_FP xnor SW_GP; -- AC1D4,AC1E3,AC1D2
HJ_SW_P <= SW_HP xnor SW_JP; -- AC1D4,AC1E3,AC1D2

IJ_SEL <= '1' when (E_SW.I_SEL='1' or E_SW.J_SEL='1') and USE_MAN_DECODER_PWR='1' else '0'; -- AC1G6,AC1D2
UV_SEL <= '1' when (E_SW.U_SEL='1' or E_SW.V_SEL='1') and USE_MAN_DECODER_PWR='1' else '0'; -- AC1G6,AC1D2

RST_COUNTER <= MACH_RST_PROT; -- BE3G5

CTL_LCH_Set <= (GT_C_TO_A_BUS and T1) or (not sTIMER_UPDATE and SW_INTRP_TIMER);
CTL_LCH_Reset <= CTRL_TRG and T3;
CTL_LCH: entity FLL port map(CTL_LCH_Set,CTL_LCH_Reset,CTRL_LCH); -- BE3G6,BE3F5

N10MSPULSE <= not(N60_CY_TIMER_PULSE and not T3); -- 10ms monostable here

CT_FF_Set <= CTRL_LCH and T4;
CT_FF: entity FLL port map(CT_FF_Set,not CTRL_LCH,CTRL_TRG); -- BE3F6
BD_FF_Set <= not CTRL_LCH and T2 and N10MSPULSE and not CNTR_FULL;
BD_FF: entity FLL port map(BD_FF_Set,not N10MSPULSE,BIN_DRIVE); -- BE3F6

process(BIN_DRIVE,RST_COUNTER,CTRL_TRG) -- BE3G7,BE3F7
	begin
	if RST_COUNTER='1' or CTRL_TRG='1' then
		C_BINARY_CNTR <= "0000";
	else	if BIN_DRIVE'event and BIN_DRIVE='0' then
				C_BINARY_CNTR <= C_BINARY_CNTR + "0001";
			end if;
	end if;
	end process;

CNTR_FULL <= C_BINARY_CNTR(4) and C_BINARY_CNTR(5) and C_BINARY_CNTR(6) and C_BINARY_CNTR(7); -- BE3G6

-- Interrupt generation
sTIMER_UPDATE <= C_BINARY_CNTR(4) and C_BINARY_CNTR(5) and C_BINARY_CNTR(6) and C_BINARY_CNTR(7); -- BE3G6,BE3G5
TIMER_UPDATE <= sTIMER_UPDATE;
-- TIMER_UPDATE_OR_EXT_INT <= sTIMER_UPDATE or EXT_INT; -- AC1D5
TIMER_UPDATE_OR_EXT_INT <= EXT_INT; -- AC1D5 ?? Temporarily prevent Timer
EXT_INT <= (F_REGISTER(0) or F_REGISTER(1) or F_REGISTER(2) or F_REGISTER(3) or
	F_REGISTER(4) or F_REGISTER(5) or F_REGISTER(6) or F_REGISTER(7)) and EXT_TRAP_MASK_ON;  -- AC1G2 ?? Should this include EXT_TRAP_MASK_ON ?
EI_LCH_Reset <= MACH_RST_SW or RESET_F_REG;
EI_LCH_Set <= EXT_INT and T3; -- ?? Seems to be needed, not as per MDM
EI_LCH: entity FLL port map(EI_LCH_Set,EI_LCH_Reset,EXT_INTRP); -- AC1K6,AC1C2

-- F register - here it is held in True polarity, in the 2030 it is inverted
C_EXT_INT <= "000000";
SET_F_REG_0 <= CK_SALS(0) and CK_SALS(1) and CK_SALS(2) and CK_SALS(3) and GT_CK_DECO; -- AB3F7 CK=1111
RESET_F_REG <= CK_SALS(0) and CK_SALS(1) and CK_SALS(2) and not CK_SALS(3) and GT_CK_DECO; -- AB3F7 CK=1110

F1A_LCH_Reset <= (L_REGISTER(1) and RESET_F_REG) or RECYCLE_RST;
F1_LCH_Set <= F_REGISTER_1A and SW_CONS_INTRP;
F1A_LCH: entity FLL port map(not SW_CONS_INTRP, F1A_LCH_Reset, F_REGISTER_1A); -- AC1L2

F07_LCH_Set <= SET_F_REG_0 & F1_LCH_Set & C_EXT_INT(2 to 7);
F07_LCH_Reset <= (0 to 7 => RECYCLE_RST) or ((0 to 7 => RESET_F_REG) and ('1' & L_REGISTER(1 to 7)));
F07_LCH: entity FLVL port map(F07_LCH_Set, F07_LCH_Reset, F_REGISTER(0 to 7)); -- AC1L2

-- H register
H_SET <= MACH_RST_2B or (E_SW.H_SEL and MAN_STOR_PWR) or
 (T4 and not CD_CTRL_REG(0) and CD_CTRL_REG(1) and not CD_CTRL_REG(2) and CD_CTRL_REG(3)); -- AB1J2 CD=0101
GT_1050_TAGS <= not CD_CTRL_REG(0) and CD_CTRL_REG(1) and not CD_CTRL_REG(2) and not CD_CTRL_REG(3); -- AB1B3 CD=0100
GT_1050_BUS <= not CD_CTRL_REG(0) and not CD_CTRL_REG(1) and not CD_CTRL_REG(2) and CD_CTRL_REG(3); -- AB1B3 CD=0001
CD_REG_2 <= CD_CTRL_REG(2); -- AB1B3
H_LCH: entity PHV8 port map(Z_BUS,H_SET,sH_REG_BITS); -- AB1L3
H_REG_BITS <= sH_REG_BITS;
HP_LCH: entity PH port map(Z_BUS_P,H_SET,sH_REG_P); -- AB1L3
H_REG_P <= sH_REG_P;
H_REG_6 <= sH_REG_BITS(6); -- AB1C6,AB1G2
H_REG_5_PWR <= sH_REG_BITS(5); -- AB1L2

-- A bus drive
GT_C_TO_A_BUS <= (E_SW.C_SEL and USE_MAN_DECODER) or
	(not GTD_CA_BITS(0) and GTD_CA_BITS(1) and not GTD_CA_BITS(2) and not GTD_CA_BITS(3) and USE_ALT_CA_DECODER); -- AB3C7 CA=0100
GT_F_TO_A <= (E_SW.F_SEL and USE_MAN_DECO_PWR) or
	(not GTD_CA_BITS(0) and not GTD_CA_BITS(1) and not GTD_CA_BITS(2) and not GTD_CA_BITS(3) and USE_ALT_CA_DECODER); -- AB3C7 CA=0000
GT_H_TO_A <= (E_SW.H_SEL and USE_MAN_DECODER) or
	(not GTD_CA_BITS(0) and GTD_CA_BITS(1) and not GTD_CA_BITS(2) and GTD_CA_BITS(3) and USE_BASIC_CA_DECODER); -- AB3C7 CA=0101

A_BUS <= not ("0000" & C_BINARY_CNTR & '0') when GT_C_TO_A_BUS='1'
	else (F_REGISTER & '0') when GT_F_TO_A='1' -- ?? F_REGISTER should be inverted?
	else not (sH_REG_BITS & sH_REG_P) when GT_H_TO_A='1'
	else "111111111"; -- AB1F6

END FMD;
