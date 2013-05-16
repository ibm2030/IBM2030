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
--    File: FMD2030_5-02A-B.vhd
--    Creation Date: 
--    Description:
--    X6,X7 assembly, ASCII latch, X6,X7 backup (5-02A), WX reg gating (5-02B)
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-09
--    Initial Release
--    Revision 1.1 2012-04-07
--		Enable MPX interruptions
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY X6X7 IS 
	port
	(
			SALS : IN SALS_Bus; -- 01C
			DECIMAL : IN STD_LOGIC; -- 06B
			CONNECT : IN STD_LOGIC; -- 06B
			N_CTRL_LM : IN STD_LOGIC; -- 06B
			CTRL_N : IN STD_LOGIC;  -- 06B
			R_REG_0_BIT : IN STD_LOGIC; -- 06C
			V67_00_OR_GM_WM : IN STD_LOGIC; -- 05A
			STATUS_IN_LCHD : IN STD_LOGIC;  -- 06A
			OPNL_IN_LCHD : IN STD_LOGIC;    -- 06A
			CARRY_0_LCHD : IN STD_LOGIC;    -- 06A
			S_REG_1_OR_R_REG_2 : IN STD_LOGIC;  -- 05A
			S : IN STD_LOGIC_VECTOR(0 to 7);    -- 07B
			G : IN STD_LOGIC_VECTOR(0 to 7);    -- 05C
			TIMER_UPDATE : IN STD_LOGIC;    -- 04C
			EXTERNAL_INT : IN STD_LOGIC;    -- 04C
			MPX_INTERRUPT : IN STD_LOGIC;   -- 08C
			SX1_INTERRUPT : IN STD_LOGIC;   -- 12D
			SX2_INTERRUPT : IN STD_LOGIC;   -- 14D
--			HSMPX : IN STD_LOGIC;   -- XXXXX
			I_WRAPPED_CPU : IN STD_LOGIC;   -- 03B
			TIMER_UPDATE_OR_EXT_INT : IN STD_LOGIC; -- 04C
			U_WRAPPED_MPX : IN STD_LOGIC;   -- 03B
			H_REG_6_BIT : IN STD_LOGIC; -- 04C
			ADDR_IN_LCHD : IN STD_LOGIC;    -- 06A
			SERV_IN_LCHD : IN STD_LOGIC;    -- 06A
			R_REG_VAL_DEC_DIG : IN STD_LOGIC;   -- 05A
			N1BC_OR_R1 : IN STD_LOGIC;  -- 05A
			Z_BUS_0 : IN STD_LOGIC; -- 06B
			G_REG_1_OR_R_REG_3 : IN STD_LOGIC;  -- 05A
			GT_BU_ROSAR_TO_WX_REG : IN STD_LOGIC;   -- 01B
			H_REG_5_PWR : IN STD_LOGIC; -- 04C
			MPX_SHARE_PULSE : IN STD_LOGIC; -- 03A
			SX_CHAIN_PULSE : IN STD_LOGIC;  -- 03A
			MACH_RST_SW : IN STD_LOGIC; -- 03D
			R_REG_4_BIT : IN STD_LOGIC; -- 06C
			ANY_PRIORITY_PULSE : IN STD_LOGIC; -- 03A
        
			-- Outputs
			XOR_OR_OR : OUT STD_LOGIC;    -- 03A,04A
			INTERRUPT : OUT STD_LOGIC;   -- 01B
			GT_GWX_TO_WX_REG : OUT STD_LOGIC;    -- 01B
			GT_FWX_TO_WX_REG : OUT STD_LOGIC;    -- 01B
			USE_CA_BASIC_DECODER : OUT STD_LOGIC;    -- 02B,01A,03C,04C,05C,07A,07C,10C
			MPX_ROS_LCH : OUT STD_LOGIC; -- 08C
			X6 : OUT STD_LOGIC;
			X7 : OUT STD_LOGIC;
			USE_ALT_CA_DECODER : OUT STD_LOGIC; -- 07C,04C,10C,07A,11C
			GT_CA_TO_W_REG : OUT STD_LOGIC; -- 01B,07A
			GT_UV_TO_WX_REG : OUT STD_LOGIC; -- 01B
			DIAG_LATCH_RST : OUT STD_LOGIC; -- NEW
			-- Debug
			DEBUG : OUT STD_LOGIC;
		  
			-- Clocks
			T1,T2,T3,T4 : IN STD_LOGIC;
			clk : IN STD_LOGIC
	);
END X6X7;

ARCHITECTURE FMD OF X6X7 IS 

signal  TEST_ASCII : STD_LOGIC;
signal  TEST_INTRP : STD_LOGIC;
signal  TEST_WRAP : STD_LOGIC;
signal  GT_ASCII_LCH : STD_LOGIC;
signal  GT_MPX_LCH : STD_LOGIC; -- Output of AA3E3
signal  GT_SX_LCH : STD_LOGIC; -- Output of AA3L6
signal  X6_MUX,X7_MUX : STD_LOGIC;
signal  CA_TO_X7_DECO : STD_LOGIC;
signal  X6_BRANCH,X7_BRANCH : STD_LOGIC;
signal  SX_CH_ROAR_RESTORE : STD_LOGIC;
signal  MPX_CH_ROAR_RESTORE : STD_LOGIC;
signal  RESTORE_0 : STD_LOGIC; -- Output of AA3K5,FL0

signal  ASCII_LCH : STD_LOGIC;
signal  MPX_CH_X6,MPX_CH_X7 : STD_LOGIC;
signal  SX_CH_X6,SX_CH_X7 : STD_LOGIC;
signal  X6_DATA,X7_DATA : STD_LOGIC;
signal  STORED_X6,STORED_X7 : STD_LOGIC;
signal  sXOR_OR_OR : STD_LOGIC;
signal  sINTERRUPT : STD_LOGIC;
signal  sGT_GWX_TO_WX_REG : STD_LOGIC;
signal  sGT_FWX_TO_WX_REG : STD_LOGIC;
signal  sUSE_CA_BASIC_DECODER : STD_LOGIC;
signal  sMPX_ROS_LCH : STD_LOGIC;

signal	REST0_LCH_Set,REST0_LCH_Reset,SXREST_LCH_Set,SXREST_LCH_Reset,
			MPXROS_LCH_Reset,MPXROS_LCH_Set,MPXREST_LCH_Set,MPXREST_LCH_Reset : STD_LOGIC;
BEGIN
-- Fig 5-02A
TEST_ASCII <= '1' when SALS.SALS_CK="1001" and SALS.SALS_AK='1' else '0'; -- AB3E7
TEST_INTRP <= '1' when SALS.SALS_CK="1010" and SALS.SALS_AK='1' else '0'; -- AB3E7
TEST_WRAP <= '1' when SALS.SALS_CK="0011" and SALS.SALS_AK='1' else '0'; -- AB3E6
DIAG_LATCH_RST <= '1' when SALS.SALS_CK="0000" and SALS.SALS_AK='1' and T1='1' else '0'; -- NEW!

sXOR_OR_OR <= DECIMAL and CONNECT and N_CTRL_LM; -- AB3D2
XOR_OR_OR <= sXOR_OR_OR;
GT_ASCII_LCH <= sXOR_OR_OR and CTRL_N and T2; -- AB3D2
DEBUG <= ASCII_LCH;

-- ?? Debug remove other interrupt sources
-- sINTERRUPT <= TIMER_UPDATE or EXTERNAL_INT or MPX_INTERRUPT or SX1_INTERRUPT or SX2_INTERRUPT; -- AA3K4
sINTERRUPT <= EXTERNAL_INT or MPX_INTERRUPT;
INTERRUPT <= sINTERRUPT;


with (SALS.SALS_CH) select X6_MUX <= -- AA3G5
    '1' when "0001",
    R_REG_0_BIT when "0010",
    V67_00_OR_GM_WM when "0011",
    STATUS_IN_LCHD when "0100",
    OPNL_IN_LCHD when "0101",
    CARRY_0_LCHD when "0110",
    S(0) when "0111",
    S_REG_1_OR_R_REG_2 when "1000",
    S(2) when "1001",
    S(4) when "1010",
    S(6) when "1011",
    G(0) when "1100",
    G(2) when "1101",
    G(4) when "1110",
    G(6) when "1111",
    '0' when others; -- 0000

with (SALS.SALS_CL) select X7_MUX <= -- AA3H5
    '1' when "0001",
    '1' when "0010", -- CL=0010 is CA>W ?? Needed otherwise CA>W always forces X7 to 0 ??
    ADDR_IN_LCHD when "0011",
    SERV_IN_LCHD when "0100",
    R_REG_VAL_DEC_DIG when "0101",
    N1BC_OR_R1 when "0110",
    Z_BUS_0 when "0111",
    G(7) when "1000",
    S(3) when "1001",
    S(5) when "1010",
    S(7) when "1011",
    G_REG_1_OR_R_REG_3 when "1100",
    G(3) when "1101",
    G(5) when "1110",
    sINTERRUPT when "1111",
    '0' when others; -- 0000


X6_BRANCH <= (not ASCII_LCH or not TEST_ASCII) and -- AA3K3
    (not TIMER_UPDATE_OR_EXT_INT or not TEST_INTRP) and -- AA3K3
    (not SX2_INTERRUPT or SX1_INTERRUPT or not TEST_INTRP) and -- AA3K4
    (not I_WRAPPED_CPU or not TEST_WRAP) and -- AA3K3
    X6_MUX;

X7_BRANCH <= (not TIMER_UPDATE_OR_EXT_INT or not TEST_INTRP) and -- AA3K3
    (not SX1_INTERRUPT or not TEST_INTRP) and -- AA3B7
    (not TEST_WRAP or not U_WRAPPED_MPX or not H_REG_6_BIT) and -- AA3J5
    X7_MUX ;
--	 and CA_TO_X7_DECO; ?? Removed as it forced X7 to 0 on CA>W ??

sGT_GWX_TO_WX_REG <= GT_BU_ROSAR_TO_WX_REG and H_REG_5_PWR; -- AA3L5
GT_GWX_TO_WX_REG <= sGT_GWX_TO_WX_REG;
sGT_FWX_TO_WX_REG <= GT_BU_ROSAR_TO_WX_REG and not H_REG_5_PWR; -- AA3C2
GT_FWX_TO_WX_REG <= sGT_FWX_TO_WX_REG;

sUSE_CA_BASIC_DECODER <= not SALS.SALS_AA;
USE_CA_BASIC_DECODER <= sUSE_CA_BASIC_DECODER;

REST0_LCH_Set <= T2 and sGT_GWX_TO_WX_REG;
REST0_LCH_Reset <= MACH_RST_SW or T1;
REST0_LCH: FLSRC port map(REST0_LCH_Set,REST0_LCH_Reset,clk,RESTORE_0); -- AA3K5 Bit 0
SXREST_LCH_Set <= T4 and RESTORE_0;
SXREST_LCH_Reset <= MACH_RST_SW or T3;
SXREST_LCH: FLSRC port map(SXREST_LCH_Set,SXREST_LCH_Reset,clk,SX_CH_ROAR_RESTORE); -- AA3K5 Bit 1
MPXROS_LCH_Set <= T2 and sGT_FWX_TO_WX_REG;
MPXROS_LCH_Reset <= MACH_RST_SW or T1;
MPXROS_LCH: FLSRC port map(MPXROS_LCH_Set,MPXROS_LCH_Reset,clk,sMPX_ROS_LCH); -- AA3L2 Bit 2
MPX_ROS_LCH <= sMPX_ROS_LCH;
MPXREST_LCH_Set <= T4 and sMPX_ROS_LCH;
MPXREST_LCH_Reset <= MACH_RST_SW or T3;
MPXREST_LCH: FLSRC port map(MPXREST_LCH_Set,MPXREST_LCH_Reset,clk,MPX_CH_ROAR_RESTORE); -- AA3L2 Bit 3

X6_DATA <= X6_BRANCH and not SX_CH_ROAR_RESTORE and not MPX_CH_ROAR_RESTORE; -- AA3L6
X7_DATA <= X7_BRANCH and not SX_CH_ROAR_RESTORE and not MPX_CH_ROAR_RESTORE; -- AA3L6

GT_MPX_LCH <= (MPX_SHARE_PULSE and T1) or MACH_RST_SW; -- AA3L4,AA3E3
GT_SX_LCH <= (SX_CHAIN_PULSE and T1) or MACH_RST_SW; -- AA3F3,AA3L6

-- ASCII latch plus X6,X7 storage for 
ASC_LCH: PH port map(R_REG_4_BIT,GT_ASCII_LCH,clk,ASCII_LCH); -- AA3L3
M7_LCH: PH port map(X7_DATA,GT_MPX_LCH,clk,MPX_CH_X7); -- AA3L3
S7_LCH: PH port map(X7_DATA,GT_SX_LCH,clk,SX_CH_X7); -- AA3L3
M6_LCH: PH port map(X6_DATA,GT_MPX_LCH,clk,MPX_CH_X6); -- AA3L3
S6_LCH: PH port map(X6_DATA,GT_SX_LCH,clk,SX_CH_X6); -- AA3L3

STORED_X6 <= (SX_CH_ROAR_RESTORE and SX_CH_X6) or (MPX_CH_ROAR_RESTORE and MPX_CH_X6); -- AA3K6
STORED_X7 <= (SX_CH_ROAR_RESTORE and SX_CH_X7) or (MPX_CH_ROAR_RESTORE and MPX_CH_X7); -- AA3K6

X6 <= X6_DATA or STORED_X6; -- Wire-AND of negated signals
X7 <= X7_DATA or STORED_X7; -- Wire-AND of negated signals

-- Page 5-02B
USE_ALT_CA_DECODER <= not sUSE_CA_BASIC_DECODER and not ANY_PRIORITY_PULSE; -- AB2F7 ??
CA_TO_X7_DECO <= '0' when SALS.SALS_CL="0010" else '1'; -- AA3H5
GT_CA_TO_W_REG <= not CA_TO_X7_DECO and not ANY_PRIORITY_PULSE; -- AA3L4,AA3G4
GT_UV_TO_WX_REG <= '1' when SALS.SALS_CK="0001" and SALS.SALS_AK='1' and ANY_PRIORITY_PULSE='0' else '0'; -- AB3E6,AB3B3

END FMD; 

