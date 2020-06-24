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
--    File: FMD2030_5-07B1.vhd
--    Creation Date:          11/01/09
--    Description:
--    SAR (MSAR) and SA (Protection Stack Address) registers
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

library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;

ENTITY SARSA IS
	port
	(
		-- Inputs
		M_ASSM_BUS,N_ASSM_BUS : IN STD_LOGIC_VECTOR(0 to 8); -- 05B
		MACH_RST_SW : IN STD_LOGIC; -- 03D
		MACH_RESET_SET_LCH_DLY : IN STD_LOGIC; -- 04B
		MAN_STOR_OR_DSPLY : IN STD_LOGIC; -- 03D
		CPU_RD_PWR : IN STD_LOGIC; -- 04D
		SEL_RDWR_CTRL : IN STD_LOGIC; -- 12C
		GT_MAN_SET_MN : IN STD_LOGIC; -- 03D
		CHNL_RD_CALL : IN STD_LOGIC; -- 04D
		XH,XL,XXH : IN STD_LOGIC; -- 08C
		MAIN_STORAGE_CP : IN STD_LOGIC; -- 08B
		MPX_CP : IN STD_LOGIC; -- 08B

		-- Outputs
		MN, MN_ST3 : OUT STD_LOGIC_VECTOR(0 to 15);
		M_P, N_P , M_ST3_P, N_ST3_P: OUT STD_LOGIC;
		SA_REG : OUT STD_LOGIC_VECTOR(0 to 7);
		EARLY_M0, M_REG_0 : OUT STD_LOGIC;
		MACH_RST_PROTECT : OUT STD_LOGIC;
		
		-- Clocks
		T1 : IN STD_LOGIC;
		SEL_T1 : IN STD_LOGIC;
		CLK : IN STD_LOGIC
		
	);
END SARSA;

ARCHITECTURE FMD OF SARSA IS 

signal LATCH_MN, LATCH_MN_ST3 : STD_LOGIC;
signal sMACH_RST_PROTECT : STD_LOGIC;
signal STACK_ADDR_REG_SET: STD_LOGIC;
signal SA_REG_IN, SA_REG_IN1, SA_REG_IN2 : STD_LOGIC_VECTOR(0 to 7);
signal sMN : STD_LOGIC_VECTOR(0 to 15);

BEGIN
-- Fig 5-07B
sMACH_RST_PROTECT <= MACH_RST_SW; -- AA3H3
MACH_RST_PROTECT <= sMACH_RST_PROTECT;
LATCH_MN <= MACH_RESET_SET_LCH_DLY or (CPU_RD_PWR and T1) or (GT_MAN_SET_MN and MAN_STOR_OR_DSPLY) or (SEL_T1 and not SEL_RDWR_CTRL); -- AA1D4
LATCH_MN_ST3 <= sMACH_RST_PROTECT or (CPU_RD_PWR and T1) or (GT_MAN_SET_MN and MAN_STOR_OR_DSPLY) or (SEL_T1 and not SEL_RDWR_CTRL); -- AA1E4
REG_M: PHV port map(M_ASSM_BUS(0 to 7),LATCH_MN,sMN(0 to 7)); -- AA1D2
REG_MP: PH port map(M_ASSM_BUS(8),LATCH_MN,M_P); -- AA1D2
REG_N: PHV port map(N_ASSM_BUS(0 to 7),LATCH_MN,sMN(8 to 15) ); -- AA1D3
REG_NP: PH port map(N_ASSM_BUS(8),LATCH_MN,N_P); -- AA1D3
REG_MST3: PHV port map(M_ASSM_BUS(0 to 7),LATCH_MN_ST3,MN_ST3(0 to 7)); -- AA1D5
REG_MST3P: PH port map(M_ASSM_BUS(8),LATCH_MN_ST3,M_ST3_P); -- AA1D5
REG_NST3: PHV port map(N_ASSM_BUS(0 TO 7),LATCH_MN_ST3,MN_ST3(8 to 15)); -- AA1D6
REG_NST3P: PH port map(N_ASSM_BUS(8),LATCH_MN_ST3,N_ST3_P); -- AA1D6

STACK_ADDR_REG_SET <= CHNL_RD_CALL or (CPU_RD_PWR and T1) or GT_MAN_SET_MN or sMACH_RST_PROTECT; -- BE3H7
SA_REG_IN1 <= "111" & M_ASSM_BUS(0 to 4) when MAIN_STORAGE_CP='1' else "00000000"; -- PE3J6
SA_REG_IN2 <= XXH & XL & XH & N_ASSM_BUS(0 to 4) when MPX_CP='1' else "00000000"; -- PE3J6
SA_REG_IN <= SA_REG_IN1 or SA_REG_IN2; -- PE3J6
REG_SA: PHV port map(SA_REG_IN,STACK_ADDR_REG_SET,SA_REG); -- PE3J6

MN <= sMN;
EARLY_M0 <= M_ASSM_BUS(0);
M_REG_0 <= sMN(0);
end FMD;
