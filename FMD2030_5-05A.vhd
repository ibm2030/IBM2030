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
--    File: FMD2030_5-05A.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    R Reg (MSDR) Indicators and Checks
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

ENTITY RIndsChks IS
	port
	(
		-- Inputs        
		TEST_LAMP : IN STD_LOGIC; -- 04A
		R_REG_BUS : IN STD_LOGIC_VECTOR(0 to 7);
		R_REG_BUS_P : IN STD_LOGIC;
		G_REG_1 : IN STD_LOGIC;
		V_REG_6,V_REG_7 : IN STD_LOGIC;
		GM_WM_DETECTED : IN STD_LOGIC; -- 06C
		CARRY_1_LCHD : IN STD_LOGIC; -- 06A
		S_REG_1 : IN STD_LOGIC; -- 07B
		W3_TO_MATCH : IN STD_LOGIC; -- 01B
		ROS_SCAN : IN STD_LOGIC; -- 03C
		GT_SW_MACH_RST : IN STD_LOGIC; -- 03A

		-- Outputs
		IND_MSDR : OUT STD_LOGIC_VECTOR(0 to 7);
		IND_MSDR_P : OUT STD_LOGIC;
		R_REG_PC : OUT STD_LOGIC; -- 07A
		R_REG_VALID_DEC_DIGIT : OUT STD_LOGIC; -- 02A
		N1BC_OR_R1 : OUT STD_LOGIC; -- 02A
		S_REG_1_OR_R_REG_2 : OUT STD_LOGIC; -- 02A
		G_REG_1_OR_R_REG_3 : OUT STD_LOGIC; -- 02A
		V67_00_OR_GM_WM : OUT STD_LOGIC; -- 02A
		N1401_MODE : OUT STD_LOGIC; -- 05B,06C,07A,01B,04D,13C
        
		-- Clocks
		T2 : IN STD_LOGIC;
		CLK : IN STD_LOGIC
	);
END RIndsChks;

ARCHITECTURE FMD OF RIndsChks IS 

signal V67_EQUALS_00 : STD_LOGIC;
signal N1401_MODE_SET,N1401_MODE_RESET : STD_LOGIC;
signal sN1401_MODE : STD_LOGIC;

BEGIN
-- Fig 5-05A
	IND_MSDR <= R_REG_BUS or (0 to 7 => TEST_LAMP);
	IND_MSDR_P <= R_REG_BUS_P or TEST_LAMP;

	R_REG_PC <= EvenParity(R_REG_BUS & R_REG_BUS_P); -- AA1K6

	R_REG_VALID_DEC_DIGIT <= ((not R_REG_BUS(0) or not R_REG_BUS(1)) and (not R_REG_BUS(0) or not R_REG_BUS(2))) and
		((not R_REG_BUS(4) or not R_REG_BUS(5)) and (not R_REG_BUS(4) or not R_REG_BUS(6))); -- ?? *and* or *or* as per MDM?

	N1401_MODE_SET <= W3_TO_MATCH and not ROS_SCAN; -- AC1C4
	N1401_MODE_RESET <= T2 or GT_SW_MACH_RST;
	MODE1401: FLL port map(S=>N1401_MODE_SET,R=>N1401_MODE_RESET,Q=>sN1401_MODE); -- AB2B2,AB1B3,AB2C2
	N1401_MODE <= sN1401_MODE;

	V67_EQUALS_00 <= not V_REG_6 and not V_REG_7; -- AA1H6
	-- AB2C2,AB2B2:
	N1BC_OR_R1 <= (not sN1401_MODE or R_REG_BUS(1)) and ((CARRY_1_LCHD and not sN1401_MODE) or sN1401_MODE);
	S_REG_1_OR_R_REG_2 <= (not sN1401_MODE or R_REG_BUS(2)) and (sN1401_MODE or S_REG_1);
	G_REG_1_OR_R_REG_3 <= (not sN1401_MODE or R_REG_BUS(3)) and (sN1401_MODE or (not sN1401_MODE and G_REG_1));
	V67_00_OR_GM_WM <= (not sN1401_MODE or GM_WM_DETECTED) and ((not sN1401_MODE and V67_EQUALS_00) or sN1401_MODE);

END FMD; 
