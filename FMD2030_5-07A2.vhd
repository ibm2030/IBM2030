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
--    File: FMD2030_5-07A2.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Check Register Indicators
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

ENTITY ChkRegInd IS
	port
	(
		-- Inputs
		LAMP_TEST : IN STD_LOGIC; -- 04A
		GT_CA_TO_W_REG : IN STD_LOGIC; -- 02B
		USE_ALT_CA_DECODER : IN STD_LOGIC; -- 02B
		USE_BASIC_CA_DECO : IN STD_LOGIC; -- 02B
		CA_SALS : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		ROS_SCAN : IN STD_LOGIC; -- 03C
		MACH_CHK_PULSE : IN STD_LOGIC; -- 03A
		GT_D_REG_TO_A_BUS : IN STD_LOGIC; -- 05C
		MACH_RST_SW : IN STD_LOGIC; -- 03D
		ANY_PRIORITY_LCH : IN STD_LOGIC; -- 03A
		SET_IND_ROSAR : IN STD_LOGIC; -- 01A
		MACH_RST_6 : IN STD_LOGIC; -- 03D
		WX_CHK : IN STD_LOGIC; -- 01A
		A_REG_PC,B_REG_PC : IN STD_LOGIC; -- 06A
		N2ND_ERROR_STOP : IN STD_LOGIC; -- 03C
		ALLOW_WRITE : IN STD_LOGIC; -- 03D
		CTRL_REG_CHK : IN STD_LOGIC; -- 01A
		SALS_PC : IN STD_LOGIC; -- 01A
		R_REG_PC : IN STD_LOGIC; -- 05A
		ALU_CHK : IN STD_LOGIC; -- 06A
		CHK_SW_PROC_SW : IN STD_LOGIC; -- 04A
		SUPPR_MACH_CHK_TRAP : IN STD_LOGIC; -- 03A
		CPU_WR_IN_R_REG : IN STD_LOGIC; -- 03D
		GT_Q_REG_TO_A_BUS : IN STD_LOGIC; -- 07C
		STACK_PC : IN STD_LOGIC; -- 08B
		MEM_PROT_REQUEST : IN STD_LOGIC; -- 03A
		SEL_CHNL_CHK : IN STD_LOGIC; -- 11A
		MACH_CHK_RST : IN STD_LOGIC; -- 04A
		AK_SAL_BIT : IN STD_LOGIC; -- 01C
		CK_SALS : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		MN_PC : IN STD_LOGIC;
		N1401_MODE : IN STD_LOGIC;

		-- Outputs
		SUPPR_A_REG_CHK : OUT STD_LOGIC; -- 03A
		ALLOW_PC_SALS : OUT STD_LOGIC; -- 01B
		MN_REG_CHK_SMPLD : OUT STD_LOGIC; -- 06C
		FIRST_MACH_CHK,FIRST_MACH_CHK_REQ : OUT STD_LOGIC; -- 03A,03C
		ANY_MACH_CHK : OUT STD_LOGIC; -- 01A,03C,04A
		IND_MC_A_REG,IND_MC_B_REG,IND_MC_STOR_ADDR,IND_MC_CTRL_REG,IND_MC_ROS_SALS,IND_MC_ROS_ADDR,IND_MC_STOR_DATA,IND_MC_ALU : OUT STD_LOGIC;
		MC : OUT STD_LOGIC_VECTOR(0 to 7);        

		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		P1 : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END ChkRegInd;

ARCHITECTURE FMD OF ChkRegInd IS 

signal W_REG_CHK : STD_LOGIC;
signal RST_MACH_CHK : STD_LOGIC;
signal MC_REG : STD_LOGIC_VECTOR(0 to 8);
signal SETMC : STD_LOGIC_VECTOR(0 to 7);
signal SET1ST : STD_LOGIC;
signal CAX1X1,CA0X11,CAX11X,CA1XXX : STD_LOGIC;
signal N_ALLOW_PC_SALS : STD_LOGIC;
signal ALLOW_A_REG_CHK : STD_LOGIC;
signal sSUPPR_A_REG_CHK : STD_LOGIC;
signal sALLOW_PC_SALS : STD_LOGIC;
signal sMN_REG_CHK_SMPLD : STD_LOGIC;
signal sANY_MACH_CHK : STD_LOGIC;
signal sMC : STD_LOGIC_VECTOR(0 to 7);
signal SUPR_A_REG_CHK_Set,SUPR_A_REG_CHK_Reset,ALLW_A_REG_CHK_Set,ALLW_A_REG_CHK_Reset,NOT_ALLOW_PC_SALS_Set : STD_LOGIC;
signal REG_MC_Set,REG_MC_Reset : STD_LOGIC_VECTOR(0 to 8);

BEGIN
-- Fig 5-07A
SUPR_A_REG_CHK_Set <= MACH_CHK_PULSE and T2;
SUPR_A_REG_CHK_Reset <= (GT_D_REG_TO_A_BUS and T1) or MACH_RST_SW;
SUPR_A_REG_CHK: FLE port map(SUPR_A_REG_CHK_Set,SUPR_A_REG_CHK_Reset,clk,sSUPPR_A_REG_CHK); -- AB3H3,AB3J4,AB3H4
SUPPR_A_REG_CHK <= sSUPPR_A_REG_CHK;

CAX1X1 <= CA_SALS(1) and CA_SALS(3); -- AB3G3
CA0X11 <= not CA_SALS(0) and CA_SALS(2) and CA_SALS(3); -- AB3J5
CAX11X <= CA_SALS(1) and CA_SALS(2); -- AB3F3
CA1XXX <= CA_SALS(0); -- AB3K5

-- MDM has USE_ALT with CAX1X1 which would check the Q reg which has no valid parity.  Using USE_BASIC checks H reg instead
ALLW_A_REG_CHK_Set <= (P1 and USE_BASIC_CA_DECO and not GT_CA_TO_W_REG and CAX1X1) or -- AB3G3 ?? MDM has USE_ALT here ??
	(USE_ALT_CA_DECODER and not GT_CA_TO_W_REG and CA0X11 and P1) or -- AB3J5
	(CAX11X and not GT_CA_TO_W_REG and USE_BASIC_CA_DECO and P1) or -- AB3F3
	(USE_BASIC_CA_DECO and CA1XXX and P1); -- AB3K5
ALLW_A_REG_CHK_Reset <= T1 or ROS_SCAN or sSUPPR_A_REG_CHK or ANY_PRIORITY_LCH;
ALLW_A_REG_CHK: FLL port map(ALLW_A_REG_CHK_Set,ALLW_A_REG_CHK_Reset,ALLOW_A_REG_CHK); -- AB3K5,AB3B6,AB3J4

NOT_ALLOW_PC_SALS_Set <= (SET_IND_ROSAR and T4) or MACH_RST_6;
NOT_ALLOW_PC_SALS: FLL port map(NOT_ALLOW_PC_SALS_Set,not T3,N_ALLOW_PC_SALS); -- AB3F6,AB3D7,AB3E5
sALLOW_PC_SALS <= not N_ALLOW_PC_SALS;
ALLOW_PC_SALS <= sALLOW_PC_SALS;

W_REG_CHK <= WX_CHK and not MACH_CHK_PULSE; -- AB3F6,AB3B6

RST_MACH_CHK <= T1 and AK_SAL_BIT when CK_SALS="1011" else '0'; -- AB3E7,AB3H5
SETMC(0) <= ALLOW_A_REG_CHK and A_REG_PC and T3; -- AB3G4
SETMC(1) <= B_REG_PC and not N2ND_ERROR_STOP and T3; -- AB3G4
sMN_REG_CHK_SMPLD <= MN_PC and ALLOW_WRITE and T3; -- AB3G4
MN_REG_CHK_SMPLD <= sMN_REG_CHK_SMPLD;

SETMC(2) <= sMN_REG_CHK_SMPLD; -- AB3G4
SETMC(3) <= sALLOW_PC_SALS and T2 and CTRL_REG_CHK; -- AB3G5
SETMC(4) <= SALS_PC and sALLOW_PC_SALS and T2; -- AB3G5
SETMC(5) <= T2 and W_REG_CHK; -- AB3G5
SETMC(6) <= (T2 and R_REG_PC and (CPU_WR_IN_R_REG or N1401_MODE)) or
	((not N2ND_ERROR_STOP or (GT_Q_REG_TO_A_BUS and not GT_CA_TO_W_REG)) and T2 and STACK_PC and MEM_PROT_REQUEST); -- AB3G6
SETMC(7) <= ALU_CHK and T4; -- AB3G6

sANY_MACH_CHK <= SETMC(0) or SETMC(1) or SETMC(2) or SETMC(3) or SETMC(4) or SETMC(5) or SETMC(6) or SETMC(7) or SEL_CHNL_CHK; -- AB3G4,AB3G5,AB3J4,AB3D7,AB3F4
ANY_MACH_CHK <= sANY_MACH_CHK;

SET1ST <= CHK_SW_PROC_SW and not SUPPR_MACH_CHK_TRAP and sANY_MACH_CHK; -- AB3G6

REG_MC_Set <= SETMC & SET1ST;
REG_MC_Reset <= (0 to 7 => MACH_CHK_RST or RST_MACH_CHK,8 => (T1 and MACH_CHK_PULSE) or MACH_CHK_RST or RST_MACH_CHK); -- AB3G7,AB3H6-removed??
REG_MC: FLVL port map(REG_MC_Set,REG_MC_Reset,MC_REG); -- AB3G4,AB3G5,AB3G6
sMC <= MC_REG(0 to 7);
MC <= sMC;
FIRST_MACH_CHK <= MC_REG(8);
FIRST_MACH_CHK_REQ <= MC_REG(8); -- AB3F6

IND_MC_A_REG <= sMC(0) or LAMP_TEST;
IND_MC_B_REG <= sMC(1) or LAMP_TEST;
IND_MC_STOR_ADDR <= sMC(2) or LAMP_TEST;
IND_MC_CTRL_REG <= sMC(3) or LAMP_TEST;
IND_MC_ROS_SALS <= sMC(4) or LAMP_TEST;
IND_MC_ROS_ADDR <= sMC(5) or LAMP_TEST;
IND_MC_STOR_DATA <= sMC(6) or LAMP_TEST;
IND_MC_ALU <= sMC(7) or LAMP_TEST;

end FMD;
