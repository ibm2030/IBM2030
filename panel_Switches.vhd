---------------------------------------------------------------------------
--    Copyright © 2015 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: panel_Switches.vhd
--    Creation Date: 13:26:00 25/11/2015
--    Description:
--    360/30 Front Panel Switch reading and status LED drivers
--    This reads all the front panel rotary and pushbutton switches
--    and also drives the 5 status LEDs at the lower-right
--    A Maxim MAX7318 device is used to scan (3 outputs) and read (8 inputs)
--    the switches, and also to drive the LEDs (5 outputs)
--
--    Revision History:
--    
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity panel_Switches is
	 Generic (
				Clock_divider : integer := 9; -- Fastest allowed is 1.4MHz / 36 for 50MHz clk
				Read_delay : integer := 700;	-- Number of divided clocks to wait between scan drive and switch read
				Number_Switches : integer := 64;
				Number_LEDs : integer := 5;
				MAX7318_address : std_logic_vector(6 downto 0) := "1000000"
				);
    Port ( -- Lamp input vector
           LEDs : in std_logic_vector(0 to Number_LEDs-1);
			  -- Switch output vector
			  Switches : out std_logic_vector(0 to Number_Switches-1);
			  -- Other inputs
			  clk : in STD_LOGIC; -- 50MHz default
			  reset : in STD_LOGIC := '0';
			  
           -- Driver outputs
           SCL : out std_logic;
			  SDA : inout std_logic
			  );
end panel_Switches;

architecture Behavioral of panel_Switches is

signal clk_out : std_logic := '0';
signal MAX7318_SCL, new_MAX7318_SCL, MAX7318_SDA, new_MAX7318_SDA : std_logic := '1';
type SPI_state_type is (idle_h,start_h,start_hl,data_l,data_lh,data_hl,ack_l,ack_l2,ack_lh,ack_h,ack_hl,stop_l,stop_lh,stop_h, stop_h2);
signal SPI_state, new_SPI_state : SPI_state_type := idle_h;
type MAX7318_state_type is (idle,writing45,writing67,writing2,delay,reading1);
signal MAX7318_state, new_MAX7318_state : MAX7318_state_type := idle;
signal SPI_error,new_SPI_error : Boolean := false;
signal bit_counter, new_bit_counter : integer range 0 to 8;
signal byteCount, new_byteCount : integer range 0 to 4;
signal delayCounter, new_delayCounter : integer range 0 to 50000;
constant top_data_out_bit : integer := 31;
signal dataOut, new_dataOut : std_logic_vector(top_data_out_bit downto 0);
signal dataIn, new_dataIn : std_logic_vector(7 downto 0);
signal writeByte, new_writeByte : std_logic_vector(3 downto 0);
signal switchBank, new_switchBank : std_logic_vector(2 downto 0) := "000";
type switchArrayType is array(0 to (Number_Switches+7)/8-1) of std_logic_vector(7 downto 0);
signal switchVector, new_switchVector : switchArrayType := (others=>"00000000");

-- MAX7318 stream is: start, address(7), r/w(1),
-- Address is 0x40 (AD0,1,2=0)
-- Registers are:
-- 00 Input 1						Unused
-- 01 Input 2						Scan inputs
-- 02 Output 1						0,1,2=Scan outputs 3,4,5,6,7=LEDs
-- 03 Output 2						Unused
-- 04 Port 1 Invert 1=Invert	00
-- 05 Port 2 Invert 1=Invert	00
-- 06 Port 1 Config 1=Input	00
-- 07 Port 2 Config 1=Input	FF

-- FSM sequence is:
-- Write 04,05: Write Command=4, Register4, Register5
-- Write 06,07: Write Command=6, Register6, Register7
-- Write 02, Wait 1ms, Read 01:	Write Command=2, Register2, Wait, Write Command=1, Read Register1

-- Basic scan allocation is:
-- Scan	Switches
--		0	ROS,RATE,ADDR_COMP
--		1	CHECK_CTL,A
--		2	B,C
--		3	D,E
--		4	E_O,SwSpare,E_I
--		5	G,H
--		6	J,SwPower,SwLeft1
--		7	SwLeft2

-- Switch bit allocation is:
-- Pos	Scan Bit		Switch			Position
--		0		0   7		ROSCTL_1			INH CF STOP
--		1		0   6		ROSCTL_3			ROS SCAN
--		2		0   5		RATE_1			INSN STEP
--		3		0   4		RATE_3			SINGLE CYC
--		4		0   3		ADDR_COMP_3
--		5		0   2		ADDR_COMP_2
--		6		0   1		ADDR_COMP_1
--		7		0   0		ADDR_COMP_0
--		8		1   7		CHECK_CTL_1		DIAGNOSTIC
--		9		1   6		CHECK_CTL_2		DISABLE
--		10		1   5		CHECK_CTL_4		STOP
--		11		1   4		CHECK_CTL_5		RESTART
--		12		1   3		A_3
--		13		1   2		A_2
--		14		1   1		A_1
--		15		1   0		A_0
--		16		2   7		B_3
--		17		2   6		B_2
--		18		2   5		B_1
--		19		2   4		B_0
--		20		2   3		C_3
--		21		2   2		C_2
--		22		2   1		C_1
--		23		2   0		C_0
--		24		3   7		D_3
--		25		3   6		D_2
--		26		3   5		D_1
--		27		3   4		D_0
--		28		3   3		F_3
--		29		3   2		F_2
--		30		3   1		F_1
--		31		3   0		F_0
--		32		4   7		SPARE_4
--		33		4   6		SPARE_2
--		34		4   5		EI_1				Black/Inner
--		35		4   4		EI_3				Grey/Outer
--		36		4   3		EO_3				\
--		37		4   2		EO_2				 \ 0
--		38		4   1		EO_1				  \ =
--		39		4   0		EO_0				   \ ?
--		40		5   7		G_3
--		41		5   6		G_2
--		42		5   5		G_1
--		43		5   4		G_0
--		44		5   3		H_3
--		45		5   2		H_2
--		46		5   1		H_1
--		47		5   0		H_0
--		48		6   7		J_3
--		49		6   6		J_2
--		50		6   5		J_1
--		51		6   4		J_0
--		52		6   3		PWR_4				LOAD
--		53		6   2		PWR_2				INTERRUPT
--		54		6   1		PB_20				DISPLAY
--		55		6   0		PB_18				STOP
--		56		7   7		PB_16				START
--		57		7   6		PB_14				LAMP TEST
--		58		7   5		PB_12				CHECK RESET
--		59		7   4		PB_10				STORE
--		60		7   3		PB_8				SET IC
--		61		7   2		PB_6				ROAR RESET
--		62		7   1		PB_4				INT TMR
--		63		7   0		PB_2				SYSTEM RESET

-- LED Driver allocation
--	Bit	Output	Lamp
--		4		7		LOAD
--		3		6		TEST
--		2		5		WAIT
--		1		4		MAN
--		0		3		SYS

begin
gen_clk : process (clk) is
	variable divider : integer := Clock_divider;
	begin
		if rising_edge(clk) then
			if (divider=0) then
				divider := Clock_divider;
				clk_out <= not clk_out;
			else
				divider := divider - 1;
			end if;
		end if;
	end process;


max7318 : process (clk_out) is
	begin
	if rising_edge(clk_out) then
	
		new_bit_counter <= bit_counter;
		new_byteCount <= byteCount;
		new_SPI_state <= SPI_state;
		new_MAX7318_state <= MAX7318_state;
		new_delayCounter <= delayCounter;
		new_dataOut <= dataOut;
		new_dataIn <= dataIn;
		new_writeByte <= writeByte;
		new_switchBank <= switchBank;
		new_switchVector <= switchVector;
		new_SPI_error <= SPI_error;
		
		case (SPI_state) is
			when idle_h =>
				new_MAX7318_SDA <= '1';
				new_MAX7318_SCL <= '1';
			when start_h =>
				new_MAX7318_SDA <= '0';
				new_MAX7318_SCL <= '1';
				new_SPI_state <= start_hl;
				new_SPI_error <= false;
			when start_hl =>
				-- Min 600ns (tSU STA)
				new_MAX7318_SDA <= '0';
				new_MAX7318_SCL <= '0';
				new_SPI_state <= data_l;
				new_bit_counter <= 7;
			when data_l =>
				-- Min 1300ns including data_lh state (tLOW)
				if (writeByte(3)='0') then
					new_MAX7318_SDA <= dataOut(top_data_out_bit);
					new_dataOut <= dataOut(top_data_out_bit-1 downto 0) & '0';
				else
					new_MAX7318_SDA <= '1';
					new_dataIn <= dataIn(6 downto 0) & MAX7318_SDA;
				end if;
				new_SPI_state <= data_lh;
			when data_lh =>
				-- Min 100ns (tSU DAT)
				new_MAX7318_SCL <= '1';
				new_SPI_state <= data_hl;
			when data_hl =>
				-- Min 700ns (tHIGH)
				new_MAX7318_SCL <= '0';
				if (bit_counter = 0) then
					new_SPI_state <= ack_l;
				else
					new_bit_counter <= bit_counter - 1;
					new_SPI_state <= data_l;
				end if;
			when ack_l =>
				-- Min 1300ns including ack_lh (tLOW)
				new_MAX7318_SCL <= '0';
				new_SPI_state <= ack_l2;
			when ack_l2 =>
				if (writeByte(3)='1') then
					new_MAX7318_SDA <= '0';
				else
					new_MAX7318_SDA <= '1';
				end if;
				new_SPI_state <= ack_lh;
			when ack_lh =>
				-- Min 300ns (tHD DAT)
				new_MAX7318_SCL <= '1';
				new_SPI_state <= ack_h;
			when ack_h =>
				-- Min 700ns (tHIGH)
				if (writeByte(3)='0') then
					if (MAX7318_SDA = '0') then
						-- Ok
					else
						-- Error
						new_SPI_error <= true;
					end if;
				else
					new_MAX7318_SDA <= '0';
				end if;
				new_SPI_state <= ack_hl;
			when ack_hl =>
				-- Min 300ns (tHD DAT)
				new_MAX7318_SCL <= '0';
				if (byteCount = 1) then
	--				new_MAX7318_SDA <= '0';
					new_SPI_state <= stop_l;
				else
					new_SPI_state <= data_l;
					new_byteCount <= byteCount - 1;
					new_writeByte <= writeByte(2 downto 0) & "0";
					new_bit_counter <= 7;
				end if;
			when stop_l =>
				new_MAX7318_SDA <= '0';
				new_SPI_state <= stop_lh;
			when stop_lh =>
	--			new_MAX7318_SDA <= '0';
				new_MAX7318_SCL <= '1';
				new_SPI_state <= stop_h;
			when stop_h =>
				-- Min 600ns (tSU STO)
				new_MAX7318_SDA <= '1';
				new_MAX7318_SCL <= '1';
				new_SPI_state <= stop_h2;
			when stop_h2 =>
				-- Min 1300ns including idle_h (tBUF)
				new_SPI_state <= idle_h;
		end case;
		
		case MAX7318_state is
			when idle =>
				if (SPI_state = idle_h) then
					new_dataOut <= MAX7318_address & "0" & "00000100" & "00000000" & "00000000"; -- 4,5 = 00,00
					new_writeByte <= "0000";
					new_byteCount <= 4;
					new_SPI_state <= start_h;
					new_MAX7318_state <= writing45;
				end if;
			when writing45 =>
				if (SPI_state = idle_h) then
					new_dataOut <= MAX7318_address & "0" & "00000110" & "00000000" & "11111111"; -- 6,7 = 00,FF
					new_writeByte <= "0000";
					new_byteCount <= 4;
					new_SPI_state <= start_h;
					new_MAX7318_state <= writing67;
				end if;
			when writing67 =>
				if (SPI_state = idle_h) then
					new_dataOut <= MAX7318_address & "0" & "00000010" & LEDs & switchBank & "00000000"; -- 2 = LLLLLSSS
					new_writeByte <= "0000";
					new_byteCount <= 3;
					new_SPI_state <= start_h;
					new_MAX7318_state <= writing2;
				end if;
			when writing2 =>
				if (SPI_state = idle_h) then
					new_delayCounter <= Read_delay;
					new_MAX7318_state <= delay;
				end if;
			when delay =>
				if (delayCounter = 0) then
					new_dataOut <= MAX7318_address & "1" & "00000001" & "11111111" & "00000000"; -- 1 = RRRRRRRR
					new_writeByte <= "0010";
					new_byteCount <= 3;
					new_SPI_state <= start_h;
					new_MAX7318_state <= reading1;
				else
					new_delayCounter <= delayCounter - 1;
				end if;
			when reading1 =>
				if (SPI_state = idle_h) then
					if (not SPI_error) then
						new_switchVector(to_integer(unsigned(switchBank))) <= dataIn(7 downto 0);
					end if;
					new_switchBank <= std_logic_vector(unsigned(switchBank) + 1);
					new_MAX7318_state <= idle;
				end if;
		end case;
		
		-- State variable updates
		MAX7318_SCL <= new_MAX7318_SCL;
		MAX7318_SDA <= new_MAX7318_SDA;
		bit_counter <= new_bit_counter;
		byteCount <= new_byteCount;
		if (reset='0') then
			SPI_state <= new_SPI_state;
			MAX7318_state <= new_MAX7318_state;
			SPI_error <= new_SPI_error;
		else
			SPI_state <= idle_h;
			MAX7318_state <= idle;
			SPI_error <= false;
		end if;
		delayCounter <= new_delayCounter;
		dataOut <= new_dataOut;
		dataIn <= new_dataIn;
		writeByte <= new_writeByte;
		switchBank <= new_SwitchBank;
		switchVector <= new_SwitchVector;
		
		-- Outputs
		switches <= switchVector(0) & switchVector(1) & switchVector(2) & switchVector(3) & switchVector(4) & switchVector(5) & switchVector(6) & switchVector(7);
		SCL <= new_MAX7318_SCL;
		if (new_MAX7318_SDA = '0') then
			-- Simulate Open Collector output - pin is defined in UCF to be PULLUP
			SDA <= '0';
		else
			SDA <= 'Z';
		end if;
	end if;
	
	end process;


end behavioral;

