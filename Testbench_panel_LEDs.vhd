--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:16:46 06/18/2015
-- Design Name:   
-- Module Name:   C:/Users/lwilkinson/Documents/Xilinx/IBM2030/Testbench_panel_LEDs.vhd
-- Project Name:  IBM2030
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: panel_LEDs
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
 
ENTITY Testbench_panel_LEDs IS
END Testbench_panel_LEDs;
 
ARCHITECTURE behavior OF Testbench_panel_LEDs IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT panel_LEDs
    PORT(
         LEDs : IN  std_logic_vector(0 to 255);
         clk : IN  std_logic;
         MAX7219_CLK : OUT  std_logic;
         MAX7219_DIN0 : OUT  std_logic;
         MAX7219_DIN1 : OUT  std_logic;
         MAX7219_DIN2 : OUT  std_logic;
         MAX7219_DIN3 : OUT  std_logic;
         MAX7219_LOAD : OUT  std_logic;
         MAX6951_CLK : OUT  std_logic;
         MAX6951_DIN : OUT  std_logic;
         MAX6951_CS0 : OUT  std_logic;
         MAX6951_CS1 : OUT  std_logic;
         MAX6951_CS2 : OUT  std_logic;
         MAX6951_CS3 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal LEDs : std_logic_vector(0 to 255) := (1 => '1',3 => '1',5 => '1',7 => '1',9 => '1',11 => '1',13 => '1',15 => '1',17 => '1',others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal MAX7219_CLK : std_logic;
   signal MAX7219_DIN0 : std_logic;
   signal MAX7219_DIN1 : std_logic;
   signal MAX7219_DIN2 : std_logic;
   signal MAX7219_DIN3 : std_logic;
   signal MAX7219_LOAD : std_logic;
   signal MAX6951_CLK : std_logic;
   signal MAX6951_DIN : std_logic;
   signal MAX6951_CS0 : std_logic;
   signal MAX6951_CS1 : std_logic;
   signal MAX6951_CS2 : std_logic;
   signal MAX6951_CS3 : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: panel_LEDs PORT MAP (
          LEDs => LEDs,
          clk => clk,
          MAX7219_CLK => MAX7219_CLK,
          MAX7219_DIN0 => MAX7219_DIN0,
          MAX7219_DIN1 => MAX7219_DIN1,
          MAX7219_DIN2 => MAX7219_DIN2,
          MAX7219_DIN3 => MAX7219_DIN3,
          MAX7219_LOAD => MAX7219_LOAD,
          MAX6951_CLK => MAX6951_CLK,
          MAX6951_DIN => MAX6951_DIN,
          MAX6951_CS0 => MAX6951_CS0,
          MAX6951_CS1 => MAX6951_CS1,
          MAX6951_CS2 => MAX6951_CS2,
          MAX6951_CS3 => MAX6951_CS3
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

      wait for 1ms;

      -- insert stimulus here 

      wait;
   end process;

END;
