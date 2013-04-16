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
--    File: FMD2030_5-01A-B.vhd
--    Creation Date: 
--    Description:
--    WX register & indicators, CCROS parity check (5-01A), WX assembly (5-01B)
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-09
--    Initial Release
--    
--
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY work;
USE work.Gates_package.all;
USE work.Buses_package.all;

-- This package implements the WX register and associated logic
-- Fig 5-01A, 5-01B

entity WX_Regs is
port (
		-- Indicators
		W_IND_P : OUT STD_LOGIC;
		X_IND_P : OUT STD_LOGIC;
		WX_IND :  OUT  STD_LOGIC_VECTOR(0 to 12);

		-- CCROS interface
		WX : OUT STD_LOGIC_VECTOR(0 to 12); -- 01BA5 01BA6 to 01CC1 04BD3
		CROS_STROBE : OUT STD_LOGIC; -- 01BD2 to 01CC1
		CROS_GO_PULSE : OUT STD_LOGIC; -- 01BD2 to 01CC1
		SALS : IN SALS_Bus; -- 01C

		-- Clock inputs
		T2,T3,T4 : IN STD_LOGIC;
		P1 : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		
		-- Switch inputs
		SWS_FGP,SWS_HJP : IN STD_LOGIC; -- 04CA3
		SWS_F3: IN STD_LOGIC; -- 04CA3
		SWS_G,SWS_H,SWS_J : IN STD_LOGIC_VECTOR(0 to 3); -- 04CA3
		
		-- UV bus input
		U_P : IN STD_LOGIC; -- 05CC3
		U3_7: IN STD_LOGIC_VECTOR(3 to 7); -- 05CC3
		V_P : IN STD_LOGIC; -- 05CC4
		V : IN STD_LOGIC_VECTOR(0 to 7); -- 05CC4
		
		-- Priority bus input
		PRIORITY_BUS_P : IN STD_LOGIC; -- 03AE6
		PRIORITY_BUS : IN STD_LOGIC_VECTOR(0 to 7); -- 03AE6
		
		-- X6,7 inputs
		X6,X7 : IN STD_LOGIC; -- 02AE6
		
		-- Status inputs
		ANY_MACH_CHK : IN STD_LOGIC; -- 07AD6
		CHK_OR_DIAG_STOP_SW : IN STD_LOGIC; -- 04AE3
		EARLY_ROAR_STOP : IN STD_LOGIC; -- 03CC6
		MACH_START_RST : IN STD_LOGIC; -- 04AD3
		ALU_CHK : IN STD_LOGIC; -- 06AE6
		ALU_CHK_LCH : IN STD_LOGIC; -- 06BE6
		MACH_RST_SET_LCH : IN STD_LOGIC; -- 04BB2
		MACH_RST_SET_LCH_DLY : IN STD_LOGIC; -- 04BB2
		USE_ALT_CU_DECODER : IN STD_LOGIC; -- 04DC2
		USE_BASIC_CA_DECODER : IN STD_LOGIC; -- 02AE6
		GT_UV_TO_WX_REG : IN STD_LOGIC; -- 02BA2
		GT_CA_TO_W_REG : IN STD_LOGIC; -- 02BA2
		GT_FWX_TO_WX_REG,GT_GWX_TO_WX_REG : IN STD_LOGIC; -- 02AE4
		GT_SWS_TO_WX_PWR : IN STD_LOGIC; -- 04AD6
		GT_SWS_TO_WX_LCH : IN STD_LOGIC; -- 03AB2
		ANY_PRIORITY_PULSE : IN STD_LOGIC; -- 03AD6
		ANY_PRIORITY_PULSE_PWR : IN STD_LOGIC; -- 03AD6
		INH_ROSAR_SET : IN STD_LOGIC; -- 03CD3
		CHK_SW_PROC_SW : IN STD_LOGIC; -- 04AE2
		ROS_SCAN : IN STD_LOGIC; -- 03CE2
		MACH_RST_2A : IN STD_LOGIC; -- 06BC6
		MACH_RST_4,MACH_RST_5 : IN STD_LOGIC; -- 03DD2
		N1401_MODE : IN STD_LOGIC; -- 05AD5
		CARRY_0_LCHD : IN STD_LOGIC; -- 06AE3
		HSMPX_TRAP : IN STD_LOGIC; -- XXXXX
		SX_CHAIN_PULSE : IN STD_LOGIC; -- 03AC6
		SEL_CC_ROS_REQ : IN STD_LOGIC; -- 12CA6
		MPX_SHARE_PULSE : IN STD_LOGIC; -- 03AC6
		ALLOW_PC_SALS : IN STD_LOGIC; -- 07AC4
		TEST_LAMP : IN STD_LOGIC; -- ?????
		
		-- Debug
		DEBUG : OUT STD_LOGIC;
		
		-- Outputs
		SET_IND_ROSAR : OUT STD_LOGIC; --- 01AB2 to 07AB3
		CTRL_REG_CHK : OUT STD_LOGIC; -- 01AD5 to 01BD1,07AC4
		WX_CHK : OUT STD_LOGIC; -- 01AB5 to 07AC3
		SAL_PC : OUT STD_LOGIC; -- 01AC5 to 01BD1,07AC4
		GT_BU_ROSAR_TO_WX_REG : OUT STD_LOGIC; -- 01BA2 to 02AE2
		SET_FW : OUT STD_LOGIC -- 01BE3 to 08CA1
);
end WX_Regs;

architecture FMD of WX_Regs is

signal  SET_IND : STD_LOGIC;
signal  FL_ROSAR_IND : STD_LOGIC;
signal  GT_CK_TO_W_REG :  STD_LOGIC;
signal  sGT_BU_ROSAR_TO_WX_REG :  STD_LOGIC;
signal  NORMAL_ENTRY :  STD_LOGIC;
signal  SET_W2,SET_W2A,SET_W2B,SET_W_REG : STD_LOGIC;
signal  SET_X_REG : STD_LOGIC;
signal  W_P : STD_LOGIC;
signal  X_P : STD_LOGIC;
signal  sSET_IND_ROSAR : STD_LOGIC;
signal  sWX : STD_LOGIC_VECTOR(0 to 12);
signal  sINH_NORM_ENTRY : STD_LOGIC;
signal  sCTRL_REG_CHK : STD_LOGIC;
signal  sSAL_PC : STD_LOGIC;
-- WX display
signal	WX_IND_X : STD_LOGIC_VECTOR(0 to 12);
signal	W_IND_P_X, X_IND_P_X : STD_LOGIC;
-- New WX value
signal  W_ASSM : STD_LOGIC_VECTOR(3 to 8); -- 8 is P
signal  X_ASSM : STD_LOGIC_VECTOR(0 to 8); -- 8 is P
-- Multiplexor backup ROSAR
signal  FWX : STD_LOGIC_VECTOR(0 to 12);
alias   FW : STD_LOGIC_VECTOR(3 to 7) is FWX(0 to 4);
alias   FX : STD_LOGIC_VECTOR(0 to 7) is FWX(5 to 12);
signal  FW_P : STD_LOGIC;
signal  FX_P : STD_LOGIC;
signal  SET_F : STD_LOGIC;
-- Selector backup ROSAR
signal  GWX : STD_LOGIC_VECTOR(0 to 12);
alias   GW : STD_LOGIC_VECTOR(3 to 7) is GWX(0 to 4);
alias   GX : STD_LOGIC_VECTOR(0 to 7) is GWX(5 to 12);
signal  GW_P : STD_LOGIC;
signal  GX_P : STD_LOGIC;
signal  SET_G : STD_LOGIC;

signal	ROSAR_IND_LATCH_Set : STD_LOGIC;
signal	PRIORITY_PARITY : STD_LOGIC;
BEGIN
-- Fig 5-01A
-- ROS Indicator register
ROSAR_IND_LATCH_Set <= (ANY_MACH_CHK and CHK_OR_DIAG_STOP_SW) or EARLY_ROAR_STOP;
ROSAR_IND_LATCH: FLL port map(ROSAR_IND_LATCH_Set,MACH_START_RST,FL_ROSAR_IND); -- AA3G4,AA3H4
-- sSET_IND_ROSAR <= (not ALU_CHK or not CHK_OR_DIAG_STOP_SW) and not FL_ROSAR_IND; -- AA3H4
sSET_IND_ROSAR <= '1'; -- Debug
SET_IND_ROSAR <= sSET_IND_ROSAR;
DEBUG <= FL_ROSAR_IND;
SET_IND <= (T4 and sSET_IND_ROSAR) or MACH_RST_SET_LCH; -- AA3J4

WINDP: PH port map(W_P,SET_IND,W_IND_P_X); -- AA3J2
W_IND_P <= W_IND_P_X or TEST_LAMP;
XINDP: PH port map(X_P,SET_IND,X_IND_P_X); -- AA3J3
X_IND_P <= X_IND_P_X or TEST_LAMP;
WXIND: PHV13 port map(sWX,SET_IND,WX_IND_X); -- AA3J2,AA3J3
WX_IND <= WX_IND_X or (WX_IND'range=>TEST_LAMP);

-- SALS parity checking
WX_CHK <= not(SALS.SALS_PA xor W_IND_P_X xor X_IND_P_X); -- AA2J4 ?? Inverted ??
-- WX_CHK <= not(SALS.SALS_PA xor W_P xor X_P); -- AA2J4 ?? or W_IND_P_X, X_IND_P_X as shown in diagram ??
sSAL_PC <= not EvenParity(USE_BASIC_CA_DECODER & SALS.SALS_AK & SALS.SALS_PK & SALS.SALS_CH & SALS.SALS_CL & 
		SALS.SALS_CM & SALS.SALS_CU & SALS.SALS_CA & SALS.SALS_CB & SALS.SALS_CK & SALS.SALS_PA & SALS.SALS_PS)
		or
		EvenParity(SALS.SALS_PN & SALS.SALS_CN);
SAL_PC <= sSAL_PC;

sCTRL_REG_CHK <= EvenParity(SALS.SALS_CD & SALS.SALS_SA & SALS.SALS_CS & SALS.SALS_CV & SALS.SALS_CC & SALS.SALS_CF & SALS.SALS_CG & SALS.SALS_PC);
CTRL_REG_CHK <= sCTRL_REG_CHK;

-- Fig 5-01B
-- W Reg assembly
PRIORITY_PARITY <= not N1401_MODE and not GT_SWS_TO_WX_LCH;
W_ASSM <= (
mux(GT_GWX_TO_WX_REG, GW & GW_P) or -- AA2G2
-- mux(ANY_PRIORITY_PULSE_PWR, (N1401_MODE & ROS_SCAN & '0' & (not GT_SWS_TO_WX_LCH and not N1401_MODE) & '0' & ROS_SCAN)) or -- AA2J2,AA2E3 ?? Sets W6 on restart ??
mux(ANY_PRIORITY_PULSE_PWR, (N1401_MODE & '0' & '0' & ROS_SCAN & ROS_SCAN & PRIORITY_PARITY)) or -- AA2J2,AA2E3 ?? See above for original version
mux(MACH_RST_2A,"00000" & not GT_SWS_TO_WX_LCH) or -- AA2F2,AA2E7 ?? See above
mux(GT_SWS_TO_WX_PWR, (SWS_F3 & SWS_G & SWS_FGP)) or -- AA2J2,AA2F2,AA2E3,AA2E2
mux(GT_UV_TO_WX_REG, U3_7 & U_P) or -- AA2J2,AA2F2,AA2E3,AA2E2
mux(GT_CK_TO_W_REG, (N1401_MODE & SALS.SALS_CK & SALS.SALS_PK)) or -- AA2J2,AA2F2,AA2E3,AA2E2
mux(GT_CA_TO_W_REG, (SALS.SALS_AA & SALS.SALS_CA & SALS.SALS_PK)) or -- AA2H2,AA2J2,AA2F2
mux(GT_FWX_TO_WX_REG, FW & FW_P)); -- AA2H2,AA2J2,AA2F2

-- X Reg assembly
sINH_NORM_ENTRY <= '1' when SALS.SALS_CK="0101" and SALS.SALS_AK='1' and CARRY_0_LCHD='1' else '0'; -- AB3H7,AA2F5

X_ASSM <= (
mux(GT_FWX_TO_WX_REG, FX & FX_P) or -- AA2G3
mux(ANY_PRIORITY_PULSE_PWR, PRIORITY_BUS & PRIORITY_BUS_P) or -- AA2G3
mux(GT_GWX_TO_WX_REG, GX & GX_P) or -- AA2G3
mux(GT_SWS_TO_WX_PWR, SWS_H & SWS_J & SWS_HJP) or -- AA2F3
mux(GT_UV_TO_WX_REG, V & V_P) or -- AA2F3
mux(NORMAL_ENTRY and not sINH_NORM_ENTRY, (SALS.SALS_CN & X6 & X7 & (SALS.SALS_PN xor X6 xor X7))) or -- AA2F3
mux(not SALS.SALS_CK(0) and SALS.SALS_CK(1) and not SALS.SALS_CK(2) and SALS.SALS_CK(3) and SALS.SALS_AK and CARRY_0_LCHD ,"000000001") or -- AA2H5
mux(ANY_PRIORITY_PULSE_PWR and SEL_CC_ROS_REQ and SX_CHAIN_PULSE, "000000110") or -- AA2H3
mux(HSMPX_TRAP and SX_CHAIN_PULSE, "000001001") -- AA2E7
);

-- WX Reg loading
GT_CK_TO_W_REG <= '1' when USE_ALT_CU_DECODER='1' and SALS.SALS_CU="10" else '0'; -- AB3D6
sGT_BU_ROSAR_TO_WX_REG <= '1' when USE_ALT_CU_DECODER='1' and SALS.SALS_CU="11" else '0'; -- AB3D6
GT_BU_ROSAR_TO_WX_REG <= sGT_BU_ROSAR_TO_WX_REG;
NORMAL_ENTRY <=  not sGT_BU_ROSAR_TO_WX_REG and not GT_UV_TO_WX_REG and not ANY_PRIORITY_PULSE; -- AA2C7

-- W_LATCH:
SET_W2A <= not ANY_PRIORITY_PULSE_PWR or not ALU_CHK_LCH or not CHK_SW_PROC_SW; -- AA2H5 ?? What does this do?
-- SET_W2A <= '1';
SET_W2B <= sGT_BU_ROSAR_TO_WX_REG or not NORMAL_ENTRY; -- AA2F2
SET_W2 <= SET_W2A and SET_W2B; -- AA2H5,AA2F2 Wired-AND
SET_W_REG <= ((GT_CA_TO_W_REG or GT_CK_TO_W_REG or SET_W2) and P1) or MACH_RST_SET_LCH_DLY; -- AA2D2
REG_W: PHV5 port map(W_ASSM(3 to 7),SET_W_REG,sWX(0 to 4)); -- AA2D2
REG_WP: PH port map(W_ASSM(8),SET_W_REG,W_P); -- AA2D2

-- X_LATCH: 
SET_X_REG <= (not INH_ROSAR_SET and P1) or MACH_RST_SET_LCH_DLY; -- AA2D2
REG_X: PHV8 port map(X_ASSM(0 to 7),SET_X_REG,sWX(5 to 12)); -- AA2D3
REG_XP: PH port map(X_ASSM(8),SET_X_REG,X_P); -- AA2D3

WX <= sWX;

-- Backup ROSAR regs
SET_F <= (MPX_SHARE_PULSE and T4) or MACH_RST_4; -- AA3G3
FWX_LCH: PHV13 port map(sWX,SET_F,FWX); -- AA3H2,AA3H3
FWP_LCH: PH port map(W_P,SET_F,FW_P); -- AA3H2
FXP_LCH: PH port map(X_P,SET_F,FX_P); -- AA3H3
SET_G <= (SX_CHAIN_PULSE and T4) or MACH_RST_5; -- AA3K2
GWX_LCH: PHV13 port map(sWX,SET_G,GWX); -- AA2K5,AA2L2
GWP_LCH: PH port map(W_P,SET_G,GW_P); -- AA2K5
GXP_LCH: PH port map(X_P,SET_G,GX_P); -- AA2L2

-- CROS triggering

-- This is what the ALD shows:
-- CROS_GO_PULSE <= not (T2 and CHK_OR_DIAG_STOP_SW and ALLOW_PC_SALS and (sSAL_PC or sCTRL_REG_CHK)); -- AA2E7,AA2E2,AA2C2
-- This is what I think it should be
CROS_GO_PULSE <= T2 and not (CHK_OR_DIAG_STOP_SW and ALLOW_PC_SALS and (sSAL_PC or sCTRL_REG_CHK)); -- AA2E7,AA2E2,AA2C2 ??
CROS_STROBE <= T3; -- AA3L6

end FMD;
