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
--    File: FMD2030_5-08B.vhd
--    Creation Date: 21:55:54 27/01/2010
--    Description:
--    Q Register and Storage Protection
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Gates_package.all;

entity QReg_STP is
    Port (
			-- Inputs
			SA_REG : in  STD_LOGIC_VECTOR (0 to 7);		-- Stack address, F0-FF are MS storage keys, 00-EF are CCW storage keys
			Z_BUS : in  STD_LOGIC_VECTOR (0 to 8);			-- Z bus used to write to Q reg
			SX1_SHARE_CYCLE, SX2_SHARE_CYCLE : in  STD_LOGIC; -- Selector channel cycle inputs
			N_SEL_SHARE_HOLD : in  STD_LOGIC;				-- Selector channel share cycle
			MAIN_STG : in  STD_LOGIC;							-- Main Storage usage
			H_REG_5_PWR : in  STD_LOGIC;						-- Priority Reg from 04C
			FORCE_M_REG_123 : in  STD_LOGIC;					-- When setting M reg for LS, from 04D
			GT_LOCAL_STORAGE : in  STD_LOGIC;				-- Local Storage usage
			GT_T_REG_TO_MN, GT_CK_TO_MN : in  STD_LOGIC; -- These operations inhibit storage protect when used with LS
			MAIN_STG_CP_1 : in  STD_LOGIC;					-- Main Storage clock pulse
			N_MEM_SELECT : in  STD_LOGIC;
			N_STACK_MEMORY_SELECT : in  STD_LOGIC;			-- Indicates that Stack memory should be read/written
			STACK_RD_WR_CONTROL : in  STD_LOGIC;			-- T to indicate Stack is being Read, F to indicate Write
			E_SW_SEL_Q : in  STD_LOGIC;						-- E switch Q Reg selection
			MAN_STORE_PWR : in  STD_LOGIC;					-- Manual Store switch for setting Q Reg
			T4 : in  STD_LOGIC;									-- Main clock phase
			MACH_RST_2B : in  STD_LOGIC;						-- Main system reset
			Z_BUS_LO_DIG_PARITY : in  STD_LOGIC;			-- Parity of Z bus bits 4-7
			CD_REG : in  STD_LOGIC_VECTOR (0 to 3);		-- ALU destination - 0011 specifies Q Reg
			CLOCK_OFF : in  STD_LOGIC;							-- CPU clock stop
			GK, HK : in  STD_LOGIC_VECTOR (0 to 3);		-- Storage key from SX1, SX2
			CLK : in STD_LOGIC;									-- 50MHz FPGA clock
			-- Outputs
			Q_REG_BUS : out  STD_LOGIC_VECTOR (0 to 8);	-- Q Reg output
			SEL_CPU_BUMP : out  STD_LOGIC;					-- Select usage of Aux Storage
			STACK_PC : out  STD_LOGIC;							-- Stack data Parity Check error
			MPX_CP : out  STD_LOGIC;							-- MPX clock pulse
			MAIN_STG_CP : out  STD_LOGIC;						-- MS clock pulse
			PROTECT_LOC_CPU_OR_MPX : out  STD_LOGIC;		-- Storage Protection check from CPU or MPX
			PROTECT_LOC_SEL_CHNL : out  STD_LOGIC			-- Storage Protection check from SX1 or SX2
			);
end QReg_STP;

architecture FMD of QReg_STP is
signal	Q_REG : STD_LOGIC_VECTOR(0 to 8);
signal	INH_STG_PROT : STD_LOGIC;
signal	sSTACK_PC : STD_LOGIC;
signal	UseQ : STD_LOGIC;
signal	SET_Q_HI, SET_Q_LO : STD_LOGIC;
subtype	stackData is STD_LOGIC_VECTOR(4 to 8);
type	stack is array(0 to 255) of stackData;
signal	STP_STACK : stack;
signal	STACK_DATA : stackData;
signal	Q0_GK0_HK0, Q1_GK1_HK1, Q2_GK2_HK2, Q3_GK3_HK3 : STD_LOGIC;
signal	STP : STD_LOGIC;
signal	HDWR_STG_KEYS_MAT : STD_LOGIC;
signal	CD0011 : STD_LOGIC;
signal	STACK_DATA_STROBE, READ_GATE, WRITE_GATE, INHIBIT_TIMING : STD_LOGIC;
type		delay is array(0 to 24) of std_logic;
signal	delayLine : delay := (others=>'0');
signal	setLatch, resetLatch : std_logic;
signal	latch : std_logic;
signal	INH_STG_PROT_PH_D : std_logic;
signal	Q47P_D : std_logic_vector(4 to 8);
begin
Q0_GK0_HK0 <= (HK(0) and SX2_SHARE_CYCLE) or (GK(0) and SX1_SHARE_CYCLE) or (Q_REG(0) and N_SEL_SHARE_HOLD); -- BE3E4 BE3F3
Q1_GK1_HK1 <= (HK(1) and SX2_SHARE_CYCLE) or (GK(1) and SX1_SHARE_CYCLE) or (Q_REG(1) and N_SEL_SHARE_HOLD); -- BE3E4 BE3F3
Q2_GK2_HK2 <= (HK(2) and SX2_SHARE_CYCLE) or (GK(2) and SX1_SHARE_CYCLE) or (Q_REG(2) and N_SEL_SHARE_HOLD); -- BE3E4 BE3F3
Q3_GK3_HK3 <= (HK(3) and SX2_SHARE_CYCLE) or (GK(3) and SX1_SHARE_CYCLE) or (Q_REG(3) and N_SEL_SHARE_HOLD); -- BE3E4 BE3F3
STP <= not INH_STG_PROT and MAIN_STG and (Q0_GK0_HK0 or Q1_GK1_HK1 or Q2_GK2_HK2 or Q3_GK3_HK3); -- BE3F4
HDWR_STG_KEYS_MAT <= (Q0_GK0_HK0 xnor Q_REG(0)) and (Q1_GK1_HK1 xnor Q_REG(1)) and (Q2_GK2_HK2 xnor Q_REG(2)) and (Q3_GK3_HK3 xnor Q_REG(3)); -- BE3F3
PROTECT_LOC_CPU_OR_MPX <= (not H_REG_5_PWR) and STP and (sSTACK_PC or not HDWR_STG_KEYS_MAT); -- BE3F2
PROTECT_LOC_SEL_CHNL <= STP and (sSTACK_PC or not HDWR_STG_KEYS_MAT); -- BE3F2

INH_STG_PROT_PH_D <= GT_T_REG_TO_MN or GT_CK_TO_MN;
INH_STG_PROT_PH: PH port map(INH_STG_PROT_PH_D,GT_LOCAL_STORAGE,clk,INH_STG_PROT); -- AA1F4
SEL_CPU_BUMP_PH: PH port map(FORCE_M_REG_123,GT_LOCAL_STORAGE,clk,SEL_CPU_BUMP); -- AA1F4

STACK_PC <= sSTACK_PC;
MPX_CP <= not MAIN_STG_CP_1; -- BE3D3 BE3G4
MAIN_STG_CP <= MAIN_STG_CP_1; -- BE3G4

CD0011 <= '1' when CD_REG="0011" else '0';
UseQ <= (CD0011 and (N_SEL_SHARE_HOLD or (not CLOCK_OFF))) or (CLOCK_OFF and N_MEM_SELECT and N_SEL_SHARE_HOLD); -- BE3J3 BE3G4 BE3J3
SET_Q_HI <= MACH_RST_2B or (MAN_STORE_PWR and E_SW_SEL_Q)  or (T4 and UseQ); -- BE3J4
SET_Q_LO <= MACH_RST_2B or (MAN_STORE_PWR and E_SW_SEL_Q)  or (T4 and UseQ) or (STACK_RD_WR_CONTROL and STACK_DATA_STROBE); -- BE3J4
Q03: PHV4 port map(Z_BUS(0 to 3),SET_Q_HI,clk,Q_REG(0 to 3)); -- BE3H2
Q47P_D <= ((Z_BUS(4 to 7) & Z_BUS_LO_DIG_PARITY) and (4 to 8 => UseQ)) or (STACK_DATA(4 to 8) and not (4 to 8 => UseQ));
Q47P: PHV5 port map(Q47P_D, SET_Q_LO, clk, Q_REG(4 to 8));
Q_REG_BUS <= Q_REG;
sSTACK_PC <= EvenParity(Q_REG(4 to 7));

STP_FL: process(clk)
begin
	if rising_edge(clk) then
		setLatch <= not N_STACK_MEMORY_SELECT;
		delayLine <= setLatch & delayLine(0 to 23);
		STACK_DATA_STROBE <= delayLine(7); -- 140ns
		resetLatch <= not delayLine(24);
		if (setLatch='1') then latch <= '1'; end if;
		if (resetLatch='1') then latch <= '0'; end if;
		READ_GATE <= latch and STACK_RD_WR_CONTROL;
		WRITE_GATE <= latch and not STACK_RD_WR_CONTROL;
		INHIBIT_TIMING <= latch and not READ_GATE;
		if WRITE_GATE='1' then
			STP_STACK(Conv_Integer(SA_REG)) <= Q_REG(4 to 8);
		elsif READ_GATE='1' then
			STACK_DATA <= STP_STACK(Conv_Integer(SA_REG));
		end if;
	end if;
end process;


end FMD;

