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
--    File: FMD2030_5-05C.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    I,J,U,V,T,G,L & D registers and A,B bus assembly
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

ENTITY RegsABAssm IS
	port
	(
		-- Inputs        
--		A_BUS_IN : INOUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		SALS : IN SALS_BUS;
		MACH_RST_SET_LCH : IN STD_LOGIC; -- 03B
		SEL_SHARE_CYCLE : IN STD_LOGIC; -- ?
		USE_MAN_DECODER : IN STD_LOGIC; -- 03D
		MAN_STOR_PWR : IN STD_LOGIC; -- 03D
		USE_MAN_DECODER_PWR : IN STD_LOGIC; -- 03D
		FG_SWS : IN STD_LOGIC_VECTOR(0 to 7); -- 04C
		FG_SW_P : IN STD_LOGIC;
		HJ_SWS : IN STD_LOGIC_VECTOR(0 to 7); -- 8 is P
		HJ_SW_P : IN STD_LOGIC;
		USE_BASIC_CA_DECODER : IN STD_LOGIC; -- 02A
		USE_ALT_CA_DECODER : IN STD_LOGIC; -- 02B
		MPX_BUS : IN STD_LOGIC_VECTOR(0 to 8); -- 08C 8 is P
		FT0,FT3,FT5,FT6 : IN STD_LOGIC; -- 08D
		FT1 : IN STD_LOGIC; -- 07C
		FT2,FT7 : IN STD_LOGIC; -- 08C
		FT4 : IN STD_LOGIC; -- 03C
		E_SW_SEL_BUS : IN E_SW_BUS_TYPE; -- 04C
		CD_CTRL_REG : IN STD_LOGIC_VECTOR(0 to 3);
		CD_REG_2 : IN STD_LOGIC; -- 04C Unused
		MACH_RST_2A_B : IN STD_LOGIC; -- 06B
		Z_BUS : IN STD_LOGIC_VECTOR(0 to 8); -- 06B 8 is P
		R_REG : IN STD_LOGIC_VECTOR(0 to 8); -- 06C 8 is P
												
		-- Outputs
		USE_CPU_DECODER : OUT STD_LOGIC; -- 05B,04D
		GATED_CA_BITS : OUT STD_LOGIC_VECTOR(0 to 3); -- 07C,10C
		GT_J_TO_A,GT_D_TO_A : OUT STD_LOGIC; -- 03C
		I,J,U,V,T,G,L : OUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		A_BUS : OUT STD_LOGIC_VECTOR(0 to 8); -- 06B 8 is P
		B_BUS_OUT : OUT STD_LOGIC_VECTOR(0 to 8); -- 06B 8 is P
        
		-- Clocks
		T4 : IN STD_LOGIC;
		clk : IN STD_LOGIC
		
	);
END RegsABAssm;

ARCHITECTURE FMD OF RegsABAssm IS 

alias CA : STD_LOGIC_VECTOR(0 to 3) is SALS.SALS_CA;
alias CK : STD_LOGIC_VECTOR(0 to 3) is SALS.SALS_CK;
alias CB : STD_LOGIC_VECTOR(0 to 1) is SALS.SALS_CB;
alias AK_SAL_BIT : STD_LOGIC is SALS.SALS_AK;

signal GT_HJ_SWS_TO_B_BUS : STD_LOGIC;
signal GT_R_TO_B,GT_L_TO_B,GT_D_TO_B,GT_CK_TO_B : STD_LOGIC;
signal GT_FG_TO_A, GT_MPX_TAGS_TO_A, GT_MPX_BUS_TO_A,GT_I_TO_A,GT_U_TO_A, GT_V_TO_A,GT_T_TO_A,GT_G_TO_A,GT_L_TO_A,GT_R_TO_A : STD_LOGIC;
signal LCH_I,LCH_J,LCH_U,LCH_V,LCH_T,LCH_G,LCH_L,LCH_D : STD_LOGIC;
signal sUSE_CPU_DECODER : STD_LOGIC;
signal sGATED_CA_BITS : STD_LOGIC_VECTOR(0 to 3);
signal sGT_J_TO_A, sGT_D_TO_A : STD_LOGIC;
signal sI,sJ,sU,sV,sT,sG,sL,sD : STD_LOGIC_VECTOR(0 to 8);


BEGIN
-- Fig 5-05C
sUSE_CPU_DECODER <= not MACH_RST_SET_LCH and not SEL_SHARE_CYCLE and not USE_MAN_DECODER; -- AB3C5
USE_CPU_DECODER <= sUSE_CPU_DECODER;
sGATED_CA_BITS <= CA and (0 to 3 => sUSE_CPU_DECODER); -- AA2J6,AA2J2
GATED_CA_BITS <= sGATED_CA_BITS;
GT_HJ_SWS_TO_B_BUS <= (not CK(0) and CK(1) and not CK(2) and not CK(3) and AK_SAL_BIT) or (MAN_STOR_PWR and USE_MAN_DECODER_PWR); -- AB3H7

GT_R_TO_B <= not CB(0) and not CB(1) and not GT_HJ_SWS_TO_B_BUS and sUSE_CPU_DECODER;
GT_L_TO_B <= not CB(0) and CB(1) and not GT_HJ_SWS_TO_B_BUS and sUSE_CPU_DECODER;
GT_D_TO_B <= CB(0) and not CB(1) and not GT_HJ_SWS_TO_B_BUS and sUSE_CPU_DECODER;
GT_CK_TO_B <= CB(0) and CB(1) and not GT_HJ_SWS_TO_B_BUS and sUSE_CPU_DECODER;
B_BUS_OUT <= ((0 to 8 => GT_R_TO_B) and R_REG) or -- AB1K5
	((0 to 8 => GT_L_TO_B) and sL) or -- AB1K5
	((0 to 8 => GT_D_TO_B) and sD) or -- AB1K5
	((0 to 8 => GT_CK_TO_B) and CK & CK & '1') or -- AB1L5
	((0 to 8 => GT_HJ_SWS_TO_B_BUS) and HJ_SWS & HJ_SW_P); -- AB1L5

GT_FG_TO_A <= '1' when sGATED_CA_BITS="0001"  and USE_ALT_CA_DECODER='1' else '0'; -- AB1F5
GT_MPX_TAGS_TO_A <= '1' when (sGATED_CA_BITS="0000" and USE_BASIC_CA_DECODER='1' and sUSE_CPU_DECODER='1') or (E_SW_SEL_BUS.FT_SEL='1' and USE_MAN_DECODER_PWR='1') else '0'; -- AA2C6 ?? and sUSE_CPU_DECODER required to prevent FT (CA=0000) from being put on A bus when not wanted
GT_MPX_BUS_TO_A <= '1' when (sGATED_CA_BITS="0110" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.FI_SEL='1') else '0'; -- AB3C3
GT_I_TO_A <= '1' when (sGATED_CA_BITS="1111" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.I_SEL='1') else '0'; -- AB1F4
sGT_J_TO_A <= '1' when (sGATED_CA_BITS="1110" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.J_SEL='1') else '0'; -- AB1F4
GT_J_TO_A <= sGT_J_TO_A;
GT_U_TO_A <= '1' when (sGATED_CA_BITS="1101" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.U_SEL='1') else '0'; -- AB1F4
GT_V_TO_A <= '1' when (sGATED_CA_BITS="1100" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.V_SEL='1') else '0'; -- AB1F4
GT_T_TO_A <= '1' when (sGATED_CA_BITS="1011" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.T_SEL='1') else '0'; -- AB1F4
GT_G_TO_A <= '1' when (sGATED_CA_BITS="1010" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.G_SEL='1') else '0'; -- AB1F4
GT_L_TO_A <= '1' when (sGATED_CA_BITS="1001" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.L_SEL='1') else '0'; -- AB3C3
sGT_D_TO_A <= '1' when (sGATED_CA_BITS="1000" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.D_SEL='1') else '0'; -- AB3C3
GT_D_TO_A <= sGT_D_TO_A;
GT_R_TO_A <= '1' when (sGATED_CA_BITS="0111" and USE_BASIC_CA_DECODER='1') or (USE_MAN_DECODER_PWR='1' and E_SW_SEL_BUS.R_SEL='1') else '0'; -- AB3C3

A_BUS <= not(FG_SWS & FG_SW_P) when GT_FG_TO_A='1' else
             not(FT0 & FT1 & FT2 & FT3 & FT4 & FT5 & FT6 & FT7 & '0') when GT_MPX_TAGS_TO_A='1' else
				 not MPX_BUS when GT_MPX_BUS_TO_A='1' else
				 not sI when GT_I_TO_A='1' else
				 not sJ when sGT_J_TO_A='1' else
				 not sU when GT_U_TO_A='1' else
				 not sV when GT_V_TO_A='1' else
				 not sT when GT_T_TO_A='1' else
				 not sG when GT_G_TO_A='1' else
				 not sL when GT_L_TO_A='1' else
				 not sD when sGT_D_TO_A='1' else
				 not R_REG when GT_R_TO_A='1' else
				 "111111111";

-- A_BUS_OUT <= A_BUS_IN or
-- 	((0 to 8 => GT_FG_TO_A) and FG_SWS & FG_SW_P) or -- AB1D6
-- 	((0 to 8 => GT_MPX_TAGS_TO_A) and FT0 & FT1 & FT2 & FT3 & FT4 & FT5 & FT6 & FT7 & '0') or -- AB1D6
-- 	((0 to 8 => GT_MPX_BUS_TO_A) and MPX_BUS) or -- AB1D6
-- 	((0 to 8 => GT_I_TO_A) and sI) or -- AB1F4
-- 	((0 to 8 => sGT_J_TO_A) and sJ) or -- AB1F4
-- 	((0 to 8 => GT_U_TO_A) and sU) or -- AB1F4
-- 	((0 to 8 => GT_V_TO_A) and sV) or -- AB1C7
-- 	((0 to 8 => GT_T_TO_A) and sT) or -- AB1C7
-- 	((0 to 8 => GT_G_TO_A) and sG) or -- AB1C7
-- 	((0 to 8 => GT_L_TO_A) and sL) or -- AB3C3
-- 	((0 to 8 => sGT_D_TO_A) and sD) or -- AB3C3
-- 	((0 to 8 => GT_R_TO_A) and R_REG); -- AB3C3

LCH_I <= '1' when (CD_CTRL_REG="1111" and T4='1') or (E_SW_SEL_BUS.I_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1G5
LCH_J <= '1' when (CD_CTRL_REG="1110" and T4='1') or (E_SW_SEL_BUS.J_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1G5
LCH_U <= '1' when (CD_CTRL_REG="1101" and T4='1') or (E_SW_SEL_BUS.U_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1G5
LCH_V <= '1' when (CD_CTRL_REG="1100" and T4='1') or (E_SW_SEL_BUS.V_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1H5
LCH_T <= '1' when (CD_CTRL_REG="1011" and T4='1') or (E_SW_SEL_BUS.T_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1H5
LCH_G <= '1' when (CD_CTRL_REG="1010" and T4='1') or (E_SW_SEL_BUS.G_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1H5
LCH_L <= '1' when (CD_CTRL_REG="1001" and T4='1') or (E_SW_SEL_BUS.L_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1J2
LCH_D <= '1' when (CD_CTRL_REG="1000" and T4='1') or (E_SW_SEL_BUS.D_SEL='1' and MAN_STOR_PWR='1') or MACH_RST_2A_B='1' else '0'; -- AB1J2

I_REG: PHV9 port map(Z_BUS,LCH_I,clk,sI); -- AB1G3
I <= sI;
J_REG: PHV9 port map(Z_BUS,LCH_J,clk,sJ); -- AB1G4
J <= sJ;
U_REG: PHV9 port map(Z_BUS,LCH_U,clk,sU); -- AB1H3
U <= sU;
V_REG: PHV9 port map(Z_BUS,LCH_V,clk,sV); -- AB1H4
V <= sV;
T_REG: PHV9 port map(Z_BUS,LCH_T,clk,sT); -- AB1J4
T <= sT;
G_REG: PHV9 port map(Z_BUS,LCH_G,clk,sG); -- AB1K4
G <= sG;
L_REG: PHV9 port map(Z_BUS,LCH_L,clk,sL); -- AB1J2
L <= sL;
D_REG: PHV9 port map(Z_BUS,LCH_D,clk,sD); -- AB1K3

END FMD; 

