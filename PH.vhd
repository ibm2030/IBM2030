----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:34:05 06/17/2015 
-- Design Name: 
-- Module Name:    PH - slt 
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

-- Simple PH (polarity hold) latch

entity PH is port( D,L: in STD_LOGIC; signal Q:out STD_LOGIC); end;

architecture slt of PH is
begin
process(L,D)
begin
if (L='1') then
	Q <= D;
end if;
end process;
end slt;

