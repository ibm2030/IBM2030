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
--    File: FMD2030_5-05B.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    M & N register (MSAR) assembly
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

ENTITY MNAssem IS
	port
	(
		-- Inputs
		MAIN_STORAGE_CP : IN STD_LOGIC; -- 04D
		SX_2_BUMP_SW_GT : IN STD_LOGIC; -- 13C
		USE_CPU_DECODER : IN STD_LOGIC; -- 05C
		E_SEL_SW_BUS : IN E_SW_BUS_Type; -- 04C
		SALS : IN SALS_Bus; -- 01C
		MEM_SEL : IN STD_LOGIC; -- 03D
		USE_MAN_DECODER_PWR : IN STD_LOGIC; -- 03D
		N1401_MODE : IN STD_LOGIC; -- 05A
		USE_MANUAL_DECODER : IN STD_LOGIC; -- 03D
		SX_2_R_W_CTRL : IN STD_LOGIC; -- 14D
		SX_2_SHARE_CYCLE : IN STD_LOGIC; -- 14D
		SX_2_GATE : IN STD_LOGIC; -- 13C
		SX_1_R_W_CTRL : IN STD_LOGIC; -- 12D
		SX_1_SHARE_CYCLE : IN STD_LOGIC; -- 12D
		SX_1_GATE : IN STD_LOGIC; -- 13C
		XXH : IN STD_LOGIC; -- 08C
		CU_DECODE_UCW : IN STD_LOGIC; -- 04D
		FORCE_M_REG_123 : IN STD_LOGIC; -- 04D
		XH,XL : IN STD_LOGIC; -- 08C
		CU_SAL_0_BIT : IN STD_LOGIC; -- 01C
		MACH_RST_2A : IN STD_LOGIC; -- 06B
		ABCD_SW_BUS : IN STD_LOGIC_VECTOR(0 to 15); -- 04B
		AB_SW_P,CD_SW_P : IN STD_LOGIC; -- 04B
		I,U,T,V,J,L,GU,GV,HU,HV : IN STD_LOGIC_VECTOR(0 to 7);
		I_P,U_P,T_P,V_P,J_P,L_P,GU_P,GV_P,HU_P,HV_P : IN STD_LOGIC;
      IJ_SEL, UV_SEL : IN STD_LOGIC; -- 04C
		
		-- Outputs
     	GT_T_TO_MN_REG : OUT STD_LOGIC; -- 08B
		GT_CK_TO_MN_REG : OUT STD_LOGIC; -- 08B
		GT_V_TO_N_REG : OUT STD_LOGIC; -- 03B
		GT_J_TO_N_REG : OUT STD_LOGIC; -- 03B
		M_BUS,N_BUS : OUT STD_LOGIC_VECTOR(0 to 7);
		M_BUS_P,N_BUS_P : OUT STD_LOGIC

	);
END MNAssem;

ARCHITECTURE FMD OF MNAssem IS 

signal GT_ABCD_SWS_TO_MN : STD_LOGIC;
signal GT_I_TO_M_REG,GT_U_TO_M_REG : STD_LOGIC;
signal CK_BUS : STD_LOGIC_VECTOR(0 to 7);
signal CK_BUS_P : STD_LOGIC;
signal GATE_L_REG_TO_M_BUS : STD_LOGIC;
signal GT_GUV_OR_HUV_TO_MN : STD_LOGIC;
signal GT_HUV_TO_MN,GT_GUV_TO_MN : STD_LOGIC;
signal M_BUSP,N_BUSP : STD_LOGIC_VECTOR(0 to 8); -- 8 is P
signal sGT_T_TO_MN_REG : STD_LOGIC;
signal sGT_CK_TO_MN_REG : STD_LOGIC;
signal sGT_V_TO_N_REG : STD_LOGIC;
signal sGT_J_TO_N_REG : STD_LOGIC;

BEGIN
-- Fig 5-05B
GT_ABCD_SWS_TO_MN <= MEM_SEL and USE_MAN_DECODER_PWR; -- AC1F3
GT_I_TO_M_REG <= IJ_SEL or (MAIN_STORAGE_CP and USE_CPU_DECODER and not SALS.SALS_CM(0) and SALS.SALS_CM(1) and SALS.SALS_CM(2)); -- AA1H2,AA1H7,AA1J7 CM=011
GT_U_TO_M_REG <= (MAIN_STORAGE_CP and USE_CPU_DECODER and SALS.SALS_CM(0) and not SALS.SALS_CM(1) and not SALS.SALS_CM(2)) or UV_SEL; -- AA1H7,AA1H2,AA1J7 CM=100
sGT_T_TO_MN_REG <= USE_CPU_DECODER and SALS.SALS_CM(0) and not SALS.SALS_CM(1) and SALS.SALS_CM(2); -- AB3E2,AB3F7-removed?? CM=101
GT_T_TO_MN_REG <= sGT_T_TO_MN_REG;
sGT_CK_TO_MN_REG <= USE_CPU_DECODER and SALS.SALS_CM(0) and SALS.SALS_CM(1) and not SALS.SALS_CM(2); -- AB3E2,AB3F7-removed?? CM=110
GT_CK_TO_MN_REG <= sGT_CK_TO_MN_REG;
CK_BUS(0) <= '1';
CK_BUS(1) <= '0';
CK_BUS(2) <= SALS.SALS_CN(0) or SX_2_BUMP_SW_GT; -- AB1C6
CK_BUS(3) <= SALS.SALS_CK(0);
CK_BUS(4) <= '1';
CK_BUS(5) <= SALS.SALS_CK(1);
CK_BUS(6) <= SALS.SALS_CK(2);
CK_BUS(7) <= SALS.SALS_CK(3);
CK_BUS_P <= (not SALS.SALS_PK or SALS.SALS_CM(0) or not CK_BUS(2)) and (not SALS.SALS_PK or SX_2_BUMP_SW_GT); -- AB1C6
sGT_V_TO_N_REG <= UV_SEL or (SALS.SALS_CM(0) and not SALS.SALS_CM(1) and not SALS.SALS_CM(2) and USE_CPU_DECODER); -- AB3C2 CM=100
GT_V_TO_N_REG <= sGT_V_TO_N_REG;
sGT_J_TO_N_REG <= (not SALS.SALS_CM(0) and SALS.SALS_CM(1) and SALS.SALS_CM(2) and USE_CPU_DECODER) or IJ_SEL; -- AB3C2 CM=011
GT_J_TO_N_REG <= sGT_J_TO_N_REG;
GT_GUV_OR_HUV_TO_MN <= USE_CPU_DECODER and SALS.SALS_CM(0) and SALS.SALS_CM(1) and SALS.SALS_CM(2); -- AB3C2 CM=111

GT_HUV_TO_MN <= (USE_MANUAL_DECODER and E_SEL_SW_BUS.E_SEL_SW_HUV_HCD) or (not SX_2_R_W_CTRL and SX_2_SHARE_CYCLE) or (SX_2_GATE and GT_GUV_OR_HUV_TO_MN); -- AE1D5
GT_GUV_TO_MN <= (USE_MANUAL_DECODER and E_SEL_SW_BUS.E_SEL_SW_GUV_GCD) or (not SX_1_R_W_CTRL and SX_1_SHARE_CYCLE) or (GT_GUV_OR_HUV_TO_MN and SX_1_GATE); -- AD1H6

GATE_L_REG_TO_M_BUS <= N1401_MODE and MAIN_STORAGE_CP and sGT_T_TO_MN_REG; -- AB2B3

M_BUSP <= ((0 to 8 => GT_HUV_TO_MN) and HU & HU_P) or -- AB1D2
	((0 to 8 => GT_ABCD_SWS_TO_MN) and ABCD_SW_BUS(0 to 7) & AB_SW_P) or -- AB1D2
	((0 to 8 => GATE_L_REG_TO_M_BUS) and L & L_P) or -- AB1D2
	((0 to 8 => GT_GUV_TO_MN) and GU & GU_P) or -- AB1C2
	((0 to 8 => GT_I_TO_M_REG) and I & I_P) or -- AB1C2
	((0 to 8 => GT_U_TO_M_REG) and U & U_P) or -- AB1C2
	(0 => '0', 1 => (XXH and CU_DECODE_UCW) or (CU_DECODE_UCW and N1401_MODE) or FORCE_M_REG_123, 2 to 8 => '0') or -- AA1B4
	(0 to 1 => '0', 2 => (CU_DECODE_UCW and XH and not N1401_MODE) or FORCE_M_REG_123, 3 to 8 => '0') or -- AB1B3,AA1J4
	(0 to 2 => '0', 3 => (CU_DECODE_UCW and XL) or (FORCE_M_REG_123 and not N1401_MODE) or (N1401_MODE and CU_SAL_0_BIT and USE_CPU_DECODER), 4 to 8 => '0') or -- AA1B4
	(0 to 7 => '0', 8 => (not N1401_MODE and sGT_T_TO_MN_REG) or MACH_RST_2A or sGT_CK_TO_MN_REG); -- AB1G2
M_BUS <= M_BUSP(0 to 7);
M_BUS_P <= M_BUSP(8);

N_BUSP <= ((0 to 8 => GT_ABCD_SWS_TO_MN) and ABCD_SW_BUS(8 to 15) & CD_SW_P) or -- AB1D4
	((0 to 8 => sGT_CK_TO_MN_REG) and CK_BUS & CK_BUS_P) or -- AB1D4
	(0 to 7 => '0', 8 => MACH_RST_2A) or -- AB1D4
	((0 to 8 => sGT_T_TO_MN_REG) and T & T_P) or -- AB1C4
	((0 to 8 => sGT_V_TO_N_REG) and V & V_P) or -- AB1C4
	((0 to 8 => sGT_J_TO_N_REG) and J & J_P) or -- AB1C4
	((0 to 8 => GT_HUV_TO_MN) and HV & HV_P) or -- AB1E4
	((0 to 8 => GT_GUV_TO_MN) and GV & GV_P); -- AB1E4
N_BUS <= N_BUSP(0 to 7);
N_BUS_P <= N_BUSP(8);

END FMD; 

