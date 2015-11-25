----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:35:52 06/17/2015 
-- Design Name: 
-- Module Name:    FLVL - slt 
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

entity FLVL is port( S,R: in STD_LOGIC_VECTOR; signal Q:out STD_LOGIC_VECTOR); end;

architecture slt of FLVL is
alias S1 : STD_LOGIC_VECTOR(Q'range) is S;
alias R1 : STD_LOGIC_VECTOR(Q'range) is R;
begin
process (S1,R1)
begin
for i in Q'range loop
if (S1(i)='1') then -- Set takes priority
	Q(i)<='1';
elsif (R1(i)='1') then
	Q(i)<='0';
end if;
end loop;
end process;
end slt;

