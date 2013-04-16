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
--    File: FMD2030_5-03A.vhd
--    Creation Date: 
--    Description:
--    Priority (microcode interruptions)
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
--		Change Priority Reset latch signal name
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY Priority IS
	port
(
        -- Inputs        
        RECYCLE_RST : IN STD_LOGIC; -- 04A
        S_REG_1_BIT : IN STD_LOGIC; -- 07B
        SALS_CDREG : IN STD_LOGIC_VECTOR(0 to 3); -- 01A?
        MACH_RST_SW : IN STD_LOGIC; -- 03D
        DATA_READY_1 : IN STD_LOGIC; -- 05D
        DATA_READY_2 : IN STD_LOGIC; -- ???
        MEM_WRAP_REQ : IN STD_LOGIC; -- 03B
        ALLOW_PROTECT : IN STD_LOGIC; -- 06C
        PROT_LOC_CPU_OR_MPX : IN STD_LOGIC; -- 08B
        READ_CALL : IN STD_LOGIC; -- 05D
        XOR_OR_OR : IN STD_LOGIC; -- 02A
        CTRL_N : IN STD_LOGIC; -- 06B
        STOP_REQ : IN STD_LOGIC; -- 03C
        SUPPR_A_REG_CHK : IN STD_LOGIC; -- 07A
        H_REG_5_PWR : IN STD_LOGIC; -- 04C
        SEL_ROS_REQ : IN STD_LOGIC; -- 12C
        FT_3_MPX_SHARE_REQ : IN STD_LOGIC; -- 08D
        H_REG_6 : IN STD_LOGIC; -- 04C
        P_8F_DETECTED : IN STD_LOGIC; -- 06C
        LOAD_IND : IN STD_LOGIC; -- 03C
        FORCE_IJ_REQ : IN STD_LOGIC; -- 04A
        FIRST_MACH_CHK_REQ : IN STD_LOGIC; -- 07A
        MACH_RST_6 : IN STD_LOGIC; -- 03D
        ALLOW_WRITE : IN STD_LOGIC; -- 03D
        GT_SWS_TO_WX_PWR : IN STD_LOGIC; -- 04A
        DIAGNOSTIC_SW : IN STD_LOGIC; -- 04A
        MACH_RST_LCH : IN STD_LOGIC; -- 04A
        HARD_STOP_LCH : IN STD_LOGIC; -- 03C
        R_REG_5 : IN STD_LOGIC; -- 06C
        H : IN STD_LOGIC_VECTOR(0 to 7); -- 04C
        FORCE_DEAD_CY_LCH : IN STD_LOGIC; -- 04A
        
        -- Outputs
        SUPPR_MACH_CHK_TRAP : OUT STD_LOGIC; -- 03C,04A,07A
        ANY_PRIORITY_PULSE_2 : OUT STD_LOGIC; -- 03B,04D
        ANY_PRIORITY_LCH : OUT STD_LOGIC; -- 04A,07A
        S_REG_1_DLYD : OUT STD_LOGIC; -- 03C
        GT_SW_TO_WX_LCH : OUT STD_LOGIC; -- 04A
        DATA_READY : OUT STD_LOGIC; -- 06C
        MEM_PROTECT_REQ : OUT STD_LOGIC; -- 07A
        HZ_DEST_RST : OUT STD_LOGIC; -- 03C,04A
        GT_SW_MACH_RST : OUT STD_LOGIC; -- 05A
        GT_SWS_TO_WX_LCH : OUT STD_LOGIC; -- 01B
        FORCE_IJ_REQ_LCH : OUT STD_LOGIC; -- 03C,04A,04B
        SYS_RST_PRIORITY_LCH :OUT STD_LOGIC; -- 06B
        MACH_CHK_PULSE : OUT STD_LOGIC; -- 03C,07A
        FORCE_IJ_PULSE : OUT STD_LOGIC; -- 04A
        SX_CHAIN_PULSE_1 : OUT STD_LOGIC; -- 12C
        ANY_PRIORITY_PULSE : OUT STD_LOGIC; -- 01C,01B,02B,04C,11C
        ANY_PRIORITY_PULSE_PWR : OUT STD_LOGIC; -- 01B,03C
        PRIORITY_BUS : OUT STD_LOGIC_VECTOR(0 to 7); -- 01B
        PRIORITY_BUS_P : OUT STD_LOGIC;
        
		-- Clocks
        T1 : IN STD_LOGIC;
        T3 : IN STD_LOGIC;
        T4 : IN STD_LOGIC;
        P4 : IN STD_LOGIC;
		  CLK : IN STD_LOGIC
	);
END Priority;

ARCHITECTURE FMD OF Priority IS 

-- Priority Bus assignments
signal sPRIORITY_BUS :  STD_LOGIC_VECTOR(0 to 7);
alias STOP_PULSE : STD_LOGIC is sPRIORITY_BUS(0);
alias PROTECT_PULSE : STD_LOGIC is sPRIORITY_BUS(1);
alias WRAP_PULSE : STD_LOGIC is sPRIORITY_BUS(2);
alias MPX_SHARE_PULSE : STD_LOGIC is sPRIORITY_BUS(3);
alias SX_CHAIN_PULSE : STD_LOGIC is sPRIORITY_BUS(4);
alias PB_MACH_CHK_PULSE : STD_LOGIC is sPRIORITY_BUS(5);
alias IPL_PULSE : STD_LOGIC is sPRIORITY_BUS(6);
alias PB_FORCE_IJ_PULSE : STD_LOGIC is sPRIORITY_BUS(7);

signal CD0101 : STD_LOGIC;
signal PRIOR_RST_CTRL : STD_LOGIC;
signal PRIORITY_LCH : STD_LOGIC;
signal FIRST_MACH_CHK_LCH : STD_LOGIC;
signal LOAD_REQ_LCH : STD_LOGIC;
signal MEM_WRAP_REQ_LCH : STD_LOGIC;
signal MEM_PROTECT_LCH : STD_LOGIC;
signal STOP_REQ_LCH : STD_LOGIC;
signal SEL_CHAIN_REQ_LCH : STD_LOGIC;
signal MPX_SHARE_REQ_LCH : STD_LOGIC;
signal HI_PRIORITY : STD_LOGIC;

signal PRIORITY_STACK_IN, PRIORITY_STACK_OUT : STD_LOGIC_VECTOR(0 to 8);

signal sSUPPR_MACH_CHK_TRAP : STD_LOGIC;
signal sANY_PRIORITY_PULSE_2 : STD_LOGIC;
signal sANY_PRIORITY_LCH : STD_LOGIC;
signal sGT_SW_TO_WX_LCH : STD_LOGIC;
signal sDATA_READY : STD_LOGIC;
signal sMEM_PROTECT_REQ : STD_LOGIC;
signal sHZ_DEST_RST : STD_LOGIC;
signal sGT_SW_MACH_RST : STD_LOGIC;
signal sGT_SWS_TO_WX_LCH : STD_LOGIC;
signal sFORCE_IJ_REQ_LCH : STD_LOGIC;
signal sSYS_RST_PRIORITY_LCH : STD_LOGIC;
signal sMACH_CHK_PULSE : STD_LOGIC;
signal sFORCE_IJ_PULSE : STD_LOGIC;
signal sANY_PRIORITY_PULSE : STD_LOGIC;
signal sMPX_SHARE_PULSE : STD_LOGIC;
signal SUPPR_MACH_TRAP_L,PRIOR_RST_Latch,MEMP_LCH_Set,MEMP_LCH_Reset,PRI_LCH_Set,
		PRI_LCH_Reset,PRISTK_LCH_Latch : STD_LOGIC;

BEGIN
-- Fig 5-03A
SUPPR_MACH_TRAP_L <= XOR_OR_OR and CTRL_N and T3;
SUPPR_MALF_TRAP_LCH: PHR port map(not R_REG_5,SUPPR_MACH_TRAP_L,RECYCLE_RST,sSUPPR_MACH_CHK_TRAP); -- AB3D2,AB3J2
-- ?? SUPPR_MACH_CHK_TRAP is from the output of the PH and not from its reset input ??
SUPPR_MACH_CHK_TRAP <= sSUPPR_MACH_CHK_TRAP; -- ??
-- SUPPR_MACH_CHK_TRAP <= not RECYCLE_RST; -- ??
sANY_PRIORITY_PULSE_2 <= sANY_PRIORITY_PULSE; -- AB3D7
ANY_PRIORITY_PULSE_2 <= sANY_PRIORITY_PULSE_2;
ANY_PRIORITY: PH port map(sANY_PRIORITY_PULSE_2,T1,sANY_PRIORITY_LCH); -- AB3D7,AB3J2
ANY_PRIORITY_LCH <= sANY_PRIORITY_LCH;
S1_DLYD: PH port map(S_REG_1_BIT,T1,S_REG_1_DLYD); -- AB3J2
WX_SABC: PH port map(sGT_SWS_TO_WX_LCH,T1,sGT_SW_TO_WX_LCH); -- AB3J2
GT_SW_TO_WX_LCH <= sGT_SW_TO_WX_LCH;
CD0101 <= '1' when SALS_CDREG="0101" else '0';
PRIOR_RST_Latch <= T4 or MACH_RST_SW;
PRIOR_RST_CTRL_PH: PHR port map(D=>CD0101,L=>PRIOR_RST_Latch,R=>sANY_PRIORITY_PULSE,Q=>PRIOR_RST_CTRL); -- AB3J2
MEMP_LCH_Set <= sDATA_READY and ALLOW_PROTECT and PROT_LOC_CPU_OR_MPX;
MEMP_LCH_Reset <= READ_CALL or RECYCLE_RST;
STG_PROT_REQ: FLL port map(MEMP_LCH_Set,MEMP_LCH_Reset,sMEM_PROTECT_REQ); -- AA1K7
MEM_PROTECT_REQ <= sMEM_PROTECT_REQ;

sHZ_DEST_RST <= (P4 and sGT_SW_TO_WX_LCH) or (T3 and PRIOR_RST_CTRL); -- AB3K5,AB3J4
HZ_DEST_RST <= sHZ_DEST_RST;
sGT_SW_MACH_RST <= MACH_RST_6 or GT_SWS_TO_WX_PWR; -- AB3J3 ??
GT_SW_MACH_RST <= sGT_SW_MACH_RST;
sDATA_READY <= (DATA_READY_1 or DATA_READY_2) and not MEM_WRAP_REQ; -- AA1J6 AA1J4
DATA_READY <= sDATA_READY;

PRI_LCH_Set <= (T1 and DIAGNOSTIC_SW) or MACH_RST_LCH or (not HARD_STOP_LCH and T3 and sANY_PRIORITY_LCH);
PRI_LCH_Reset <= sHZ_DEST_RST or sGT_SW_MACH_RST;
PRIORITY: FLL port map(S=>PRI_LCH_Set,R=>PRI_LCH_Reset,Q=>PRIORITY_LCH); -- AB3J4,AB3L4

-- Priority stack register - all inputs are inverted AB3L2
PRIORITY_STACK_IN(0) <= GT_SWS_TO_WX_PWR;
PRIORITY_STACK_IN(1) <= FIRST_MACH_CHK_REQ;
PRIORITY_STACK_IN(2) <= P_8F_DETECTED or LOAD_IND;
PRIORITY_STACK_IN(3) <= FORCE_IJ_REQ;
PRIORITY_STACK_IN(4) <= MEM_WRAP_REQ;
PRIORITY_STACK_IN(5) <= sMEM_PROTECT_REQ;
PRIORITY_STACK_IN(6) <= STOP_REQ;
PRIORITY_STACK_IN(7) <= SUPPR_A_REG_CHK and not H_REG_5_PWR and SEL_ROS_REQ;
PRIORITY_STACK_IN(8) <= FT_3_MPX_SHARE_REQ and not H_REG_6 and not H_REG_5_PWR;
PRISTK_LCH_Latch <= MACH_RST_6 or (not ALLOW_WRITE and T3) or (P4 and GT_SWS_TO_WX_PWR);
PRISTK_LCH: PHV9 port map(    D => PRIORITY_STACK_IN,
        L => PRISTK_LCH_Latch,
		  Q => PRIORITY_STACK_OUT);
sGT_SWS_TO_WX_LCH <= PRIORITY_STACK_OUT(0);
GT_SWS_TO_WX_LCH <= sGT_SWS_TO_WX_LCH;
FIRST_MACH_CHK_LCH <= PRIORITY_STACK_OUT(1);
LOAD_REQ_LCH <= PRIORITY_STACK_OUT(2);
sFORCE_IJ_REQ_LCH <= PRIORITY_STACK_OUT(3);
FORCE_IJ_REQ_LCH <= sFORCE_IJ_REQ_LCH;
MEM_WRAP_REQ_LCH <= PRIORITY_STACK_OUT(4);
MEM_PROTECT_LCH <= PRIORITY_STACK_OUT(5);
STOP_REQ_LCH <= PRIORITY_STACK_OUT(6);
SEL_CHAIN_REQ_LCH <= PRIORITY_STACK_OUT(7);
MPX_SHARE_REQ_LCH <= PRIORITY_STACK_OUT(8);

-- HI priorities AB3K3
sMACH_CHK_PULSE <= not sSUPPR_MACH_CHK_TRAP and not PRIORITY_LCH and not sGT_SWS_TO_WX_LCH and FIRST_MACH_CHK_LCH; -- ?? SUPPRESS_MACH_CHECK_TRAP should be inverted ??
MACH_CHK_PULSE <= sMACH_CHK_PULSE;
PB_MACH_CHK_PULSE <= sMACH_CHK_PULSE;
IPL_PULSE <= not sMACH_CHK_PULSE and not PRIORITY_LCH and not sGT_SWS_TO_WX_LCH and LOAD_REQ_LCH and not H(0);
sFORCE_IJ_PULSE <= not IPL_PULSE and not sMACH_CHK_PULSE and not sGT_SWS_TO_WX_LCH and not PRIORITY_LCH and sFORCE_IJ_REQ_LCH and not H(4);
FORCE_IJ_PULSE <= sFORCE_IJ_PULSE;
PB_FORCE_IJ_PULSE <= sFORCE_IJ_PULSE;
WRAP_PULSE <= not sFORCE_IJ_PULSE and not PRIORITY_LCH and not sGT_SWS_TO_WX_LCH and not IPL_PULSE and not sMACH_CHK_PULSE and MEM_WRAP_REQ_LCH and not H(2);
HI_PRIORITY <= FORCE_DEAD_CY_LCH or sGT_SWS_TO_WX_LCH or sMACH_CHK_PULSE or IPL_PULSE or sFORCE_IJ_PULSE or WRAP_PULSE; -- AB3K3
PRIORITY_BUS <= sPRIORITY_BUS;

-- LO priorities AB3K4
PROTECT_PULSE <= not HI_PRIORITY and not PRIORITY_LCH and MEM_PROTECT_LCH and not H(3);
STOP_PULSE <= not PROTECT_PULSE and not PRIORITY_LCH and not HI_PRIORITY and STOP_REQ_LCH;
SX_CHAIN_PULSE <= not STOP_PULSE and not PROTECT_PULSE and not HI_PRIORITY and not PRIORITY_LCH and SEL_CHAIN_REQ_LCH and not H(5);
SX_CHAIN_PULSE_1 <= SX_CHAIN_PULSE;
sMPX_SHARE_PULSE <= not SX_CHAIN_PULSE and not STOP_PULSE and not PROTECT_PULSE and not PRIORITY_LCH and not HI_PRIORITY and MPX_SHARE_REQ_LCH and not (H(5) or H(6)); -- ??
MPX_SHARE_PULSE <= sMPX_SHARE_PULSE;

SRP_LCH: FLL port map(MACH_RST_SW,T4,sSYS_RST_PRIORITY_LCH); -- AB3L3
SYS_RST_PRIORITY_LCH <= sSYS_RST_PRIORITY_LCH;

sANY_PRIORITY_PULSE <= sMPX_SHARE_PULSE or SX_CHAIN_PULSE or STOP_PULSE or PROTECT_PULSE or HI_PRIORITY or sSYS_RST_PRIORITY_LCH; -- AB3K4 ??
ANY_PRIORITY_PULSE <= sANY_PRIORITY_PULSE;
ANY_PRIORITY_PULSE_PWR <= sANY_PRIORITY_PULSE and not MACH_RST_SW; -- AB3D4

PRIORITY_BUS_P <= (sSYS_RST_PRIORITY_LCH or FORCE_DEAD_CY_LCH) and not GT_SWS_TO_WX_PWR; -- AB3H5 ??

END FMD; 

