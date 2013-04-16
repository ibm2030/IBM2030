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
--    File: FMD2030_5-03B.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Storage Wrap (references >8k, >16k, >32k or wrapping over 64k)
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
--		Reset UMPX latch on RECYCLE_RST
--		Change to 64k wrap
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY StorageWrap IS
	port
	(
      -- Inputs        
      SALS : IN SALS_Bus;
		CTRL : IN CTRL_REG;
		ANY_PRIORITY_PULSE_2 : IN STD_LOGIC; -- 03A
		H_REG_5_PWR,H_REG_6 : IN STD_LOGIC; -- 04C
		NTRUE : IN STD_LOGIC; -- 06B
		CARRY_0 : IN STD_LOGIC; -- 06B
		COMPLEMENT : IN STD_LOGIC; -- 06B
		GT_J_TO_N_REG,GT_V_TO_N_REG : IN STD_LOGIC; -- 05B
		M012 : IN STD_LOGIC_VECTOR(0 to 2); -- 07B
		RECYCLE_RST : IN STD_LOGIC; -- 04A
		ALLOW_WRITE : IN STD_LOGIC; -- 03D
		READ_CALL : IN STD_LOGIC; -- 05D
		MAIN_STORAGE : IN STD_LOGIC; -- 04D
		DATA_READY_1,DATA_READY_2 : IN STD_LOGIC; -- 05D
		        
		-- Outputs
		GT_CK_DECO : OUT STD_LOGIC; -- 03C,04C
		SEL_DATA_READY : OUT STD_LOGIC; -- 11C,13C,06C
		MEM_WRAP_REQ : OUT STD_LOGIC; -- 03A
		MEM_WRAP : OUT STD_LOGIC; -- 06C,11A,13A
		I_WRAPPED_CPU,U_WRAPPED_MPX : OUT STD_LOGIC; -- 02A
        
		-- Clocks
		T1,T2,T4 : IN STD_LOGIC;
		P1 : IN STD_LOGIC;
		CLK : IN STD_LOGIC
	);
END StorageWrap;

ARCHITECTURE FMD OF StorageWrap IS 

signal RESTORE_WRAP,STORE_WRAP : STD_LOGIC;
signal U_WRAP_CPU,WRAP_BUFF : STD_LOGIC; -- PH outputs
signal NOT_MPX_OR_SEL,ALL_B_GATED,DEST_U,DEST_I_OR_RESTORE,CARRY_OUT_TRUE,CARRY_OUT_COMP,WRAP_TRUE,RESET_WRAP,CHECK_U_WRAP,CHECK_I_WRAP,CHECK_MPX_WRAP,CARRY_OUT : STD_LOGIC;
signal WRAP64 : STD_LOGIC;
signal sGT_CK_DECO : STD_LOGIC;
signal sMEM_WRAP_REQ : STD_LOGIC;
signal sMEM_WRAP : STD_LOGIC;
signal sI_WRAPPED_CPU, sU_WRAPPED_MPX : STD_LOGIC;
signal UWRAP_LCH_Reset,MWR_LCH_Set,MWR_LCH_Reset : STD_LOGIC;

BEGIN
-- Fig 5-03B
sGT_CK_DECO <= not ANY_PRIORITY_PULSE_2 and SALS.SALS_AK and P1; -- AB3B3,AB3F6 ??
GT_CK_DECO <= sGT_CK_DECO;
RESTORE_WRAP <= '1' when SALS.SALS_AK='1' and SALS.SALS_CK="0010" else '0'; -- AB3E6
STORE_WRAP <= '1' when not (sGT_CK_DECO='1' and SALS.SALS_CK="1100") else '0'; -- AB3E6,AB3L6

-- The Wrap latches remember whether a carry was associated with values stored in the U or I registers
-- If so that means we wrapped around from 64k to 0.  The Wrap latches are only used if the UV/IJ value is
-- subsequently moved into MN
NOT_MPX_OR_SEL <= not(H_REG_5_PWR or H_REG_6); -- AB2L4
-- "ALL_B_GATED" means reset U wrap ??
-- "not ALL_B_GATED" means check U wrap ??
-- The FMD doesn't seem to show this way around, but microcode (e.g. QA781:C3) implies it
ALL_B_GATED <= not (not CTRL.GT_B_REG_HI or not CTRL.GT_B_REG_LO); -- AB2M3
DEST_U <= '1' when CTRL.CTRL_CD="1101" and T4='1' else '0'; -- AB2M3
DEST_I_OR_RESTORE <= '1' when (T4='1' and CTRL.CTRL_CD="1111") or (T1='1' and RESTORE_WRAP='1') else '0'; -- AB2M2 AB2M5
CARRY_OUT_TRUE <= not RESTORE_WRAP and NTRUE and CARRY_0; -- AB2M3 AB2L3
CARRY_OUT_COMP <= COMPLEMENT and not CARRY_0; -- AB2M3
WRAP_TRUE <= CARRY_OUT_TRUE or (RESTORE_WRAP and WRAP_BUFF); -- AB2L3
RESET_WRAP <= NOT_MPX_OR_SEL and ALL_B_GATED and DEST_U; -- AB2M3
CHECK_U_WRAP <= NOT_MPX_OR_SEL and DEST_U and not ALL_B_GATED; -- AB2L4
CHECK_I_WRAP <= NOT_MPX_OR_SEL and DEST_I_OR_RESTORE; -- AB2L4
CHECK_MPX_WRAP <= H_REG_6 and not H_REG_5_PWR; -- AB2L4
CARRY_OUT <= CARRY_OUT_TRUE or CARRY_OUT_COMP; -- AB2L3

UWRAP_LCH_Reset <= RECYCLE_RST or RESET_WRAP;
UWRAP_LCH: PHR port map(D=>WRAP_TRUE,L=>CHECK_U_WRAP,R=>UWRAP_LCH_Reset,Q=>U_WRAP_CPU); -- AB2M4
IWRAP_LCH: PHR port map(D=>WRAP_TRUE,L=>CHECK_I_WRAP,R=>RECYCLE_RST,Q=>sI_WRAPPED_CPU); -- AB2M4
I_WRAPPED_CPU <= sI_WRAPPED_CPU;
UMPX_LCH: PHR port map(D=>CARRY_OUT,L=>CHECK_MPX_WRAP,R=>RECYCLE_RST,Q=>sU_WRAPPED_MPX); -- AB2M4 ?? Doesn't have reset in FMD - causes Diag failure
U_WRAPPED_MPX <= sU_WRAPPED_MPX;
WBUFF_LCH: PH port map(D=>sI_WRAPPED_CPU,L=>STORE_WRAP,Q=>WRAP_BUFF); -- AB2M4 ?? *not* sI_WRAPPED_CPU ??

WRAP64 <= (not H_REG_6 and GT_V_TO_N_REG and U_WRAP_CPU) or
	(GT_J_TO_N_REG and not H_REG_6 and sI_WRAPPED_CPU) or
	(GT_V_TO_N_REG and H_REG_6 and sU_WRAPPED_MPX);

-- Select the appropriate wrap condition based on storage size:
-- sMEM_WRAP <= M012(0) or M012(1) or M012(2); -- 8k
-- sMEM_WRAP <= M012(0) or M012(1); -- 16k
-- sMEM_WRAP <= M012(0); -- 32k
sMEM_WRAP <= WRAP64; -- 64k
MEM_WRAP <= sMEM_WRAP;

MWR_LCH_Set <= MAIN_STORAGE and T2 and (sMEM_WRAP and not ALLOW_WRITE);	-- ?? ALLOW_WRITE use unclear - dot logic
MWR_LCH_Reset <= READ_CALL or RECYCLE_RST;
MWR_LCH: FLL port map(MWR_LCH_Set,MWR_LCH_Reset,sMEM_WRAP_REQ);
MEM_WRAP_REQ <= sMEM_WRAP_REQ;
SEL_DATA_READY <= (DATA_READY_1 or DATA_READY_2) and not sMEM_WRAP_REQ;

END FMD; 
