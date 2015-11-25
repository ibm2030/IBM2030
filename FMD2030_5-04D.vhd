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
--    File: FMD2030_5-04D.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Read/Write Storage Controls
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

ENTITY RWStgCntl IS
	port
	(
		-- Inputs        
		SALS : IN SALS_Bus;
		ANY_PRIORITY_PULSE,ANY_PRIORITY_PULSE_2 : IN STD_LOGIC; -- 03A
		SEL_SHARE_HOLD : IN STD_LOGIC; -- 12D
		G_REG_0_BIT,G_REG_1_BIT : IN STD_LOGIC; -- 05C
		N1401_MODE : IN STD_LOGIC; -- 05A
		USE_CPU_DECODER : IN STD_LOGIC; -- 05C
		USE_MAN_DECODER : IN STD_LOGIC; -- 03D
		E_SW_SEL_AUX_STG : IN STD_LOGIC; -- 04C
		MEM_SEL : IN STD_LOGIC; -- 03D
		ALLOW_WRITE,ALLOW_WRITE_2 : IN STD_LOGIC; -- 03D
		SEL_RD_WR_CTRL : IN STD_LOGIC; -- 12C
		MAN_STOR_OR_DISPLAY : IN STD_LOGIC; -- 03D
		MACH_RST_1 : IN STD_LOGIC; -- 03D
		MANUAL_RD_CALL,MANUAL_WR_CALL : IN STD_LOGIC; -- 03D
		HSMPX_READ_CALL : IN STD_LOGIC; -- ?
		SEL_RD_CALL_TO_STP : IN STD_LOGIC; -- 12C
		SELECT_CPU_BUMP : IN STD_LOGIC; -- 08B

		-- Outputs
		USE_ALT_CU_DECODE : OUT STD_LOGIC; -- 01B
		USE_GR_OR_HR : OUT STD_LOGIC; -- 12D,14D
		USE_R : OUT STD_LOGIC; -- 06C,03D
		CPU_WRITE_IN_R_REG : OUT STD_LOGIC; -- 07A
		CPU_WRITE_PWR : OUT STD_LOGIC; -- 03D,12D,03D,05D
		COMPUTE : OUT STD_LOGIC; -- 01C
		CPU_READ_PWR : OUT STD_LOGIC; -- 07B,03D,05D
		FORCE_M_REG_123 : OUT STD_LOGIC; -- 05B,08B
		CU_DECODE_UCW : OUT STD_LOGIC; -- 05B
		MAIN_STORAGE_CP : OUT STD_LOGIC; -- 07B,05Bm08B
		LOCAL_STORAGE_CP : OUT STD_LOGIC; -- 07A
		MAIN_STORAGE : OUT STD_LOGIC; -- 03B,06C,04B,06C,07A,08B
		EARLY_LOCAL_STG : OUT STD_LOGIC; -- 05D
		GT_LOCAL_STG : OUT STD_LOGIC; -- 08B
		CHANNEL_RD_CALL : OUT STD_LOGIC; -- 07B
		N_MEM_SELECT : OUT STD_LOGIC; -- 07B
		RW_CTRL_STACK : OUT STD_LOGIC; -- 07B
        
		-- Clocks
		T1 : IN STD_LOGIC;
		SEL_T1 : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END RWStgCntl;

ARCHITECTURE FMD OF RWStgCntl IS 

signal RD_SEL,WR_SEL : STD_LOGIC;
signal CU01,CM0X0 : STD_LOGIC;
signal CU_DECODE_CPU_LOCAL,MAN_SEL_LOCAL : STD_LOGIC;
signal sCU_DECODE_UCW : STD_LOGIC;
signal sMAIN_STORAGE_CP : STD_LOGIC;
signal sGT_LOCAL_STG : STD_LOGIC;
signal sCHANNEL_RD_CALL : STD_LOGIC;
signal sCPU_READ_PWR : STD_LOGIC;
signal sCPU_WRITE_PWR : STD_LOGIC;
signal sUSE_ALT_CU_DECODE : STD_LOGIC;
signal sUSE_R : STD_LOGIC;
signal sEARLY_LOCAL_STG : STD_LOGIC;

BEGIN
-- Fig 5-04D
sCHANNEL_RD_CALL <= (SEL_T1 and not SEL_RD_WR_CTRL) or HSMPX_READ_CALL; -- AD1L5,BE3E4
CHANNEL_RD_CALL <= sCHANNEL_RD_CALL;
RD_SEL <= MANUAL_RD_CALL or (sCPU_READ_PWR and T1) or sCHANNEL_RD_CALL; -- BE3D3,BE3H5,BE3J5
WR_SEL <= (T1 and sCPU_WRITE_PWR and ALLOW_WRITE_2) or MANUAL_WR_CALL or (SEL_RD_CALL_TO_STP or HSMPX_READ_CALL); -- BE3J5,BE3H5
N_MEM_SELECT <= not (not SELECT_CPU_BUMP and (RD_SEL or WR_SEL)); -- BE3H6
-- ?? Note TD not implemented (yet)
RW_LCH: entity FLL port map(RD_SEL,WR_SEL,RW_CTRL_STACK); -- BE3J5

sUSE_ALT_CU_DECODE <= not ANY_PRIORITY_PULSE and not sCPU_READ_PWR; -- AB3D2
USE_ALT_CU_DECODE <= sUSE_ALT_CU_DECODE;

CU01 <= not SALS.SALS_CU(0) and SALS.SALS_CU(1); -- AB3E2
USE_GR_OR_HR <= (sUSE_ALT_CU_DECODE and USE_CPU_DECODER and CU01); -- AB3E2,AB3H6-removed??
sUSE_R <= not CU01 and not SEL_SHARE_HOLD; -- AB3D5,AB3H3
USE_R <= sUSE_R;

CM0X0 <= not SALS.SALS_CM(0) and not SALS.SALS_CM(2); -- AB3D6
CPU_WRITE_IN_R_REG <= sUSE_R and CM0X0; -- AB3F2
sCPU_WRITE_PWR <= CM0X0;
CPU_WRITE_PWR <= sCPU_WRITE_PWR;
sCPU_READ_PWR <= (SALS.SALS_CM(0) and not ANY_PRIORITY_PULSE_2) or (SALS.SALS_CM(1) and SALS.SALS_CM(2) and not ANY_PRIORITY_PULSE_2); -- AB3B6,AB3D2
CPU_READ_PWR <= sCPU_READ_PWR;

COMPUTE <= not sCPU_WRITE_PWR and not sCPU_READ_PWR; -- AB3F2

CU_DECODE_CPU_LOCAL <= ((not G_REG_0_BIT or N1401_MODE) and (N1401_Mode or not G_REG_1_BIT) and SALS.SALS_CU(0) and SALS.SALS_CU(1) and USE_CPU_DECODER) or
	(not SALS.SALS_CU(0) and SALS.SALS_CU(1) and USE_CPU_DECODER); -- AA1C2,AA1J4 ?? *not* N1401_MODE ??
FORCE_M_REG_123 <= CU_DECODE_CPU_LOCAL; -- AA1H2
sCU_DECODE_UCW <= SALS.SALS_CU(0) and not SALS.SALS_CU(1) and USE_CPU_DECODER; -- AA1C2
CU_DECODE_UCW <= sCU_DECODE_UCW;
MAN_SEL_LOCAL <= USE_MAN_DECODER and E_SW_SEL_AUX_STG; -- AA1C2
sEARLY_LOCAL_STG <= CU_DECODE_CPU_LOCAL or sCU_DECODE_UCW or MAN_SEL_LOCAL; -- AA1C3
EARLY_LOCAL_STG <= sEARLY_LOCAL_STG;


sMAIN_STORAGE_CP <= not sEARLY_LOCAL_STG; -- AA1J2
MAIN_STORAGE_CP <= sMAIN_STORAGE_CP;
-- SELECT_CPU_BUMP <= sEARLY_LOCAL_STG; -- ? Not sure!

sGT_LOCAL_STG <= ((MEM_SEL and not ALLOW_WRITE) and MAN_STOR_OR_DISPLAY) or (T1 and sCPU_READ_PWR) or (SEL_T1 and not SEL_RD_WR_CTRL) or MACH_RST_1; -- AA1C2,AA1J2-removed??,AA1G4 
GT_LOCAL_STG <= sGT_LOCAL_STG;


LS_LCH: entity PH port map(not sMAIN_STORAGE_CP,sGT_LOCAL_STG,LOCAL_STORAGE_CP); -- AA1F4
MS_LCH: entity PH port map(not sEARLY_LOCAL_STG,sGT_LOCAL_STG,MAIN_STORAGE); -- AA1F4

END FMD; 

