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
--    Revision 1.1 2012-04-07
--    1050 Serial console added
--    External main and aux storage, with pre-loading from platform flash
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
				-- Seven-segment displays
	        ssd : out std_logic_vector(7 downto 0); -- 7-segment segment cathodes - active=0, a=bit0, g=bit6, dp=bit7
           ssdan : out std_logic_vector(3 downto 0); -- 7-segment digit anodes - active=0, RHS=bit0

				-- Discrete LEDs
           led : out std_logic_vector(7 downto 0); -- 8 LEDs
			  
			  -- Pushbuttons and switches
           pb : in std_logic_vector(3 downto 0); -- 4 pushbuttons
           sw : in std_logic_vector(7 downto 0); -- 8 slide switches
			  
			  -- Connections to scanned front panel switches
			  pa_io1,pa_io2,pa_io3,pa_io4 : in std_logic := '0'; -- 4 digital inputs
			  pa_io5,pa_io6,pa_io7,pa_io8,pa_io9,
			  pa_io10,pa_io11,pa_io12,pa_io13,pa_io14 : out std_logic; -- 10 digital switch scanning outputs
			  pa_io15,pa_io16,pa_io17,pa_io18,ma2_db0,ma2_db1,
			  ma2_db2,ma2_db3,ma2_db4,ma2_db5: in std_logic := '0'; -- 10 digital switch scan inputs
--			  ma2_db6,ma2_db7,ma2_astb,ma2_dstb,ma2_write, ma2_wait, ma2_reset, ma2_int : in std_logic := '0'; -- 8 digital inputs (not used)

				-- Keyboard connection
--				ps2_clk : inout std_logic; -- Keyboard/Mouse clock (not used)
--				ps2_data : inout std_logic; -- Keyboard/Mouse data (not used)

				-- Video output
				vga_r,vga_g,vga_b,vga_hs,vga_vs : out std_logic; -- VGA output RGB+Sync
				
				-- Panel switches input
				MAX7318_SCL : out std_logic;
				MAX7318_SDA : inout std_logic;
				-- Panel lights output
				MAX7219_CLK,MAX7219_LOAD,MAX7219_DIN : out std_logic;
				-- MAX6951 is charlieplexed LED mux (miniature panel)
				MAX6951_CLK,MAX6951_CS0,MAX6951_CS1,MAX6951_CS2,MAX6951_CS3,MAX6951_DIN : out std_logic;
				
			  -- Static RAM interface
			  sramaddr : out std_logic_vector(17 downto 0);
			  srama : inout std_logic_vector(8 downto 0);
			  sramace : out std_logic;
			  sramwe : out std_logic;
			  sramoe : out std_logic;
			  sramaub : out std_logic;
			  sramalb : out std_logic;
			  
			  -- Serial I/O
			  serialRx : in std_logic;
			  serialTx : out std_logic := '1';
			  
			  -- 50Mhz clock
			  clk : in std_logic;
			  
			  -- Configuration PROM interface
			  din : in std_logic;
			  reset_prom : out std_logic;
			  rclk : out std_logic);
			  
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
signal	IND_LP : STD_LOGIC;
-- SX
signal   IND_COUNT : STD_LOGIC_VECTOR(0 to 15) := "0000000000000000";
signal	IND_COUNT_LP, IND_COUNT_HP : STD_LOGIC := '1';
signal	IND_SX1_DATA : STD_LOGIC_VECTOR(0 to 7) := "00000000";
signal	IND_SX1_DATAP : STD_LOGIC := '1';
signal	IND_SX1_COMMAND: STD_LOGIC_VECTOR(0 to 7) := "00000000";
signal	IND_SX1_KEY: STD_LOGIC_VECTOR(0 to 3) := "0000";
signal	IND_SX1_KEYP : STD_LOGIC := '1';
signal	IND_SX1_PCI, IND_SX1_SKIP, IND_SX1_SLI, IND_SX1_CD, IND_SX1_CC : STD_LOGIC;
signal	IND_SX1_DA_CHK, IND_SX1_PROT_CHK, IND_SX1_PROG_CHK, IND_SX1_IL_CHK, IND_SX1_CHNLDATA_CHK, IND_SX1_IF_CHK, IND_SX1_CHNLCTRL_CHK : STD_LOGIC;
signal	IND_SX1_STATIN_TAG, IND_SX1_ADRIN_TAG, IND_SX1_OPIN_TAG, IND_SX1_SUPOUT_TAG, IND_SX1_SERVOUT_TAG, IND_SX1_CMMDOUT_TAG, IND_SX1_ADROUT_TAG, IND_SX1_SELOUT_TAG : STD_LOGIC;

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
signal	StorageIn : STORAGE_IN_INTERFACE;  -- CPU interface to storage
signal	StorageOut : STORAGE_OUT_INTERFACE;  -- CPU interface to storage
signal	SerialIn : PCH_CONN;
signal	SerialOut : RDR_CONN;
signal	SerialControl : CONN_1050;
signal	SerialBusUngated : STD_LOGIC_VECTOR(7 downto 0);
signal	RxDataAvailable : STD_LOGIC;
signal	RxAck, PunchGate : STD_LOGIC;

signal	SO : Serial_Output_Lines;

signal	SwSlow : STD_LOGIC := '0'; -- Set to '1' to slow clock down to 1Hz, not used

signal	N60_CY_TIMER_PULSE : STD_LOGIC; -- Used for the Interval Timer
signal	Clock1ms : STD_LOGIC; -- 1kHz clock for single-shots etc.

signal	DEBUG : DEBUG_BUS; -- Passed to all modeles to probe signals

signal LED_vector : std_logic_vector(0 to 255);
signal LED2_vector : std_logic_vector(0 to 4);
signal Switch_vector : std_logic_vector(0 to 63);

begin

	cpu : entity work.cpu port map (
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
			
			-- Storage interface
			StorageIn => StorageIn,
			StorageOut => StorageOut,
			
			-- Serial interface for 1050
			serialInput.SerialRx => SerialRx,
			serialInput.DCD => '1',
			serialInput.DSR => '1',
			serialInput.RI => '0',
			serialInput.CTS => '1',
			serialOutput => SO,
			
			-- Multiplexor interface not connected to anything yet
			MPX_BUS_O => open,
			MPX_BUS_I => (others=>'0'),
			MPX_TAGS_O => open,
			MPX_TAGS_I => (others=>'0'),
			
			DEBUG => DEBUG, -- Used to pass debug signals up to the top level for output
			N60_CY_TIMER_PULSE => N60_CY_TIMER_PULSE, -- Actually 50Hz
			Clock1ms => Clock1ms,
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
		Indicators(			  9) => IND_LP,
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
	led(7) <= DEBUG.Probe;
	
	IND_LP <= SW_LAMP_TEST;
	
	-- Temporary Selector Channel indicators
	IND_COUNT_LP <= '1';
	IND_COUNT_HP <= '1';
	IND_COUNT <= (others => SW_LAMP_TEST);
	IND_SX1_DATA <= (others => SW_LAMP_TEST);
	IND_SX1_DATAP <= SW_LAMP_TEST;
	IND_SX1_COMMAND <= (others => SW_LAMP_TEST);
	IND_SX1_KEY <= (others => SW_LAMP_TEST);
	IND_SX1_KEYP <= SW_LAMP_TEST;
	IND_SX1_PCI <= SW_LAMP_TEST;
	IND_SX1_SKIP <= SW_LAMP_TEST;
	IND_SX1_SLI <= SW_LAMP_TEST;
	IND_SX1_CD <= SW_LAMP_TEST;
	IND_SX1_CC <= SW_LAMP_TEST;
	IND_SX1_DA_CHK <= SW_LAMP_TEST;
	IND_SX1_PROT_CHK <= SW_LAMP_TEST;
	IND_SX1_PROG_CHK <= SW_LAMP_TEST;
	IND_SX1_IL_CHK <= SW_LAMP_TEST;
	IND_SX1_CHNLDATA_CHK <= SW_LAMP_TEST;
	IND_SX1_STATIN_TAG <= SW_LAMP_TEST;
	IND_SX1_ADRIN_TAG <= SW_LAMP_TEST;
	IND_SX1_OPIN_TAG <= SW_LAMP_TEST;
	IND_SX1_SUPOUT_TAG <= SW_LAMP_TEST;
	IND_SX1_SERVOUT_TAG <= SW_LAMP_TEST;
	IND_SX1_CMMDOUT_TAG <= SW_LAMP_TEST;
	IND_SX1_ADROUT_TAG <= SW_LAMP_TEST;
	IND_SX1_SELOUT_TAG <= SW_LAMP_TEST;
	IND_SX1_IF_CHK <= SW_LAMP_TEST;
	IND_SX1_CHNLCTRL_CHK <= SW_LAMP_TEST;
				
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
		
		-- MAX7318
		SCL => MAX7318_SCL,
		SDA => MAX7318_SDA,
		
		-- Clocks etc.
		clk => clk, -- 50MHz clock
		status_lamps(4) => IND_LOAD,
		status_lamps(3) => IND_TEST,
		status_lamps(2) => IND_WAIT,
		status_lamps(1) => IND_MAN,
		status_lamps(0) => IND_SYST,
--		Clock1ms => Clock1ms,
		Timer => N60_CY_TIMER_PULSE -- Output from Switches is actually 50Hz
		);

      core_storage : entity storage port map(
				phys_address => sramaddr(16 downto 0),
				phys_data => srama(8 downto 0),
				phys_CE => sramace,
				phys_OE => sramoe,
				phys_WE => sramwe,
				phys_UB => sramaub,
				phys_LB => sramalb,
				-- Interface to config ROM
				din => din,
				reset_prom => reset_prom,
				cclk => rclk,
				-- Storage interface to CPU
				StorageIn => StorageIn,
				StorageOut => StorageOut,
--				Debug => Debug,
				-- Other inputs
				clk => clk
				);
		sramaddr(17) <= '0';
		
		LED_vector <= (
				0 => IND_SALS.SALS_PA,
				1 => IND_SALS.SALS_CN(5),
				2 => IND_SALS.SALS_CN(4),
				3 => IND_SALS.SALS_CN(3),
				4 => IND_SALS.SALS_CN(2),
				5 => IND_SALS.SALS_CN(1),
				6 => IND_SALS.SALS_CN(0),
				7 => IND_SALS.SALS_PN,
				8 => X_IND_P,
				9 => WX_IND(4),
				10 => WX_IND(3),
				11 => WX_IND(2),
				12 => WX_IND(1),
				13 => WX_IND(0),
				14 => W_IND_P,
				15 => IND_LP,
				16 => WX_IND(12),
				17 => WX_IND(11),
				18 => WX_IND(10),
				19 => WX_IND(9),
				20 => WX_IND(8),
				21 => WX_IND(7),
				22 => WX_IND(6),
				23 => WX_IND(5),
				24 => IND_SALS.SALS_CL(2),
				25 => IND_SALS.SALS_CL(1),
				26 => IND_SALS.SALS_CL(0),
				27 => IND_SALS.SALS_CH(3),
				28 => IND_SALS.SALS_CH(2),
				29 => IND_SALS.SALS_CH(1),
				30 => IND_SALS.SALS_CH(0),
				31 => IND_SALS.SALS_PS,
				32 => IND_SALS.SALS_CB(1),
				33 => IND_SALS.SALS_CB(0),
				34 => IND_SALS.SALS_CA(3),
				35 => IND_SALS.SALS_CA(2),
				36 => IND_SALS.SALS_CA(1),
				37 => IND_SALS.SALS_CA(0),
				38 => IND_SALS.SALS_AA,
				39 => IND_SALS.SALS_CL(3),
				40 => IND_SALS.SALS_CK(0),
				41 => IND_SALS.SALS_PK,
				42 => IND_SALS.SALS_AK,
				43 => IND_SALS.SALS_CU(1),
				44 => IND_SALS.SALS_CU(0),
				45 => IND_SALS.SALS_CM(2),
				46 => IND_SALS.SALS_CM(1),
				47 => IND_SALS.SALS_CM(0),
				48 => IND_SALS.SALS_CD(3),
				49 => IND_SALS.SALS_CD(2),
				50 => IND_SALS.SALS_CD(1),
				51 => IND_SALS.SALS_CD(0),
				52 => IND_SALS.SALS_PC,
				53 => IND_SALS.SALS_CK(3),
				54 => IND_SALS.SALS_CK(2),
				55 => IND_SALS.SALS_CK(1),
				56 => IND_SALS.SALS_CC(0),
				57 => IND_SALS.SALS_CV(1),
				58 => IND_SALS.SALS_CV(0),
				59 => IND_SALS.SALS_CG(1),
				60 => IND_SALS.SALS_CG(0),
				61 => IND_SALS.SALS_CF(2),
				62 => IND_SALS.SALS_CF(1),
				63 => IND_SALS.SALS_CF(0),
				64 => IND_COUNT_HP, -- Count-P
				65 => IND_SALS.SALS_CS(3),
				66 => IND_SALS.SALS_CS(2),
				67 => IND_SALS.SALS_CS(1),
				68 => IND_SALS.SALS_CS(0),
				69 => IND_SALS.SALS_SA,
				70 => IND_SALS.SALS_CC(2),
				71 => IND_SALS.SALS_CC(1),
				-- Count 72-87,95
				72 => IND_COUNT(8),
				73 => IND_COUNT(6),
				74 => IND_COUNT(5),
				75 => IND_COUNT(4),
				76 => IND_COUNT(3),
				77 => IND_COUNT(2),
				78 => IND_COUNT(1),
				79 => IND_COUNT(0),
				80 => IND_COUNT(15),
				81 => IND_COUNT(14),
				82 => IND_COUNT(13),
				83 => IND_COUNT(12),
				84 => IND_COUNT(11),
				85 => IND_COUNT(10),
				86 => IND_COUNT(9),
				87 => IND_COUNT_LP,
				95 => IND_COUNT(0),
				-- SX1
				88 => IND_SX1_DATA(5),
				89 => IND_SX1_DATA(4),
				90 => IND_SX1_DATA(3),
				91 => IND_SX1_DATA(2),
			   92 => IND_SX1_DATA(1),
				93 => IND_SX1_DATA(0),
				94 => IND_SX1_DATAP,
				96 => IND_SX1_COMMAND(4),
				97 => IND_SX1_KEY(3),
				98 => IND_SX1_KEY(2),
				99 => IND_SX1_KEY(1),
				100 => IND_SX1_KEY(0),
				101 => IND_SX1_KEYP,
				102 => IND_SX1_DATA(7),
				103 => IND_SX1_DATA(6),
				104 => IND_SX1_PCI,
				105 => IND_SX1_SKIP,
				106 => IND_SX1_SLI,
				107 => IND_SX1_CD,
				108 => IND_SX1_CC,
				109 => IND_SX1_COMMAND(7),
				110 => IND_SX1_COMMAND(6),
				111 => IND_SX1_COMMAND(5),
				112 => IND_SX1_DA_CHK,
				113 => IND_SX1_PROT_CHK,
				114 => IND_SX1_PROG_CHK,
				115 => IND_SX1_IL_CHK,
				116 => IND_SX1_CHNLDATA_CHK,
				117 => IND_SX1_STATIN_TAG,
				118 => IND_SX1_ADRIN_TAG,
				119 => IND_SX1_OPIN_TAG,
				120 => '0', -- LED5
				121 => IND_SX1_SUPOUT_TAG,
				122 => IND_SX1_SERVOUT_TAG,
				123 => IND_SX1_CMMDOUT_TAG,
				124 => IND_SX1_ADROUT_TAG,
				125 => IND_SX1_SELOUT_TAG,
				126 => IND_SX1_IF_CHK,
				127 => IND_SX1_CHNLCTRL_CHK,
				-- SX2 128-150. 162-167
				
				-- Temporary indicators 152-159
				152 => IND_LOAD,
				153 => IND_TEST,
				154 => IND_WAIT,
				155 => IND_MAN,
				156 => IND_SYST,
				157 => '1', -- Power
				158 => '1',
				159 => '1',

				160 => IND_ADDR_IN,
				161 => IND_OPNL_IN,
				-- 162-167 in SX2
				168 => IND_FO_P,
				169 => IND_SUPPR_OUT,
				170 => IND_SERV_OUT,
				171 => IND_CMMD_OUT,
				172 => IND_ADDR_OUT,
				173 => IND_SEL_OUT,
				174 => IND_SERV_IN,
				175 => IND_STATUS_IN,
				176 => IND_FO(7),
				177 => IND_FO(6),
				178 => IND_FO(5),
				179 => IND_FO(4),
				180 => IND_FO(3),
				181 => IND_FO(2),
				182 => IND_FO(1),
				183 => IND_FO(0),
				184 => IND_M(6),
				185 => IND_M(5),
				186 => IND_M(4),
				187 => IND_M(3),
				188 => IND_M(2),
				189 => IND_M(1),
				190 => IND_M(0),
				191 => IND_M(8),
				192 => IND_N(5),
				193 => IND_N(4),
				194 => IND_N(3),
				195 => IND_N(2),
				196 => IND_N(1),
				197 => IND_N(0),
				198 => IND_N(8),
				199 => IND_M(7),
				200 => IND_MSDR(2),
				201 => IND_MSDR(1),
				202 => IND_MSDR(0),
				203 => IND_MSDR_P,
				204 => IND_LOC_STG,
				205 => IND_MAIN_STG,
				206 => IND_N(7),
				207 => IND_N(6),
				208 => IND_ALU(1),
				209 => IND_ALU(0),
				210 => IND_ALU(8),
				211 => IND_MSDR(7),
				212 => IND_MSDR(6),
				213 => IND_MSDR(5),
				214 => IND_MSDR(4),
				215 => IND_MSDR(3),
				216 => IND_B(0),
				217 => IND_B(8),
				218 => IND_ALU(7),
				219 => IND_ALU(6),
				220 => IND_ALU(5),
				221 => IND_ALU(4),
				222 => IND_ALU(3),
				223 => IND_ALU(2),
				224 => IND_A(8),
				225 => IND_B(7),
				226 => IND_B(6),
				227 => IND_B(5),
				228 => IND_B(4),
				229 => IND_B(3),
				230 => IND_B(2),
				231 => IND_B(1),
				232 => IND_A(7),
				233 => IND_A(6),
				234 => IND_A(5),
				235 => IND_A(4),
				236 => IND_A(3),
				237 => IND_A(2),
				238 => IND_A(1),
				239 => IND_A(0),
				240 => IND_CHK_B_REG,
				241 => IND_1050_REQ,
				242 => IND_1050_INTRV,
				243 => IND_CHK_STOR_DATA,
				244 => IND_CHK_STOR_ADDR,
				245 => IND_ALLOW_WR,
				246 => IND_CY_MATCH,
				247 => IND_EX,
				248 => IND_CHK_CTRL_REG,
				249 => IND_CHK_ROS_SALS,
				250 => IND_CHK_ROS_ADDR,
				251 => IND_COMP_MODE,
				252 => IND_SEL_CHNL,
				253 => IND_MPX,
				254 => IND_CHK_ALU,
				255 => IND_CHK_A_REG,
				others => '0');
				
		LED2_vector <= (
				0=>IND_LOAD,
				1=>IND_TEST,
				2=>IND_WAIT,
				3=>IND_MAN,
				4=>IND_SYST);
		
		front_panel_LEDs : entity panel_LEDs 
		generic map(
			clock_divider => 2,
			number_LEDs => 256
			)
		port map(
			clk => clk,
			LEDs => LED_vector,

			-- MAX7219 is standard LED mux (full-size panel)
			MAX7219_CLK => MAX7219_CLK,
			MAX7219_LOAD => MAX7219_LOAD,
			MAX7219_DIN => MAX7219_DIN,
			-- MAX6951 is charlieplexed LED mux (miniature panel)
			MAX6951_CLK => MAX6951_CLK,
			MAX6951_CS0 => MAX6951_CS0,
			MAX6951_CS1 => MAX6951_CS1,
			MAX6951_CS2 => MAX6951_CS2,
			MAX6951_CS3 => MAX6951_CS3,
			MAX6951_DIN => MAX6951_DIN
			);
			
		number_LEDs : entity segment_LEDs
		port map(
			clk => clk,
			number(15 downto 13) => "000",
			number(12 downto 0) => WX_IND(0 to 12),
			anodes => ssdan,
			cathodes => ssd
			);
			
		DEBUG.Selection <= CONV_INTEGER(unsigned(SW_J));
		
		SerialTx <= SO.SerialTx;
		
-- with DEBUG.Selection select
--	DEBUG.Probe <=
--		SerialBusUngated(0) when 0, SerialBusUngated(1) when 1, SerialBusUngated(2) when 2, SerialBusUngated(3) when 3,
--		SerialBusUngated(4) when 4, SerialBusUngated(5) when 5, SerialBusUngated(6) when 6, SerialBusUngated(7) when 7,
--		RxDataAvailable when others;
				
end FMD;
