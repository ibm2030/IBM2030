--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:36:53 11/26/2015
-- Design Name:   
-- Module Name:   C:/Users/lwilkinson/Documents/Xilinx/IBM2030GIT/Testbench_panel_Switches.vhd
-- Project Name:  IBM2030
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: panel_Switches
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Testbench_panel_Switches IS
END Testbench_panel_Switches;
 
ARCHITECTURE behavior OF Testbench_panel_Switches IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT panel_Switches
    PORT(
         LEDs : IN  std_logic_vector(0 to 4);
         clk : IN  std_logic;
         Switches : OUT  std_logic_vector(0 to 63);
         SCL : OUT  std_logic;
         SDA : INOUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal LEDs : std_logic_vector(0 to 4) := (others => '0');
   signal clk : std_logic := '0';

	--BiDirs
   signal MAX7318_SDA : std_logic;

 	--Outputs
   signal Switches : std_logic_vector(0 to 63);
   signal MAX7318_SCL : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: panel_Switches PORT MAP (
          LEDs => LEDs,
          clk => clk,
          Switches => Switches,
          SCL => MAX7318_SCL,
          SDA => MAX7318_SDA
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		wait for 10ms;

      wait;
   end process;

END;
