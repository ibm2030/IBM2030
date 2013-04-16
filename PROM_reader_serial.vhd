--*****************************************************************************************
--**
--**  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are 
--**              provided to you "as is". Xilinx and its licensors make and you 
--**              receive no warranties or conditions, express, implied, statutory 
--**              or otherwise, and Xilinx specifically disclaims any implied 
--**              warranties of merchantability, non-infringement, or fitness for a 
--**              particular purpose. Xilinx does not warrant that the functions 
--**              contained in these designs will meet your requirements, or that the
--**              operation of these designs will be uninterrupted or error free, or 
--**              that defects in the Designs will be corrected. Furthermore, Xilinx 
--**              does not warrant or make any representations regarding use or the 
--**              results of the use of the designs in terms of correctness, accuracy, 
--**              reliability, or otherwise. 
--**
--**              LIMITATION OF LIABILITY. In no event will Xilinx or its licensors be 
--**              liable for any loss of data, lost profits, cost or procurement of 
--**              substitute goods or services, or for any special, incidental, 
--**              consequential, or indirect damages arising from the use or operation 
--**              of the designs or accompanying documentation, however caused and on 
--**              any theory of liability. This limitation will apply even if Xilinx 
--**              has been advised of the possibility of such damage. This limitation 
--**              shall apply not-withstanding the failure of the essential purpose of 
--**              any limited remedies herein. 
--**
--*****************************************************************************************
--	MODULE  : PROM_reader_serial.vhd
--	AUTHOR  : Stephan Neuhold
--	VERSION : v1.00
--
--
--	REVISION HISTORY:
--	-----------------
--	No revisions
--
--
--	FUNCTION DESCRIPTION:
--	---------------------
--	This module provides the control state machine
--	for reading data from the PROM. This includes
--	searching for synchronisation patterns, retrieving
--	data, resetting the PROMs address counter.


--***************************
--*	Library declarations
--***************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;


--***********************
--*	Entity declaration
--***********************
entity PROM_reader_serial is
	generic(
		length : integer := 5;
		frequency : integer := 50
		);

	port(
		clock : in std_logic; 
		reset : in std_logic;	--active high
		read : in std_logic;	--active low
		next_sync : in std_logic;	--active low
		din : in std_logic;
		sync_pattern : in std_logic_vector((2**length) - 1 downto 0);
		cclk : out std_logic;
		sync : out std_logic;	--active low
		data_ready : out std_logic;	--active low
		reset_prom : out std_logic;	--active high
		dout : out std_logic_vector(7 downto 0)
		);
end PROM_reader_serial;


architecture Behavioral of PROM_reader_serial is


component clock_management
	generic(
		length : integer := 5;
		frequency : integer := 50
		);
	port(
		clock : in std_logic;
		enable : in std_logic;
		read_enable : out std_logic;
		cclk : out std_logic
		);
end component;


component shift_compare_serial
	generic(
		length : integer := 5
		);
	port(
		clock : in std_logic;
		reset : in std_logic;
		enable : in std_logic;
		din : in std_logic;
		b : in std_logic_vector((2**length) - 1 downto 0);
		eq : out std_logic;
		din_shifted : out std_logic_vector(7 downto 0)
		);
end component;


type state_type is (Look4Sync, Wait4Active, GetData, PresentData);
signal current_state : state_type;
signal count : std_logic_vector(length downto 0);
signal din_read_enable : std_logic;
signal sync_found : std_logic;
signal data : std_logic_vector(7 downto 0);
signal sync_int : std_logic;
signal cclk_on : std_logic;
signal reset_n : std_logic;


begin


--Clock generation and clock enable generation
Clock_Manager: clock_management
	generic map(
		length => length,
		frequency => frequency
		)
	port map(
		clock => clock,
		enable => cclk_on,
		read_enable => din_read_enable,
		cclk => cclk
		);


--Shift and compare operation
Shift_And_Compare: shift_compare_serial
	generic map(
		length => length
		)
	port map(
		clock => clock,
		reset => reset,
		enable => din_read_enable,
		din => din,
		b => sync_pattern,
		eq => sync_found,
		din_shifted =>	data
		);


--State machine
process (clock, reset, current_state, sync_int, read, count,
			data, sync_found)
begin
	if (reset = '1') then
		current_state <= Look4Sync;	--this can be changed to Wait4Active so that the FPGA doesnt go looking for data immediately after config
		dout <= (others => '0');
		count <= (others => '0');
		sync_int <= '0';
		data_ready <= '1';
		reset_PROM <= '0';
		cclk_on <= '1';

	elsif rising_edge(clock) then
		case current_state is
		
			--*************************************************************
			--*	This state clocks in one bit of data at a time from the
			--*	PROM. With every new bit clocked in a comparison is done
			--*	to check whether it matches the synchronisation pattern.
			--*	If the pattern is found then a further bits are read
			--*	from the PROM to provide the first byte of data appearing
			--*	after the synchronisation pattern.
			--*************************************************************
			when Look4Sync =>
				count <= (others => '0');
				data_ready <= '1';
				sync_int <= '0';
				reset_PROM <= '1';
				if (sync_found = '1') then
					current_state <= Wait4Active;
					sync_int <= '1';
					cclk_on <= '0';
				end if;

			--*********************************************************
			--*	At this point the state machine waits for user input.
			--*	If the user pulses the "read" signal then 8 bits of
			--*	are retrieved from the PROM. If the user wants to
			--*	look for another synchronisation pattern and pulses
			--*	the "next_sync" signal, then the state machine goes
			--*	into the "Look4Sync" state.
			--*********************************************************
			when Wait4Active =>
				count <= (others => '0');
				data_ready <= '1';
				if (read = '0' or sync_int = '1') then
					current_state <= GetData;
					cclk_on <= '1';
				end if;
				if (next_sync = '0') then
					current_state <= Look4Sync;
					cclk_on <= '1';
				end if;

			--*********************************************************
			--*	This state gets the data from the PROM. If the
			--*	synchronisation pattern has just been found then
			--*	enough data is retrieved to present the first
			--*	8 bits after the pattern. This is dependant on the
			--*	synchronisation pattern length.
			--*	If the synchronisation pattern has already been found
			--*	previously then only the next 8 bits of data are
			--*	retrieved.
			--*********************************************************
			when GetData =>
				if (din_read_enable = '1') then
					count <= count + 1;
					if (sync_int = '1') then
						if (count = (2**length) - 1) then
							current_state <= PresentData;
							sync_int <= '0';
							cclk_on <= '0';
						end if;
					else
						if (count = 7) then
							current_state <= PresentData;
							sync_int <= '0';
							cclk_on <= '0';
						end if;
					end if;
				end if;

			--*******************************************************
			--*	This state tells the user that 8 bits of data have
			--*	been retrieved and is presented on the "dout" port.
			--*	The "Wait4Active" state is then entered to wait for
			--*	another user request.
			--*******************************************************
			when PresentData =>
				dout <= data;
				data_ready <= '0';
				current_state <= Wait4Active;

			when others =>
				null;

		end case;
	end if;
	sync <= not sync_found;
end process;


end Behavioral;
