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
--    File: FMD2030_5-03C.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Clock Start & Stop control
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
--    Revision 1.1 2012-04-07
--		Change PROC_STOP_LOOP condition to make STOP/START buttons happier
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY ClockStartStop IS
	port
	(
		-- Switches
		SW_START,SW_LOAD,SW_SET_IC,SW_STOP : IN std_logic;
		SW_INH_CF_STOP,SW_PROC,SW_SCAN : IN std_logic;
		SW_SINGLE_CYCLE,SW_INSTRUCTION_STEP,SW_RATE_SW_PROCESS : IN std_logic;
		SW_PWR_OFF : IN std_logic;

		-- Other inputs
		ALLOW_MAN_OPER : IN std_logic;
		FT3_MPX_SHARE_REQ : IN std_logic;
		M_CONV_OSC : IN std_logic;
		SEL_ROS_REQ : IN std_logic;
		MACH_RST_3 : IN std_logic;
		CLOCK_ON : IN std_logic;
		SAR_DLYD_STOP_SW : IN std_logic;
		MATCH : IN std_logic;
		SALS : IN SALS_Bus;
		FORCE_IJ_REQ : IN std_logic;
		MACH_START_RST : IN std_logic;
		MACH_RST_SW : IN std_logic;
		USE_BASIC_CA_DECO : IN std_logic;
		S_REG_1_DLYD : IN std_logic;
		INTERRUPT : IN std_logic;
		END_OF_E_CY_LCH : IN std_logic;
		ANY_PRIORITY_PULSE : IN std_logic;
		FORCE_IJ_REQ_LCH : IN std_logic;
		P_CONV_OSC : IN std_logic;
		MAN_OPERATION : IN std_logic;
		ALLOW_WRITE : IN std_logic;
		MACH_CHK_PULSE : IN std_logic;
		MACH_CHK_RST : IN std_logic;
		HZ_DEST_RST : IN std_logic;
		FIRST_MACH_CHK : IN std_logic;
		CHK_OR_DIAG_STOP_SW : IN std_logic;
		ANY_MACH_CHK : IN std_logic;
		MATCH_LCH : IN std_logic;
		EARLY_ROAR_STOP_SW : IN std_logic;
		ALU_CHK : IN std_logic;
		DIAGNOSTIC_SW : IN std_logic;
		CS_DECODE_X001 : IN std_logic;
		BASIC_CS0 : IN std_logic;
		SUPPR_MACH_CHK_TRAP : IN std_logic;
		Z_BUS_0 : IN std_logic;
		SAR_STOP_SW : IN std_logic;
		ROAR_STOP_SW : IN std_logic;
		ANY_PRIORITY_PULSE_PWR : IN std_logic;
		GT_CK_DECODE : IN std_logic;
		SX1_SHARE_CYCLE,SX2_SHARE_CYCLE : IN std_logic;
		SEL_T4 : IN std_logic;
		SEL_SHARE_HOLD : IN std_logic;
		SEL_CONV_OSC : IN std_logic;
		SEL_BASIC_CLOCK_OFF : IN std_logic;
		GT_J_REG_TO_A_BUS : IN std_logic;
		M_CONV_OSC_2 : IN std_logic;
		MPX_SHARE_REQ : IN std_logic;
		SYSTEM_RESET_SW : IN std_logic;

		-- Outputs
		START_SW_RST : OUT std_logic;
		E_CY_STOP_SAMPLE : OUT std_logic;
		LOAD_KEY_SW : OUT std_logic;
		LOAD_KEY_INLK : OUT std_logic;
		SET_IC_ALLOWED : OUT std_logic;
		INH_ROSAR_SET : OUT std_logic;
		STOP_REQ : OUT std_logic;
		ROS_SCAN : OUT std_logic;
		ROS_CTRL_PROC_SW : OUT std_logic;
		FT_4_LD_IND : OUT std_logic;
		LOAD_REQ_LCH : OUT std_logic;
		LOAD_IND : OUT std_logic;
		RST_SEL_CHNL_DIAG_LCHS : OUT std_logic;
		RST_LOAD : OUT std_logic;
		CLOCK_START_LCH : OUT std_logic;
		PWR_OFF_SW : OUT std_logic;
		N2ND_ERROR_STOP : OUT std_logic;
		SEL_CHNL_CPU_CLOCK_STOP : OUT std_logic;
		CLOCK_START : OUT std_logic;
		EARLY_ROAR_STOP : OUT std_logic;
		HARD_STOP_LCH : OUT std_logic;
--		CLOCK_RST : OUT std_logic;
--		CLOCK_STOP : OUT std_logic;
		DEBUG : OUT std_logic;
        
		-- Clocks
		T2,T3,T4 : IN std_logic;
		P1 : IN std_logic;
		clk : IN std_logic
	);
END ClockStartStop;

ARCHITECTURE slt OF ClockStartStop IS 

signal STT_RST_INLK : std_logic := '1';
signal CLK_STT_CTRL : std_logic := '0';
signal SET_IC_START : std_logic;
signal SET_IC_INLK : std_logic := '1';
signal PROCESS_STOP : std_logic := '0';
signal PROC_STOP_LOOP_ACTIVE : std_logic;
signal LOAD_KEY : std_logic := '0';
signal CF100T4 : std_logic;
signal CF_STOP : std_logic := '0';
signal INSTRUCTION_STEP_SW : std_logic;
signal SINGLE_CYCLE_SW : std_logic;
signal HS_MACH_CHK, HS_ALU_CHK, HS_DIAG, HS_MATCH, HS_INSTR : std_logic;
signal LOAD_REQ : std_logic;
signal PWR_OFF : std_logic := '0';
signal sSTART_SW_RST : std_logic := '0';
signal sE_CY_STOP_SAMPLE : std_logic := '0';
signal sLOAD_KEY_SW : std_logic;
signal sLOAD_KEY_INLK : std_logic := '1';
signal sSET_IC_ALLOWED : std_logic := '0';
signal sROS_SCAN : std_logic;
signal sLOAD_IND : std_logic := '0';
signal sRST_SEL_CHNL_DIAG_LCHS : std_logic;
signal sRST_LOAD : std_logic;
signal sCLOCK_START_LCH : std_logic := '0';
signal sPWR_OFF_SW : std_logic;
signal sN2ND_ERROR_STOP : std_logic := '0';
signal sSEL_CHNL_CPU_CLOCK_STOP : std_logic;
signal sCLOCK_START : std_logic;
signal sEARLY_ROAR_STOP : std_logic;
signal sHARD_STOP_LCH : std_logic := '0';
signal sCLOCK_RST : std_logic;
signal sCLOCK_STOP : std_logic;
signal HS_DIAG_DEGLITCHED : std_logic;
-- The following signals are required to allow the FL components to instantiate
signal CSC_LCH_Set,SSR_LCH_Set,SSR_LCH_Reset,ECS_LCH_Set,ECS_LCH_Reset,LKI_LCH_Set,
		LK_LCH_Set,LK_LCH_Reset,SI_LCH_Set,SI_LCH_Reset,SIA_LCH_Set,SIA_LCH_Reset,
		PS_LCH_Set,PS_LCH_Reset,CFS_LCH_Reset,CS_LCH_Set,CS_LCH_Reset,N2E_LCH_Set,N2E_LCH_Reset,
		PO_LCH_Set,HS_LCH_Set : std_logic;

BEGIN
-- Fig 5-03C
-- STT RST INLK
SRI_LCH: FLL port map(R=>sSTART_SW_RST,S=>SW_START,Q=>STT_RST_INLK); -- AC1G7 - Note inputs reversed to make inverted output
-- STT RST
SSR_LCH_Set <= ALLOW_MAN_OPER and STT_RST_INLK and not SW_START;
SSR_LCH_Reset <= T2 or MACH_RST_SW;
SSR_LCH: FLL port map(S=>SSR_LCH_Set,R=>SSR_LCH_Reset,Q=>sSTART_SW_RST); -- AC1G7
START_SW_RST <= sSTART_SW_RST;
-- CLK STT CTRL
CSC_LCH_Set <= sCLOCK_RST or sE_CY_STOP_SAMPLE;
CSC_LCH: FLL port map(S=>CSC_LCH_Set,R=>sSTART_SW_RST,Q=>CLK_STT_CTRL); -- AC1F5
-- E CY STOP SAMPLE
ECS_LCH_Set <= SET_IC_START or (FT3_MPX_SHARE_REQ and M_CONV_OSC and PROC_STOP_LOOP_ACTIVE) or
	(M_CONV_OSC and PROC_STOP_LOOP_ACTIVE and SEL_ROS_REQ) or
	(not SW_START and M_CONV_OSC and not CLK_STT_CTRL); -- "not CLK_STT_CTRL" ?? is CLK_STT_CTRL meant to be inverted?
ECS_LCH_Reset <= MACH_RST_SW or T4;
ECS_LCH: FLL port map(S=>ECS_LCH_Set, R=>ECS_LCH_Reset, Q=>sE_CY_STOP_SAMPLE); -- AC1F7
E_CY_STOP_SAMPLE <= sE_CY_STOP_SAMPLE;	
-- LOAD KEY INLK
LKI_LCH_Set <= (not SW_LOAD and MACH_RST_3) or LOAD_KEY;
LKI_LCH: FLL port map(R=>LKI_LCH_Set, S=>SW_LOAD, Q=>sLOAD_KEY_INLK); -- AC1F7 - Note inputs reversed to make inverted output
LOAD_KEY_INLK <= sLOAD_KEY_INLK;
-- LOAD KEY
LK_LCH_Set <= not sLOAD_KEY_SW and sLOAD_KEY_INLK;
LK_LCH_Reset <= T4 or sCLOCK_RST;
LK_LCH: FLL port map(S=>LK_LCH_Set, R=>LK_LCH_Reset, Q=>LOAD_KEY); -- AC1F7
sLOAD_KEY_SW <= SW_LOAD;
LOAD_KEY_SW <= sLOAD_KEY_SW;
-- SET IC INLK
SI_LCH_Set <= (CLOCK_ON and SW_SET_IC) or MACH_RST_3 or sSET_IC_ALLOWED; -- MACH_RST_3 inverted??
SI_LCH_Reset <= not SW_SET_IC; -- FMD is missing invert on switch output??
SI_LCH: FLL port map(S=>SI_LCH_Set, R=>SI_LCH_Reset, Q=>SET_IC_INLK); -- AC1G7
-- SET IC
SIA_LCH_Set <= ALLOW_MAN_OPER and not SET_IC_INLK and SW_SET_IC;
SIA_LCH_Reset <= T2 or MACH_RST_SW;
SIA_LCH: FLL port map(S=>SIA_LCH_Set, R=>SIA_LCH_Reset, Q=>sSET_IC_ALLOWED); -- AC1G7
SET_IC_ALLOWED <= sSET_IC_ALLOWED;
SET_IC_START <= not FORCE_IJ_REQ_LCH and M_CONV_OSC and sSET_IC_ALLOWED; -- AC1D6
-- PROCESS STOP
PS_LCH_Set <= sSET_IC_ALLOWED or SW_STOP or (SAR_DLYD_STOP_SW and MATCH) or (INSTRUCTION_STEP_SW and T4);
PS_LCH_Reset <= sSTART_SW_RST or '0'; -- ?? What is second reset input?
PS_LCH: FLL port map(S=>PS_LCH_Set, R=>PS_LCH_Reset, Q=>PROCESS_STOP); -- AC1E5
DEBUG <= PROCESS_STOP; -- ?? DEBUG ??
-- PROC_STOP_LOOP_ACTIVE <= (not (USE_BASIC_CA_DECO and SALS.SALS_CA(0) and SALS.SALS_CA(1) and SALS.SALS_CA(2) and not SALS.SALS_CA(3)) and PROCESS_STOP and CF_STOP); -- AA2G5,AC1D5,AC1F5-removed??
PROC_STOP_LOOP_ACTIVE <= ((USE_BASIC_CA_DECO and SALS.SALS_CA(0) and SALS.SALS_CA(1) and SALS.SALS_CA(2) and not SALS.SALS_CA(3)) and PROCESS_STOP and CF_STOP); -- AA2G5,AC1D5,AC1F5-removed?? and inverter on AA2G5 removed??
INH_ROSAR_SET <= PROC_STOP_LOOP_ACTIVE and not ANY_PRIORITY_PULSE; -- AC1D5
STOP_REQ <= PROCESS_STOP and not S_REG_1_DLYD and not INTERRUPT and END_OF_E_CY_LCH; -- AC1H7
-- CF STOP
CF100T4 <= SALS.SALS_CF(0) and not SALS.SALS_CF(1) and not SALS.SALS_CF(2) and T4; -- AA2G5
CFS_LCH_Reset <= (not CF100T4 and T4) or (not FORCE_IJ_REQ and not sROS_SCAN and not SW_PROC) or MACH_START_RST; -- AC1G5 AC1K6 AC1M5 AC1F2 ?? SW_INH_CF_STOP instead of SW_PROC ??
CFS_LCH: FLL port map(S=>CF100T4, R=>CFS_LCH_Reset, Q=>CF_STOP); -- AC1D5
sROS_SCAN <= SW_SCAN;
ROS_SCAN <= sROS_SCAN;
ROS_CTRL_PROC_SW <= SW_PROC;

SINGLE_CYCLE_SW <= SW_SINGLE_CYCLE;
INSTRUCTION_STEP_SW <= SW_INSTRUCTION_STEP;

-- LOAD REQ
sRST_LOAD <= GT_CK_DECODE and SALS.SALS_CK(0) and SALS.SALS_CK(1) and not SALS.SALS_CK(2) and SALS.SALS_CK(3); -- AB3F7
RST_LOAD <= sRST_LOAD;
sRST_SEL_CHNL_DIAG_LCHS <= MACH_RST_3 or sRST_LOAD; -- AC1F5,AC1H6
LOAD_REQ_FL: FLL port map(LOAD_KEY, sRST_SEL_CHNL_DIAG_LCHS, sLOAD_IND); -- AC1E5
RST_SEL_CHNL_DIAG_LCHS <= sRST_SEL_CHNL_DIAG_LCHS;
LOAD_IND <= sLOAD_IND;
LOAD_REQ <= sLOAD_IND;
LOAD_REQ_LCH <= sLOAD_IND; -- AC1F2
FT_4_LD_IND <= sLOAD_IND;
-- CLOCK START
CS_LCH_Set <= (LOAD_KEY and P_CONV_OSC) or (P_CONV_OSC and sE_CY_STOP_SAMPLE and not MAN_OPERATION);
CS_LCH_Reset <= sCLOCK_RST or sCLOCK_STOP;
CS_LCH: FLL port map(S=>CS_LCH_Set, R=>CS_LCH_Reset, Q=>sCLOCK_START_LCH); -- AC1K6
CLOCK_START_LCH <= sCLOCK_START_LCH;

sSEL_CHNL_CPU_CLOCK_STOP <= not (not SX1_SHARE_CYCLE and not SX2_SHARE_CYCLE and T4) and
	not (not SX1_SHARE_CYCLE and not SX2_SHARE_CYCLE and SEL_T4) and
	not (not SX1_SHARE_CYCLE and not SX2_SHARE_CYCLE and not SEL_SHARE_HOLD) and
	not (not SX1_SHARE_CYCLE and not SX2_SHARE_CYCLE and SEL_CONV_OSC and SEL_BASIC_CLOCK_OFF); -- AD1D2,AD1C4
SEL_CHNL_CPU_CLOCK_STOP <= sSEL_CHNL_CPU_CLOCK_STOP;
sCLOCK_START <= (not sSEL_CHNL_CPU_CLOCK_STOP and sCLOCK_START_LCH and not PWR_OFF) and ((GT_J_REG_TO_A_BUS or not CF_STOP) and sCLOCK_START_LCH); -- AC1E4,AC1G6 ?? CLOCK_START_LCH twice?
CLOCK_START <= sCLOCK_START;
-- 2ND ERR STP
N2E_LCH_Set <= MACH_CHK_PULSE and P1;
N2E_LCH_Reset <= MACH_CHK_RST or HZ_DEST_RST;
N2E_LCH: FLL port map(S=>N2E_LCH_Set, R=>N2E_LCH_Reset, Q=>sN2ND_ERROR_STOP); -- AB3F4
N2ND_ERROR_STOP <= sN2ND_ERROR_STOP;
--PWR OFF
sPWR_OFF_SW <= SW_PWR_OFF;
PWR_OFF_SW <= sPWR_OFF_SW;
PO_LCH_Set <= sPWR_OFF_SW and T3 and not ALLOW_WRITE;
PO_LCH: FLL port map(S=>PO_LCH_Set, R=>MACH_START_RST, Q=>PWR_OFF); -- AC1F4
-- HARD STOP
HS_MACH_CHK <= (sN2ND_ERROR_STOP and T4 and FIRST_MACH_CHK) or (CHK_OR_DIAG_STOP_SW and ANY_MACH_CHK); -- AB3F4
sEARLY_ROAR_STOP <= MATCH_LCH and EARLY_ROAR_STOP_SW; -- AC1K5
EARLY_ROAR_STOP <= sEARLY_ROAR_STOP;
HS_ALU_CHK <= CHK_OR_DIAG_STOP_SW and ALU_CHK and T4; -- AB3H3
-- Z0_DELAY: entity AR port map(Z_BUS_0,clk,Z_BUS_0_DLYD); -- Delay to ensure Z0 signal is there at the end of T4
-- T4_DELAY: entity AR port map(T4,clk,T4_DLYD); -- Delay to ensure Z0 signal is there at the end of T4
HS_DIAG <= T4 and DIAGNOSTIC_SW and CS_DECODE_X001 and BASIC_CS0 and SUPPR_MACH_CHK_TRAP and not Z_BUS_0; -- AC1J6
-- DEGLITCH: entity DEGLITCH2 port map(HS_DIAG,clk,HS_DIAG_DEGLITCHED);
HS_MATCH <= (SAR_STOP_SW and MATCH_LCH and T4) or (ROAR_STOP_SW and T4 and MATCH_LCH) or (T4 and SINGLE_CYCLE_SW);
HS_INSTR <= T4 and INSTRUCTION_STEP_SW and ANY_PRIORITY_PULSE_PWR and sROS_SCAN; -- AB3H2

HS_LCH_Set <= HS_MACH_CHK or sEARLY_ROAR_STOP or HS_ALU_CHK or HS_DIAG or HS_MATCH or HS_INSTR;
HS_LCH: FLL port map(S=>HS_LCH_Set, R=>MACH_START_RST, Q=>sHARD_STOP_LCH); -- AB3H6
HARD_STOP_LCH <= sHARD_STOP_LCH;

sCLOCK_RST <= MACH_RST_3 or (sHARD_STOP_LCH and M_CONV_OSC_2) or (M_CONV_OSC_2 and not GT_J_REG_TO_A_BUS and CF_STOP); -- AC1F6,AC1G5
-- CLOCK_RST <= sCLOCK_RST;

sCLOCK_STOP <= (PROC_STOP_LOOP_ACTIVE and not SEL_ROS_REQ and not MPX_SHARE_REQ and T2) or (not LOAD_REQ and sLOAD_KEY_SW) or SYSTEM_RESET_SW; -- AC1H7,AC1J6,AC1J7
-- CLOCK_STOP <= sCLOCK_STOP;

END slt; 

