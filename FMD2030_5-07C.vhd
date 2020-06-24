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
--    File: FMD2030_5-07C.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    A Register Assembly
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

ENTITY ARegAssm IS
	port
	(
		-- Inputs        
		USE_MANUAL_DECODER : IN STD_LOGIC; -- 03D
		USE_ALT_CA_DECODER : IN STD_LOGIC; -- 02B
		USE_BASIC_CA_DECO : IN STD_LOGIC; -- 02A
		E_SEL_SW_BUS : IN E_SW_BUS_Type; -- 04C
		GTD_CA_BITS : IN STD_LOGIC_VECTOR(0 to 3); -- 05C
		CHK_SW_DISABLE : IN STD_LOGIC; -- 04A
		S : IN STD_LOGIC_VECTOR(0 to 7); -- 07B
		MC_CTRL_REG : IN STD_LOGIC_VECTOR(0 to 7); -- 07A
		Q_REG : IN STD_LOGIC_VECTOR(0 to 8); -- 08B
		SEL_CHNL_GJ_BUS : IN STD_LOGIC_VECTOR(0 to 8) := "000000000"; -- 11B
		GT_GJ_TO_A_REG : IN STD_LOGIC := '0'; -- 12C
		-- Outputs
--		GT_DDC_TO_A_BUS : OUT STD_LOGIC; -- 07A
		GT_Q_REG_TO_A_BUS : OUT STD_LOGIC; -- 07A
		A_BUS : INOUT STD_LOGIC_VECTOR(0 to 8)
	);
END ARegAssm;

ARCHITECTURE FMD OF ARegAssm IS 

signal	GT_MC_REG_TO_A_BUS : STD_LOGIC;
signal	sGT_Q_REG_TO_A_BUS : STD_LOGIC;
signal	sGT_DDC_TO_A_BUS : STD_LOGIC;
signal	GT_S_REG_TO_A : STD_LOGIC;
signal	JI_REG : STD_LOGIC_VECTOR(0 to 8) := "000000000"; -- BE3D5

BEGIN
-- Fig 5-07C
GT_MC_REG_TO_A_BUS <= '1' when USE_ALT_CA_DECODER='1' and GTD_CA_BITS="0010" else '0'; -- AB1F5
sGT_Q_REG_TO_A_BUS <= '1' when (USE_MANUAL_DECODER='1' and E_SEL_SW_BUS.Q_SEL='1') or (USE_ALT_CA_DECODER='1' and GTD_CA_BITS="0101") else '0'; -- AB3C7
GT_Q_REG_TO_A_BUS <= sGT_Q_REG_TO_A_BUS;
sGT_DDC_TO_A_BUS <= '1' when (USE_MANUAL_DECODER='1' and E_SEL_SW_BUS.JI_SEL='1') or (USE_ALT_CA_DECODER='1' and GTD_CA_BITS="0110") else '0'; -- AB3C7
-- GT_DDC_TO_A_BUS <= sGT_DDC_TO_A_BUS;
GT_S_REG_TO_A <= '1' when (USE_MANUAL_DECODER='1' and E_SEL_SW_BUS.S_SEL='1') or (USE_BASIC_CA_DECO='1' and GTD_CA_BITS="0100") else '0'; -- AB3C3

A_BUS <= not(S & '0') when GT_S_REG_TO_A='1' else
	not(MC_CTRL_REG & '0') when GT_MC_REG_TO_A_BUS='1' and CHK_SW_DISABLE='0' else -- ABJK6 AB3L6
	not JI_REG when sGT_DDC_TO_A_BUS='1' else
	not SEL_CHNL_GJ_BUS when GT_GJ_TO_A_REG='1' else
	not Q_REG when sGT_Q_REG_TO_A_BUS='1' else -- AC2D2
	"111111111";
-- A_REG_BUS_2 <= ((S & '0') and (A_REG_BUS_2'range => GT_S_REG_TO_A)) or ((MC_CTRL_REG & '0') and (A_REG_BUS_2'range => (GT_MC_REG_TO_A_BUS and not CHK_SW_DISABLE))); -- ABJK6 AB3L6
-- A_REG_BUS_3 <= (JI_REG and (A_REG_BUS_3'range => sGT_DDC_TO_A_BUS)) or (SEL_CHNL_GJ_BUS and (A_REG_BUS_3'range => GT_GJ_TO_A_REG)) or (Q_REG and (A_REG_BUS_3'range => GT_Q_REG_TO_A_BUS)); -- AC2D2

END FMD; 

