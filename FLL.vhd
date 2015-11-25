----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:25:51 06/17/2015 
-- Design Name: 
-- Module Name:    FLL - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- FLL is a level-triggered SR flip-flop

entity FLL is port(S,R: in STD_LOGIC; signal Q:out STD_LOGIC); end;

architecture slt of FLL is
begin
process(S,R)
begin
if (S='1') then -- Set takes priority
	Q<='1' after 1ns;
elsif (R='1') then
	Q<='0' after 1ns;
end if;
end process;
end slt;


