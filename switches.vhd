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
--    File: switches.vhd
--    Creation Date: 21:49:37 20/01/2010
--    Description:
--    360/30 Front Panel switch handling
--    Some switches are provided by the pushbuttons and sliders on the S3BOARD
--    Rotary switches are connected externally with a mixture of scanning and
--    discrete inputs.  In all cases the "Process" position is not connected so
--    omitting the switches entirely allows the system to run normally.
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-09
--    Revision 1.01 2010-07-20  [LJW] Add Switch connection information
--    Initial Release
--    
--
-- Func            Port         Pin Conn A2      A       B       C       D       E       F       G       H       J       AC      E'      ROS     Rate    Check
--                 Ground                1       -       -       -       -       -       -       -       -       -       -       -       -       -       -
--                 +5V                   2       -       -       -       -       -       -       -       -       -       -       -       -       -       -
--                 +3.3V        Vcco     3       -       -       -       -       -       -       -       -       -       -       C       C       C       C
-- Hex0            pa_io1       E6       4       *       *       *       *       *       *       *       *       *       #       -       -       -       -
-- Hex1            pa_io2       D5       5       *       *       *       *       *       *       *       *       *       #       -       -       -       -
-- Hex2            pa_io3       C5       6       *       *       *       *       *       *       *       *       *       #       -       -       -       -
-- Hex3            pa_io4       D6       7       *       *       *       *       *       *       *       *       *       #       -       -       -       -
-- ScanA           pa_io5       C6       8       S       -       -       -       -       -       -       -       -       -       -       -       -       -
-- ScanB           pa_io6       E7       9       -       S       -       -       -       -       -       -       -       -       -       -       -       -
-- ScanC           pa_io7       C7       10      -       -       S       -       -       -       -       -       -       -       -       -       -       -
-- ScanD           pa_io8       D7       11      -       -       -       S       -       -       -       -       -       -       -       -       -       -
-- ScanE           pa_io9       C8       12      -       -       -       -       S       -       -       -       -       -       -       -       -       -
-- ScanF           pa_io10      D8       13      -       -       -       -       -       S       -       -       -       -       -       -       -       -
-- ScanG           pa_io11      C9       14      -       -       -       -       -       -       S       -       -       -       -       -       -       -
-- ScanH           pa_io12      D10      15      -       -       -       -       -       -       -       S       -       -       -       -       -       -
-- ScanJ           pa_io13      A3       16      -       -       -       -       -       -       -       -       S       -       -       -       -       -
-- ScanAC          pa_io14      B4       17      -       -       -       -       -       -       -       -       -       S       -       -       -       -
-- E_Inner         pa_io15      A4       18      -       -       -       -       -       -       -       -       -       -       *       -       -       -
-- E_Outer         pa_io16      B5       19      -       -       -       -       -       -       -       -       -       -       *       -       -       -
-- ROS InhCFStop   pa_io17      A5       20      -       -       -       -       -       -       -       -       -       -       -       *       -       -
-- ROS Scan        pa_io18      B6       21      -       -       -       -       -       -       -       -       -       -       -       *       -       -
-- Rate_InstrStep  ma2_db0      B7       22      -       -       -       -       -       -       -       -       -       -       -       -       *       -
-- Rate_SingleCyc  ma2_db1      A7       23      -       -       -       -       -       -       -       -       -       -       -       -       *       -
-- Check_Diag      ma2_db2      B8       24      -       -       -       -       -       -       -       -       -       -       -       -       -       *
-- Check_Disable   ma2_db3      A8       25      -       -       -       -       -       -       -       -       -       -       -       -       -       *
-- Check_Stop      ma2_db4      A9       26      -       -       -       -       -       -       -       -       -       -       -       -       -       *
-- Check_Restart   ma2_db5      B10      27      -       -       -       -       -       -       -       -       -       -       -       -       -       *
-- 
-- * = Hex0,1,2,3 inputs have diodes from each of the 9 hex-encoded switches A-J (A to switch, K to FPGA, total 36 diodes)
-- # = The Address Compare switch (AC) is 10-position, unencoded, with diodes to perform the 0-9 encoding (total 15 diodes)
-- S = Scan output to switch common (one output at a time goes high to scan)
-- C = Common connection for non-scanned switches
-- Switch E' is the selector switch which is part of switch E and selects the inner, middle or outer rings
-- The "Proc" positions of the ROS, Rate and Check switches are not connected - if no switches are present then these 3 and the AC switch default to "Proc"
-- The "Middle" position of the E selector switch is not connected - the default is therefore the MS/LS ring
-- Pulldowns are provided by the FPGA input
-- 
-- Most of the remaining switches are connected to the on-board pushbuttons and slide switches:
--    Reset
--    Start
--    Stop
--    Load
--    Lamp Test
--    ROAR Reset
--    Display
--    Store
--    Check Reset
--    Set IC
--    Interrupt
--    Fast/Slow clock control
-- Two switches are not used:
--    Power Off
--    Timer Interrupt
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Buses_package.all;
use work.Gates_package.EvenParity;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity switches is
    Port ( -- Raw switch inputs: (These can be modified to suit the board being used)
           SwA_scan : out  STD_LOGIC;
           SwB_scan : out  STD_LOGIC;
           SwC_scan : out  STD_LOGIC;
           SwD_scan : out  STD_LOGIC;
           SwE_scan : out  STD_LOGIC;
           SwF_scan : out  STD_LOGIC;
           SwG_scan : out  STD_LOGIC;
           SwH_scan : out  STD_LOGIC;
           SwJ_scan : out  STD_LOGIC;
           SwAC_scan : out  STD_LOGIC; -- Address Compare
           Hex_in : in  STD_LOGIC_VECTOR(3 downto 0);
           SW_E_Inner, SW_E_Outer : in STD_LOGIC;
           RawSw_Proc_Inh_CF_Stop, RawSw_Proc_Scan : in STD_LOGIC; -- ROS Control
           RawSw_Rate_Single_Cycle, RawSw_Rate_Instruction_Step : in STD_LOGIC; -- Rate
           RawSw_Chk_Chk_Restart, RawSw_Chk_Diagnostic, RawSw_Chk_Stop, RawSw_Chk_Disable : in STD_LOGIC; -- Check Control
           pb : in std_logic_vector(3 downto 0); -- On-board pushbuttons
           sw : in std_logic_vector(7 downto 0); -- On-board slide switches

           -- Other inputs
           clk : in STD_LOGIC; -- 50MHz

           -- Conditioned switch outputs:
           SwA,SwB,SwC,SwD,SwF,SwG,SwH,SwJ : out STD_LOGIC_VECTOR(3 downto 0);
           SwAP,SwBP,SwCP,SwDP,SwFP,SwGP,SwHP,SwJP : out STD_LOGIC;
           SwE : out E_SW_BUS_Type;
           Sw_PowerOff, Sw_Interrupt, Sw_Load : out STD_LOGIC; -- Right-hand pushbuttons
           Sw_SystemReset, Sw_RoarReset, Sw_Start, Sw_SetIC, Sw_CheckReset,
           Sw_Stop, Sw_IntTmr, Sw_Store, Sw_LampTest, Sw_Display : out STD_LOGIC; -- Left-hand pushbuttons
           Sw_Proc_Inh_CF_Stop, Sw_Proc_Proc, Sw_Proc_Scan : out STD_LOGIC; -- ROS Control
           Sw_Rate_Single_Cycle, Sw_Rate_Instruction_Step, Sw_Rate_Process : out STD_LOGIC; -- Rate
           Sw_Chk_Chk_Restart, Sw_Chk_Diagnostic, Sw_Chk_Stop, Sw_Chk_Process, Sw_Chk_Disable : out STD_LOGIC; -- Check Control
           Sw_ROAR_RESTT,Sw_ROAR_RESTT_WITHOUT_RST,Sw_EARLY_ROAR_STOP,Sw_ROAR_STOP, Sw_ROAR_RESTT_STOR_BYPASS,
           Sw_ROAR_SYNC,Sw_ADDR_COMP_PROC,Sw_SAR_DLYD_STOP,Sw_SAR_STOP,Sw_SAR_RESTART : out STD_LOGIC; -- Address Compare

           -- 50Hz Timer signal
           Timer : out STD_LOGIC
           );
end switches;

architecture Behavioral of switches is
subtype debounce is std_logic_vector(0 to 3);
signal scan : std_logic_vector(3 downto 0) := "0000";
signal counter : std_logic_vector(14 downto 0) := (others=>'0');
signal timerCounter : std_logic_vector(5 downto 0) := (others=>'0');
signal SwE_raw : std_logic_vector(3 downto 0) := "0000";
signal SwAC : std_logic_vector(3 downto 0) := "0000"; -- Address Compare switch
signal Parity_in : std_logic;
signal RawSw_PowerOff, RawSw_Interrupt, RawSw_Load, RawSw_SystemReset, RawSw_RoarReset, RawSw_Start,
		RawSw_SetIC, RawSw_CheckReset, RawSw_Stop, RawSw_IntTmr, RawSw_Store, RawSw_LampTest,
		RawSw_Display : STD_LOGIC; -- Right-hand pushbuttons

signal debouncePowerOff, debounceInterrupt, debounceLoad,
		debounceSystemReset, debounceRoarReset, debounceStart, debounceSetIC, debounceCheckReset,
		debounceStop, debounceIntTmr, debounceStore, debounceLampTest, debounceDisplay : debounce;
signal timerOut : std_logic := '0';
constant divider : std_logic_vector(14 downto 0) := "100111000100000"; -- 20,000 gives 2.5kHz
constant sample  : std_logic_vector(14 downto 0) := "100111000011110"; -- 19,999
constant divider100 : std_logic_vector(4 downto 0) := "11001"; --- 25 converts 2.5kHz to 100Hz for timer
begin

Parity_in <= EvenParity(Hex_in);

scan_counter: process(clk)
	begin
	if (rising_edge(clk)) then
		if counter=sample then
			if scan="0000" then SwA <= Hex_in; SwAP <= Parity_in; end if;
			if scan="0001" then SwB <= Hex_in; SwBP <= Parity_in; end if;
			if scan="0010" then SwC <= Hex_in; SwCP <= Parity_in; end if;
			if scan="0011" then SwD <= Hex_in; SwDP <= Parity_in; end if;
			if scan="0100" then SwE_raw <= Hex_in; end if;
			if scan="0101" then SwF <= Hex_in; SwFP <= Parity_in; end if;
			if scan="0110" then SwG <= Hex_in; SwGP <= Parity_in; end if;
			if scan="0111" then SwH <= Hex_in; SwHP <= Parity_in; end if;
			if scan="1000" then SwJ <= Hex_in; SwJP <= Parity_in; end if;
			if scan="1001" then SwAC <= Hex_in; end if;
		end if;
		if counter=divider then
			counter<=(others=>'0');
			if scan="1001" then
				scan <= "0000";
			else
				scan <= scan + 1;
			end if;
			debouncePowerOff <= debouncePowerOff(1 to 3) & rawSw_PowerOff;
			debounceInterrupt <= debounceInterrupt(1 to 3) & rawSw_Interrupt;
			debounceLoad <= debounceLoad(1 to 3) & rawSw_Load;
			debounceSystemReset <= debounceSystemReset(1 to 3) & rawSw_SystemReset;
			debounceRoarReset <= debounceRoarReset(1 to 3) & rawSw_RoarReset;
			debounceStart <= debounceStart(1 to 3) & rawSw_Start;
			debounceSetIC <= debounceSetIC(1 to 3) & rawSw_SetIC;
			debounceCheckReset <= debounceCheckReset(1 to 3) & rawSw_CheckReset;
			debounceStop <= debounceStop(1 to 3) & rawSw_Stop;
			debounceIntTmr <= debounceIntTmr(1 to 3) & rawSw_IntTmr;
			debounceStore <= debounceStore(1 to 3) & rawSw_Store;
			debounceLampTest <= debounceLampTest(1 to 3) & rawSw_LampTest;
			debounceDisplay <= debounceDisplay(1 to 3) & rawSw_Display;
			if (debouncePowerOff = "0000") then Sw_PowerOff <= '0'; else if (debouncePowerOff = "1111") then Sw_PowerOff <= '1';	end if;	end if;
			if (debounceInterrupt = "0000") then Sw_Interrupt <= '0'; else if (debounceInterrupt = "1111") then Sw_Interrupt <= '1';	end if;	end if;
			if (debounceLoad = "0000") then Sw_Load  <= '0'; else if (debounceLoad = "1111") then Sw_Load  <= '1';	end if;	end if;
			if (debounceSystemReset = "0000") then Sw_SystemReset <= '0'; else if (debounceSystemReset = "1111") then Sw_SystemReset <= '1';	end if;	end if;
			if (debounceRoarReset = "0000") then Sw_RoarReset <= '0'; else if (debounceRoarReset = "1111") then Sw_RoarReset <= '1';	end if;	end if;
			if (debounceStart = "0000") then Sw_Start <= '0'; else if (debounceStart = "1111") then Sw_Start <= '1';	end if;	end if;
			if (debounceSetIC = "0000") then Sw_SetIC <= '0'; else if (debounceSetIC = "1111") then Sw_SetIC <= '1';	end if;	end if;
			if (debounceCheckReset = "0000") then Sw_CheckReset <= '0'; else if (debounceCheckReset = "1111") then Sw_CheckReset <= '1';	end if;	end if;
			if (debounceStop = "0000") then Sw_Stop <= '0'; else if (debounceStop = "1111") then Sw_Stop <= '1';	end if;	end if;
			if (debounceIntTmr = "0000") then Sw_IntTmr <= '0'; else if (debounceIntTmr = "1111") then Sw_IntTmr <= '1';	end if;	end if;
			if (debounceStore = "0000") then Sw_Store <= '0'; else if (debounceStore = "1111") then Sw_Store <= '1';	end if;	end if;
			if (debounceLampTest = "0000") then Sw_LampTest <= '0'; else if (debounceLampTest = "1111") then Sw_LampTest <= '1';	end if;	end if;
			if (debounceDisplay = "0000") then Sw_Display <= '0'; else if (debounceDisplay = "1111") then Sw_Display <= '1';	end if;	end if;

			if (timerCounter = divider100) then
				timerOut <= not timerOut;
				Timer <= timerOut;
				timerCounter <= (others=>'0');
			else
				timerCounter <= timerCounter + 1;
			end if;
		else
			counter <= counter + 1;
		end if;
	end if;
	end process;

SwA_scan <= '1' when scan="0000" else '0';
SwB_scan <= '1' when scan="0001" else '0';
SwC_scan <= '1' when scan="0010" else '0';
SwD_scan <= '1' when scan="0011" else '0';
SwE_scan <= '1' when scan="0100" else '0';
SwF_scan <= '1' when scan="0101" else '0';
SwG_scan <= '1' when scan="0110" else '0';
SwH_scan <= '1' when scan="0111" else '0';
SwJ_scan <= '1' when scan="1000" else '0';
SwAC_scan <= '1' when scan="1001" else '0';


	-- Inner ring
SwE.I_SEL <= '1' when SwE_raw="0000" and SW_E_INNER='1' else '0';
SwE.J_SEL <= '1' when SwE_raw="0001" and SW_E_INNER='1' else '0';
SwE.U_SEL <= '1' when SwE_raw="0010" and SW_E_INNER='1' else '0';
SwE.V_SEL <= '1' when SwE_raw="0011" and SW_E_INNER='1' else '0';
SwE.L_SEL <= '1' when SwE_raw="0100" and SW_E_INNER='1' else '0';
SwE.T_SEL <= '1' when SwE_raw="0101" and SW_E_INNER='1' else '0';
SwE.D_SEL <= '1' when SwE_raw="0110" and SW_E_INNER='1' else '0';
SwE.R_SEL <= '1' when SwE_raw="0111" and SW_E_INNER='1' else '0';
SwE.S_SEL <= '1' when SwE_raw="1000" and SW_E_INNER='1' else '0';
SwE.G_SEL <= '1' when SwE_raw="1001" and SW_E_INNER='1' else '0';
SwE.H_SEL <= '1' when SwE_raw="1010" and SW_E_INNER='1' else '0';
SwE.FI_SEL <= '1' when SwE_raw="1011" and SW_E_INNER='1' else '0';
SwE.FT_SEL <= '1' when SwE_raw="1100" and SW_E_INNER='1' else '0';
	-- Mid ring
SwE.MS_SEL <= '1' when SwE_raw="0000" and SW_E_INNER='0' and SW_E_OUTER='0' else '0';
SwE.LS_SEL <= '1' when SwE_raw="0001" and SW_E_INNER='0' and SW_E_OUTER='0' else '0';
	-- Outer ring
SwE.E_SEL_SW_GS <= '1' when SwE_raw="0000" and SW_E_OUTER='1' else '0';
SwE.E_SEL_SW_GT <= '1' when SwE_raw="0001" and SW_E_OUTER='1' else '0';
SwE.E_SEL_SW_GUV_GCD <= '1' when SwE_raw="0010" and SW_E_OUTER='1' else '0';
SwE.E_SEL_SW_HS <= '1' when SwE_raw="0011" and SW_E_OUTER='1' else '0';
SwE.E_SEL_SW_HT <= '1' when SwE_raw="0100" and SW_E_OUTER='1' else '0';
SwE.E_SEL_SW_HUV_HCD <= '1' when SwE_raw="0101" and SW_E_OUTER='1' else '0';
SwE.Q_SEL <= '1' when SwE_raw="0110" and SW_E_OUTER='1' else '0';
SwE.C_SEL <= '1' when SwE_raw="0111" and SW_E_OUTER='1' else '0';
SwE.F_SEL <= '1' when SwE_raw="1000" and SW_E_OUTER='1' else '0';
SwE.TT_SEL <= '1' when SwE_raw="1001" and SW_E_OUTER='1' else '0';
SwE.TI_SEL <= '1' when SwE_raw="1010" and SW_E_OUTER='1' else '0';
SwE.JI_SEL <= '1' when SwE_raw="1011" and SW_E_OUTER='1' else '0';

-- SwE.IJ_SEL <= '1' when (SwE_raw="0000" or SwE_raw="0001") and SW_E_INNER='1' and USE_MAN_DECODER_PWR='1' else '0'; -- AC1G6,AC1D2
-- SwE.UV_SEL <= '1' when (SwE_raw="0010" or SwE_raw="0011") and SW_E_INNER='1' and USE_MAN_DECODER_PWR='1' else '0'; -- AC1G6,AC1D2

-- Address Compare
Sw_ADDR_COMP_PROC <= '1' when SwAC="0000" else '0';
Sw_SAR_DLYD_STOP <= '1' when SwAC="0001" else '0';
Sw_SAR_STOP <= '1' when SwAC="0010" else '0';
Sw_SAR_RESTART <= '1' when SwAC="0011" else '0';
Sw_ROAR_RESTT_STOR_BYPASS <= '1' when SwAC="0100" else '0';
Sw_ROAR_RESTT <= '1' when SwAC="0101" else '0';
Sw_ROAR_RESTT_WITHOUT_RST <= '1' when SwAC="0110" else '0';
Sw_EARLY_ROAR_STOP <= '1' when SwAC="0111" else '0';
Sw_ROAR_STOP <= '1' when SwAC="1000" else '0';
Sw_ROAR_SYNC <= '1' when SwAC="1001" else '0';

-- ROS Control
Sw_Proc_Inh_CF_Stop <= '1' when RawSw_Proc_Inh_CF_Stop='1' else '0';
Sw_Proc_Proc <= '1' when RawSw_Proc_Inh_CF_Stop='0' and RawSw_Proc_Scan='0' else '0';
Sw_Proc_Scan <= '1' when RawSw_Proc_Scan='1' else '0';

-- Rate
Sw_Rate_Single_Cycle <= '1' when RawSw_Rate_Single_Cycle='1' else '0';
Sw_Rate_Process <= '1' when RawSw_Rate_Single_Cycle='0' and RawSw_Rate_Instruction_Step='0' else '0';
Sw_Rate_Instruction_Step <= '1' when RawSw_Rate_Instruction_Step='1' else '0';

-- Check Control
Sw_Chk_Chk_Restart <= '1' when RawSw_Chk_Chk_Restart='1' else '0';
Sw_Chk_Diagnostic <= '1' when RawSw_Chk_Diagnostic='1' else '0';
Sw_Chk_Stop <= '1' when RawSw_Chk_Stop='1' else '0';
Sw_Chk_Process <= '1' when RawSw_Chk_Chk_Restart='0' and RawSw_Chk_Diagnostic='0' and RawSw_Chk_Stop='0' and RawSw_Chk_Disable='0' else '0';
Sw_Chk_Disable <= '1' when RawSw_Chk_Disable='1' else '0';

-- Unimplemented switches
RawSw_PowerOff <= '0';
RawSw_IntTmr <= '0';

-- Pushbuttons
RawSw_SystemReset <= pb(0);
RawSw_Start <= pb(1);
RawSw_Load <= pb(2);
RawSw_Stop <= pb(3);

-- Slide switches
RawSw_Display <= sw(1);
RawSw_Store <= sw(2);
RawSw_Interrupt <= sw(3);
RawSw_RoarReset <= sw(4);
RawSw_SetIC <= sw(5);
RawSw_CheckReset <= sw(6);
RawSw_LampTest <= sw(7);

end behavioral;

