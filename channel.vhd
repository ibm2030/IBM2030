---------------------------------------------------------------------------
--    Copyright (c) 2013 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: channel.vhd
--    Creation Date: 2013-03-25
--    Description:
--    Generic S/360 Channel interface
--
--    Revision History:
--    Revision 1.0 2013-03-25
--    Initial Release
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
library work;
use work.Gates_package.all;
use work.Buses_package.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- The channel data is transferred via an SPI link
-- The CPU end (this end) is the master and repeatedly polls the slave (device) end
-- At a 8.3MHz clock rate, this updates about every 2us
-- Each transfer is 16 bits as follows (MSB to LSB)
-- CPU to Device
-- 15		Operational Out
-- 14		Suppress Out
-- 13		Clock Out
-- 12		Select Out
-- 11		Hold Out
-- 10		Address Out \
--  9		Command Out  \
--  8		Service Out   \ At most one of these 3 can be active
--  7 - 0 Data Out
--
-- Device to CPU
-- 15		Operational In
-- 14		Request In
-- 13		
-- 12		Select In
-- 11		
-- 10		Address In \
--  9		Status In   \
--  8		Service In   \ At most one of these 3 can be active
--  7 - 0 Data In

-- CCW opcodes:
-- 	DASD
--    02 = Read IPL (CC=00,Hh=00, Read R1 Data)
--		03 = NOP
--    13 = Restore
--    ?? = Recalibrate
--    07 = Seek BBCCHH
--    0B = Seek xxCCHH
--    1B = Seek xxxxHH
--    1A = Read Head Address (*)
--    12 = Read Count (*)
--    16 = Read R0 (*)
--    06 = Read Data (*)
--    0E = Read Key & Data (*)
--    1E = Read Count, Key & Data (*)
-- (*) = Can add x'80' for multi-track
--
-- Initially all Seeks are ignored, and all Reads read the SD card from the start (Adr=0)
-- Initially all Reads return incrementing values starting with 00
--

-- Fig numbers like 2-34a refer to the 2841 FETO manual

entity channel_interface IS
	port
	(
		-- Channel        
		MPX_BUS_O : IN STD_LOGIC_VECTOR(0 to 8);
		MPX_BUS_I : OUT STD_LOGIC_VECTOR(0 to 8);
		MPX_TAGS_O : IN MPX_TAGS_OUT;
		MPX_TAGS_I : OUT MPX_TAGS_IN;

		-- SPI
		SPI_CS, SPI_MOSI, SPI_CLK : out std_logic;
		SPI_MISO : in std_logic;
		
		DEBUG : INOUT DEBUG_BUS;

		-- Clocks
		clk : in std_logic -- 50MHz clock
	);
end entity channel_interface;

architecture behavioural of channel_interface is

	component CU is
	port (
		-- Channel interface
		-- Fig 2-34a
		bc_COMMO : in std_logic;
		bc_SERVO : in std_logic;
		bc_SUPPO : in std_logic;
		bc_SELTO : in std_logic;
		bc_SORSP : in std_logic;
		BUS_OUT_PARITY_ERROR : in std_logic;
		LOGIC_START : out std_logic; -- Reset Hold Out latch
		MACH_RESET : out std_logic;
		ER_7 : in std_logic;
		CA_EQ_15 : out std_logic;
		A_BUS : in std_logic_vector(0 to 7); -- A Bus in to CU
		-- Fig 2-34b
		ROS_ERROR : out std_logic;
		D_BUS_1_BIT : out std_logic; -- To reset Op In latch
		SCAN : out std_logic; -- Reset Op In latch
		LOCAL : out std_logic; -- Resets 'Enabled'
		ER_3 : in std_logic; -- From CU End
		BUS_IN : out std_logic_vector(0 to 7); -- DW Reg 0-7
		BUS_IN_P : out std_logic; -- DW Reg P
		-- Fig 2-34c
		IG_Reg : out std_logic_vector(0 to 7); -- 0=Write Latch 2=Read Latch 3=Queued 4=Poll Enable 5=Status_In 6=IG_6 7=Address_In
		-- Fig 2-34d
--		A_BUS_EQ_DR : out std_logic; -- Set 'Transfer Control'
--		A_BUS_EQ_IH : out std_logic; -- Set 'Transfer Control'
--		A_TIME : out std_logic; -- Gate Service Request reset
--		B_TIME : out std_logic; -- Gate Service Request set
--		C_TIME : out std_logic;
--		D_TIME : out std_logic; -- Gates A_BUS_EQ_DR and A_BUS_EQ_IH
		Transfer_Control_1 : out std_logic;
		A_BUS_TO_ER : out std_logic;
		CHECK_STOP : out std_logic; -- not CHECK_STOP gates General Reset
		SELECTIVE_RESET : in std_logic;
		GENERAL_RESET : in std_logic;
		
		-- External interface
		cs : out std_logic;
		mosi : out std_logic;
		miso : in std_logic;
		sclk : out std_logic;

		-- Debugging
		DEBUG : INOUT DEBUG_BUS;

		clk : in std_logic	-- 50MHz
	);
	end component CU;
	
	signal DEBUG2 : DEBUG_BUS;

	constant Switched_To_A : std_logic := '1';
	constant Switched_To_B : std_logic := '0';
	constant Disable_Chan_A : std_logic := '0';
	constant Enable_Chan_A : std_logic := '1';
	constant Power_Off_Gate : std_logic := '1'; -- (AI)
	
	signal Gated_Command_Out_A : std_logic;
	signal bc_COMMO_set : std_logic;
	signal Disc_plus_Busy : std_logic; -- (K) & (L)
--	signal A_TIME,B_TIME,C_TIME,D_TIME : std_logic;
	signal bc_COMMO, bc_SERVO, bc_SUPPO, bc_SELTO, bc_SORSP : std_logic;
	signal BUS_OUT_PARITY_ERROR : std_logic;
	signal LOGIC_START : std_logic;
	signal BUS_IN, D_BUS : std_logic_vector(0 to 7);
	signal BUS_IN_P : std_logic;
	signal MACH_RESET : std_logic;
	signal ER_7 : std_logic;
	signal CA_EQ_15 : std_logic;
	signal D_BUS_1_BIT : std_logic;
	signal LOCAL : std_logic;
	signal ERROR_3 : std_logic;
	signal CD_15 : std_logic;
	signal Reg_Reset : std_logic;
--	signal A_BUS_EQ_DR, A_BUS_EQ_IH : std_logic;
	signal Transfer_Control_1 : std_logic;
	signal A_BUS_TO_ER : std_logic;
	signal CHECK_STOP : std_logic;
	signal Selective_Reset : std_logic;
	signal General_Reset : std_logic;
	signal ROS_Error : std_logic;
	signal Scan : std_logic;
	
	-- Tags In
	signal ADR_IN, OPL_IN, SRV_IN, STA_IN, REQ_IN, SEL_IN : std_logic;
	-- Tags Out
	signal OPL_OUT, ADR_OUT, CMD_OUT, SRV_OUT, HLD_OUT, SEL_OUT, SUP_OUT : std_logic;
	-- Bus Out
	signal BUS_OUT : std_logic_vector(0 to 8);
	
	-- Internal signals
	signal Enabled_A : std_logic; -- (V)
	signal Operational_Out_A : std_logic; -- (A)
	signal Service_Out_A : std_logic;
	signal Operational_In_A : std_logic; -- (T)
	signal Gated_Service_Out : std_logic; -- (B)
	signal Address_Out_A : std_logic; -- (C) & (D)
	signal Gated_Address_Out_A : std_logic; -- (E)
	signal Gated_Suppress_Out_A : std_logic; -- (F)
	signal SUPPO_Set, SUPPO_Reset : std_logic;
	signal SUPPO_In : std_logic;
	signal SELTO_In : std_logic;
	signal Initial_Select_A : std_logic; -- (Q)
	signal SVC_Request_P1 : std_logic; -- (AH)
	signal Select_Out_A : std_logic; -- (G) & (H)
	signal Select_Out_FL : std_logic;
	signal SELOFL_Set,SELOFL_Reset : std_logic;
	signal Select_Out_Chan_A : std_logic; -- (AJ)
	signal Dlyd_Select_Out_A : std_logic; -- (I)
	signal Sel_Out_Or_Dlyd_Sel_Out_A : std_logic; -- (J)
	signal Gated_Dlyd_or_Select_Out_A : std_logic; -- (N)
	signal HIO_Set, HIO_Reset : std_logic;
	signal Parity_Error : std_logic;
	signal Addr_Compare_A : std_logic; -- (M) & (N)
	signal Operational_In_Latch : std_logic; -- (U)
	signal Responding_On_A : std_logic; -- (R)
	signal Steer_Latch_A_set,Steer_Latch_A_reset : std_logic;
	signal Steering_Latch_A : std_logic;
	signal Propagate_Sel_Out_A : std_logic; -- (O) & (P)
	signal CU_Busy_Status_A : std_logic; -- (S)
	signal CU_End_reset : std_logic;
	signal CU_End_A : std_logic;
	signal Operational_In_set, Operational_In_reset : std_logic;
	signal Meter_Enabled_set, Meter_Enabled_reset : std_logic;
	signal Clock_Out_Chan_A : std_logic;
	signal Outstanding_Status_A : std_logic;
	signal Operational_In : std_logic;
	signal Request_In_Chan_A : std_logic; -- (AC)
	signal Gate_D_Bus_to_IG_Reg : std_logic; -- (IF)
	signal Bus_In_Busy,Bus_In_Data : std_logic_vector(0 to 8);
	signal Gate_IG_Reg : std_logic;
	signal IG_Reg : std_logic_vector(0 to 7);
	alias Write_Latch is IG_Reg(0); -- (Z)
	alias Read_Latch is IG_Reg(2); -- (X) & (Y)
	alias Queued is IG_Reg(3);
	alias Poll_Enable is IG_Reg(4); -- (AB)
	alias IG5_Bit_Status_In_Latch is IG_Reg(5); -- (AA)
	alias IG6 is IG_Reg(6);
	alias IG7_Bit_Addr_In_Latch is IG_Reg(7); -- (W)
	signal Service_In : std_logic; -- (AG)
	signal Gate_Interrupt_A : std_logic;
	signal Request_In_Channel_A : std_logic; -- (AC) & (AD)
	signal Gated_Attention_0,Gated_Attention_1,Gated_Attention_2,Gated_Attention_3 : std_logic;
	signal Any_Gated_Attention : std_logic;
	signal Transfer_Control_2_set, Transfer_Control_2_reset : std_logic;
	signal Transfer_Control_2 : std_logic;
	signal Service_Request_set, Service_Request_reset : std_logic;
	signal Service_Request : std_logic;
	signal Service_In_set, Service_In_reset : std_logic;
	signal Selective_Reset_gate, Selective_Reset_set, Selective_Reset_reset : std_logic;
	
begin
-- Status byte
-- 0 Attention
-- 1 Status Modifier
-- 2 Control Unit End
-- 3 Busy
-- 4 Channel End
-- 5 Device End
-- 6 Unit Check
-- 7 Unit Exception

-- Fig 2-34a
	Operational_Out_A <= OPL_OUT and Enabled_A;
	Gated_Command_Out_A <= CMD_OUT and Switched_To_A and Operational_Out_A;
	bc_COMMO_set <= Gated_Command_Out_A or Disc_plus_Busy;
--	COMMO: PH port map(D=>bc_COMMO_set,L=>C_TIME,Q=>bc_COMMO);
	COMMO: FD port map(D=>bc_COMMO_set,C=>clk,Q=>bc_COMMO);
	Service_Out_A <= SRV_OUT and Operational_In_A and Operational_Out_A;
	Gated_Service_Out <= Service_Out_A;
--	SERVO: PH port map(D=>Gated_Service_out,L=>C_TIME,Q=>bc_SERVO);
	SERVO: FD port map(D=>Gated_Service_out,C=>clk,Q=>bc_SERVO);
	Address_Out_A <= ADR_OUT and Operational_Out_A;
	Gated_Address_Out_A <= Address_Out_A and Switched_To_A;
	Gated_Suppress_Out_A <= SUP_OUT and Switched_To_A;
	SUPPO_Set <= IG5_Bit_Status_In_Latch and Gated_Suppress_Out_A;
	SUPPO_Reset <= not Gated_Suppress_Out_A or Mach_Reset;
	SUPPO_FL: FDRS port map(D=>SUPPO_In,C=>Clk,S=>SUPPO_Set,R=>SUPPO_Reset,Q=>SUPPO_In);
--	SUPPO: PH port map(D=>SUPPO_In,L=>C_TIME,Q=>bc_SUPPO);
	SUPPO: FD port map(D=>SUPPO_In,C=>clk,Q=>bc_SUPPO);
	SELTO_In <= not Disc_plus_Busy and Initial_Select_A;
--	SELTO: PH port map(D=>SELTO_in,L=>C_TIME,Q=>bc_SELTO);
	SELTO: FD port map(D=>SELTO_in,C=>clk,Q=>bc_SELTO);
--	SORSP: PH port map(D=>SVC_Request_P1,L=>C_TIME,Q=>bc_SORSP);
	SORSP: FD port map(D=>SVC_Request_P1,C=>clk,Q=>bc_SORSP);
	
	Select_Out_A <= HLD_OUT and Select_Out_FL and OPL_OUT;
	SELOFL_Set <= Select_Out_Chan_A and HLD_OUT;
	SELOFL_Reset <= not HLD_OUT or Logic_Start;
	SELO_FL: FDRS port map(D=>Select_out_FL,C=>Clk,S=>SELOFL_Set,R=>SELOFL_Reset,Q=>Select_out_FL);
	SELO_Dly: process(clk) is
		variable dly5,dly4,dly3,dly2,dly1 : std_logic := '0';
		-- Delay 125ns = 6 cycles
		begin
		if rising_edge(clk) then
			Dlyd_Select_Out_A <= dly5;
			dly5 := dly4;
			dly4 := dly3;
			dly3 := dly2;
			dly2 := dly1;
			dly1 := Select_Out_A;
		end if;
		end process;
	Sel_Out_Or_Dlyd_Sel_Out_A <= Dlyd_Select_Out_A or Select_Out_A;
	Gated_Dlyd_or_Select_Out_A <= Switched_To_A and Sel_Out_Or_Dlyd_Sel_Out_A;
	HIO_Set <= (Operational_In_A and Gated_Address_Out_A and not Gated_Dlyd_or_Select_Out_A) or
		(IG5_Bit_Status_In_Latch and not Operational_In_Latch) or Mach_Reset;
	HIO_Reset <= (not Operational_In_Latch and not Responding_on_A) or ROS_Error;
	HIO: FDRS port map(D=>ER_7,C=>Clk,S=>HIO_Set,R=>HIO_Reset,Q=>ER_7);
	Disc_plus_Busy <= ER_7 and not HIO_Reset;
	
	Addr_Compare_A <= Address_Out_A and 
	    BUS_OUT(0) and 
	not BUS_OUT(1) and 
	not BUS_OUT(2) and
	not BUS_OUT(3) and
	not Operational_In_A and
	not Parity_Error;
	
	Parity_Error <= EvenParity(BUS_OUT);
	Bus_Out_Parity_Error <= Parity_Error and Switched_To_A; -- "and CA_EQ_15" removed
	
	-- Fig 2-34b
	Steer_Latch_A_set <= Operational_In_A
		or (Request_In_Chan_A and not Address_Out_A and not Select_Out_A)
		or (not Select_Out_A and Addr_Compare_A);
	Steer_Latch_A_reset <= (not Address_Out_A and not Request_In_Chan_A and not Select_Out_A)
		or (not Select_Out_A and Address_Out_A and not Addr_Compare_A)
		or (not Address_Out_A and Switched_To_B and Select_Out_A);
	Steering_Latch_A_FL : FDRS port map(D=>Steering_Latch_A,C=>Clk,S=>Steer_Latch_A_set,R=>Steer_Latch_A_reset,Q=>Steering_Latch_A);
	Propagate_Sel_Out_A <= (Select_Out_A and not Enabled_A) or (Dlyd_Select_Out_A and not Steering_Latch_A);
	Initial_Select_A <= Steering_Latch_A and Enabled_A and Dlyd_Select_Out_A;
	Responding_On_A <= Steering_Latch_A and Sel_Out_Or_Dlyd_Sel_Out_A;
	CU_Busy_Status_A <= Responding_On_A and Disc_plus_Busy and not Operational_In_A;
	CU_End_reset <= (Gated_Service_Out and Operational_In_A) or Mach_Reset;
	CU_End_FL: FDRS port map(D=>CU_End_A,C=>Clk,S=>CU_Busy_Status_A,R=>CU_End_reset,Q=>CU_End_A);
	Error_3 <= Switched_To_A and CU_End_A;
	Operational_In_set <= (Switched_To_A and (IG7_Bit_Addr_in_Latch or ROS_Error) and Initial_Select_A and not Propagate_Sel_Out_A);
--	Operational_In_reset <= Mach_Reset or (Gate_D_Bus_to_IG_Reg and D_Bus_1_Bit) or Scan;
	Operational_In_reset <= Mach_Reset or (D_Bus_1_Bit) or Scan;
	Operational_In_FL: FDRS port map(D=>Operational_In_Latch,C=>Clk,S=>Operational_In_set, R=>Operational_In_reset, Q=> Operational_In_Latch);
	Operational_In_A <= Switched_to_A and not Disc_plus_Busy and Operational_In_Latch;
	Meter_Enabled_set <= (Mach_Reset or Clock_Out_Chan_A) and not Disable_Chan_A;
	Meter_Enabled_reset <= not Outstanding_Status_A
		and (Mach_Reset or Clock_Out_Chan_A)
		and not Enable_Chan_A
		and (not Switched_to_A or Local or Poll_Enable);
	Meter_Enabled_FL: FDRS port map(D=>Enabled_A,C=>Clk,S=>Meter_Enabled_set,R=>Meter_Enabled_reset,Q=>Enabled_A);
	Bus_In_Busy <= '0' & CU_Busy_Status_A & '0' & CU_Busy_Status_A & "00000";
	Bus_In_Data <= BUS_IN & BUS_IN_P when Operational_In_A='1' else "000000000";
	MPX_BUS_I <= Bus_In_Data or Bus_In_Busy when (Power_Off_Gate='1') and (CU_Busy_Status_A='1' or Operational_In_A='1') 
		else "ZZZZZZZZZ";
	
	-- Fig 2-34c
--	Gate_IG_Reg <= (CD_15 and D_Time) or Reg_Reset;
--	IG_Reg_PH: PHV8 port map(D=>D_Bus,L=>Gate_IG_Reg,Q=>IG_Reg);
	ADR_IN <= IG7_Bit_Addr_In_Latch and not Gated_Address_Out_A when Operational_In_A='1' and Power_Off_Gate='1'
		else '0';
	OPL_IN <= '1' when Operational_In_A='1' and Power_Off_Gate='1'
		else '0';
	SRV_IN <= Service_In when Operational_In_A='1' and Power_Off_Gate='1'
		else '0';
	STA_IN <= '1' when (CU_Busy_Status_A='1' or (Operational_In_A='1' and IG5_Bit_Status_In_Latch='1'))
			and Power_Off_Gate='1'
		else '0';
	Gate_Interrupt_A <= Poll_Enable or Queued or IG6;
	Request_In_Channel_A <= Gate_Interrupt_A
		and ((IG6 and Switched_To_A) or not SUP_OUT)
		and Enabled_A
		and not Switched_to_B
		and not Propagate_Sel_Out_A
		and Any_Gated_Attention;
	Any_Gated_Attention <=
		Gated_Attention_0 or
		Gated_Attention_1 or
		Gated_Attention_2 or
		Gated_Attention_3 or
		Queued;
	REQ_IN <= '1' when Request_In_Channel_A='1' and Power_Off_Gate='1'
		else '0';
	
	-- Fig 2-34d
--	Transfer_Control_1_set <= (A_Bus_eq_DR and Read_Latch and D_Time) or (D_Time and A_Bus_eq_IH);
--	Transfer_Control_1_reset <= C_Time or Mach_Reset;
--	Transfer_Control_1_FL: FDRS port map(D=>Transfer_Control_1,C=>Clk,S=>Transfer_Control_1_set,R=>Transfer_Control_1_reset,Q=>Transfer_Control_1);
--	Service_Request_set <= (B_Time and Transfer_Control_1 and Read_Latch) or (Write_Latch and not Service_In);
--	Service_Request_reset <= Mach_Reset or (Service_In and A_Time);
--	Service_Request_FL: FLL port map(S=>Service_Request_set,R=>Service_Request_reset,Q=>Service_Request);
	Service_Request_set <= (Transfer_Control_1 and Read_Latch) or (Write_Latch and not Service_In);
	Service_Request_reset <= Mach_Reset or Service_In;
	Service_Request_FL: FDRS port map(C=>clk,D=>Service_Request,S=>Service_Request_set,R=>Service_Request_reset,Q=>Service_Request);
	
--	Transfer_Control_2_set <= D_Time and Service_Request;
--	Transfer_Control_2_reset <= B_Time and not Service_Request;
--	Transfer_Control_2_FL: FLL port map(S=>Transfer_Control_2_set,R=>Transfer_Control_2_reset,Q=>Transfer_Control_2);
	Transfer_Control_2_FL: FDRS port map(C=>clk,D=>Transfer_Control_2,S=>Service_Request,R=>not Service_Request,Q=>Transfer_Control_2);
	
	Service_In_set <=Transfer_Control_2 and not Gated_Service_Out;
--	Service_In_reset <= (Transfer_Control_1 and A_Time and not Read_Latch)
--		or (Read_Latch and Gated_Service_Out and not Transfer_Control_2)
--		or (A_Time and A_Bus_to_ER)
--		or Mach_Reset;
--	Service_In_FL: FLL port map(S=>Service_In_set,R=>Service_In_reset,Q=>Service_In);
	Service_In_reset <= (Transfer_Control_1 and not Read_Latch)
		or (Read_Latch and Gated_Service_Out and not Transfer_Control_2)
		or (A_Bus_to_ER)
		or Mach_Reset;
	Service_In_FL: FDRS port map(C=>clk,D=>Service_In,S=>Service_In_set,R=>Service_In_reset,Q=>Service_In);
	
	SVC_Request_P1 <= (Service_In and Read_Latch) or (Service_Request and Read_Latch) or (Service_In and Gated_Service_Out);
	
	Selective_Reset_gate <= Switched_to_A and Operational_Out_A;
	Selective_Reset_set <= Operational_In_A and Gated_Suppress_Out_A and not Selective_Reset_gate;
	Selective_Reset_reset <= not Logic_Start or Selective_Reset_gate;
	Selective_Reset_FL: FDRS port map(D=>Selective_Reset,C=>Clk,S=>Selective_Reset_set,R=>Selective_Reset_reset,Q=>Selective_Reset);
	General_Reset <= Switched_To_A and not Operational_Out_A and not SUP_OUT and Enabled_A and not Check_Stop;
	
	-- Select Out / In configuration
	Select_Out_Chan_A <= SEL_OUT;
	SEL_IN <= Propagate_Sel_Out_A;
	
	MPX_TAGS_I.OPL_IN <= OPL_IN;
	MPX_TAGS_I.ADR_IN <= ADR_IN;
	MPX_TAGS_I.STA_IN <= STA_IN;
	MPX_TAGS_I.SRV_IN <= SRV_IN;
	MPX_TAGS_I.SEL_IN <= SEL_IN;
	MPX_TAGS_I.REQ_IN <= REQ_IN;
	MPX_TAGS_I.MTR_IN <= '0';

	-- Clocked Tags Out:
	OPL_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.OPL_OUT,Q=>OPL_OUT);
	ADR_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.ADR_OUT,Q=>ADR_OUT);
	CMD_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.CMD_OUT,Q=>CMD_OUT);
	SRV_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.SRV_OUT,Q=>SRV_OUT);
	HLD_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.HLD_OUT,Q=>HLD_OUT);
	SEL_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.SEL_OUT,Q=>SEL_OUT);
	SUP_OUT_FF: FDCE port map(C=>Clk,D=>MPX_TAGS_O.SUP_OUT,Q=>SUP_OUT);
	-- Clocked Bus Out
	BUS_OUT_FF: for i in 0 to 8 generate
		BUS_O_FF: FD port map(C=>Clk,D=>MPX_BUS_O(i),Q=>BUS_OUT(i));
	end generate;

Control_Unit : CU port map(
		bc_COMMO => bc_COMMO,
		bc_SERVO => bc_SERVO,
		bc_SUPPO => bc_SUPPO,
		bc_SELTO => bc_SELTO,
		bc_SORSP => bc_SORSP,
		BUS_OUT_PARITY_ERROR => BUS_OUT_PARITY_ERROR,
		LOGIC_START => LOGIC_START,
		A_BUS => BUS_OUT(0 to 7),
--		C_TIME => C_TIME,
		MACH_RESET => MACH_RESET,
		ER_7 => ER_7,
		CA_EQ_15 => CA_EQ_15,
		ROS_ERROR => Ros_Error,
		D_BUS_1_BIT => D_BUS_1_BIT,
		SCAN => Scan,
		LOCAL => LOCAL,
		ER_3 => ERROR_3,
		BUS_IN => BUS_IN,
		BUS_IN_P => BUS_IN_P,
		IG_REG => IG_Reg,
--		A_BUS_EQ_DR => A_BUS_EQ_DR,
--		D_TIME => D_TIME,
--		A_BUS_EQ_IH => A_BUS_EQ_IH,
--		A_TIME => A_TIME,
--		B_TIME => B_TIME,
		Transfer_Control_1 => Transfer_Control_1,

		A_BUS_TO_ER => A_BUS_TO_ER,
		CHECK_STOP => CHECK_STOP,
		SELECTIVE_RESET => Selective_Reset,
		GENERAL_RESET => General_Reset,
		
		-- External interface
		cs => spi_cs,
		mosi => spi_mosi,
		miso => spi_miso,
		sclk => spi_clk,

		-- Debugging
		DEBUG => DEBUG2,

		clk => clk);

-- Debug stuff

with DEBUG.Selection select
	DEBUG.Probe <=
		OPL_IN when 0,
		ADR_IN when 1,
		STA_IN when 2,
		REQ_IN when 3,
		SEL_IN when 4,
		SRV_IN when 5,
		HLD_OUT when 6,
		SEL_OUT when 7,
		ADR_OUT when 8,
		CMD_OUT when 9,
  		SRV_OUT when 10,
  		SUP_OUT when 11,
  		OPL_OUT when 12,
		DEBUG2.Probe when others;
		
with DEBUG.Selection select
DEBUG.SevenSegment <=
	OPL_OUT &
	ADR_OUT &
	CMD_OUT &
	SRV_OUT &
	HLD_OUT &
	SEL_OUT &
	SUP_OUT &
	'0' &
	OPL_IN &
	ADR_IN &
	STA_IN &
	SRV_IN &
	REQ_IN &
	SEL_IN &
	'0' &
	'0' when 0,
	BUS_OUT(0 to 7) & BUS_IN(0 to 7) when 1,
	Steering_Latch_A & Operational_In_Latch & SVC_Request_P1 & bc_COMMO &
	bc_SERVO & bc_SUPPO & bc_SELTO & bc_SORSP &
	Addr_Compare_A & Enabled_A & Operational_In_A & Gated_Dlyd_or_Select_Out_A &
	CU_Busy_Status_A & CU_End_A & Disc_plus_Busy & Service_In when 4,
	BUS_IN & IG_Reg when 5,
	DEBUG2.SevenSegment when others; -- 2,3,6,7...
	
DEBUG2.Selection <= DEBUG.Selection;
END behavioural; 
