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
--	MODULE  : clock_management.vhd
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
--	This module generates an enable signal for
--	the shift register and comparator. It also
--	generates the clock signal that is connected
--	to the PROM.
--	The enable and clock signals are generated
--	based on the "frequency" generic entered for
--	the system clock.
--	The clock signal is only generated at the
--	appropriate times. All other states the clock
--	signal is kept at a logic high. The PROMs
--	address counter only increments on a rising
--	edge of this clock.


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
entity clock_management is
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
end clock_management;


architecture Behavioral of clock_management is


signal cclk_int : std_logic := '1';
signal enable_cclk : std_logic;
signal SRL_length : std_logic_vector(3 downto 0);
signal temp : integer := (frequency / 20) - 1;


begin


--***************************************************
--*	The length of the SRL16 is based on the system
--*	clock frequency entered. This frequency is then
--*	"divided" down to approximately 10MHz.
--***************************************************
SRL_length <= conv_std_logic_vector(temp, length - 1);

Divider0: SRL16
	generic map(
		init => X"0001"
		)
	port map(
		clk => clock,
		d => enable_cclk,
		a0 => SRL_length(0),
		a1 => SRL_length(1),
		a2 => SRL_length(2),
		a3 => SRL_length(3),
		q => enable_cclk
		);


--***************************************************
--*	This process generates the enable signal for
--*	the shift register and the comparator. It also
--*	generates the clock signal used to increment
--*	the PROMs address counter.
--***************************************************
process(clock, enable_cclk, enable, cclk_int)
begin
	if rising_edge(clock) then
		if (enable = '1') then
			if (enable_cclk = '1') then
				cclk_int <= not cclk_int;
			end if;
			if (enable_cclk = '1' and cclk_int = '1') then
				read_enable <= '1';
			else
				read_enable <= '0';
			end if;
		else
			cclk_int <= '1';
		end if;
	end if;
	cclk <= cclk_int;
end process;


end Behavioral;
