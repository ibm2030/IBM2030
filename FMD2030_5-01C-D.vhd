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
--    File: FMD2030_5-01C-D.vhd
--    Creation Date: 
--    Description:
--    CCROS storage, SALS (Sense Amplifier Latches), CTRL register
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
--		Change CCROS initialisation
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE std.textio.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;
library CCROS;
use CCROS.CCROS.all;

ENTITY CCROS IS 
	port
	(
		-- Inputs
		WX : IN STD_LOGIC_VECTOR(0 to 12);  -- 01B
		MACH_RST_SW : IN STD_LOGIC;         -- 03D
		MANUAL_STORE : IN STD_LOGIC;        -- 03D
		ANY_PRIORITY_LCH : IN STD_LOGIC;    -- 03A
		COMPUTE : IN STD_LOGIC;             -- 04D
		MACH_RST_MPX : IN STD_LOGIC;        -- 08C

		CROS_STROBE : IN STD_LOGIC;         -- 01B
		CROS_GO_PULSE : IN STD_LOGIC;       -- 01B

		-- Outputs
		SALS: OUT SALS_Bus;
		CTRL : OUT CTRL_REG;
		CTRL_REG_RST : OUT STD_LOGIC;            -- 07B
		CK_SAL_P_BIT_TO_MPX : OUT STD_LOGIC;        -- ?

		-- Clocks
		T1 : IN STD_LOGIC;
		P1 : IN STD_LOGIC;
		Clk : IN STD_LOGIC		-- 50MHz
	);
END CCROS;

ARCHITECTURE FMD OF CCROS IS 

signal SALS_Word : STD_LOGIC_VECTOR(0 to 54) := (others=>'1');

alias  SALS_PN : STD_LOGIC is SALS_Word(0);
alias  SALS_CN : STD_LOGIC_VECTOR(0 to 5) is SALS_Word(1 to 6);
alias  SALS_PS : STD_LOGIC is SALS_Word(7);
alias  SALS_PA : STD_LOGIC is SALS_Word(8);
alias  SALS_CH : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(9 to 12);
alias  SALS_CL : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(13 to 16);
alias  SALS_CM : STD_LOGIC_VECTOR(0 to 2) is SALS_Word(17 to 19);
alias  SALS_CU : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(20 to 21);
alias  SALS_CA : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(22 to 25);
alias  SALS_CB : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(26 to 27);
alias  SALS_CK : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(28 to 31);
alias  SALS_PK : STD_LOGIC is SALS_Word(32);
alias  SALS_PC : STD_LOGIC is SALS_Word(33);
alias  SALS_CD : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(34 to 37);
alias  SALS_CF : STD_LOGIC_VECTOR(0 to 2) is SALS_Word(38 to 40);
alias  SALS_CG : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(41 to 42);
alias  SALS_CV : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(43 to 44);
alias  SALS_CC : STD_LOGIC_VECTOR(0 to 2) is SALS_Word(45 to 47);
alias  SALS_CS : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(48 to 51);
alias  SALS_AA : STD_LOGIC is SALS_Word(52);
alias  SALS_SA : STD_LOGIC is SALS_Word(53);
alias  SALS_AK : STD_LOGIC is SALS_Word(54);

constant CCROS : CCROS_Type := Package_CCROS;
-- constant CCROS : CCROS_Type := readCCROS;

signal AUX_CTRL_REG_RST : STD_LOGIC;
signal SET_CTRL_REG : STD_LOGIC;
signal sCTRL : CTRL_REG;
signal sCTRL_REG_RST : STD_LOGIC;

signal CD_LCH_Set,CD_LCH_Reset,CS_LCH_Set,CS_LCH_Reset : STD_LOGIC_VECTOR(0 to 3);
signal STRAIGHT_LCH_Set,CROSSED_LCH_Set,CC2_LCH_Set,CC2_LCH_Reset,GTAHI_LCH_Set,GTAHI_LCH_Reset,
		GTALO_LCH_Set,GTALO_LCH_Reset,COMPCY_LCH_Set,COMPCY_LCH_Reset,CG0_Set,CG1_Set,CG_Reset : STD_LOGIC;
signal CV_LCH_Set,CV_LCH_Reset,CC01_LCH_Set,CC01_LCH_Reset : STD_LOGIC_VECTOR(0 to 1);
signal CROS_STROBE_DELAY : STD_LOGIC_VECTOR(1 to 6) := "000000";
BEGIN

-- Page 5-01C
sCTRL_REG_RST <= MACH_RST_SW or MANUAL_STORE or ANY_PRIORITY_LCH;
CTRL_REG_RST <= sCTRL_REG_RST;
AUX_CTRL_REG_RST <= T1 or sCTRL_REG_RST;
SET_CTRL_REG <= not ANY_PRIORITY_LCH and P1;

CD_LCH_Set <= SALS_CD and (0 to 3 => SET_CTRL_REG);
CD_LCH_Reset <= (0 to 3 => T1 or sCTRL_REG_RST);
CD_LCH: FLVL port map(CD_LCH_Set,CD_LCH_Reset,sCTRL.CTRL_CD); -- AA2C6

STRAIGHT_LCH_Set <= sCTRL_REG_RST or (SET_CTRL_REG and not SALS_CF(0));
STRAIGHT_LCH: FLL port map(STRAIGHT_LCH_Set, T1, sCTRL.STRAIGHT);
CROSSED_LCH_Set <= SET_CTRL_REG and SALS_CF(0);
CROSSED_LCH: FLL port map(CROSSED_LCH_Set, AUX_CTRL_REG_RST, sCTRL.CROSSED);

CC2_LCH_Set <= SET_CTRL_REG and SALS_CC(2);
CC2_LCH_Reset <= T1 or sCTRL_REG_RST;
CC2_LCH: FLL port map(CC2_LCH_Set, CC2_LCH_Reset, sCTRL.CTRL_CC(2));
GTAHI_LCH_Set <= SET_CTRL_REG and SALS_CF(1);
GTAHI_LCH_Reset <= T1 or sCTRL_REG_RST;
GTAHI_LCH: FLL port map(GTAHI_LCH_Set, GTAHI_LCH_Reset, sCTRL.GT_A_REG_HI);
GTALO_LCH_Set <= SET_CTRL_REG and SALS_CF(2);
GTALO_LCH_Reset <= T1 or sCTRL_REG_RST;
GTALO_LCH: FLL port map(GTALO_LCH_Set, GTALO_LCH_Reset, sCTRL.GT_A_REG_LO);
COMPCY_LCH_Set <= SET_CTRL_REG and COMPUTE;
COMPCY_LCH_Reset <= T1 or sCTRL_REG_RST;
COMPCY_LCH: FLL port map(COMPCY_LCH_Set, COMPCY_LCH_Reset, sCTRL.COMPUTE_CY_LCH);

CG0_Set <= MANUAL_STORE or (SET_CTRL_REG and SALS_CG(0));
CG_Reset <= T1 or (MACH_RST_SW or ANY_PRIORITY_LCH); -- ?? Required to prevent simultaneous Set & Reset of CG by MANUAL_STORE
CG0: FLL port map(CG0_Set, CG_Reset, sCTRL.CTRL_CG(0)); sCTRL.GT_B_REG_HI <= sCTRL.CTRL_CG(0);
CG1_Set <= MANUAL_STORE or (SET_CTRL_REG and SALS_CG(1));
CG1: FLL port map(CG1_Set, CG_Reset, sCTRL.CTRL_CG(1)); sCTRL.GT_B_REG_LO <= sCTRL.CTRL_CG(1);

CV_LCH_Set <= SALS_CV and (0 to 1 => SET_CTRL_REG);
CV_LCH_Reset <= (0 to 1 => T1 or sCTRL_REG_RST);
CV_LCH: FLVL port map(CV_LCH_Set,CV_LCH_Reset,sCTRL.CTRL_CV); -- AA2D6
CC01_LCH_Set <= SALS_CC(0 to 1) and (0 to 1 => SET_CTRL_REG);
CC01_LCH_Reset <= (0 to 1 => T1 or sCTRL_REG_RST);
CC01_LCH: FLVL port map(CC01_LCH_Set,CC01_LCH_Reset,sCTRL.CTRL_CC(0 to 1)); -- AA2D6

CS_LCH_Set <= SALS_CS and (0 to 3 => SET_CTRL_REG);
CS_LCH_Reset <= (0 to 3 => T1 or sCTRL_REG_RST);
CS_LCH: FLVL port map(CS_LCH_Set,CS_LCH_Reset,sCTRL.CTRL_CS); -- AA2D7
CTRL <= sCTRL;

CK_SAL_P_BIT_TO_MPX <= SALS_PK and not MACH_RST_MPX;

-- Page 5-01D
-- CCROS microcode storage
-- Start of read is CROS_GO_PULSE
-- End of read is CCROS_STROBE
-- Should use falling edge of CCROS_STROBE to gate data from CCROS into SALS (actually happens earlier)
CCROS_RESET_SET: process (Clk,CROS_STROBE,CROS_GO_PULSE,WX)
begin
-- Reset SALS when CROS_GO_PULSE goes Low
-- Set SALS 100ns after CROS_STROBE goes High (start of T3)
-- ROAR should have been set during T1 so we have a 1.5 minor cycle (~280ns) access time
	if (Clk'Event and Clk='1') then
--		if (CROS_STROBE='1' and CROS_STROBE_DELAY="10000") then
			--SALS_Word <= (others => '0');
--		else 
		if (CROS_STROBE='1' and CROS_STROBE_DELAY="111100") then
			SALS_Word <= CCROS(CCROS_Address_Type(conv_integer(unsigned(WX(1 to 12)))));
--		end if;
		end if;
		CROS_STROBE_DELAY <= CROS_STROBE & CROS_STROBE_DELAY(1 to 5);
		end if;
end process;

SALS.SALS_PN <= SALS_PN;
SALS.SALS_CN <= SALS_CN;
SALS.SALS_PS <= SALS_PS;
SALS.SALS_PA <= SALS_PA;
SALS.SALS_CH <= SALS_CH;
SALS.SALS_CL <= SALS_CL;
SALS.SALS_CM <= SALS_CM;
SALS.SALS_CU <= SALS_CU;
SALS.SALS_CA <= SALS_CA;
SALS.SALS_CB <= SALS_CB;
SALS.SALS_CK <= SALS_CK;
SALS.SALS_PK <= SALS_PK;
SALS.SALS_PC <= SALS_PC;
SALS.SALS_CD <= SALS_CD;
SALS.SALS_CF <= SALS_CF;
SALS.SALS_CG <= SALS_CG;
SALS.SALS_CV <= SALS_CV;
SALS.SALS_CC <= SALS_CC;
SALS.SALS_CS <= SALS_CS;
SALS.SALS_AA <= SALS_AA;
SALS.SALS_SA <= SALS_SA;
SALS.SALS_AK <= SALS_AK;

END FMD; 

