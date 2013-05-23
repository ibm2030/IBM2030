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
--    File: ibm2030-led.vhd
--    Creation Date: 2012-04-25
--    Description:
--    Front panel with LED indicators via MAX7221 drivers and SPI
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2012-04-25
--    Initial Release
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

entity led_panel IS
	port
	(
		-- Inputs        
		Indicators : in std_logic_vector(IndicatorRange);

		-- Outputs
		SPI_CS, SPI_MOSI, SPI_CLK : out std_logic;

		-- Clocks
		clk : in std_logic -- 50MHz clock
	);
end entity led_panel;

architecture behavioural of led_panel is

	type led_state_t is (led_reset, 
		led_run1, led_run2, led_run3, led_run4);
	signal led_state : led_state_t := led_reset;
	signal led_digit : STD_LOGIC_VECTOR(3 downto 0) := "1010";
	signal led_device : STD_LOGIC_VECTOR(3 downto 0) := "1111";
	signal spi_reset : STD_LOGIC := '0';
	signal spi_data_latch : STD_LOGIC := '0';
	signal spi_data_ack : STD_LOGIC;
	signal spi_in_bus : STD_LOGIC_VECTOR(15 downto 0);
	signal s_spi_cs : STD_LOGIC;
	signal counter100 : integer;
	constant divider10ms : integer := 500000;
	
begin
spi : entity spi_master generic map (N => 16, CPOL=>'0', CPHA=>'0', PREFETCH => 1) port map (
	sclk_i => clk,
	pclk_i => clk,
	rst_i => spi_reset,
	spi_ssel_o => s_spi_cs,
	spi_sck_o => SPI_CLK,
	spi_mosi_o => SPI_MOSI,
	spi_miso_i => 'X',
	di_req_o => open,
	di_i => spi_in_bus,
	wren_i => spi_data_latch,
	wr_ack_o => spi_data_ack,
	do_valid_o => open,
	do_o => open
	);
SPI_CS <= s_spi_cs; -- Use this to generate multiple CS* values to multiple devices

--	The MAX7221 accepts a 16-bit word.
--		Bits 15-12 are ignored.
--		Bits 11-8 specify one of 14 registers.
--		Bits 7-0 are data which is clocked into the register at the rising edge of CS*
--
--	Registers are:
--		0		No-op (useful when cascading)
--		1-8	Digits 0-7 (one bit per LED)
--		9		Decode mode (all bits 0 - power up default)
--		A		Intensity (bottom 4 bits, 0=dim ... F=bright, set to F)
--		B		Scan limit (bottom 3 bits, 0=Digit 1 only ... 7=Digits 1-7, set to 7)
--		C		Shutdown (bottom bit, 1=normal, 0=shutdown, set to 1)
--		F		Display test (bottom bit, 0=normal, 1=test, set to 0

-- All registers 1 - C are written repeatedly, at a 100Hz rate

-- For multiple devices the system will be changed to:
-- 1. Write register 1-8 for device 1 (Select="0001")
-- 2. Write register 1-8 for device 2 (Select="0010")
-- 3. Write register 1-8 for device 3 (Select="0100")
-- 4. Write register 1-8 for device 4 (Select="1000")
-- 5. Write registers A-C for all devices simultaneously (Select="1111")
-- 6. Repeat from step 1

drive_leds : process (clk) is
begin
	if rising_edge(clk) then
		case led_state is
			when led_reset =>
				-- spi_reset defaults to '1'
				led_state <= led_run1;
				spi_reset <= '0';
			when led_run1 =>
				-- Present Display data
				-- D0: A B C D E F = MSDR P 0 1 2 3 4
				-- D1: A B C = MSDR 5 6 7
				-- D2-7: Zero
				spi_in_bus(15 downto 8) <= "0000" & led_digit;
				case led_digit is
					when "0001" => spi_in_bus(7 downto 0) <= "0" & Indicators(166 to 171) & "0"; -- D0 (1)
					when "0010" => spi_in_bus(7 downto 0) <= "0" & Indicators(172 to 174) & "0000"; -- D1 (2)
					when "1010" => spi_in_bus(7 downto 0) <= "00000001"; -- Intensity (A) = Min
					when "1011" => spi_in_bus(7 downto 0) <= "00000111"; -- Scan Limit (B) = 8 digits
					when "1100" => spi_in_bus(7 downto 0) <= "00000001"; -- Shutdown (C) = Normal
					when others => spi_in_bus(7 downto 0) <= "00000000"; -- Decode (9) = None  Digits (3-8) = Blank
				end case;
				led_state <= led_run2;
			when led_run2 =>
				-- Latch Display data and wait for acknowledgement
				spi_data_latch <= '1';
				if (spi_data_ack = '1') then
					led_state <= led_run3;
				end if;
			when led_run3 => -- Wait for transmission to complete
				spi_data_latch <= '0';
				if (s_spi_cs = '1') then
					if (led_digit="1000") then
						-- Last digit, move on to next device, or register A for all devices
						if (led_device="1000") then
							led_device <= "1111";
							led_digit <= "1010";
							led_state <= led_run1;
						else
							led_device <= led_device(2 downto 0) & "0";
							led_digit <= "0001";
							led_state <= led_run1;
						end if;
					else if (led_digit="1100") then
							-- Last register, go back to first after 10ms wait
							led_state <= led_run4;
							counter100 <= divider10ms;
							led_device <= "0001";
							led_digit <= "0001";
						else
							-- Go on to next register immediately
							led_state <= led_run1;
							led_digit <= led_digit+"0001";
						end if;
					end if;
				end if;
			when led_run4 =>
				-- Wait for one tick (10ms) after sending all LEDs
				counter100 <= counter100 -1;
				if (counter100 = 0) then
					led_state <= led_run1;
				end if;
			when others =>
		end case;
	end if;
end process drive_leds;

END behavioural; 
