----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2025 11:38:59 AM
-- Design Name: 
-- Module Name: ibm2030_reset_run - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ibm2030_reset_run is
--  Port ( );
end ibm2030_reset_run;

architecture Behavioral of ibm2030_reset_run is

signal reset, run : std_logic := '0';
signal sysclk, clk50M, clk40M : std_logic := '0';
signal sda : std_logic := '0';

begin

dut : entity ibm2030 port map (
    sysclk => sysclk,
    clk50M => clk50M,
    clk40M => clk40M,
    pb(0) => reset,
    pb(1) => run,
    pb(2) => '0',
    pb(3) => '0',
    pb(4) => '0',
    pb(5) => '0',
    sw => (others => '0'),
    MAX7318_SDA => sda,
    serialrx => '0',
    bram1_clk => '0',
    bram1_rst => '0',
    bram1_en => '0',
    bram1_we => (others => '0'),
    bram1_addr => (others=>'0'),
    bram1_wrdata => (others => '0'),
    bram2_clk => '0',
    bram2_rst => '0',
    bram2_en => '0',
    bram2_we => (others => '0'),
    bram2_addr => (others=>'0'),
    bram2_wrdata => (others => '0'
    )
);

sysclk_gen : process begin
    sysclk <= '0';
    wait for 4ns;
    sysclk <= '1';
    wait for 4ns;
end process;

clk50M_gen : process begin
    clk50M <= '0';
    wait for 10ns;
    clk50M <= '1';
    wait for 10ns;
end process;

clk40M_gen : process begin
    clk40M <= '0';
    wait for 12ns;
    clk40M <= '1';
    wait for 13ns;
end process;

sim : process begin 
reset <= '1';
wait for 3ms;

reset <= '0';
wait for 3ms;

run <= '1';
wait for 3ms;

run <= '0';
wait for 3ms;

wait;
end process;

end Behavioral;
