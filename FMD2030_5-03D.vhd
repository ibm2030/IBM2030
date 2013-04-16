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
--    File: FMD2030_5-03D.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Manual Controls - Front panel switches Display, Store & Reset
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

ENTITY ManualControls IS
	port
	(
		-- Inputs        
		E_SW_SEL_MAIN_STG,E_SW_SEL_AUX_STG : IN STD_LOGIC; -- 04C
		E_CY_STOP_SMPL : IN STD_LOGIC; -- 03C
		SEL_CHNL_DATA_XFER : IN STD_LOGIC; -- 12D
		POWER_ON_RESET : IN STD_LOGIC; -- 14A
		LOAD_KEY_SW : IN STD_LOGIC; -- 03C
		CLOCK_OFF,CLOCK_ON : IN STD_LOGIC; -- 08A
		WRITE_ECHO_1,WRITE_ECHO_2 : IN STD_LOGIC; -- 05D
		READ_ECHO_1,READ_ECHO_2 : IN STD_LOGIC; -- 05D
		CPU_READ_PWR : IN STD_LOGIC; -- 04D
		SEL_AUX_RD_CALL : IN STD_LOGIC; -- 12C
		SEL_WR_CALL : IN STD_LOGIC; -- 12C
		ROAR_RESTT_STOR_BYPASS : IN STD_LOGIC;
		RECYCLE_RST : IN STD_LOGIC; -- 04A
		MAN_DSPLY_GUV_HUV : IN STD_LOGIC; -- 12C
		CPU_WR_PWR : IN STD_LOGIC; -- 04D
		LOAD_KEY_INLK : IN STD_LOGIC; -- 03C
		POWER_OFF_SW : IN STD_LOGIC; -- 03C
		IJ_SEL_SW,UV_SEL_SW : IN STD_LOGIC; -- 04C
		SEL_AUX_WR_CALL : IN STD_LOGIC; -- 12C
		USE_R : IN STD_LOGIC; -- 04D
		SEL_T1 : IN STD_LOGIC;
		CU_SALS : IN STD_LOGIC_VECTOR(0 to 1);

		-- Switches
		SW_DSPLY, SW_STORE,SW_SYS_RST : IN STD_LOGIC;

		-- Outputs
		MACH_RST_SW,MACH_RST_1,MACH_RST_3,MACH_RST_4,MACH_RST_5,MACH_RST_6,SYSTEM_RST_SW : OUT STD_LOGIC; -- Various
		STG_MEM_SEL : OUT STD_LOGIC; -- 08D,04D,05B,06C
		USE_MAN_DECODER_PWR : OUT STD_LOGIC; -- 04C,05C,05B
		USE_MANUAL_DECODER : OUT STD_LOGIC; -- 04D,05B,04C,10C,07C,11C,05C
		ALLOW_MAN_OPERATION : OUT STD_LOGIC; -- 03C,04A
		MANUAL_DISPLAY : OUT STD_LOGIC; -- 06C,12C
		MAN_STOR_OR_DSPLY : OUT STD_LOGIC; -- 04D,04A,06B,07B
		MAN_STORE : OUT STD_LOGIC; -- 01C,06A,04B,06B,06C,01C,06A,04C
		MAN_STORE_PWR : OUT STD_LOGIC; -- 05C,08B,06C,07B
		STORE_S_REG_RST : OUT STD_LOGIC; -- 07B
		CPU_SET_ALLOW_WR_LCH : OUT STD_LOGIC; -- 06C
		MAN_RD_CALL : OUT STD_LOGIC; -- 05D,04D
		GT_MAN_SET_MN : OUT STD_LOGIC; -- 07B
		AUX_WRITE_CALL : OUT STD_LOGIC; -- 04B
		ALLOW_WRITE : OUT STD_LOGIC; -- 05D,04A,06C,07A,04D,12C
		ALLOW_WR_DLYD : OUT STD_LOGIC; -- 03A,04A,04D,12D,05D,03C,04B,06C,03B,04A
		MANUAL_OPERATION : OUT STD_LOGIC; -- 03C
		MAN_WRITE_CALL : OUT STD_LOGIC; -- 05D
		STORE_R : OUT STD_LOGIC; -- 06C
		        
		-- Clocks
		CONV_OSC : IN STD_LOGIC;
		T1,T2 : IN STD_LOGIC;
		Clk : IN STD_LOGIC -- 50MHz
		
	);
END ManualControls;

ARCHITECTURE FMD OF ManualControls IS 

signal AC1D4 : STD_LOGIC;
signal WRITE_ECHO,READ_ECHO : STD_LOGIC;
signal MAN_RD_INLK : STD_LOGIC;
signal MAN_RD_CALL_LCH : STD_LOGIC;
signal MAN_WR_CALL : STD_LOGIC;
signal MAN_WR_CALL_RST : STD_LOGIC;
signal sMACH_RST_SW,sMACH_RST_3,sSYSTEM_RST_SW : STD_LOGIC;
signal sSTG_MEM_SEL : STD_LOGIC;
signal sUSE_MANUAL_DECODER : STD_LOGIC;
signal sALLOW_MAN_OPERATION : STD_LOGIC;
signal sMANUAL_DISPLAY : STD_LOGIC;
signal sMAN_STOR_OR_DSPLY : STD_LOGIC;
signal sMAN_STORE,sMAN_STORE2 : STD_LOGIC;
signal sSTORE_S_REG_RST : STD_LOGIC;
signal sCPU_SET_ALLOW_WR_LCH : STD_LOGIC;
signal sMAN_RD_CALL : STD_LOGIC;
signal sALLOW_WRITE : STD_LOGIC;
signal sALLOW_WR : STD_LOGIC;
signal sSTORE_R : STD_LOGIC;
signal UMD_LCH_Set,UMD_LCH_Reset,MD_LCH_Set,MS_LCH_Set,AW_LCH_Set,AW_LCH_Reset,
		MW_LCH_Set,MW_LCH_Reset,MRC_LCH_Set,MRC_LCH_Reset,SR_LCH_Set,SR_LCH_Reset : STD_LOGIC;

BEGIN
-- Fig 5-03D
-- USE MAN DECODER
sSTG_MEM_SEL <= E_SW_SEL_MAIN_STG or E_SW_SEL_AUX_STG; -- AC1H3
STG_MEM_SEL <= sSTG_MEM_SEL;
sALLOW_MAN_OPERATION <= (not E_CY_STOP_SMPL and not SEL_CHNL_DATA_XFER and CLOCK_OFF); -- AC1C4,AC1G3 ?? Removed a NOT here
ALLOW_MAN_OPERATION <= sALLOW_MAN_OPERATION;
UMD_LCH_Set <= (sALLOW_MAN_OPERATION and SW_DSPLY) or (sALLOW_MAN_OPERATION and SW_STORE);
UMD_LCH_Reset <= E_CY_STOP_SMPL or sMACH_RST_3;
UMD_LCH: FLL port map(UMD_LCH_Set,UMD_LCH_Reset, sUSE_MANUAL_DECODER); -- AC1G4
USE_MANUAL_DECODER <= sUSE_MANUAL_DECODER;		
USE_MAN_DECODER_PWR <= not E_CY_STOP_SMPL and sUSE_MANUAL_DECODER; -- AC1J4

-- MAN DSPLY
AC1D4 <= (not E_CY_STOP_SMPL and not SEL_CHNL_DATA_XFER and CONV_OSC); -- AC1G2,AC1D4 -- Inverter removed ??
MD_LCH_Set <= CLOCK_OFF and SW_DSPLY and AC1D4;
MD_LCH: FLL port map(MD_LCH_Set,not SW_DSPLY,sMANUAL_DISPLAY); -- AC1G4 - FMD missing invert on Reset input ??
MANUAL_DISPLAY <= sMANUAL_DISPLAY;

-- MAN STORE R
sSTORE_S_REG_RST <= not CLOCK_ON and SW_STORE; -- AC1J6
STORE_S_REG_RST <= sSTORE_S_REG_RST;
MS_LCH_Set <= AC1D4 and sSTORE_S_REG_RST;
MS_LCH: FLL port map(MS_LCH_Set,not SW_STORE,sMAN_STORE); -- AC1E5
MAN_STORE <= sMAN_STORE;
-- MAN_STORE_PWR <= sMAN_STORE; -- AC1F3 -- Need to delay this a bit
MAN_STORE_DELAY: AR port map(sMAN_STORE,Clk,sMAN_STORE2); -- AC1F3
MAN_STORE2_DELAY: AR port map(sMAN_STORE2,Clk,MAN_STORE_PWR); -- AC1F3
sMAN_STOR_OR_DSPLY <= sMANUAL_DISPLAY or sMAN_STORE; -- AC1J2,AC1F3
MAN_STOR_OR_DSPLY <= sMAN_STOR_OR_DSPLY;

-- SYS RST
sSYSTEM_RST_SW <= SW_SYS_RST;
SYSTEM_RST_SW <= sSYSTEM_RST_SW;
sMACH_RST_SW <= SW_SYS_RST or POWER_ON_RESET or LOAD_KEY_SW;
MACH_RST_SW <= sMACH_RST_SW;
sMACH_RST_3 <= sMACH_RST_SW;
MACH_RST_1 <= sMACH_RST_3;
MACH_RST_3 <= sMACH_RST_3;
MACH_RST_4 <= sMACH_RST_3;
MACH_RST_5 <= sMACH_RST_3;
MACH_RST_6 <= sMACH_RST_3;

WRITE_ECHO <= WRITE_ECHO_1 or WRITE_ECHO_2; -- AA1J4
READ_ECHO <= READ_ECHO_1 or READ_ECHO_2; -- AA1K4

MAN_WR_CALL_RST <= WRITE_ECHO or sMACH_RST_3; -- AC1H3

sCPU_SET_ALLOW_WR_LCH <= (sMAN_STOR_OR_DSPLY and READ_ECHO) or (CPU_READ_PWR and T2); -- AA1K4  Wire-OR of negated signals
CPU_SET_ALLOW_WR_LCH <= sCPU_SET_ALLOW_WR_LCH;

-- ALLOW WR
AW_LCH_Set <= sCPU_SET_ALLOW_WR_LCH or SEL_AUX_RD_CALL;
AW_LCH_Reset <= sMACH_RST_3 or SEL_WR_CALL or MAN_WR_CALL or (ROAR_RESTT_STOR_BYPASS and RECYCLE_RST) or (CPU_WR_PWR and T2);
ALLOW_WRITE_LCH: FLL port map(AW_LCH_Set,AW_LCH_Reset,sALLOW_WRITE); -- AA1J2,AA1F6,AA1H3
ALLOW_WRITE <= sALLOW_WRITE;	
DELAY_ALLOW_WR : entity AR port map (D=>sALLOW_WRITE,clk=>Clk,Q=>sALLOW_WR); -- AA1H2,AA1J7
ALLOW_WR_DLYD <= sALLOW_WR;

-- MAN WR CALL
MW_LCH_Set <= (sALLOW_WR and LOAD_KEY_INLK) or (sALLOW_WR and sSYSTEM_RST_SW) or (sALLOW_WR and POWER_OFF_SW) or (sMAN_STOR_OR_DSPLY and READ_ECHO);
MW_LCH_Reset <= CLOCK_ON or MAN_WR_CALL_RST;
MW_LCH: FLL port map(MW_LCH_Set,MW_LCH_Reset,MAN_WR_CALL); -- AC1J2,AC1F4,AC1H5

-- MAN RD INLK
MAN_RD_INLK_FL: FLL port map(MAN_RD_CALL_LCH,not sMAN_STOR_OR_DSPLY,MAN_RD_INLK); -- AC1F4
-- MAN RD CALL
MRC_LCH_Set <= sSTG_MEM_SEL and not MAN_RD_INLK and sMAN_STOR_OR_DSPLY;
MRC_LCH_Reset <= not sMAN_STOR_OR_DSPLY or READ_ECHO;
MAN_RD_CALL_FL: FLL port map(MRC_LCH_Set,MRC_LCH_Reset,MAN_RD_CALL_LCH); -- AC1J2,AC1E2
sMAN_RD_CALL <= MAN_RD_CALL_LCH and not sALLOW_WR; -- AC1J2
MAN_RD_CALL <= sMAN_RD_CALL;

GT_MAN_SET_MN <= (MAN_RD_CALL_LCH and sUSE_MANUAL_DECODER and not sALLOW_WR) or
	(sMANUAL_DISPLAY and IJ_SEL_SW and not sALLOW_WR) or
	(sMANUAL_DISPLAY and UV_SEL_SW and not sALLOW_WR)
	or MAN_DSPLY_GUV_HUV; -- AC1H4,AC1G3

AUX_WRITE_CALL <= (CPU_WR_PWR and T2) or SEL_AUX_WR_CALL; -- AA1K4,AA1C3

MANUAL_OPERATION <= sMAN_RD_CALL or MAN_WR_CALL or MAN_WR_CALL_RST or READ_ECHO;

-- STORE R
SR_LCH_Set <= MAN_WR_CALL or (T1 and USE_R);
SR_LCH_Reset <= SEL_T1 or (T1 and not CU_SALS(0) and CU_SALS(1));
SR_LCH: FLL port map(SR_LCH_Set,SR_LCH_Reset,sSTORE_R); -- 06C
STORE_R <= sSTORE_R;
MAN_WRITE_CALL <= not READ_ECHO and MAN_WR_CALL and sSTORE_R; -- AC1G3

END FMD; 
