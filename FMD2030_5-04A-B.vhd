---------------------------------------------------------------------------
--    Copyright � 2010 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: FMD2030_5-04A-B.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Recycle Controls (04A) & Address Matching (04B)
--    Recycle Controls handles restarts and resets
--    Address Matching handles ROAR and SAR address matching (Address Compare switch)
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

ENTITY RecycleCtrlsMatch IS
	port
	(
		-- Inputs
		N_CTRL_N : IN STD_LOGIC; -- 06B
		XOR_OR_OR : IN STD_LOGIC; -- 02A
		S_REG_7_BIT : IN STD_LOGIC; -- 07B
		CLOCK_ON,CLOCK_OFF : IN STD_LOGIC; -- 08A
		MAN_STOR_OR_DSPLY : IN STD_LOGIC; -- 03D
		HARD_STOP_LCH : IN STD_LOGIC; -- 03C
		MPX_METERING_IN : IN STD_LOGIC; -- 08D
		METER_IN_SX1 : IN STD_LOGIC; -- 11D
		METER_IN_SX2 : IN STD_LOGIC; -- 13D
		SEL_SHARE_HOLD : IN STD_LOGIC; -- 12D
		KEY_SW : IN STD_LOGIC; -- 14A
		MACH_RST_SW : IN STD_LOGIC; -- 03D
		LOAD_KEY_SW : IN STD_LOGIC; -- 03C
		SYSTEM_RESET_SW : IN STD_LOGIC; -- 03D
		CL_SALS : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		INH_ROSAR_SET : IN STD_LOGIC; -- 03C
		ALLOW_WRITE : IN STD_LOGIC; -- 03D
		ALLOW_WRITE_DLYD : IN STD_LOGIC; -- 03D
		SET_IC_LCH : IN STD_LOGIC; -- 03C
		MACH_RST_3 : IN STD_LOGIC; -- 03D
		FORCE_IJ_PULSE : IN STD_LOGIC; -- 03A
		FORCE_IJ_REQ_LCH : IN STD_LOGIC; -- 03A
		START_SW_RST : IN STD_LOGIC; -- 03C
		MACH_RST_6 : IN STD_LOGIC; -- 03D
		ANY_MACH_CHK : IN STD_LOGIC; -- 07A
		ANY_PRIORITY_LCH : IN STD_LOGIC; -- 03A
		SUPPR_MACH_CHK_TRAP : IN STD_LOGIC; -- 03A
		ALLOW_MAN_OPERATION : IN STD_LOGIC; -- 03D
		LOAD_IND : IN STD_LOGIC; -- 03C
		N1050_INTRV_REQ : IN STD_LOGIC; -- 10C
		TT6_POS_ATTN : IN STD_LOGIC; -- 10B
		FT2_MPX_OPNL : IN STD_LOGIC; -- 08C
		H_REG_5_PWR : IN STD_LOGIC; -- 04C
		ROS_CTRL_PROC_SW : IN STD_LOGIC; -- 03C
		RATE_SW_PROC_SW : IN STD_LOGIC; -- 03C
		ODD : IN STD_LOGIC; -- 06B
		INTRODUCE_ALU_CHK : IN STD_LOGIC; -- 06B
		GT_SW_TO_WX_LCH : IN STD_LOGIC; -- 03A
		HZ_DEST_RST : IN STD_LOGIC; -- 03A
		MAIN_STORAGE : IN STD_LOGIC; -- 03D
		WX_REG_BUS : IN STD_LOGIC_VECTOR(0 to 12); -- 01B
		ABCD_SW_BUS : IN STD_LOGIC_VECTOR(0 to 15); --04C
		MN_REGS_BUS : IN STD_LOGIC_VECTOR(0 to 15); -- 07A
		AUX_WRITE_CALL : IN STD_LOGIC; -- 03D
		DIAG_LATCH_RST : IN STD_LOGIC; -- NEW

		-- Switches
		SW_LAMP_TEST : IN STD_LOGIC;
		SW_CHK_RST : IN STD_LOGIC;
		SW_ROAR_RST : IN STD_LOGIC;
		SW_CHK_RESTART,SW_DIAGNOSTIC,SW_CHK_STOP,SW_CHK_SW_PROCESS,SW_CHK_SW_DISABLE : IN STD_LOGIC;
		SW_ROAR_RESTT_STOR_BYPASS,SW_ROAR_RESTT,SW_ROAR_RESTT_WITHOUT_RST,SW_EARLY_ROAR_STOP,
		SW_ROAR_STOP,SW_ROAR_SYNC,SW_ADDR_COMP_PROC,SW_SAR_DLYD_STOP,SW_SAR_STOP,SW_SAR_RESTART : IN STD_LOGIC;

		-- Outputs
		LAMP_TEST : OUT STD_LOGIC; -- Various
		CLOCK_OUT : OUT STD_LOGIC; -- 11D,13D,08D
		TO_KEY_SW : OUT STD_LOGIC; -- 14A
		METERING_OUT : OUT STD_LOGIC; -- 08D,13D,11D
		MACH_RST_SET_LCH : OUT STD_LOGIC; -- 06B,01A
		MACH_RST_SET_LCH_DLYD : OUT STD_LOGIC; -- 01B,06C,07B
		FORCE_DEAD_CY_LCH : OUT STD_LOGIC; -- 03A
		END_OF_E_CY_LCH : OUT STD_LOGIC; -- 03C
		FORCE_IJ_REQ : OUT STD_LOGIC; -- 03A,03C
		MACH_START_RST : OUT STD_LOGIC; -- 03C
		DIAGNOSTIC_SW : OUT STD_LOGIC; -- 03A,03C,06B,08D
		CHK_OR_DIAG_STOP_SW : OUT STD_LOGIC; -- 01A,01B,03C,13A,11A,11D,13D
--		CHK_SW_PROCESS_SW : OUT STD_LOGIC; -- 08D,07A,01B,11A
--		CHK_SW_DISABLE_SW : OUT STD_LOGIC; -- 07C
		RECYCLE_RST : OUT STD_LOGIC; -- 03A,06B,03D,06B,04C,08D
		MACH_CHK_RST : OUT STD_LOGIC; -- 03C,07A
		CHK_RST_SW : OUT STD_LOGIC; -- 11A,13A
		MACH_RST_LCH : OUT STD_LOGIC; -- 03A
		GT_SWS_TO_WX_PWR : OUT STD_LOGIC; -- 01B,03A,06B
		MATCH_LCH : OUT STD_LOGIC; -- 03C
		MATCH : OUT STD_LOGIC; -- 03C

		-- Indicators
		IND_SYST,IND_MAN,IND_WAIT,IND_TEST,IND_LOAD,IND_EX,IND_CY_MATCH : OUT STD_LOGIC;
		IND_ALLOW_WR,IND_1050_INTRV,IND_1050_REQ,IND_MPX,IND_SEL_CHNL : OUT STD_LOGIC;
		        
		-- Clocks
		T1,T2,T3,T4 : IN STD_LOGIC;
		Clk : IN STD_LOGIC
	);
END RecycleCtrlsMatch;

ARCHITECTURE FMD OF RecycleCtrlsMatch IS 

signal NWAIT : STD_LOGIC;
signal CHNL_TO_METER : STD_LOGIC;
signal SYSTEM_OPERATING : STD_LOGIC;
signal FORCE_DEAD_CY : STD_LOGIC;
signal TEST : STD_LOGIC;
signal END_OF_E_CYCLE : STD_LOGIC;
signal CHK_RESTT_LCH : STD_LOGIC;
signal CHK_RESTART_SW,CHK_STOP_SW : STD_LOGIC;
signal ROAR_RESTT_SW_ORED : STD_LOGIC;
signal RST_MATCH : STD_LOGIC;
signal MATCH_SET_MACH_RST_LCH : STD_LOGIC;
signal GT_MATCH_MN_CKT_1,GT_MATCH_WX_CKT_2 : STD_LOGIC;
signal OEA1,OEA2,OEA3,ANDWX,ANDMN : STD_LOGIC;
signal sTO_KEY_SW : STD_LOGIC;
signal sLAMP_TEST : STD_LOGIC;
signal sCLOCK_OUT : STD_LOGIC;
signal sFORCE_DEAD_CY_LCH : STD_LOGIC;
signal sEND_OF_E_CY_LCH : STD_LOGIC;
signal sFORCE_IJ_REQ : STD_LOGIC;
signal sMACH_RST_SET_LCH : STD_LOGIC;
signal sDIAGNOSTIC_SW : STD_LOGIC;
signal sRECYCLE_RST : STD_LOGIC;
signal sMACH_CHK_RST : STD_LOGIC;
signal sMATCH_LCH : STD_LOGIC;
signal sCHK_SW_PROCESS_SW : STD_LOGIC;
signal sMATCH : STD_LOGIC;
signal sMACH_RST_LCH : STD_LOGIC;
signal sGT_SWS_TO_WX_REG : STD_LOGIC;
signal NW_LCH_Set,NW_LCH_Reset,MRS_LCH_Reset,EEC_LCH_Set,FIJ_LCH_Set,FIJ_LCH_Reset,
		CR_LCH_Set,CR_LCH_Reset,MR_LCH_Set,MR_LCH_Reset,GSWX_LCH_Set,GSWX_LCH_Reset,
		M_LCH_Set,M_LCH_Reset : STD_LOGIC;
signal DIAG_LATCH : STD_LOGIC;

BEGIN
-- Fig 5-04A
NW_LCH_Set <= N_CTRL_N and XOR_OR_OR and T2;
NW_LCH_Reset <= not S_REG_7_BIT or sRECYCLE_RST;
NW_LCH: entity work.FLL port map(NW_LCH_Set,NW_LCH_Reset,NWAIT); --AC1E6,AC1F6
sCLOCK_OUT <= (not NWAIT and CLOCK_ON) or MAN_STOR_OR_DSPLY; -- AC1G6
CLOCK_OUT <= sCLOCK_OUT;
CHNL_TO_METER <= not HARD_STOP_LCH and (MPX_METERING_IN or METER_IN_SX1 or METER_IN_SX2); -- AC1K4,AC1F2 ??
SYSTEM_OPERATING <= sCLOCK_OUT or CHNL_TO_METER; -- AB2D2
sTO_KEY_SW <= sCLOCK_OUT or CHNL_TO_METER or SEL_SHARE_HOLD; -- AB2D2
TO_KEY_SW <= sTO_KEY_SW;
METERING_OUT <= sTO_KEY_SW and KEY_SW; -- AB2F4

sLAMP_TEST <= SW_LAMP_TEST;
LAMP_TEST <= sLAMP_TEST;
IND_SYST <= SYSTEM_OPERATING or sLAMP_TEST;
IND_MAN <= ALLOW_MAN_OPERATION or sLAMP_TEST;
IND_WAIT <= NWAIT or sLAMP_TEST;
IND_TEST <= TEST or sLAMP_TEST;
IND_LOAD <= LOAD_IND or sLAMP_TEST;
IND_EX <= END_OF_E_CYCLE or sLAMP_TEST;
IND_CY_MATCH <= sMATCH_LCH or sLAMP_TEST;
IND_ALLOW_WR <= ALLOW_WRITE or sLAMP_TEST;
IND_1050_INTRV <= N1050_INTRV_REQ or sLAMP_TEST;
IND_1050_REQ <= TT6_POS_ATTN or sLAMP_TEST;
IND_MPX <= FT2_MPX_OPNL or sLAMP_TEST;
IND_SEL_CHNL <= H_REG_5_PWR or sLAMP_TEST;

TEST <= (not ROS_CTRL_PROC_SW) or (not RATE_SW_PROC_SW) or (not SW_ADDR_COMP_PROC) or (not ODD) or (not sCHK_SW_PROCESS_SW) or INTRODUCE_ALU_CHK; -- AC1C4,AC1K5,AC1D4,AC1K5 ??

MRS_LCH_Reset <= not LOAD_KEY_SW and not SYSTEM_RESET_SW;
MRS_LCH: entity work.FLL port map(MACH_RST_SW,MRS_LCH_Reset,sMACH_RST_SET_LCH); -- AA2H5,AA2F5
MACH_RST_SET_LCH <= sMACH_RST_SET_LCH;
MACH_RST_SET_LCH_DLYD <= sMACH_RST_SET_LCH; -- ?? Should be delayed by 1 gate
-- MACH_RST_DELAY: AR port map(D=>sMACH_RST_SET_LCH,CLK=>Clk,Q=>MACH_RST_SET_LCH_DLYD); -- Delay
FORCE_DEAD_CY <= SW_SAR_RESTART and T4 and MATCH_SET_MACH_RST_LCH; -- AB3B6
FDC_LCH: entity work.FLL port map(FORCE_DEAD_CY,T3,sFORCE_DEAD_CY_LCH); -- AB3L3
FORCE_DEAD_CY_LCH <= sFORCE_DEAD_CY_LCH;

EEC_LCH_Set <= T2 and (CL_SALS(0) and CL_SALS(1) and CL_SALS(2) and CL_SALS(3)); -- ?? additional NOT
EEC_LCH: entity work.FLL port map(EEC_LCH_Set,T1,sEND_OF_E_CY_LCH); -- AC1G4 ?? Reset input is unlabeled
END_OF_E_CY_LCH <= sEND_OF_E_CY_LCH;
END_OF_E_CYCLE <= sEND_OF_E_CY_LCH or INH_ROSAR_SET; -- AC1J7

MATCH_SET_MACH_RST_LCH <= ((SW_SAR_RESTART and sMATCH_LCH and not ALLOW_WRITE_DLYD) or 
	(not ALLOW_WRITE_DLYD and CHK_RESTT_LCH and not ROAR_RESTT_SW_ORED and not SW_ROAR_RESTT_STOR_BYPASS)); -- AC1D2,AC1E6,AC1D4 ?? AC1D4 removed ??

FIJ_LCH_Set <= (MATCH_SET_MACH_RST_LCH and CLOCK_ON) or SET_IC_LCH; -- ?? *not* MATCH_SET_MACH_RST_LCH & *not* CLOCK_ON ??
FIJ_LCH_Reset <= MACH_RST_3 or (T1 and FORCE_IJ_PULSE);
FIJ_LCH: entity work.FLL port map(FIJ_LCH_Set,FIJ_LCH_Reset,sFORCE_IJ_REQ); -- AC1E6,AC1H6
FORCE_IJ_REQ <= sFORCE_IJ_REQ;
MACH_START_RST <= (sFORCE_IJ_REQ and not FORCE_IJ_REQ_LCH) or START_SW_RST or MACH_RST_6; -- AB3J5,AB3H3

CR_LCH_Set <= ANY_MACH_CHK and CHK_RESTART_SW;
CR_LCH_Reset <= ANY_PRIORITY_LCH or sMACH_CHK_RST;
CR_LCH: entity work.FLL port map(CR_LCH_Set,CR_LCH_Reset,CHK_RESTT_LCH); -- AB3H4,AC1H6

CHK_RESTART_SW <= SW_CHK_RESTART;
-- Diagnostic latch is not in the FMD but must have appeared later
-- It is set on Sys Reset and reset by the YL / 0->DIAG function (Alt-CK=0000)
DIAG_FL: entity work.FLL port map(S=>MACH_RST_6,R=>DIAG_LATCH_RST,Q=>DIAG_LATCH);

sDIAGNOSTIC_SW <= SW_DIAGNOSTIC or DIAG_LATCH;
DIAGNOSTIC_SW <= sDIAGNOSTIC_SW;

CHK_STOP_SW <= SW_CHK_STOP;
sCHK_SW_PROCESS_SW <= SW_CHK_SW_PROCESS;
-- CHK_SW_PROCESS_SW <= sCHK_SW_PROCESS_SW;
-- CHK_SW_DISABLE_SW <= SW_CHK_SW_DISABLE;

CHK_OR_DIAG_STOP_SW <= (sDIAGNOSTIC_SW and SUPPR_MACH_CHK_TRAP) or CHK_STOP_SW; -- AC1H3,AC1F5 ?? *not* SUPPR_MACH_CHK_TRAP ??

sRECYCLE_RST <= sMACH_RST_SET_LCH or
	(SW_ROAR_RESTT_STOR_BYPASS and GT_SW_TO_WX_LCH) or
	(ANY_PRIORITY_LCH and sFORCE_DEAD_CY_LCH and SW_SAR_RESTART) or
	(SW_ROAR_RESTT_WITHOUT_RST and GT_SW_TO_WX_LCH and CHK_RESTART_SW) or
	(GT_SW_TO_WX_LCH and SW_ROAR_RESTT); -- AB3K5,AB3L5,AB3L4
RECYCLE_RST <= sRECYCLE_RST;

sMACH_CHK_RST <= sRECYCLE_RST or SW_CHK_RST;  -- AB3L3,AB3H5
MACH_CHK_RST <= sMACH_CHK_RST;

CHK_RST_SW <= SW_CHK_RST; -- AB3F5

MR_LCH_Set <= FORCE_DEAD_CY or MACH_RST_6;
MR_LCH_Reset <= HZ_DEST_RST or SW_ROAR_RST; -- ?? *not* SW_ROAR_RST
MR_LCH: entity work.FLL port map(MR_LCH_Set,MR_LCH_Reset,sMACH_RST_LCH); -- AB3F2,AB3J4
MACH_RST_LCH <= sMACH_RST_LCH;

GSWX_LCH_Set <= (SW_ROAR_RST and ALLOW_MAN_OPERATION) or
	(SW_ROAR_RESTT_STOR_BYPASS and sMATCH) or
	(T3 and ROAR_RESTT_SW_ORED and CHK_RESTT_LCH and not ALLOW_WRITE_DLYD) or
	(not ALLOW_WRITE_DLYD and ROAR_RESTT_SW_ORED and sMATCH) or
	(SW_ROAR_RESTT_STOR_BYPASS and CHK_RESTT_LCH);
GSWX_LCH_Reset <= MACH_RST_SW or (T3 and GT_SW_TO_WX_LCH);
GSWX_LCH: entity work.FLL port map(GSWX_LCH_Set,GSWX_LCH_Reset,sGT_SWS_TO_WX_REG); -- AC1H5,AC1H7,AC1H4,AC1K5,AC1J7

GT_SWS_TO_WX_PWR <= not sMACH_RST_LCH and sGT_SWS_TO_WX_REG; -- AC1E7

-- Fig 5-04B
ROAR_RESTT_SW_ORED <= SW_ROAR_RESTT or SW_ROAR_RESTT_WITHOUT_RST; -- AC1M5
GT_MATCH_WX_CKT_2 <= SW_ROAR_RESTT or SW_ROAR_RESTT_WITHOUT_RST or SW_EARLY_ROAR_STOP or
	SW_ROAR_RESTT_STOR_BYPASS or SW_ROAR_STOP or SW_ROAR_SYNC; -- AC1M6
GT_MATCH_MN_CKT_1 <= SW_ADDR_COMP_PROC or
	(MAIN_STORAGE and SW_SAR_DLYD_STOP) or
	(MAIN_STORAGE and SW_SAR_STOP) or
	(MAIN_STORAGE and SW_SAR_RESTART); -- AC1M6

RST_MATCH <= (SW_ADDR_COMP_PROC and T1) or
	(SW_ROAR_SYNC and T1) or
	(not ALLOW_WRITE_DLYD and START_SW_RST) or
	(FORCE_IJ_REQ_LCH and T1) or
	(sGT_SWS_TO_WX_REG and T1); -- AC1H3,AC1K4

OEA1 <= '1' when (not ABCD_SW_BUS(4 to 7) xor ((MN_REGS_BUS(4 to 7) and (4 to 7 => GT_MATCH_MN_CKT_1)) or (WX_REG_BUS(1 to 4) and (1 to 4 => GT_MATCH_WX_CKT_2))))="1111" else '0'; -- AA2C4
OEA2 <= '1' when (not ABCD_SW_BUS(8 to 11) xor ((MN_REGS_BUS(8 to 11) and (8 to 11 => GT_MATCH_MN_CKT_1)) or (WX_REG_BUS(5 to 8) and (5 to 8 => GT_MATCH_WX_CKT_2))))="1111" else '0'; -- AA2C5
OEA3 <= '1' when (not ABCD_SW_BUS(12 to 15) xor ((MN_REGS_BUS(12 to 15) and (12 to 15 => GT_MATCH_MN_CKT_1)) or (WX_REG_BUS(9 to 12) and (9 to 12 => GT_MATCH_WX_CKT_2))))="1111" else '0'; -- AA2D5

ANDMN <= AUX_WRITE_CALL and
	(ABCD_SW_BUS(0) xnor MN_REGS_BUS(0)) and
	(ABCD_SW_BUS(1) xnor MN_REGS_BUS(1)) and
	(ABCD_SW_BUS(2) xnor MN_REGS_BUS(2)) and
	(ABCD_SW_BUS(3) xnor MN_REGS_BUS(3)) and
	GT_MATCH_MN_CKT_1 and OEA2 and OEA1 and OEA3; -- AC1K7,AC1L7

ANDWX <= (WX_REG_BUS(0) xor not ABCD_SW_BUS(3)) and OEA1 and OEA2 and OEA3 and GT_MATCH_WX_CKT_2 and T3; -- AC1L7

M_LCH_Set <= ANDMN or ANDWX;
M_LCH_Reset <= RST_MATCH or MACH_RST_SW;
M_LCH: entity work.FLL port map(M_LCH_Set,M_LCH_Reset,sMATCH_LCH); -- AC1L7,AC1L4
MATCH_LCH <= sMATCH_LCH;
sMATCH <= sMATCH_LCH and not CLOCK_OFF; -- AC1H5
MATCH <= sMATCH;

END FMD; 
