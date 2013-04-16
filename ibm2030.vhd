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
--    File: ibm2030.vhd
--    Creation Date: 21:17:39 2005-04-18
--    Description:
--    Top-level System360/30, including CPU, Panel Lamps and Panel Switches
--    Does not yet include I/O
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-09
--    Initial release - no I/O
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

entity ibm2030 is
    Port ( -- Physical I/O on Digilent S3 Board
--	        ssd : out std_logic_vector(7 downto 0); -- 7-segment segment cathodes (not used)
--         ssdan : out std_logic_vector(3 downto 0); -- 7-segment digit anodes (not used)
           led : out std_logic_vector(7 downto 0); -- 8 LEDs
           pb : in std_logic_vector(3 downto 0); -- 4 pushbuttons
           sw : in std_logic_vector(7 downto 0); -- 8 slide switches
			  pa_io1,pa_io2,pa_io3,pa_io4 : in std_logic := '0'; -- 4 digital inputs
			  pa_io5,pa_io6,pa_io7,pa_io8,pa_io9,
			  pa_io10,pa_io11,pa_io12,pa_io13,pa_io14 : out std_logic; -- 10 digital switch scanning outputs
			  pa_io15,pa_io16,pa_io17,pa_io18,ma2_db0,ma2_db1,
			  ma2_db2,ma2_db3,ma2_db4,ma2_db5: in std_logic := '0'; -- 10 digital switch scan inputs
--			  ma2_db6,ma2_db7,ma2_astb,ma2_dstb,ma2_write, ma2_wait, ma2_reset, ma2_int : in std_logic := '0'; -- 8 digital inputs (not used)
--			  ps2_clk : inout std_logic; -- Keyboard/Mouse clock (not used)
--			  ps2_data : inout std_logic; -- Keyboard/Mouse data (not used)
			  vga_r,vga_g,vga_b,vga_hs,vga_vs : out std_logic; -- VGA output RGB+Sync
			  clk : in std_logic);
end ibm2030;

architecture FMD of ibm2030 is

-- Indicator outputs from CPU
signal	WX_IND : std_logic_vector(0 to 12);
signal	W_IND_P : std_logic;
signal	X_IND_P : std_logic;
signal	IND_SALS : SALS_BUS;
signal	IND_EX,IND_CY_MATCH,IND_ALLOW_WR,IND_1050_INTRV,IND_1050_REQ,IND_MPX,IND_SEL_CHNL : STD_LOGIC;
signal	IND_MSDR : STD_LOGIC_VECTOR(0 to 7);
signal	IND_MSDR_P : STD_LOGIC;
signal	IND_OPNL_IN : STD_LOGIC;
signal	IND_ADDR_IN : STD_LOGIC;
signal	IND_STATUS_IN : STD_LOGIC;
signal	IND_SERV_IN : STD_LOGIC;
signal	IND_SEL_OUT : STD_LOGIC;
signal	IND_ADDR_OUT : STD_LOGIC;
signal	IND_CMMD_OUT : STD_LOGIC;
signal	IND_SERV_OUT : STD_LOGIC;
signal	IND_SUPPR_OUT : STD_LOGIC;
signal	IND_FO : STD_LOGIC_VECTOR(0 to 7);
signal	IND_FO_P: STD_LOGIC;
signal	IND_A : STD_LOGIC_VECTOR(0 to 8);
signal	IND_B : STD_LOGIC_VECTOR(0 to 8);
signal	IND_ALU : STD_LOGIC_VECTOR(0 to 8);
signal	IND_M : STD_LOGIC_VECTOR(0 to 8);
signal	IND_N : STD_LOGIC_VECTOR(0 to 8);
signal	IND_MAIN_STG : STD_LOGIC;
signal	IND_LOC_STG : STD_LOGIC;
signal	IND_COMP_MODE : STD_LOGIC;
signal	IND_CHK_A_REG : STD_LOGIC;
signal	IND_CHK_B_REG : STD_LOGIC;
signal	IND_CHK_STOR_ADDR : STD_LOGIC;
signal	IND_CHK_CTRL_REG : STD_LOGIC;
signal	IND_CHK_ROS_SALS : STD_LOGIC;
signal	IND_CHK_ROS_ADDR : STD_LOGIC;
signal	IND_CHK_STOR_DATA : STD_LOGIC;
signal	IND_CHK_ALU : STD_LOGIC;
signal	IND_SYST : STD_LOGIC;
signal	IND_MAN : STD_LOGIC;
signal	IND_WAIT : STD_LOGIC;
signal	IND_TEST : STD_LOGIC;
signal	IND_LOAD : STD_LOGIC;

-- Switch inputs to CPU
signal	SW_START,SW_LOAD,SW_SET_IC,SW_STOP,SW_POWER_OFF : STD_LOGIC;
signal	SW_INH_CF_STOP,SW_PROC,SW_SCAN : STD_LOGIC;
signal	SW_SINGLE_CYCLE,SW_INSTRUCTION_STEP,SW_RATE_SW_PROCESS : STD_LOGIC;
signal	SW_LAMP_TEST,SW_DSPLY,SW_STORE,SW_SYS_RST : STD_LOGIC;
signal	SW_CHK_RST,SW_ROAR_RST,SW_CHK_RESTART,SW_DIAGNOSTIC : STD_LOGIC;
signal	SW_CHK_STOP,SW_CHK_SW_PROCESS,SW_CHK_SW_DISABLE,SW_ROAR_RESTT_STOR_BYPASS : STD_LOGIC;
signal	SW_ROAR_RESTT,SW_ROAR_RESTT_WITHOUT_RST,SW_EARLY_ROAR_STOP,SW_ROAR_STOP : STD_LOGIC;
signal	SW_ROAR_SYNC,SW_ADDR_COMP_PROC,SW_SAR_DLYD_STOP,SW_SAR_STOP,SW_SAR_RESTART : STD_LOGIC;
signal	SW_INTRP_TIMER, SW_CONS_INTRP : STD_LOGIC;
signal	SW_A,SW_B,SW_C,SW_D,SW_F,SW_G,SW_H,SW_J : STD_LOGIC_VECTOR(0 to 3);
signal	SW_AP,SW_BP,SW_CP,SW_DP,SW_FP,SW_GP,SW_HP,SW_JP : STD_LOGIC;
signal	E_SW : E_SW_BUS_Type;

-- Misc stuff
signal	SwSlow : STD_LOGIC := '0'; -- Set to '1' to slow clock down to 1Hz, not used

signal	N60_CY_TIMER_PULSE : STD_LOGIC; -- Used for the Interval Timer

signal	DEBUG : STD_LOGIC := '0'; -- Spare variable for debug purposes

begin

	cpu : entity cpu port map (
			WX_IND => WX_IND,
			W_IND_P => W_IND_P,
			X_IND_P => X_IND_P,
			IND_SALS => IND_SALS,
			IND_EX => IND_EX,
			IND_CY_MATCH => IND_CY_MATCH,
			IND_ALLOW_WR => IND_ALLOW_WR,
			IND_1050_INTRV => IND_1050_INTRV,
			IND_1050_REQ => IND_1050_REQ,
			IND_MPX => IND_MPX,
			IND_SEL_CHNL => IND_SEL_CHNL,
			IND_MSDR => IND_MSDR,
			IND_MSDR_P => IND_MSDR_P,
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
			IND_LOAD => IND_LOAD,
			IND_WAIT => IND_WAIT,
			IND_TEST => IND_TEST,
			IND_MAN => IND_MAN,
			IND_SYST => IND_SYST,
			
			SW_START => SW_START,
			SW_LOAD => SW_LOAD,
			SW_SET_IC => SW_SET_IC,
			SW_STOP => SW_STOP,
			SW_POWER_OFF => SW_POWER_OFF,
			SW_INH_CF_STOP => SW_INH_CF_STOP,
			SW_PROC => SW_PROC,
			SW_SCAN => SW_SCAN,
			SW_SINGLE_CYCLE => SW_SINGLE_CYCLE,
			SW_INSTRUCTION_STEP => SW_INSTRUCTION_STEP,
			SW_RATE_SW_PROCESS => SW_RATE_SW_PROCESS,
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
			SW_A => SW_A,
			SW_B => SW_B,
			SW_C => SW_C,
			SW_D => SW_D,
			SW_F => SW_F,
			SW_G => SW_G,
			SW_H => SW_H,
			SW_J => SW_J,
			SW_AP => SW_AP,
			SW_BP => SW_BP,
			SW_CP => SW_CP,
			SW_DP => SW_DP,
			SW_FP => SW_FP,
			SW_GP => SW_GP,
			SW_HP => SW_HP,
			SW_JP => SW_JP,
			E_SW => E_SW,
			
			-- Multiplexor interface not connected to anything yet
			MPX_BUS_O => open,
			MPX_BUS_I => (others=>'0'),
			MPX_TAGS_O => open,
			MPX_TAGS_I => (others=>'0'),
			
			DEBUG => DEBUG, -- Used to pass debug signals up to the top level for output
			N60_CY_TIMER_PULSE => N60_CY_TIMER_PULSE, -- Actually 50Hz
			SwSlow => SwSlow,
			clk => clk -- 50Mhz clock
			);


	frontPanel : entity vga_panel port map (
		Clock50 => clk,
		Red => vga_r, Green => vga_g, Blue => vga_b,
		HS => vga_hs, VS => vga_vs,

		Indicators(			  0) => '0', -- Constant
		Indicators(  		  1) => IND_SALS.SALS_PN,
		Indicators(  2 to	  7) => IND_SALS.SALS_CN,
		Indicators(  		  8) => IND_SALS.SALS_PA,
		Indicators(			  9) => '0', -- LP
		Indicators(			 10) => W_IND_P,
		Indicators( 11 to	 15) => WX_IND(0 to 4),
		Indicators(			 16) => X_IND_P,
		Indicators( 17 to	 24) => WX_IND(5 to 12),
		Indicators(			 25) => IND_SALS.SALS_PS,
		Indicators( 26 to	 29) => IND_SALS.SALS_CH,
		Indicators( 30 to	 33) => IND_SALS.SALS_CL,
		Indicators(			 34) => IND_SALS.SALS_AA,
		Indicators( 35 to	 38) => IND_SALS.SALS_CA,
		Indicators( 39 to	 40) => IND_SALS.SALS_CB,
		Indicators( 41 to	 43) => IND_SALS.SALS_CM,
		Indicators( 44 to	 45) => IND_SALS.SALS_CU,
		Indicators(			 46) => IND_SALS.SALS_AK,
		Indicators(			 47) => IND_SALS.SALS_PK,
		Indicators( 48 to	 51) => IND_SALS.SALS_CK,
		Indicators(			 52) => IND_SALS.SALS_PC,
		Indicators( 53 to	 56) => IND_SALS.SALS_CD,
		Indicators( 57 to	 59) => IND_SALS.SALS_CF,
		Indicators( 60 to	 61) => IND_SALS.SALS_CG,
		Indicators( 62 to	 63) => IND_SALS.SALS_CV,
		Indicators( 64 to	 66) => IND_SALS.SALS_CC,
		Indicators(			 67) => IND_SALS.SALS_SA,
		Indicators( 68 to	 71) => IND_SALS.SALS_CS,
		-- Skip 18 + 9 + 9 + 5 + 9 + 6 = 56 for SX1 (72 to 127)
		Indicators( 72	to	127) => "00000000000000000000000000000000000000000000000000000000",
		-- If we had SX2 there would be another 56 here
		-- MPX
		Indicators(			128) => IND_OPNL_IN,
		Indicators(			129) => IND_ADDR_IN,
		Indicators(			130) => IND_STATUS_IN,
		Indicators(			131) => IND_SERV_IN,
		Indicators(			132) => IND_SEL_OUT,
		Indicators(			133) => IND_ADDR_OUT,
		Indicators(			134) => IND_CMMD_OUT,
		Indicators(			135) => IND_SERV_OUT,
		Indicators(			136) => IND_SUPPR_OUT,
		Indicators(			137) => IND_FO_P,
		Indicators(138	to	145) => IND_FO,
		-- MSAR
		Indicators(			146) => IND_MAIN_STG,
		Indicators(       147) => IND_M(8),
		Indicators(148 to 155) => IND_M(0 to 7),
		Indicators(       156) => IND_N(8),
		Indicators(157 to 164) => IND_N(0 to 7),
		Indicators(			165) => IND_LOC_STG,
		-- MSDR
		Indicators(			166) => IND_MSDR_P,
		Indicators(167 to 174) => IND_MSDR,
		-- ALU
		Indicators(			175) => IND_ALU(8),
		Indicators(176	to	183) => IND_ALU(0 to 7),
		Indicators(			184) => IND_EX,
		Indicators(			185) => IND_CY_MATCH,
		Indicators(			186) => IND_ALLOW_WR,
		Indicators(			187) => IND_CHK_STOR_ADDR,
		Indicators(			188) => IND_CHK_STOR_DATA,
		Indicators(			189) => IND_1050_INTRV,
		Indicators(			190) => IND_1050_REQ,
		Indicators(			191) => IND_CHK_B_REG,
		Indicators(			192) => IND_CHK_A_REG,
		Indicators(			193) => IND_CHK_ALU,
		-- A,B
		Indicators(			194) => IND_A(8),
		Indicators(195	to	202) => IND_A(0 to 7),
		Indicators(			203) => IND_B(8),
		Indicators(204 to 211) => IND_B(0 to 7),
		Indicators(			212) => IND_MPX,
		Indicators(			213) => IND_SEL_CHNL,
		Indicators(			214) => IND_COMP_MODE,
		Indicators(			215) => IND_CHK_ROS_ADDR,
		Indicators(			216) => IND_CHK_ROS_SALS,
		Indicators(			217) => IND_CHK_CTRL_REG,
		-- The following indicators mimic the 8 Hex rotary switches to make it easier to set them
		Indicators(218 to 221) => SW_A(0 to 3),
		Indicators(222 to 225) => SW_B(0 to 3),
		Indicators(226 to 229) => SW_C(0 to 3),
		Indicators(230 to 233) => SW_D(0 to 3),
		Indicators(234 to 237) => SW_F(0 to 3),
		Indicators(238 to 241) => SW_G(0 to 3),
		Indicators(242 to 245) => SW_H(0 to 3),
		Indicators(246 to 249) => SW_J(0 to 3)
	);
   -- LEDs are set here		
	led(0) <= IND_LOAD;
	led(1) <= IND_TEST;
	led(2) <= IND_WAIT;
	led(3) <= IND_MAN;
	led(4) <= IND_SYST;
	led(5) <= '0';
 	led(6) <= '0';
	led(7) <= DEBUG;
	
	frontPanel_switches: entity switches port map (
	   -- Hardware switch inputs and scan outputs
		SwA_scan => pa_io5,
		SwB_scan => pa_io6,
		SwC_scan => pa_io7,
		SwD_scan => pa_io8,
		SwE_scan => pa_io9,
		SwF_scan => pa_io10,
		SwG_scan => pa_io11,
		SwH_scan => pa_io12,
		SwJ_scan => pa_io13,
		SwAC_scan => pa_io14,
		Hex_in(0) => pa_io1,
		Hex_in(1) => pa_io2,
		Hex_in(2) => pa_io3,
		Hex_in(3) => pa_io4,
		SW_E_INNER => pa_io15,
		SW_E_OUTER => pa_io16,
		RawSw_Proc_Inh_CF_Stop => pa_io17,
		RawSw_Proc_Scan => pa_io18,
		RawSw_Rate_Single_Cycle => ma2_db1,
		RawSw_Rate_Instruction_Step => ma2_db0,
		RawSw_Chk_Chk_Restart => ma2_db5,
		RawSw_Chk_Diagnostic => ma2_db2,
		RawSw_Chk_Stop => ma2_db4,
		RawSw_Chk_Disable => ma2_db3,
		sw => sw,
		pb => pb,

      -- Switches fed to CPU
		SwA => SW_A, SwAP => SW_AP,
		SwB => SW_B, SwBP => SW_BP,
		SwC => SW_C, SwCP => SW_CP,
		SwD => SW_D, SwDP => SW_DP,
		SwE => E_SW,
		SwF => SW_F, SwFP => SW_FP,
		SwG => SW_G, SwGP => SW_GP,
		SwH => SW_H, SwHP => SW_HP,
		SwJ => SW_J, SwJP => SW_JP,
	   Sw_PowerOff => SW_POWER_OFF,
		Sw_Interrupt => SW_CONS_INTRP,
		Sw_Load => SW_LOAD,
	   Sw_SystemReset => SW_SYS_RST,
		Sw_RoarReset => SW_ROAR_RST,
		Sw_Start => SW_START,
		Sw_SetIC => SW_SET_IC,
		Sw_CheckReset => SW_CHK_RST,
	   Sw_Stop => SW_STOP,
		Sw_IntTmr => SW_INTRP_TIMER,
		Sw_Store => SW_STORE,
		Sw_LampTest => SW_LAMP_TEST,
		Sw_Display => SW_DSPLY,
		Sw_Proc_Inh_CF_Stop => SW_INH_CF_STOP,
		Sw_Proc_Proc => SW_PROC,
		Sw_Proc_Scan => SW_SCAN,
		Sw_Rate_Single_Cycle => SW_SINGLE_CYCLE,
		Sw_Rate_Instruction_Step => SW_INSTRUCTION_STEP,
		Sw_Rate_Process => SW_RATE_SW_PROCESS,
		Sw_Chk_Chk_Restart => SW_CHK_RESTART,
		Sw_Chk_Diagnostic => SW_DIAGNOSTIC,
		Sw_Chk_Stop => SW_CHK_STOP,
		Sw_Chk_Process => SW_CHK_SW_PROCESS,
		Sw_Chk_Disable => SW_CHK_SW_DISABLE,
		Sw_ROAR_RESTT_STOR_BYPASS => SW_ROAR_RESTT_STOR_BYPASS,
		Sw_ROAR_RESTT => SW_ROAR_RESTT,
		Sw_ROAR_RESTT_WITHOUT_RST => SW_ROAR_RESTT_WITHOUT_RST,
		Sw_EARLY_ROAR_STOP => SW_EARLY_ROAR_STOP,
		Sw_ROAR_STOP => SW_ROAR_STOP,
		Sw_ROAR_SYNC => SW_ROAR_SYNC,
		Sw_ADDR_COMP_PROC => SW_ADDR_COMP_PROC,
		Sw_SAR_DLYD_STOP => SW_SAR_DLYD_STOP,
		Sw_SAR_STOP => SW_SAR_STOP,
		Sw_SAR_RESTART => SW_SAR_RESTART,
		
		-- Clocks etc.
		clk => clk, -- 50MHz clock
		Timer => N60_CY_TIMER_PULSE -- Output from Switches is actually 50Hz
		);

end FMD;
