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
--    File: FMD2030_5-07B2.vhd
--    Creation Date:          01/11/09
--    Description:
--    S Register
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
--		Change GT_CS_OPT to level-triggered latch
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;
-- use work.all;

ENTITY SReg IS
port
	(
	  SA : IN STD_LOGIC; -- 01C
		CS : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		CD : IN STD_LOGIC_VECTOR(0 to 3); -- 01C
		N_Z_BUS : IN STD_LOGIC_VECTOR(0 to 7);
		Z_BUS0, CARRY_0, Z_BUS_HI_0, Z_BUS_LO_0 : IN STD_LOGIC; -- 06B
		GT_CARRY_TO_S3 : IN STD_LOGIC;
		S : OUT STD_LOGIC_VECTOR(0 to 7);
		GT_Z_BUS_TO_S : OUT STD_LOGIC;
		S_REG_RST : OUT STD_LOGIC;
		CTRL_REG_RST : IN STD_LOGIC; -- 01C
		MAN_STOR_PWR : IN STD_LOGIC; -- 03D
		STORE_S_REG_RST : IN STD_LOGIC; -- 03D
		E_SW_SEL_S : IN STD_LOGIC; -- 04C
		MACH_RST_2C : IN STD_LOGIC; -- 06B
		T_REQUEST : IN STD_LOGIC; -- 10BC6
		FB_K_T2_PULSE : OUT STD_LOGIC;
		CS_DECODE_X001 : OUT STD_LOGIC; -- 03C
		BASIC_CS_0 : OUT STD_LOGIC; -- 03C
		P1, T1, T2, T3, T4 : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END SReg;

ARCHITECTURE FMD OF SReg IS
signal SETS, RESETS : STD_LOGIC_VECTOR(0 to 7);
signal CS_X000,CS_X001,CS_X010,CS_X011,CS_X100,CS_X101,CS_X110,CS_X111,CS_X01X,CS_X0X1,CS_0XXX,CS_1XXX : STD_LOGIC;
signal CD_0110 : STD_LOGIC;
signal GT_CS_OPT_DECODER, GT_CS_BASIC_DECODER : STD_LOGIC;
signal BASIC_NOT_CS_0, sBASIC_CS_0 : STD_LOGIC;
signal sGT_Z_BUS_TO_S : STD_LOGIC;
signal sS_REG_RST : STD_LOGIC;
signal GT_CS_OPT_Set,GT_CS_OPT_Reset : STD_LOGIC;
signal S_REG_Set,S_REG_Reset : STD_LOGIC_VECTOR(0 to 7);

BEGIN
-- Fig 5-07B
CS_X000 <= '1' when CS(1 to 3)="000" else '0';
CS_X001 <= '1' when CS(1 to 3)="001" else '0';
CS_DECODE_X001 <= CS_X001;
CS_X010 <= '1' when CS(1 to 3)="010" else '0';
CS_X011 <= '1' when CS(1 to 3)="011" else '0';
CS_X100 <= '1' when CS(1 to 3)="100" else '0';
CS_X101 <= '1' when CS(1 to 3)="101" else '0';
CS_X110 <= '1' when CS(1 to 3)="110" else '0';
CS_X111 <= '1' when CS(1 to 3)="111" else '0';
CS_X01X <= '1' when CS(1 to 2)="01" else '0';
CS_X0X1 <= '1' when CS(1)='0' and CS(3)='1' else '0';
CS_0XXX <= '1' when CS(0)='0' else '0';
CS_1XXX <= '1' when CS(0)='1' else '0';
GT_CS_OPT_Set <= SA and P1;
GT_CS_OPT_Reset <= CTRL_REG_RST or T1;
-- GT_CS_OPT: FLE port map(GT_CS_OPT_Set, GT_CS_OPT_Reset, clk, GT_CS_OPT_DECODER); -- AB3E5
GT_CS_OPT: entity work.FLL port map(S=>GT_CS_OPT_Set, R=>GT_CS_OPT_Reset, Q=>GT_CS_OPT_DECODER); -- AB3E5
GT_CS_BASIC_DECODER <= not GT_CS_OPT_DECODER; -- AB3E5
BASIC_NOT_CS_0 <= GT_CS_BASIC_DECODER and CS_0XXX; -- AA3L5  Could be" GT_CS_BASIC_DECODER and not CS(0)"
sBASIC_CS_0 <= GT_CS_BASIC_DECODER and CS_1XXX; -- AA3L5  Could be "GT_CS_BASIC_DECODER and CS(0)"
BASIC_CS_0 <= sBASIC_CS_0;
FB_K_T2_PULSE <= sBASIC_CS_0 and T2 and CS_X110; -- AA3F7, AA3E3

CD_0110 <= '1' when CD="0110" else '0'; -- AA3B7, AA3J6
sGT_Z_BUS_TO_S <= (CD_0110 and T4) or (MAN_STOR_PWR and E_SW_SEL_S) or MACH_RST_2C; -- AA3J6
GT_Z_BUS_TO_S <= sGT_Z_BUS_TO_S;

sS_REG_RST <= (CD_0110 and T3) or (STORE_S_REG_RST and E_SW_SEL_S) or MACH_RST_2C; -- AA3J6
S_REG_RST <= sS_REG_RST;


SETS(0) <= CS_X111 and BASIC_NOT_CS_0; -- AA3G7
SETS(1) <= T_REQUEST and CS_X101 and BASIC_NOT_CS_0; -- AA3G7
SETS(2) <= CS_X001 and not Z_BUS0 and sBASIC_CS_0; -- AA3H7
SETS(3) <= GT_CARRY_TO_S3 and CARRY_0; -- AA3H7
SETS(4) <= BASIC_NOT_CS_0 and CS_X01X and Z_BUS_HI_0; -- AA3J7
SETS(5) <= BASIC_NOT_CS_0 and CS_X0X1 and Z_BUS_LO_0; -- AA3J7
SETS(6) <= CS_X011 and sBASIC_CS_0; -- AA3K7
SETS(7) <= CS_X101 and sBASIC_CS_0; -- AA3K7

RESETS(0) <= CS_X110 and BASIC_NOT_CS_0; -- AA3G7
RESETS(1) <= CS_X101 and not T_REQUEST and BASIC_NOT_CS_0; -- AA3G7
RESETS(2) <= CS_X000 and sBASIC_CS_0; -- AA3H7
RESETS(3) <= not CARRY_0 and GT_CARRY_TO_S3; -- AA3H7
RESETS(4) <= (BASIC_NOT_CS_0 and not Z_BUS_HI_0 and CS_X01X) or (BASIC_NOT_CS_0 and CS_X100); -- AA3J7
RESETS(5) <= (BASIC_NOT_CS_0 and not Z_BUS_LO_0 and CS_X0X1) or (BASIC_NOT_CS_0 and CS_X100); -- AA3J7
RESETS(6) <= sBASIC_CS_0 and CS_X010; -- AA3K7
RESETS(7) <= sBASIC_CS_0 and CS_X100; -- AA3K7

S_REG_Set <= mux(sGT_Z_BUS_TO_S,not N_Z_BUS) or mux(T4,SETS); -- ?? "T4 and not T1" to prevent erroneous S4 value
S_REG_Reset <= (S'range=>sS_REG_RST) or mux(T4,RESETS); -- ?? "T4 and not T1" to prevent erroneous S4 value
S_REG: FLVL port map(S_REG_Set, S_REG_Reset, S); -- AA3G7, AA3H7, AA3J7, AA3K7
END FMD;
