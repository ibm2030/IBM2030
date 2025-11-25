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
LIBRARY buses;
USE buses.Buses_package.all;
use UNISIM.vcomponents.all;
use work.all;

entity ibm2030 is
    Generic ( ClockFrequency : integer := 125 );
    Port ( -- Physical I/O on Digilent Zybo z7020 Board
            -- PMOD JA (XADC) Serial I/O
            -- PMOD JB (HS) MAX7219 (FS panel)
            -- PMOD JC (HS) VGA
            -- PMOD JD (HS) VGA
            -- PMOD JE (Std) Max6951 (mini panel) MAX7318 (switches)
            -- PMOD JF (MIO) Unused
            
			-- Discrete LEDs
            rgbled : out std_logic_vector(5 downto 0); -- 2 RGB LEDs LED6 R V16 G F17 B M17  LED5 R Y11 G T5 B Y12
            led : out std_logic_vector(4 downto 0);      -- 5 LEDs MIO7 D18 G14 M15 M14
			  
			-- Pushbuttons and switches
            pb : in std_logic_vector(5 downto 0); -- 6 pushbuttons MIO51,MIO50,Y16,K19,P16,K18
            sw : in std_logic_vector(3 downto 0); -- 4 slide switches T16 W13 P15 G15
			  
            -- I2C for switches PMOD JD
            MAX7318_SCL : out std_logic;    -- PMOD JE 1 V12
            MAX7318_SDA : inout std_logic;  -- PMOD JE 2 W16
            -- I2C for lamps
            -- MAX7219 is standard LED mux (full-size panel)
            MAX7219_CLK, MAX7219_LOAD, MAX7219_DIN : out std_logic; --  PMOD JB 1,2,3 V8 W8 U7
			-- MAX6951 is charlieplexed LED mux (miniature panel)
            MAX6951_CLK,MAX6951_CS0,MAX6951_CS1,MAX6951_CS2,MAX6951_CS3,MAX6951_DIN : out std_logic; -- PMOD JE 3,4,5,6,7,8 J15 H15 V13 U17 T17 Y17

			-- Keyboard connection
--				ps2_clk : inout std_logic; -- Keyboard/Mouse clock (not used)
--				ps2_data : inout std_logic; -- Keyboard/Mouse data (not used)

            -- VGA output
            red0, red1, red2, red3, blue0, blue1, blue2, blue3, green0, green1, green2, green3, vga_hs, vga_vs : out std_logic;   -- PMOD JC (J1),JD (J2) V15 W15 T11 T10 W14 Y14 T12 U12 T14 T15 P14 R14 U14 U15
            
			-- HDMI output
			d_p : out std_logic_vector(2 downto 0);     -- B19,C20,D19
			d_n : out std_logic_vector(2 downto 0);     -- A20,B20,D20
			clk_p : out std_logic;                      -- H16
			clk_n : out std_logic;                      -- H17
            				
			-- Serial I/O PMOD JA
			SerialRx : in std_logic;           -- JA4 K14
			SerialTx : out std_logic := '1';   -- JA3 K16
			SerialRTS : out std_logic := '1';  -- Unused
			SerialDTR : out std_logic := '1';  -- Unused
			  
			-- MicroSD
--            sd_d : inout std_logic_vector(3 downto 0);    -- MIO45,44,43,42
--            sd_cclk : out std_logic;                      -- MIO40
--            sd_cmd : inout std_logic;                     -- MIO41
--            sd_cd : in std_logic;                         -- NIO47  
			  
			-- Configuration PROM interface
--			din : in std_logic;
--			reset_prom : out std_logic;
--			rclk : out std_logic);

            -- AXI interface from PS to storag
            bram1_addr : in std_logic_vector(15 downto 2);
	        bram1_clk : in std_logic;
        	bram1_wrdata : in std_logic_vector(31 downto 0);
	        bram1_en : in std_logic;
	        bram1_rst : in std_logic;
	        bram1_we : in std_logic_vector(3 downto 0);
            bram1_rddata : out std_logic_vector(31 downto 0);
	        
        	bram2_addr : in std_logic_vector(10 downto 2);
	        bram2_clk : in std_logic;
	        bram2_wrdata : in std_logic_vector(31 downto 0);
	        bram2_en : in std_logic;
	        bram2_rst : in std_logic;
	        bram2_we : in std_logic_vector(3 downto 0);
	        bram2_rddata : out std_logic_vector(31 downto 0);
                        
			-- 125Mhz, fastest clock
			sysclk : in std_logic;  -- K17
			-- 50MHz clock
			clk50M : in std_logic;
			-- 40MHz clock
			clk40M : in std_logic);
		  
			  
end ibm2030;

architecture FMD of ibm2030 is

attribute X_INTERFACE_INFO : string;

attribute X_INTERFACE_INFO of bram1_addr : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL ADDR"; 
attribute X_INTERFACE_INFO of bram1_clk : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL CLK"; 
attribute X_INTERFACE_INFO of bram1_wrdata : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL DIN"; 
attribute X_INTERFACE_INFO of bram1_en : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL EN"; 
attribute X_INTERFACE_INFO of bram1_rst : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL RST"; 
attribute X_INTERFACE_INFO of bram1_we : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL WE"; 
attribute X_INTERFACE_INFO of bram1_rddata : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM1_CTRL DOUT"; 

attribute X_INTERFACE_INFO of bram2_addr : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL ADDR"; 
attribute X_INTERFACE_INFO of bram2_clk : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL CLK"; 
attribute X_INTERFACE_INFO of bram2_wrdata : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL DIN"; 
attribute X_INTERFACE_INFO of bram2_en : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL EN"; 
attribute X_INTERFACE_INFO of bram2_rst : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL RST"; 
attribute X_INTERFACE_INFO of bram2_we : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL WE"; 
attribute X_INTERFACE_INFO of bram2_rddata : signal is "xilinx.com:interface:bram_rtl:1.0 BRAM2_CTRL DOUT"; 


-- Temporary HDMI output stub
component hdmi_panel port (
    Clock125 : in std_logic;
    Indicators : in std_logic_vector(0 to 249)
);
end component;

-- Indicator outputs from CPU
-- signal  Indicators : std_logic_vector(0 to 259);
signal	W_IND : std_logic_vector(3 to 7);
signal	X_IND : std_logic_vector(0 to 7);
signal	W_IND_P : std_logic;
signal	X_IND_P : std_logic;
signal	IND_SALS : SALS_BUS;
signal	IND_EX,IND_CY_MATCH,IND_ALLOW_WR,IND_1050_INTRV,IND_1050_REQ,IND_MPX,IND_SEL_CHNL : STD_LOGIC;
signal	IND_MSDR : STD_LOGIC_VECTOR(0 to 7);
signal	IND_MSDR_P : STD_LOGIC;
signal	IND_SEL_IN : STD_LOGIC;
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
signal  IND_COUNT : STD_LOGIC_VECTOR(0 to 15) := "0000000000000000";
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
-- signal	SerialIn : PCH_CONN;
-- signal	SerialOut : RDR_CONN;
-- signal	SerialControl : CONN_1050;
signal	SerialBusUngated : STD_LOGIC_VECTOR(7 downto 0);
signal	RxDataAvailable : STD_LOGIC;
signal	RxAck, PunchGate : STD_LOGIC;
signal  vga_r, vga_g, vga_b : STD_LOGIC;

-- signal	SO : Serial_Output_Lines;
-- signal  SI : Serial_Input_Lines;
signal  n1050Outputs : PCH_CONN;
signal  n1050Inputs : RDR_CONN;
signal  n1050Control : CONN_1050;

signal	SwSlow : STD_LOGIC := '0'; -- Set to '1' to slow clock down to 1Hz, not used

signal	N60_CY_TIMER_PULSE : STD_LOGIC; -- Used for the Interval Timer
signal	Clock1ms : STD_LOGIC; -- 1kHz clock for single-shots etc.

signal	DEBUG : DEBUG_BUS; -- Passed to all modeles to probe signals

signal Switch_vector : std_logic_vector(0 to 63);

attribute mark_debug : string;
attribute keep : string;
-- attribute mark_debug of Indicators : signal is "true";
attribute mark_debug of n1050Outputs : signal is "true";
attribute keep of n1050Outputs : signal is "true";
attribute mark_debug of n1050Inputs : signal is "true";
attribute keep of n1050Inputs : signal is "true";
attribute mark_debug of n1050Control : signal is "true";
attribute keep of n1050Control : signal is "true";

begin

	cpu : entity work.cpu port map (
	
--	       Indicator Lamps
            W_IND => W_IND,
            X_IND => X_IND,
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
            IND_CMMD_OUT => IND_CMMD_OUT,
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
            IND_SYST => IND_SYST,
            IND_MAN => IND_MAN,
            IND_WAIT =>IND_WAIT,
            IND_TEST => IND_TEST,
            IND_LOAD => IND_LOAD,
                        
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
			SW_SYS_RST_P => SW_SYS_RST,
			SW_CHK_RST_P => SW_CHK_RST,
			SW_ROAR_RST_P => SW_ROAR_RST,
			SW_CHK_RESTART => SW_CHK_RESTART,
			SW_DIAGNOSTIC => SW_DIAGNOSTIC,
			SW_CHK_STOP => SW_CHK_STOP,
			SW_CHK_SW_PROCESS => SW_CHK_SW_PROCESS,
			SW_CHK_SW_DISABLE => SW_CHK_SW_DISABLE,
			SW_ROAR_RESTT_STOR_BYPASS => SW_ROAR_RESTT_STOR_BYPASS,
			SW_ROAR_RESTT => SW_ROAR_RESTT,
			SW_ROAR_RESTT_WITHOUT_RST_P => SW_ROAR_RESTT_WITHOUT_RST,
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
			
			-- Serial interface for 1050
			RDR_CONN_EXIT => n1050Inputs,
			PCH_CONN_ENTRY => n1050Outputs,
			n1050_CONTROL => n1050Control,
--			SerialInput => SI,
--			SerialOutput => SO,
			
			-- Multiplexor interface not connected to anything yet
			MPX_BUS_O => open,
			MPX_BUS_I => (others=>'0'),
			MPX_TAGS_O => open,
--			MPX_TAGS_O.OPL_OUT => open,
--            MPX_TAGS_O.ADR_OUT => open,
--            MPX_TAGS_O.ADR_OUT2 => open,
--            MPX_TAGS_O.CMD_OUT => open,
--            MPX_TAGS_O.STA_OUT => open,
--            MPX_TAGS_O.SRV_OUT => open,
--            MPX_TAGS_O.HLD_OUT => open,
--            MPX_TAGS_O.SEL_OUT => open,
--            MPX_TAGS_O.SUP_OUT => open,
--            MPX_TAGS_O.MTR_OUT => open,
--            MPX_TAGS_O.CLK_OUT => open,
            MPX_TAGS_I.OPL_IN => '0',
            MPX_TAGS_I.ADR_IN => '0',
            MPX_TAGS_I.STA_IN => '0',
            MPX_TAGS_I.SRV_IN => '0',
            MPX_TAGS_I.SEL_IN => '0',
            MPX_TAGS_I.REQ_IN => '0',
            MPX_TAGS_I.MTR_IN => '0',
            
            -- Storage interface
	        bram1.addr => bram1_addr,
	        bram1.clk => bram1_clk,
            bram1.wrdata => bram1_wrdata,
	        bram1.en => bram1_en,
	        bram1.rst => bram1_rst,
	        bram1.we => bram1_we,    
	        bram1_rddata => bram1_rddata,

	        bram2.addr => bram2_addr,
	        bram2.clk => bram2_clk,
            bram2.wrdata => bram2_wrdata,
	        bram2.en => bram2_en,
	        bram2.rst => bram2_rst,
	        bram2.we => bram2_we,            
	        bram2_rddata => bram2_rddata,
			
			DEBUG => open, -- Used to pass debug signals up to the top level for output
			N60_CY_TIMER_PULSE => N60_CY_TIMER_PULSE, -- Actually 50Hz
			Clock1ms => Clock1ms,
			SwSlow => SwSlow,
			sysclk => sysclk,
			clk40M => clk40M,
			clk50M => clk50M -- 50Mhz clock
			);


	frontPanel : entity lamp_panel port map (
	   IND_LP => IND_LP,
        W_IND => W_IND,
        X_IND => X_IND,
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
        IND_SEL_IN => IND_SEL_IN,
        IND_STATUS_IN => IND_STATUS_IN,
        IND_SERV_IN => IND_SERV_IN,
        IND_SEL_OUT => IND_SEL_OUT,
        IND_ADDR_OUT => IND_ADDR_OUT,
        IND_CMMD_OUT => IND_CMMD_OUT,
        IND_SERV_OUT => IND_SERV_OUT,
        IND_SUPPR_OUT => IND_SUPPR_OUT,
        IND_FO => IND_FO,
        IND_FO_P => IND_FO_P,
        
        IND_COUNT => IND_COUNT,
        IND_COUNT_LP => IND_COUNT_LP,
        IND_COUNT_HP => IND_COUNT_HP,
        IND_SX1_DATA => IND_SX1_DATA,
		IND_SX1_DATAP => IND_SX1_DATAP,
        IND_SX1_COMMAND => IND_SX1_COMMAND,
	    IND_SX1_KEY => IND_SX1_KEY,
		IND_SX1_KEYP => IND_SX1_KEYP,
		IND_SX1_PCI => IND_SX1_PCI,
		IND_SX1_SKIP => IND_SX1_SKIP,
		IND_SX1_SLI => IND_SX1_SLI,
		IND_SX1_CD => IND_SX1_CD,
		IND_SX1_CC => IND_SX1_CC,
		IND_SX1_DA_CHK => IND_SX1_DA_CHK,
		IND_SX1_PROT_CHK => IND_SX1_PROT_CHK,
		IND_SX1_PROG_CHK => IND_SX1_PROG_CHK,
		IND_SX1_IL_CHK => IND_SX1_IL_CHK,
		IND_SX1_CHNLDATA_CHK => IND_SX1_CHNLDATA_CHK,
		IND_SX1_STATIN_TAG => IND_SX1_STATIN_TAG,
		IND_SX1_ADRIN_TAG => IND_SX1_ADRIN_TAG,
		IND_SX1_OPIN_TAG => IND_SX1_OPIN_TAG,
		IND_SX1_SUPOUT_TAG => IND_SX1_SUPOUT_TAG,
		IND_SX1_SERVOUT_TAG => IND_SX1_SERVOUT_TAG,
		IND_SX1_CMMDOUT_TAG => IND_SX1_CMMDOUT_TAG,
		IND_SX1_ADROUT_TAG => IND_SX1_ADROUT_TAG,
		IND_SX1_SELOUT_TAG => IND_SX1_SELOUT_TAG,
		IND_SX1_IF_CHK => IND_SX1_IF_CHK,
		IND_SX1_CHNLCTRL_CHK => IND_SX1_CHNLCTRL_CHK,
		 
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
        IND_SYST => IND_SYST,
        IND_MAN => IND_MAN,
        IND_WAIT =>IND_WAIT,
        IND_TEST => IND_TEST,
        IND_LOAD => IND_LOAD,	
	
		Clock50 => clk50M,
		
		-- VGA out
		Red => vga_r, Green => vga_g, Blue => vga_b,
		HS => vga_hs, VS => vga_vs,
		
		-- HDMI out
		
		-- LEDs out
		LEDS => led
		
	);
	-- For now we only have 1 bit per colour, not 4
	red0 <= vga_r; red1 <= vga_r; red2 <= vga_r; red3 <= vga_r;
	green0 <= vga_g; green1 <= vga_g; green2 <= vga_g; green3 <= vga_g;
	blue0 <= vga_b; blue1 <= vga_b; blue2 <= vga_b; blue3 <= vga_b;

   -- LEDs are set here		
	led(0) <= IND_LOAD;
	led(1) <= IND_TEST;
	led(2) <= IND_WAIT;
	led(3) <= IND_MAN;
	led(4) <= IND_SYST;
--	led(5) <= '0';
-- 	led(6) <= '0';
--	led(7) <= DEBUG.Probe;
	
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
--		SwA_scan => pa_io5,
--		SwB_scan => pa_io6,
--		SwC_scan => pa_io7,
--		SwD_scan => pa_io8,
--		SwE_scan => pa_io9,
--		SwF_scan => pa_io10,
--		SwG_scan => pa_io11,
--		SwH_scan => pa_io12,
--		SwJ_scan => pa_io13,
--		SwAC_scan => pa_io14,
--		Hex_in(0) => pa_io1,
--		Hex_in(1) => pa_io2,
--		Hex_in(2) => pa_io3,
--		Hex_in(3) => pa_io4,
--		SW_E_INNER => pa_io15,
--		SW_E_OUTER => pa_io16,
--		RawSw_Proc_Inh_CF_Stop => pa_io17,
--		RawSw_Proc_Scan => pa_io18,
--		RawSw_Rate_Single_Cycle => ma2_db1,
--		RawSw_Rate_Instruction_Step => ma2_db0,
--		RawSw_Chk_Chk_Restart => ma2_db5,
--		RawSw_Chk_Diagnostic => ma2_db2,
--		RawSw_Chk_Stop => ma2_db4,
--		RawSw_Chk_Disable => ma2_db3,
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
		clk50M => clk50M, -- 50MHz clock
		status_lamps(4) => IND_LOAD,
		status_lamps(3) => IND_TEST,
		status_lamps(2) => IND_WAIT,
		status_lamps(1) => IND_MAN,
		status_lamps(0) => IND_SYST,
		Clock1ms => Clock1ms,
		Timer => N60_CY_TIMER_PULSE -- Output from Switches is actually 50Hz
		);


		
		front_panel_LEDs : entity panel_LEDs 
		generic map(
			clock_divider => 2
			)
		port map(
			clk50M => clk50M,
			
    	    IND_LP => IND_LP,
            W_IND => W_IND,
            X_IND => X_IND,
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
            IND_SEL_IN => IND_SEL_IN,
            IND_STATUS_IN => IND_STATUS_IN,
            IND_SERV_IN => IND_SERV_IN,
            IND_SEL_OUT => IND_SEL_OUT,
            IND_ADDR_OUT => IND_ADDR_OUT,
            IND_CMMD_OUT => IND_CMMD_OUT,
            IND_SERV_OUT => IND_SERV_OUT,
            IND_SUPPR_OUT => IND_SUPPR_OUT,
            IND_FO => IND_FO,
            IND_COUNT => IND_COUNT,
            IND_COUNT_LP => IND_COUNT_LP,
            IND_COUNT_HP => IND_COUNT_HP,
            IND_SX1_DATA => IND_SX1_DATA,
            IND_SX1_DATAP => IND_SX1_DATAP,
            IND_SX1_COMMAND => IND_SX1_COMMAND,
            IND_SX1_KEY => IND_SX1_KEY,
            IND_SX1_KEYP => IND_SX1_KEYP,
            IND_SX1_PCI => IND_SX1_PCI,
            IND_SX1_SKIP => IND_SX1_SKIP,
            IND_SX1_SLI => IND_SX1_SLI,
            IND_SX1_CD => IND_SX1_CD,
            IND_SX1_CC => IND_SX1_CC,
            IND_SX1_DA_CHK => IND_SX1_DA_CHK,
            IND_SX1_PROT_CHK => IND_SX1_PROT_CHK,
            IND_SX1_PROG_CHK => IND_SX1_PROG_CHK,
            IND_SX1_IL_CHK => IND_SX1_IL_CHK,
            IND_SX1_CHNLDATA_CHK => IND_SX1_CHNLDATA_CHK,
            IND_SX1_STATIN_TAG => IND_SX1_STATIN_TAG,
            IND_SX1_ADRIN_TAG => IND_SX1_ADRIN_TAG,
            IND_SX1_OPIN_TAG => IND_SX1_OPIN_TAG,
            IND_SX1_SUPOUT_TAG => IND_SX1_SUPOUT_TAG,
            IND_SX1_SERVOUT_TAG => IND_SX1_SERVOUT_TAG,
            IND_SX1_CMMDOUT_TAG => IND_SX1_CMMDOUT_TAG,
            IND_SX1_ADROUT_TAG => IND_SX1_ADROUT_TAG,
            IND_SX1_SELOUT_TAG => IND_SX1_SELOUT_TAG,
            IND_SX1_IF_CHK => IND_SX1_IF_CHK,
            IND_SX1_CHNLCTRL_CHK => IND_SX1_CHNLCTRL_CHK,
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
            IND_SYST => IND_SYST,
            IND_MAN => IND_MAN,
            IND_WAIT =>IND_WAIT,
            IND_TEST => IND_TEST,
            IND_LOAD => IND_LOAD,	
            
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
			
--		number_LEDs : entity segment_LEDs
--		port map(
--			clk => clk,
--			number(15 downto 13) => STD_LOGIC_VECTOR'("000"),
--			number(12 downto 0) => WX_IND(0 to 12),
--			anodes => ssdan,
--			cathodes => ssd
--			);
			
		DEBUG.Selection <= CONV_INTEGER(unsigned(SW_J));
		
    consoleTypewriter : entity ibm1050 port map (
        SerialIn => n1050Outputs,
        SerialOut => n1050Inputs,
        SerialControl => n1050Control,
        SerialInput.SerialRx => SerialRx,
        SerialInput.DCD => '1',
        SerialInput.DSR => '1',
        SerialInput.RI => '0',
        SerialInput.CTS => '1',
        SerialOutput.SerialTx => SerialTx,
        SerialOutput.RTS => SerialRTS,
        SerialOutput.DTR => SerialDTR,
        clk50 => clk50M
    );
    
    -- Divide 50MHz to 1kHz
    clockDivider : process (clk50M) is 
        variable Divider1K : integer range 0 to 50000 := 0;
    begin
        if rising_edge(clk50M) then
            if (Divider1K >= 50000) then
                Divider1K := 0;
            end if;
            if (Divider1K >= 25000) then
                Clock1ms <= '1';
            else
                Clock1ms <= '0';
            end if;
        end if;
    end process clockDivider;
    
 -- with DEBUG.Selection select
--	DEBUG.Probe <=
--		SerialBusUngated(0) when 0, SerialBusUngated(1) when 1, SerialBusUngated(2) when 2, SerialBusUngated(3) when 3,
--		SerialBusUngated(4) when 4, SerialBusUngated(5) when 5, SerialBusUngated(6) when 6, SerialBusUngated(7) when 7,
--		RxDataAvailable when others;
				
end FMD;
