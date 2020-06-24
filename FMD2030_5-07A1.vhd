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
--    File: FMD2030_5-07A1.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    MN (MSAR) indicators
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

ENTITY MNInd IS
	port
	(
		-- Inputs
		MN : IN STD_LOGIC_VECTOR(0 to 15);
		M_P, N_P : IN STD_LOGIC;
		LAMP_TEST : IN STD_LOGIC; -- 04A
		MAIN_STG,LOCAL_STG : IN STD_LOGIC; -- 04D
		N1401_MODE : IN STD_LOGIC; -- 05A

		-- Outputs
		IND_M : OUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		IND_N : OUT STD_LOGIC_VECTOR(0 to 8); -- 8 is P
		IND_MAIN_STG,IND_LOC_STG,IND_COMP_MODE : OUT STD_LOGIC;
		MN_PC : OUT STD_LOGIC -- 06C,11A,13A
	);
END MNInd;

ARCHITECTURE FMD OF MNInd IS 

BEGIN
-- Fig 5-07A
IND_M <= "111111111" when LAMP_TEST='1' else MN(0 to 7) & M_P;
IND_N <= "111111111" when LAMP_TEST='1' else MN(8 to 15) & N_P;
IND_MAIN_STG <= MAIN_STG or LAMP_TEST;
IND_LOC_STG <= LOCAL_STG or LAMP_TEST;
IND_COMP_MODE <= N1401_MODE or LAMP_TEST;

MN_PC <= (EvenParity(MN(0 to 7) & M_P) or EvenParity(MN(8 to 15) & N_P)) and not LOCAL_STG; -- AA1C4,AA1C5,AA1E5,AA1E6,AA1C3,AA1J3
END FMD;

