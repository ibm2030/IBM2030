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
--    File: ibm1050.vhd
--    Creation Date: 21:17:39 2005-04-18
--    Description:
--    1050 (Console Typewriter) attachment
--
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2012-04-07
--    Initial release - no Tilt/Rotate to ASCII conversion on printing or handling
--			of Shift-Up or Shift-Down, also no ASCII to key-code conversion on input
--			(all this is handled inside the CPU)
---------------------------------------------------------------------------
library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;
use UNISIM.vcomponents.all;
use work.all;

entity ibm1050 is
    Port (
			SerialIn : inout PCH_CONN;	-- Data lines in to CPU
			SerialOut : in RDR_CONN;	-- Data lines out of CPU
			SerialControl : in CONN_1050;	-- Control lines out of CPU
			
			-- Serial I/O
			serialInput : in Serial_Input_Lines;
			serialOutput : out Serial_Output_Lines;
			
			-- 50Mhz clock
			clk : in std_logic
			);			  
end ibm1050;

architecture FMD of ibm1050 is

signal	SerialBusUngated : STD_LOGIC_VECTOR(7 downto 0);
signal	RxDataAvailable : STD_LOGIC;
signal	TxBufferEmpty : STD_LOGIC;
signal	serialOutputByte : STD_LOGIC_VECTOR(7 downto 0);
signal	serialOutputStrobe : STD_LOGIC := '0';
signal	RxAck, PunchGate : STD_LOGIC;
signal	resetSerial : STD_LOGIC := '0';
type		printerStateType is (waitForEnable,printerReset,printerEnabled,printCharacter,waitForCharacter,waitFree,printCR,waitForCR,printLF,waitForLF);
signal	printerState : printerStateType := waitForEnable;
signal	RDR_1_CLUTCH_timer : STD_LOGIC_VECTOR(15 downto 0);

begin

Printer: process (clk)
begin
if rising_edge(clk) then
	case printerState is
		when waitForEnable =>
			serialIn.HOME_RDR_STT_LCH <= '0'; -- Not running
			serialIn.RDR_1_CLUTCH_1050 <= '0'; -- Not ready to receive a character
			serialOutputStrobe <= '0';
			if (serialControl.HOME_RDR_START='1') then
				resetSerial <= '1';
				printerState <= printerReset;
			elsif (serialControl.CARR_RETURN_AND_LINE_FEED='1') then
				printerState <= printCR;
			end if;
		when printerReset =>
			resetSerial <= '0';
			printerState <= printerEnabled;
		when printerEnabled =>
			serialIn.HOME_RDR_STT_LCH <= '1'; -- Running
			serialIn.RDR_1_CLUTCH_1050 <= TxBufferEmpty; -- Ready to receive a character
			if (serialControl.HOME_RDR_START='0') then
				printerState <= waitForEnable;
			elsif (serialOut.RD_STROBE='1') then
				printerState <= printCharacter;
			elsif (serialControl.CARR_RETURN_AND_LINE_FEED='1') then
				printerState <= printCR;
			end if;
		when printCharacter =>
			serialIn.RDR_1_CLUTCH_1050 <= '0'; -- Not ready for another character
			serialOutputByte <= '0' & SerialOut.RDR_BITS; -- Here we could translate from TILT/ROTATE to ASCII
			serialOutputStrobe <= '1';
			printerState <= waitForCharacter;
			RDR_1_CLUTCH_TIMER <= x"9C40"; -- 9C40 = 40000 = 800us
		when waitForCharacter =>
		-- Need to wait in this state for long enough to guarantee that
		-- RDR_1_CLUTCH is still low at Y_TIME to reset ALLOW_STROBE latch
			serialOutputStrobe <= '0';
			if (serialOut.RD_STROBE='0') then
				RDR_1_CLUTCH_timer <= RDR_1_CLUTCH_timer - "0000000000000001";
				if (RDR_1_CLUTCH_timer="0000000000000000") then
					printerState <= printerEnabled;
				end if;
			end if;
		when printCR =>
			if (TxBufferEmpty='1') then
				serialOutputByte <= "00001101"; -- CR
				serialOutputStrobe <= '1';
				printerState <= waitForCR;
			end if;
		when waitForCR =>
			serialOutputStrobe <= '0';
			printerState <= printLF;
		when printLF =>
			if (TxBufferEmpty='1') then
				serialOutputByte <= "00001010"; -- LF
				serialOutputStrobe <= '1';
				printerState <= waitForLF;
			end if;
		when waitForLF =>
			serialOutputStrobe <= '0';
			if (serialControl.CARR_RETURN_AND_LINE_FEED='0') then -- Wait for CRLF to drop
				if (serialControl.HOME_RDR_START='0') then
					printerState <= waitForEnable;
				else
					printerState <= printerEnabled;
				end if;
			end if;
		when others =>
			printerState <= waitForEnable;
	end case;
end if;
end process Printer;

		serial_port : entity RS232RefComp port map(
				RST => '0',	--Master Reset
				CLK => clk,
				-- Rx (PCH)
		    	RXD => SerialInput.serialRx,
				RDA => RxDataAvailable,	-- Rx data available
				PE => open,		-- Parity Error Flag
				FE => open,		-- Frame Error Flag
				OE => open,		-- Overwrite Error Flag
				DBOUT => SerialBusUngated,	-- Rx data (needs to be 0 when RDA=0)
				RD => RxAck,		-- Read strobe
				-- Tx (RDR)
				TXD => serialOutput.serialTx,
				TBE => TxBufferEmpty,	-- Tx buffer empty
				DBIN => serialOutputByte,	-- Tx data
				WR => serialOutputStrobe		-- Write Strobe
				);
		-- Make incoming data 0 when nothing is available
		SerialIn.PCH_BITS <= SerialBusUngated(6 downto 0) when PunchGate='1' else "0000000";
		PunchStrobeSS : logic.Gates_package.SS port map (clk=>clk, count=>2500, D=>RxDataAvailable, Q=>RxAck); -- 50us or so
		SerialIn.PCH_1_CLUTCH_1050 <= RxAck;
		PunchGateSS : logic.Gates_package.SS port map (clk=>clk, count=>3000, D=>RxDataAvailable, Q=>PunchGate); -- A bit more than 50us so Read Interlock is reset after PCH_1_CLUTCH drops

		SerialIn.CPU_CONNECTED <= '1'; -- 1050 always on-line
		SerialIn.HOME_OUTPUT_DEV_RDY <= '1'; -- Printer always ready
		SerialIn.RDR_2_READY <= '0';
--		SerialIn.HOME_RDR_STT_LCH <= SerialControl.HOME_RDR_START;
		SerialIn.REQ_KEY <= '0';
		
		SerialOutput.RTS <= '1';
		SerialOutput.DTR <= '1';

end FMD;
