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
--    File: cpu.vhd
--    Creation Date: 22:15:23 2010-06-30
--    Description:
--    Top level of the CPU proper, combining all the various modules
--    including Processor, Storage, Multiplexor and (eventually) Selector(s)
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
--    
--
---------------------------------------------------------------------------
library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Buses_package.all;
use UNISIM.vcomponents.all;
use work.all;

entity cpu is
    Port ( 
			WX_IND : OUT std_logic_vector(0 to 12);
			W_IND_P : OUT std_logic;
			X_IND_P : OUT std_logic;
			IND_SALS : OUT SALS_Bus;
			IND_EX,IND_CY_MATCH,IND_ALLOW_WR,IND_1050_INTRV,IND_1050_REQ,IND_MPX,IND_SEL_CHNL : OUT STD_LOGIC;
			IND_MSDR : OUT STD_LOGIC_VECTOR(0 to 7);
			IND_MSDR_P : OUT STD_LOGIC;
			IND_OPNL_IN : OUT STD_LOGIC;
			IND_ADDR_IN : OUT STD_LOGIC;
			IND_STATUS_IN : OUT STD_LOGIC;
			IND_SERV_IN : OUT STD_LOGIC;
			IND_SEL_OUT : OUT STD_LOGIC;
			IND_ADDR_OUT : OUT STD_LOGIC;
			IND_CMMD_OUT : OUT STD_LOGIC;
			IND_SERV_OUT : OUT STD_LOGIC;
			IND_SUPPR_OUT : OUT STD_LOGIC;
			IND_FO : OUT STD_LOGIC_VECTOR(0 to 7);
			IND_FO_P: OUT STD_LOGIC;
			IND_A : OUT STD_LOGIC_VECTOR(0 to 8);
			IND_B : OUT STD_LOGIC_VECTOR(0 to 8);
			IND_ALU : OUT STD_LOGIC_VECTOR(0 to 8);
			IND_M : OUT STD_LOGIC_VECTOR(0 to 8);
			IND_N : OUT STD_LOGIC_VECTOR(0 to 8);
			IND_MAIN_STG : OUT STD_LOGIC;
			IND_LOC_STG : OUT STD_LOGIC;
			IND_COMP_MODE : OUT STD_LOGIC;
			IND_CHK_A_REG : OUT STD_LOGIC;
			IND_CHK_B_REG : OUT STD_LOGIC;
			IND_CHK_STOR_ADDR : OUT STD_LOGIC;
			IND_CHK_CTRL_REG : OUT STD_LOGIC;
			IND_CHK_ROS_SALS : OUT STD_LOGIC;
			IND_CHK_ROS_ADDR : OUT STD_LOGIC;
			IND_CHK_STOR_DATA : OUT STD_LOGIC;
			IND_CHK_ALU : OUT STD_LOGIC;
			IND_SYST : OUT STD_LOGIC;
			IND_MAN : OUT STD_LOGIC;
			IND_WAIT : OUT STD_LOGIC;
			IND_TEST : OUT STD_LOGIC;
			IND_LOAD : OUT STD_LOGIC;
			SW_START,SW_LOAD,SW_SET_IC,SW_STOP,SW_POWER_OFF : IN std_logic;
			SW_INH_CF_STOP,SW_PROC,SW_SCAN : IN std_logic;
			SW_SINGLE_CYCLE,SW_INSTRUCTION_STEP,SW_RATE_SW_PROCESS : IN std_logic;
			SW_LAMP_TEST,SW_DSPLY,SW_STORE,SW_SYS_RST : IN STD_LOGIC;
			SW_CHK_RST,SW_ROAR_RST,SW_CHK_RESTART,SW_DIAGNOSTIC : IN STD_LOGIC;
			SW_CHK_STOP,SW_CHK_SW_PROCESS,SW_CHK_SW_DISABLE,SW_ROAR_RESTT_STOR_BYPASS : IN STD_LOGIC;
			SW_ROAR_RESTT,SW_ROAR_RESTT_WITHOUT_RST,SW_EARLY_ROAR_STOP,SW_ROAR_STOP : IN STD_LOGIC;
			SW_ROAR_SYNC,SW_ADDR_COMP_PROC,SW_SAR_DLYD_STOP,SW_SAR_STOP,SW_SAR_RESTART : IN STD_LOGIC;
			SW_INTRP_TIMER, SW_CONS_INTRP : IN STD_LOGIC;
			SW_A,SW_B,SW_C,SW_D,SW_F,SW_G,SW_H,SW_J : IN STD_LOGIC_VECTOR(0 to 3);
			SW_AP,SW_BP,SW_CP,SW_DP,SW_FP,SW_GP,SW_HP,SW_JP : IN STD_LOGIC;
			E_SW : E_SW_BUS_Type;
			
			-- External MPX connections
			MPX_BUS_O : OUT STD_LOGIC_VECTOR(0 to 8);
			MPX_BUS_I : IN STD_LOGIC_VECTOR(0 to 8);
			MPX_TAGS_O : OUT MPX_TAGS_OUT;
			MPX_TAGS_I : IN MPX_TAGS_IN;

			-- Storage (RAM) interface
			StorageIn : IN STORAGE_IN_INTERFACE;
			StorageOut : OUT STORAGE_OUT_INTERFACE;
			
--			PCH_CONN_ENTRY : IN PCH_CONN;
--			RDR_1_CONN_EXIT : OUT RDR_CONN;
--			n1050_CONTROL : OUT CONN_1050;
			
			-- Hardware Serial Port
			serialInput : in Serial_Input_Lines;
			serialOutput : out Serial_Output_Lines;
			
			DEBUG : INOUT DEBUG_BUS;
			USE_MAN_DECODER_PWR : OUT STD_LOGIC;
			Clock1ms : IN STD_LOGIC;
			N60_CY_TIMER_PULSE : IN STD_LOGIC;
			M_CONV_OSC : OUT STD_LOGIC;
			SwSlow : in std_logic;
			clk : in std_logic);
end cpu;

architecture FMD of cpu is

-- Outputs from UDC1 (5-01 through 5-05)
signal	sSALS : SALS_Bus;
signal	CTRL : CTRL_REG;
signal	T1,T2,T3,T4 : std_logic;
signal	SEL_T1, SEL_T3, SEL_T4 : std_logic;
signal	P1,P2,P3,P4 : std_logic;
signal	A_BUS1, B_BUS : std_logic_vector(0 to 8);
signal	CLOCK_START : std_logic;
signal	CLOCK_ON : std_logic;
signal STORE_S_REG_RST : std_logic; -- 03DC2
signal CTRL_REG_RST : std_logic; -- 01CB2
signal TO_KEY_SW : std_logic;
signal METERING_OUT : std_logic;
signal GT_1050_TAGS : std_logic;
signal GT_1050_BUS : std_logic;
signal	SET_IND_ROSAR : STD_LOGIC;
signal	GT_LOCAL_STORAGE : STD_LOGIC;
signal	GT_T_REG_TO_MN : STD_LOGIC;
signal  GT_CK_TO_MN : STD_LOGIC;
signal	N_STACK_MEM_SELECT : STD_LOGIC;
signal	WX_CHK : STD_LOGIC;

-- Outputs from UDC2 (5-06 through 5-09C)
signal	Z_BUS,R : std_logic_vector(0 to 8);
signal	MN : std_logic_vector(0 to 15);
signal CLOCK_OFF : std_logic;
signal A_REG_PC : std_logic;
signal MN_PC : std_logic;
signal Z0_BUS_0 : std_logic;
signal Z_0 : std_logic;
signal N_CTRL_N : std_logic;
signal ALU_CHK_LCH : std_logic;
signal	SELECT_CPU_BUMP : std_logic;
--signal	sMPX_BUS_O : std_logic_vector(0 to 8);
signal	P_1050_SEL_OUT : STD_LOGIC;
signal	P_1050_SEL_IN : STD_LOGIC;
signal	n1050_REQ_IN : STD_LOGIC;
signal	n1050_CE_MODE : STD_LOGIC;
signal	MPX_OPN_LT_GATE : STD_LOGIC;
signal	ADDR_OUT : STD_LOGIC;

-- Outputs from UDC3 (5-10A through 5-14D)
signal	A_BUS3 : STD_LOGIC_VECTOR(0 to 8);
signal	SEL_WR_CALL : STD_LOGIC := '0';
signal	SX1_SHARE_CYCLE : STD_LOGIC := '0';
signal	SX2_SHARE_CYCLE : STD_LOGIC := '0';
signal	SEL_AUX_WR_CALL : STD_LOGIC := '0';
signal	SEL_AUX_RD_CALL : STD_LOGIC := '0';
signal	SEL_CONV_OSC : STD_LOGIC;
signal	SEL_BASIC_CLOCK_OFF : STD_LOGIC;
signal	SEL_SHARE_HOLD : STD_LOGIC := '0';
signal	SEL_SHARE_CYCLE : STD_LOGIC := '0';
signal	SEL_CHNL_DATA_XFER : STD_LOGIC := '0';
signal	SEL_ROS_REQ : STD_LOGIC := '0';
signal	SEL_READ_CALL : STD_LOGIC := '0';
signal	SEL_RD_WR_CTRL : STD_LOGIC := '0';
signal	SEL_RD_CALL_TO_STP : STD_LOGIC := '0';
signal	SEL_CC_ROS_REQ : STD_LOGIC := '0';
signal	MAN_DSPLY_GUV_HUV : STD_LOGIC := '0';
signal	HSMPX_TRAP : STD_LOGIC := '0';
signal	n1050_SEL_O : STD_LOGIC;
signal	n1050_SEL_IN : STD_LOGIC;
signal	n1050_INSTALLED : STD_LOGIC;
signal	n1050_OP_IN : STD_LOGIC;

-- Inputs to UDC3
signal	SEL_DATA_READY : STD_LOGIC;
signal	SEL_CHNL_CPU_CLOCK_STOP : STD_LOGIC;
signal	RST_SEL_CHNL_DIAG_LCHS : STD_LOGIC;
signal	LOAD_REQ_LCH : STD_LOGIC;
signal	USE_GR_OR_HR : STD_LOGIC;
signal	SX_CHAIN_PULSE_1 : STD_LOGIC;
signal	CHK_RST_SW : STD_LOGIC;

signal	S : std_logic_vector(0 to 7);
signal	sM_CONV_OSC,P_CONV_OSC,M_CONV_OSC_2 : std_logic;
signal	MACH_RST_2A,MACH_RST_2B,MACH_RST_3, MACH_RST_6 : std_logic;
signal	CARRY_0 : STD_LOGIC;
signal	COMPLEMENT,NTRUE : STD_LOGIC;
signal	FT0,FT1,FT2,FT3,FT5,FT6,FT7 : STD_LOGIC;
signal	M_ASSM_BUS1, N_ASSM_BUS1 : STD_LOGIC_VECTOR(0 to 8);
signal	M_ASSM_BUS2, N_ASSM_BUS2 : STD_LOGIC_VECTOR(0 to 8);
signal	M_ASSM_BUS3, N_ASSM_BUS3 : STD_LOGIC_VECTOR(0 to 8);
signal	N1050_INTRV_REQ : STD_LOGIC := '0';
signal	TT6_POS_ATTN : STD_LOGIC := '0';
-- signal	FT2_MPX_OPNL : STD_LOGIC := '0';
signal	MPX_METERING_IN,METER_IN_SX1,METER_IN_SX2 : STD_LOGIC;
signal	KEY_SW : STD_LOGIC;
signal	GT_SWS_TO_WX_PWR : STD_LOGIC;
signal	GT_MAN_SET_MN : STD_LOGIC;
signal	EXT_TRAP_MASK_ON : STD_LOGIC;
signal	MANUAL_STORE,MAN_STOR_OR_DSPLY : STD_LOGIC;
signal	RECYCLE_RST : STD_LOGIC;
signal	T_REQUEST : STD_LOGIC := '0';
signal	MACH_RST_SET_LCH : STD_LOGIC;
signal	RST_LOAD : STD_LOGIC;
signal	CARRY_0_LCHD,CARRY_1_LCHD : STD_LOGIC;
signal	ALU_CHK : STD_LOGIC;
signal	CTRL_N,N_CTRL_LM : STD_LOGIC;
signal	SX1_RD_CYCLE,SX2_RD_CYCLE : STD_LOGIC;
signal	SX1_WR_CYCLE,SX2_WR_CYCLE : STD_LOGIC;
signal	GT_DETECTORS_TO_HR : STD_LOGIC;
signal	CPU_RD_PWR : STD_LOGIC;
signal	XH,XL,XXH : STD_LOGIC;
signal	SET_FW : STD_LOGIC;
signal	keyboard_data : STD_LOGIC_VECTOR(7 downto 0);
signal	keyboard_error : STD_LOGIC;
signal	USE_MANUAL_DECODER : STD_LOGIC;
signal	sUSE_MAN_DECODER_PWR : STD_LOGIC;
signal	LOCAL_STORAGE_CP, MAIN_STORAGE_CP : STD_LOGIC;
signal	STACK_RD_WR_CONTROL : STD_LOGIC;
signal	H_REG_5_PWR : STD_LOGIC;
signal	FORCE_M_REG_123 : STD_LOGIC;
signal	N_SEL_SHARE_HOLD : STD_LOGIC;
signal	GK,HK : STD_LOGIC_VECTOR(0 to 3);
signal	PROT_LOC_CPU_OR_MPX : STD_LOGIC;
signal	PROT_LOC_SEL_CHNL : STD_LOGIC;
signal	EARLY_M_REG_0 : STD_LOGIC;
signal	ODD : STD_LOGIC; -- 06B to 04A
signal	SUPPR_A_REG_CHK : STD_LOGIC;
signal	STATUS_IN_LCHD : STD_LOGIC;
signal	M_REG_0 : STD_LOGIC;
signal	SYS_RST_PRIORITY_LCH : STD_LOGIC;
signal	STORE_R : STD_LOGIC;
signal	SAL_PC : STD_LOGIC;
signal	R_REG_PC : STD_LOGIC;
signal	N2ND_ERROR_STOP : STD_LOGIC;
signal	MEM_WRAP : STD_LOGIC;
signal	MACH_RST_PROT : STD_LOGIC;
signal	MACH_RST_MPX : STD_LOGIC;
signal	GM_WM_DETECTED : STD_LOGIC;
signal	FIRST_MACH_CHK_REQ : STD_LOGIC;
signal	FIRST_MACH_CHK : STD_LOGIC;
signal	DECIMAL : STD_LOGIC;
signal	INTRODUCE_ALU_CHK : STD_LOGIC;
signal	SERV_IN_LCHD, ADDR_IN_LCHD, OPNL_IN_LCHD : STD_LOGIC;
signal	MPX_SHARE_REQ, MPX_INTERRUPT : STD_LOGIC;
signal	CS_DECODE_X001 : STD_LOGIC;
signal	SX1_INTERRUPT, SX2_INTERRUPT : STD_LOGIC;
signal	SX_1_GATE, SX_2_GATE : STD_LOGIC;
signal	SX_1_R_W_CTRL, SX_2_R_W_CTRL : STD_LOGIC;
signal	SX_2_BUMP_SW_GT : STD_LOGIC;
-- signal	FT3_MPX_SHARE_REQ : STD_LOGIC;
signal	CONNECT : STD_LOGIC;
signal	P_8F_DETECTED : STD_LOGIC;
signal	BASIC_CS0 : STD_LOGIC;
signal	USE_R : STD_LOGIC;
signal	ANY_MACH_CHK : STD_LOGIC;
signal	USE_MAIN_MEMORY, USE_LOCAL_MAIN_MEMORY : STD_LOGIC;
signal	ALLOW_PROTECT : STD_LOGIC;
signal	USE_BASIC_CA_DECO, USE_ALT_CA_DECODER : STD_LOGIC;
signal	ALLOW_PC_SALS : STD_LOGIC;
signal	SUPPR_MACH_CHK_TRAP : STD_LOGIC;
signal	N1401_MODE : STD_LOGIC;
signal	MEM_PROTECT_REQUEST : STD_LOGIC;
signal	MANUAL_DISPLAY : STD_LOGIC;
signal	MAIN_STORAGE : STD_LOGIC;
signal	MACH_RST_SET_LCH_DLY : STD_LOGIC;
signal	MACH_RST_SW : STD_LOGIC;
signal	MACH_CHK_RST : STD_LOGIC;
signal	MACH_CHK_PULSE : STD_LOGIC;
signal	GT_D_REG_TO_A_BUS : STD_LOGIC;
signal	GT_CA_TO_W_REG : STD_LOGIC;
signal	DATA_READY : STD_LOGIC;
signal	CTRL_REG_CHK : STD_LOGIC;
signal	CPU_WRITE_IN_R_REG : STD_LOGIC;
signal	CPU_SET_ALLOW_WR_LCH : STD_LOGIC;
signal	ANY_PRIORITY_LCH : STD_LOGIC;
signal	ALLOW_WRITE_DLYD : STD_LOGIC;
signal	ALLOW_WRITE : STD_LOGIC;
signal	STORE_HR : STD_LOGIC;
signal	STORE_GR : STD_LOGIC;
signal	SEL_R_W_CTRL : STD_LOGIC;
signal	SEL_CHNL_CHK : STD_LOGIC;
signal	HR_REG_0_7, GR_REG_0_7 : STD_LOGIC_VECTOR(0 to 7);
signal	STORE_BITS : STD_LOGIC_VECTOR(0 to 8); -- 8 is P
signal	HR_REG_P_BIT : STD_LOGIC;
signal	GR_REG_P_BIT : STD_LOGIC;
signal	GT_DETECTORS_TO_GR : STD_LOGIC;
signal	EVEN_HR_0_7_BITS, EVEN_GR_0_7_BITS : STD_LOGIC;
signal	CHANNEL_RD_CALL : STD_LOGIC;
signal	MPX_ROS_LCH : STD_LOGIC;
signal	CK_SAL_P_BIT_TO_MPX : STD_LOGIC;
signal	STG_MEM_SEL : STD_LOGIC;
signal	GATED_CA_BITS : STD_LOGIC_VECTOR(0 to 3);
signal	CLOCK_START_LCH : STD_LOGIC;
signal	LOAD_IND : STD_LOGIC;
signal	CLOCK_OUT : STD_LOGIC;
signal	READ_ECHO_1, READ_ECHO_2, WRITE_ECHO_1, WRITE_ECHO_2 : STD_LOGIC;
signal	DIAGNOSTIC_SW : STD_LOGIC;
signal	A_BUS, sFI : STD_LOGIC_VECTOR(0 to 8);

begin

	firstBit: entity udc1 (FMD) port map (
		SALS => sSALS,
		CTRL => CTRL,
		WX_IND => WX_IND,
		X_IND_P => X_IND_P,
		W_IND_P => W_IND_P,
		A_BUS => A_BUS1,
		B_BUS => B_BUS,
		Z_BUS => Z_BUS,
		MPX_BUS => sFI,
		S => S,
		R => R,
		MN => MN,
		M_ASSM_BUS => M_ASSM_BUS1,
		N_ASSM_BUS => N_ASSM_BUS1,
		SW_START => SW_START,
		SW_LOAD => SW_LOAD,
		SW_SET_IC => SW_SET_IC,
		SW_STOP => SW_STOP,
		SW_INH_CF_STOP => SW_INH_CF_STOP,
		SW_PROC => SW_PROC,
		SW_SCAN => SW_SCAN,
		SW_SINGLE_CYCLE => SW_SINGLE_CYCLE,
		SW_INSTRUCTION_STEP => SW_INSTRUCTION_STEP,
		SW_RATE_SW_PROCESS => SW_RATE_SW_PROCESS,
		SW_PWR_OFF => SW_POWER_OFF,
		SW_LAMP_TEST => SW_LAMP_TEST,
		SW_DSPLY => SW_DSPLY,
		SW_STORE => SW_STORE,
		SW_SYS_RST => SW_SYS_RST,
		SW_CHK_RST => SW_CHK_RST,
		SW_ROAR_RST => SW_ROAR_RST,
		SW_CHK_RESTART => SW_CHK_RESTART,
		SW_DIAGNOSTIC => SW_DIAGNOSTIC,
		SW_CHK_STOP => SW_CHK_STOP,
		SW_CHK_SW_PROCESS => SW_CHK_SW_PROCESS,
		SW_CHK_SW_DISABLE => SW_CHK_SW_DISABLE,
		SW_ROAR_RESTT_STOR_BYPASS => SW_ROAR_RESTT_STOR_BYPASS,
		SW_ROAR_RESTT => SW_ROAR_RESTT,
		SW_ROAR_RESTT_WITHOUT_RST => SW_ROAR_RESTT_WITHOUT_RST,
		SW_EARLY_ROAR_STOP => SW_EARLY_ROAR_STOP,
		SW_ROAR_STOP => SW_ROAR_STOP,
		SW_ROAR_SYNC => SW_ROAR_SYNC,
		SW_ADDR_COMP_PROC => SW_ADDR_COMP_PROC,
		SW_SAR_DLYD_STOP => SW_SAR_DLYD_STOP,
		SW_SAR_STOP => SW_SAR_STOP,
		SW_SAR_RESTART => SW_SAR_RESTART,
		SW_INTRP_TIMER => SW_INTRP_TIMER,
		SW_CONS_INTRP => SW_CONS_INTRP,
		SW_A => SW_A,SW_B => SW_B,SW_C => SW_C,SW_D => SW_D,
		SW_F => SW_F,SW_G => SW_G,SW_H => SW_H,SW_J => SW_J,
		SW_AP => SW_AP,SW_BP => SW_BP,SW_CP => SW_CP,SW_DP => SW_DP,
		SW_FP => SW_FP,SW_GP => SW_GP,SW_HP => SW_HP,SW_JP => SW_JP,
		TO_KEY_SW => TO_KEY_SW,
		
		E_SW => E_SW, -- Main E switch bus

		IND_SYST => IND_SYST,
		IND_MAN => IND_MAN,
		IND_WAIT => IND_WAIT,
		IND_TEST => IND_TEST,
		IND_LOAD => IND_LOAD,
		IND_EX => IND_EX,
		IND_CY_MATCH => IND_CY_MATCH,
		IND_ALLOW_WR => IND_ALLOW_WR,
		IND_1050_INTRV => IND_1050_INTRV,
		IND_1050_REQ => IND_1050_REQ,
		IND_MPX => IND_MPX,
		IND_SEL_CHNL => IND_SEL_CHNL,
		IND_MSDR => IND_MSDR,
		IND_MSDR_P => IND_MSDR_P,

		CARRY_0 => CARRY_0,
		CARRY_0_LCHD => CARRY_0_LCHD,
		CARRY_1_LCHD => CARRY_1_LCHD,
      COMPLEMENT => COMPLEMENT,
		NTRUE => NTRUE,
		MPX_METERING_IN => MPX_METERING_IN,
		CLOCK_OUT => CLOCK_OUT,
		METERING_OUT => METERING_OUT,
		METER_IN_SX1 => METER_IN_SX1,
		METER_IN_SX2 => METER_IN_SX2,
		KEY_SW => KEY_SW,
		N60_CY_TIMER_PULSE => N60_CY_TIMER_PULSE,
		N1050_INTRV_REQ => N1050_INTRV_REQ,
		GT_1050_TAGS => GT_1050_TAGS,
		GT_1050_BUS => GT_1050_BUS,
		TT6_POS_ATTN => TT6_POS_ATTN,
		FT2_MPX_OPNL => FT2,
		EXT_TRAP_MASK_ON => EXT_TRAP_MASK_ON,
		FT0 => FT0,
		FT1 => FT1,
		FT2 => FT2,
		FT3 => FT3,
		FT5 => FT5,
		FT6 => FT6,
		FT7 => FT7,
		MANUAL_STORE => MANUAL_STORE,
		RECYCLE_RST => RECYCLE_RST,
		ALU_CHK => ALU_CHK,
		CTRL_N => CTRL_N,
		N_CTRL_N => N_CTRL_N,
		N_CTRL_LM => N_CTRL_LM,
		STORE_S_REG_RST => STORE_S_REG_RST,
		MAIN_STORAGE_CP => MAIN_STORAGE_CP,
		LOCAL_STORAGE_CP => LOCAL_STORAGE_CP,
		SET_IND_ROSAR => SET_IND_ROSAR,
		USE_MAN_DECODER_PWR => sUSE_MAN_DECODER_PWR,
		N_STACK_MEM_SELECT => N_STACK_MEM_SELECT,
		STACK_RD_WR_CONTROL => STACK_RD_WR_CONTROL,
		H_REG_5_PWR => H_REG_5_PWR,
		FORCE_M_REG_123 => FORCE_M_REG_123,
		GT_LOCAL_STORAGE => GT_LOCAL_STORAGE,
		GT_T_TO_MN_REG => GT_T_REG_TO_MN,
		GT_CK_TO_MN_REG => GT_CK_TO_MN,
		SX1_SHARE_CYCLE => SX1_SHARE_CYCLE,
		SX2_SHARE_CYCLE => SX2_SHARE_CYCLE,
		PROT_LOC_CPU_OR_MPX => PROT_LOC_CPU_OR_MPX,
		WX_CHK => WX_CHK,
		EARLY_M_REG_0 => EARLY_M_REG_0,
		ODD => ODD,
		XH => XH,
		XL => XL,
		XXH => XXH,
		SUPPR_A_REG_CHK => SUPPR_A_REG_CHK,
		STATUS_IN_LCHD => STATUS_IN_LCHD,
		M_REG_0 => M_REG_0,
		SYS_RST_PRIORITY_LCH => SYS_RST_PRIORITY_LCH,
		STORE_R => STORE_R,
		SAL_PC => SAL_PC,
		R_REG_PC => R_REG_PC,
		RST_LOAD => RST_LOAD,
		N2ND_ERROR_STOP => N2ND_ERROR_STOP,
		MEM_WRAP => MEM_WRAP,
		MACH_RST_PROT => MACH_RST_PROT,
		MACH_RST_MPX => MACH_RST_MPX,
		MACH_RST_2A => MACH_RST_2A,
		MACH_RST_2B => MACH_RST_2B,
		MACH_RST_3 => MACH_RST_3,
		MACH_RST_6 => MACH_RST_6,
		GM_WM_DETECTED => GM_WM_DETECTED,
		FIRST_MACH_CHK_REQ => FIRST_MACH_CHK_REQ,
		FIRST_MACH_CHK => FIRST_MACH_CHK,
		DECIMAL => DECIMAL,
		INTRODUCE_ALU_CHK => INTRODUCE_ALU_CHK,
		SERV_IN_LCHD => SERV_IN_LCHD,
		ADDR_IN_LCHD => ADDR_IN_LCHD,
		OPNL_IN_LCHD => OPNL_IN_LCHD,
		MPX_SHARE_REQ => MPX_SHARE_REQ,
		MPX_INTERRUPT => MPX_INTERRUPT,
		CS_DECODE_X001 => CS_DECODE_X001,
		CLOCK_OFF => CLOCK_OFF,
		CONNECT => CONNECT,
		P_8F_DETECTED => P_8F_DETECTED,
		BASIC_CS0 => BASIC_CS0,
		ANY_MACH_CHK => ANY_MACH_CHK,
		ALU_CHK_LCH => ALU_CHK_LCH,
		ALLOW_PROTECT => ALLOW_PROTECT,
		ALLOW_PC_SALS => ALLOW_PC_SALS,
		USE_R => USE_R,
		USE_BASIC_CA_DECODER => USE_BASIC_CA_DECO,
		USE_ALT_CA_DECODER => USE_ALT_CA_DECODER,
		SUPPR_MACH_CHK_TRAP => SUPPR_MACH_CHK_TRAP,
		SEL_DATA_READY => SEL_DATA_READY,
		N1401_MODE => N1401_MODE,
		STG_MEM_SEL => STG_MEM_SEL,
		MEM_PROT_REQUEST => MEM_PROTECT_REQUEST,
		MANUAL_DISPLAY => MANUAL_DISPLAY,
		MAIN_STORAGE => MAIN_STORAGE,
		MACH_RST_SET_LCH_DLY => MACH_RST_SET_LCH_DLY,
		MACH_RST_SET_LCH => MACH_RST_SET_LCH,
		MACH_CHK_RST => MACH_CHK_RST,
		MACH_CHK_PULSE => MACH_CHK_PULSE,
		GT_D_REG_TO_A_BUS => GT_D_REG_TO_A_BUS,
		GT_CA_TO_W_REG => GT_CA_TO_W_REG,
		DATA_READY => DATA_READY,
		CTRL_REG_CHK => CTRL_REG_CHK,
		CPU_WRITE_IN_R_REG => CPU_WRITE_IN_R_REG,
		CPU_SET_ALLOW_WR_LCH => CPU_SET_ALLOW_WR_LCH,
		ANY_PRIORITY_LCH => ANY_PRIORITY_LCH,
		ALLOW_WRITE => ALLOW_WRITE,
		ALLOW_WRITE_DLYD => ALLOW_WRITE_DLYD,
		GT_MAN_SET_MN => GT_MAN_SET_MN,
		MPX_ROS_LCH => MPX_ROS_LCH,
		CTRL_REG_RST => CTRL_REG_RST,
		CK_SAL_P_BIT_TO_MPX => CK_SAL_P_BIT_TO_MPX,
		CHANNEL_RD_CALL => CHANNEL_RD_CALL,
		GTD_CA_BITS => GATED_CA_BITS,
		Z0_BUS_0 => Z0_BUS_0,
		Z_0 => Z_0,
		USE_MANUAL_DECODER => USE_MANUAL_DECODER,
		USE_MAIN_MEMORY => USE_MAIN_MEMORY,
		USE_LOC_MAIN_MEM => USE_LOCAL_MAIN_MEMORY,
		SELECT_CPU_BUMP => SELECT_CPU_BUMP,
		MAN_STOR_OR_DSPLY => MAN_STOR_OR_DSPLY,
		GT_SWS_TO_WX_PWR => GT_SWS_TO_WX_PWR,
		CPU_RD_PWR => CPU_RD_PWR,
		LOAD_IND => LOAD_IND,
		SET_FW => SET_FW,
		MACH_RST_SW => MACH_RST_SW,
		LOAD_REQ_LCH => LOAD_REQ_LCH,
		USE_GR_OR_HR => USE_GR_OR_HR,
		SX_CHAIN_PULSE_1 => SX_CHAIN_PULSE_1,
		CHK_RST_SW => CHK_RST_SW,
		DIAGNOSTIC_SW => DIAGNOSTIC_SW,
		MAN_DSPLY_GUV_HUV => MAN_DSPLY_GUV_HUV,
		HSMPX_TRAP => HSMPX_TRAP,
		READ_ECHO_1 => READ_ECHO_1,
		READ_ECHO_2 => READ_ECHO_2,
		WRITE_ECHO_1 => WRITE_ECHO_1,
		WRITE_ECHO_2 => WRITE_ECHO_2,
		
		SX_1_R_W_CTRL => SX_1_R_W_CTRL,
		SX_2_R_W_CTRL => SX_2_R_W_CTRL,
		SX_2_BUMP_SW_GT => SX_2_BUMP_SW_GT,
		
		SEL_WR_CALL => SEL_WR_CALL,
		SEL_AUX_WR_CALL => SEL_AUX_WR_CALL,
		SEL_AUX_RD_CALL => SEL_AUX_RD_CALL,
		SEL_T1 => SEL_T1,
		SEL_T4 => SEL_T4,
		SEL_CONV_OSC => SEL_CONV_OSC,
		SEL_BASIC_CLOCK_OFF => SEL_BASIC_CLOCK_OFF,
		SEL_SHARE_HOLD => SEL_SHARE_HOLD,
		SEL_SHARE_CYCLE => SEL_SHARE_CYCLE,
		SEL_CHNL_DATA_XFER => SEL_CHNL_DATA_XFER,
		SEL_ROS_REQ => SEL_ROS_REQ,
		SEL_READ_CALL => SEL_READ_CALL,
		SEL_RD_WR_CTRL => SEL_RD_WR_CTRL,
		SEL_RD_CALL_TO_STP => SEL_RD_CALL_TO_STP,
		SEL_CHNL_CPU_CLOCK_STOP => SEL_CHNL_CPU_CLOCK_STOP,
		RST_SEL_CHNL_DIAG_LCHS => RST_SEL_CHNL_DIAG_LCHS,
		SEL_CC_ROS_REQ => SEL_CC_ROS_REQ,
		SX1_INTERRUPT => SX1_INTERRUPT,
		SX2_INTERRUPT => SX2_INTERRUPT,
		SX_1_GATE => SX_1_GATE,
		SX_2_GATE => SX_2_GATE,
		
		CLOCK_ON => CLOCK_ON,
		M_CONV_OSC => sM_CONV_OSC,
		P_CONV_OSC => P_CONV_OSC,
		M_CONV_OSC_2 => M_CONV_OSC_2,
		CLOCK_START => CLOCK_START,
		CLOCK_START_LCH => CLOCK_START_LCH,
		
		-- UDC1 Debug stuff
		DEBUG => Debug,
		-- End of Debug stuff

		T1 => T1,
		T2 => T2,
		T3 => T3,
		T4 => T4,
		P1 => P1,
		P4 => P4,
		CLK => CLK
		);		

	IND_SALS <= sSALS;
	USE_MAN_DECODER_PWR <= sUSE_MAN_DECODER_PWR;
	
	secondBit: entity udc2 (FMD) port map (
		SALS => sSALS,
		CTRL => CTRL,
		A_BUS1 => A_BUS,
		B_BUS => B_BUS,
		Z_BUS => Z_BUS,
		E_BUS => E_SW,
		M_ASSM_BUS => M_ASSM_BUS2,
		N_ASSM_BUS => N_ASSM_BUS2,
		S => S,
		R => R,
		MN => MN,
		Sw_Slow => SwSlow,
		CLOCK_START => CLOCK_START,
		MACH_RST_3 => MACH_RST_3,
		MACH_RST_6 => MACH_RST_6,
		MANUAL_STORE => MANUAL_STORE,
		RECYCLE_RST => RECYCLE_RST,
		CLOCK_IN => clk,
		M_CONV_OSC => sM_CONV_OSC,
		P_CONV_OSC => P_CONV_OSC,
		M_CONV_OSC_2 => M_CONV_OSC_2,
		CLOCK_ON => CLOCK_ON,
		LAMP_TEST => SW_LAMP_TEST,
		MAN_STOR_OR_DSPLY => MAN_STOR_OR_DSPLY,
		MACH_RST_SET_LCH => MACH_RST_SET_LCH,
		DIAG_SW => DIAGNOSTIC_SW,
		CHK_SW_PROC_SW => SW_CHK_SW_PROCESS,
		ROS_SCAN => SW_SCAN,
		GT_SWS_TO_WX_PWR => GT_SWS_TO_WX_PWR,
		RST_LOAD => RST_LOAD,
		SYSTEM_RST_PRIORITY_LCH => SYS_RST_PRIORITY_LCH,
		CARRY_0_LATCHED => CARRY_0_LCHD,
		CARRY_1_LCHD => CARRY_1_LCHD,
		ALU_CHK => ALU_CHK,
		NTRUE => NTRUE,
		COMPLEMENT => COMPLEMENT,
		P_CTRL_N => CTRL_N,
		N_CTRL_LM => N_CTRL_LM,
		SX1_RD_CYCLE => SX1_RD_CYCLE,
		SX2_RD_CYCLE => SX2_RD_CYCLE,
		SX1_WR_CYCLE => SX1_WR_CYCLE,
		SX2_WR_CYCLE => SX2_WR_CYCLE,
		SX1_SHARE_CYCLE => SX1_SHARE_CYCLE,
		SX2_SHARE_CYCLE => SX2_SHARE_CYCLE,
		CPU_RD_PWR => CPU_RD_PWR,
		GT_MAN_SET_MN => GT_MAN_SET_MN,
		CHNL_RD_CALL => CHANNEL_RD_CALL,
		XH => XH,
		XL => XL,
		XXH => XXH,
		MAN_STOR_PWR => MANUAL_STORE,
		STORE_S_REG_RST => STORE_S_REG_RST,
		E_SW_SEL_S => E_SW.S_SEL,
		CTRL_REG_RST => CTRL_REG_RST,
		CLOCK_OFF => CLOCK_OFF,
		A_REG_PC => A_REG_PC,
		Z0_BUS_0 => Z0_BUS_0,
		Z_0 => Z_0,
		P_CONNECT => CONNECT,
		N_CTRL_N => N_CTRL_N,
		ALU_CHK_LCH => ALU_CHK_LCH,
		MN_PC => MN_PC,
		SET_IND_ROSAR => SET_IND_ROSAR,
		N_STACK_MEMORY_SELECT => N_STACK_MEM_SELECT,
		STACK_RD_WR_CONTROL => STACK_RD_WR_CONTROL,
		H_REG_5_PWR => H_REG_5_PWR,
		FORCE_M_REG_123 => FORCE_M_REG_123,
		GT_LOCAL_STORAGE => GT_LOCAL_STORAGE,
		GT_T_REG_TO_MN => GT_T_REG_TO_MN, -- from 05B
		GT_CK_TO_MN => GT_CK_TO_MN,
		MAIN_STG_CP_1 => MAIN_STORAGE_CP,
		N_STACK_MEM_SELECT => N_STACK_MEM_SELECT,
		SEL_CPU_BUMP => SELECT_CPU_BUMP,
		PROTECT_LOC_CPU_OR_MPX => PROT_LOC_CPU_OR_MPX,
		PROTECT_LOC_SEL_CHNL => PROT_LOC_SEL_CHNL,
		WX_CHK => WX_CHK,
		EARLY_M0 => EARLY_M_REG_0,
		ODD => ODD,
		SUPPR_A_REG_CHK => SUPPR_A_REG_CHK,
		STATUS_IN_LCHD => STATUS_IN_LCHD,
		STORE_R => STORE_R,
		SALS_PC => SAL_PC,
		R_REG_PC => R_REG_PC,
		N2ND_ERROR_STOP => N2ND_ERROR_STOP,
		MEM_WRAP => MEM_WRAP,
		USE_R => USE_R,
		USE_MAIN_MEM => USE_MAIN_MEMORY,
		USE_LOC_MAIN_MEM => USE_LOCAL_MAIN_MEMORY,
		USE_BASIC_CA_DECO => USE_BASIC_CA_DECO,
		USE_ALT_CA_DECODER => USE_ALT_CA_DECODER,
		SUPPR_MACH_CHK_TRAP => SUPPR_MACH_CHK_TRAP,
		SEL_DATA_READY => SEL_DATA_READY,
		N1401_MODE => N1401_MODE,
		STG_MEM_SELECT => STG_MEM_SEL,
		MEM_PROT_REQUEST => MEM_PROTECT_REQUEST,
		MANUAL_DISPLAY => MANUAL_DISPLAY,
		MAIN_STG => MAIN_STORAGE,
		MACH_RST_SW => MACH_RST_SW,
		MACH_RST_SET_LCH_DLY => MACH_RST_SET_LCH_DLY,
		MACH_CHK_RST => MACH_CHK_RST,
		MACH_CHK_PULSE => MACH_CHK_PULSE,
		LOCAL_STG => LOCAL_STORAGE_CP,
		GT_D_REG_TO_A_BUS => GT_D_REG_TO_A_BUS,
		GT_CA_TO_W_REG => GT_CA_TO_W_REG,
		DATA_READY => DATA_READY,
		CTRL_REG_CHK => CTRL_REG_CHK,
		CPU_WR_IN_R_REG => CPU_WRITE_IN_R_REG,
		CPU_SET_ALLOW_WR_LCH => CPU_SET_ALLOW_WR_LCH,
		ANY_PRIORITY_LCH => ANY_PRIORITY_LCH,
		ALLOW_WRITE_DLYD => ALLOW_WRITE_DLYD,
		ALLOW_WRITE => ALLOW_WRITE,
		T_REQUEST => T_REQUEST,
		P_8F_DETECTED => P_8F_DETECTED,
		CHK_SW_DISABLE => SW_CHK_SW_DISABLE,
		USE_MANUAL_DECODER => USE_MANUAL_DECODER,
		GATED_CA_BITS => GATED_CA_BITS,
		FIRST_MACH_CHK_REQ => FIRST_MACH_CHK_REQ,
		FIRST_MACH_CHK => FIRST_MACH_CHK,
		EXT_TRAP_MASK_ON => EXT_TRAP_MASK_ON,
		MACH_RST_2A => MACH_RST_2A,
		MACH_RST_2B => MACH_RST_2B,
		BASIC_CS0 => BASIC_CS0,
		ANY_MACH_CHK => ANY_MACH_CHK,
		ALLOW_PC_SALS => ALLOW_PC_SALS,
		CARRY_0 => CARRY_0,
		ALLOW_PROTECT => ALLOW_PROTECT,
		CS_DECODE_X001 => CS_DECODE_X001,
		DECIMAL => DECIMAL,
		M_REG_0 => M_REG_0,
		MACH_RST_PROT => MACH_RST_PROT,
		INTRODUCE_ALU_CHK => INTRODUCE_ALU_CHK,
		MPX_ROS_LCH => MPX_ROS_LCH,
		FT7 => FT7,
		FT6 => FT6,
		FT5 => FT5,
		FT2 => FT2,
		FT0 => FT0,
		FT3 => FT3,
		MPX_INTERRUPT => MPX_INTERRUPT,
		MPX_METERING_IN => MPX_METERING_IN,
		STORE_BITS => STORE_BITS,
		READ_ECHO_1 => READ_ECHO_1,
		READ_ECHO_2 => READ_ECHO_2,
		WRITE_ECHO_1 => WRITE_ECHO_1,
		WRITE_ECHO_2 => WRITE_ECHO_2,
		
		SERV_IN_LCHD => SERV_IN_LCHD,
		ADDR_IN_LCHD => ADDR_IN_LCHD,
		OPNL_IN_LCHD => OPNL_IN_LCHD,
		MACH_RST_MPX => MACH_RST_MPX,
		SET_FW => SET_FW,
		MPX_SHARE_REQ => MPX_SHARE_REQ,
		LOAD_IND => LOAD_IND,
		CLOCK_OUT => CLOCK_OUT,
		METERING_OUT => METERING_OUT,
		
		-- Signals from UDC3
		N_SEL_SHARE_HOLD => N_SEL_SHARE_HOLD, -- from 12D
		GK => GK, -- from 11B
		HK => HK, -- from 13B
		STORE_HR => STORE_HR,
		STORE_GR => STORE_GR,
		SEL_SHARE_CYCLE => SEL_SHARE_CYCLE,
		SEL_R_W_CTRL => SEL_R_W_CTRL,
		SEL_CHNL_CHK => SEL_CHNL_CHK,
		HR_REG_0_7 => HR_REG_0_7,
		GR_REG_0_7 => GR_REG_0_7,
		HR_REG_P_BIT => HR_REG_P_BIT,
		GR_REG_P_BIT => GR_REG_P_BIT,
		GT_HSMPX_INTO_R_REG => '0',
		DR_CORR_P_BIT => '0',
		GT_DETECTORS_TO_HR => GT_DETECTORS_TO_HR,
		GT_DETECTORS_TO_GR => GT_DETECTORS_TO_GR,
		EVEN_HR_0_7_BITS => EVEN_HR_0_7_BITS,
		EVEN_GR_0_7_BITS => EVEN_GR_0_7_BITS,
		ADDR_OUT => ADDR_OUT,
		
		-- Indicators
		IND_OPNL_IN => IND_OPNL_IN,
		IND_ADDR_IN => IND_ADDR_IN,
		IND_STATUS_IN => IND_STATUS_IN,
		IND_SERV_IN => IND_SERV_IN,
		IND_SEL_OUT => IND_SEL_OUT,
		IND_ADDR_OUT => IND_ADDR_OUT,
		IND_CMMD_OUT => IND_CMMD_OUT,
		IND_SERV_OUT => IND_SERV_OUT,
		IND_SUPPR_OUT => IND_SUPPR_OUT,
		IND_FO => IND_FO,
		IND_FO_P => IND_FO_P,
		IND_A => IND_A,
		IND_B => IND_B,
		IND_ALU => IND_ALU,
		IND_M => IND_M,
		IND_N => IND_N,
		IND_MAIN_STG => IND_MAIN_STG,
		IND_LOC_STG => IND_LOC_STG,
		IND_COMP_MODE => IND_COMP_MODE,
		IND_CHK_A_REG => IND_CHK_A_REG,
		IND_CHK_B_REG => IND_CHK_B_REG,
		IND_CHK_STOR_ADDR => IND_CHK_STOR_ADDR,
		IND_CHK_CTRL_REG => IND_CHK_CTRL_REG,
		IND_CHK_ROS_SALS => IND_CHK_ROS_SALS,
		IND_CHK_ROS_ADDR => IND_CHK_ROS_ADDR,
		IND_CHK_STOR_DATA => IND_CHK_STOR_DATA,
		IND_CHK_ALU => IND_CHK_ALU,
		
      -- Selector & Mpx channels
      MPX_BUS_O => MPX_BUS_O,
		MPX_BUS_I => MPX_BUS_I,
		MPX_TAGS_O => MPX_TAGS_O,
		MPX_TAGS_I => MPX_TAGS_I,
		FI => sFI,
		MPX_OPN_LT_GATE => MPX_OPN_LT_GATE,
		n1050_SEL_O => n1050_SEL_O,
		n1050_SEL_IN => n1050_SEL_IN,
		P_1050_SEL_OUT => P_1050_SEL_OUT,
		P_1050_SEL_IN => P_1050_SEL_IN,
		n1050_INSTALLED => n1050_INSTALLED,
		n1050_REQ_IN => n1050_REQ_IN,
		n1050_OP_IN => n1050_OP_IN,
      n1050_CE_MODE => n1050_CE_MODE,
	  
	   StorageIn => StorageIn,
	   StorageOut => StorageOut,
		
		-- UDC2 Debug stuff
		DEBUG => open,
		
		SEL_T1 => SEL_T1,
		T1 => T1,
		T2 => T2,
		T3 => T3,
		T4 => T4,
		P1 => P1,
		P2 => P2,
		P3 => P3,
		P4 => P4,
		SEL_T3 => SEL_T3,
		Clk => Clk
		);
			
	thirdBit : entity udc3 (FMD) port map (
		-- Inputs
		E_SW_SEL_BUS => E_SW,
		USE_MANUAL_DECODER => USE_MANUAL_DECODER,
		USE_ALT_CA_DECODER => USE_ALT_CA_DECODER,
		USE_BASIC_CA_DECO => USE_BASIC_CA_DECO,
		GTD_CA_BITS => GATED_CA_BITS,
		Z_BUS => Z_BUS,
		GT_1050_TAGS_OUT => GT_1050_TAGS,
		GT_1050_BUS_OUT => GT_1050_BUS,
--		PCH_CONN_ENTRY => PCH_CONN_ENTRY,
		P_1050_SEL_OUT => P_1050_SEL_OUT,
		P_1050_SEL_IN => P_1050_SEL_IN,
		n1050_OP_IN => n1050_OP_IN,
		SUPPRESS_OUT => FT0,
		CK_SAL_P_BIT => CK_SAL_P_BIT_TO_MPX,
		MPX_OPN_LT_GATE => MPX_OPN_LT_GATE,
		RECYCLE_RESET => RECYCLE_RST,
		
		-- Outputs
		A_BUS => A_BUS3,
		M_ASSM_BUS => M_ASSM_BUS3,
		N_ASSM_BUS => N_ASSM_BUS3,
		T_REQUEST => T_REQUEST,
--		RDR_1_CONN_EXIT => RDR_1_CONN_EXIT,
--		n1050_CONTROL => n1050_CONTROL,
		N1050_INTRV_REQ => N1050_INTRV_REQ,
		TT6_POS_ATTN => TT6_POS_ATTN,
		n1050_SEL_O => n1050_SEL_O,
		n1050_INSTALLED => n1050_INSTALLED,
		n1050_REQ_IN => n1050_REQ_IN,
      n1050_CE_MODE => n1050_CE_MODE,
		ADDR_OUT => ADDR_OUT,
		
		SerialInput => SerialInput,
		SerialOutput => SerialOutput,
		
		-- Clocks
		clk => clk,
		Clock1ms => Clock1ms,
		Clock60Hz => N60_CY_TIMER_PULSE,
		
		-- UDC3 debug
		DEBUG => open,

		T1 => T1,
		T2 => T2,
		T3 => T3,
		T4 => T4,
		P1 => P1,
		P2 => P2,
		P3 => P3,
		P4 => P4
	);

	M_CONV_OSC <= sM_CONV_OSC;
	
-- Temporary substitutes for UDC3
	SEL_CONV_OSC <= P_CONV_OSC; -- 12A
	SEL_BASIC_CLOCK_OFF <= not CLOCK_ON and not CLOCK_START_LCH; -- 12A

-- Combining buses
  M_ASSM_BUS2 <= M_ASSM_BUS1 or M_ASSM_BUS3;
  N_ASSM_BUS2 <= N_ASSM_BUS1 or N_ASSM_BUS3;
  A_BUS <= A_BUS1 and A_BUS3;
  
	
end FMD;
