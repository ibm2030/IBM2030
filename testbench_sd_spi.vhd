--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:40:51 03/14/2013
-- Design Name:   
-- Module Name:   testbench_sd_spi.vhd
-- Project Name:  ibm2030
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sd_controller
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
USE ieee.std_logic_unsigned.all;
USE STD.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY testbench_sd_spi IS
END testbench_sd_spi;
 
ARCHITECTURE behavior OF testbench_sd_spi IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sd_controller
	 GENERIC(
			WRITE_TIMEOUT : integer := 1
			);
    PORT(
			cs : out std_logic;
			mosi : out std_logic;
			miso : in std_logic;
			sclk : out std_logic;
			card_present : in std_logic;
			card_write_prot : in std_logic;

			rd : in std_logic; -- Should latch addr on rising edge
			rd_multiple : in std_logic; -- Should latch addr on rising edge
			wr : in std_logic; -- Should latch addr on rising edge
			wr_multiple : in std_logic; -- Should latch addr on rising edge
			addr : in std_logic_vector(31 downto 0);
			reset : in std_logic;
			sd_error : out std_logic; -- '1' if an error occurs, reset on next RD or WR
			sd_busy : out std_logic; -- '0' if a RD or WR can be accepted
			sd_error_code : out std_logic_vector(2 downto 0);
			
			din : in std_logic_vector(7 downto 0);
			din_valid : in std_logic;
			din_taken : out std_logic;
			
			dout : out std_logic_vector(7 downto 0);
			dout_avail : out std_logic;
			dout_taken : in std_logic;
			
			clk : in std_logic;	-- twice the SPI clk
			
			-- Debug stuff
			sd_type : out std_logic_vector(1 downto 0);
			sd_fsm : out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal miso : std_logic := '0';
   signal rd : std_logic := '0';
   signal rd_multiple : std_logic := '0';
   signal wr : std_logic := '0';
   signal wr_multiple : std_logic := '0';
   signal addr : std_logic_vector(31 downto 0) := (others => '0');
   signal reset : std_logic := '1';
   signal din : std_logic_vector(7 downto 0) := (others => '0');
   signal din_valid : std_logic := '0';
   signal dout_taken : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal cs : std_logic;
   signal mosi : std_logic;
   signal sclk : std_logic;
   signal sd_state : std_logic_vector(1 downto 0);
   signal sd_fsm : std_logic_vector(7 downto 0);
	signal sd_error : std_logic;
	signal sd_error_code : std_logic_vector(2 downto 0);
	signal sd_busy : std_logic;
   signal din_taken : std_logic;
   signal dout : std_logic_vector(7 downto 0);
   signal dout_avail : std_logic;

   -- Clock period definitions
--   constant sclk_period : time := 1000 ns;
   constant clk_period : time := 20 ns;
	
	signal clocks : integer := 0;
 
constant CPOL : std_logic := '0';
signal clk_pol : std_logic;

constant byteArraySize : integer := 4000;

signal rx_byte : std_logic_vector(7 downto 0);
signal rx_bit_counter : integer := 0;
signal rx_byte_counter : integer := 0;

signal tx_byte : std_logic_vector(7 downto 0);
signal tx_bit_counter : integer := 0;
signal tx_byte_counter : integer := 0;


type byte2_array is array(0 to byteArraySize) of std_logic_vector(15 downto 0);

shared variable input_output_bytes  : byte2_array := (
	-- The following list of words defines what the card expects to receive and
	-- what it should generate in response.
	--
	-- A word is x"RRTT" RR=Expected received byte, TT=Simultaneously transmitted byte
	-- A "FF" as the expected received byte means "Don't care"
	-- CMD0 FF400000000095
	x"FFFF", -- 0
	x"40FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"95FF",
	x"FFFF", -- Wait
	x"FF01", -- R1 b7=0
	
	-- CMD8 FF48000001AA87
	x"FFFF", -- 9
	x"48FF",
	x"00FF",
	x"00FF",
	x"01FF",
	x"AAFF",
	x"87FF",
	x"FFFF", -- Wait
	x"FF01", -- R7
	x"FF00",
	x"FF00",
	x"FF01",
	x"FFAA",
	
	-- CMD55 FF770000000001
	x"FFFF", -- 22
	x"77FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"65FF",
	x"FFFF", -- Wait
	x"FF01", -- R1 IDLE=1
	
	-- CMD41 FF690000004001
	x"FFFF", -- 31
	x"69FF",
	x"40FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"77FF",
	x"FFFF", -- Wait
	x"FF01", -- R1 IDLE=1

	-- CMD55 FF770000000001
	x"FFFF", -- 40
	x"77FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"65FF",
	x"FFFF", -- Wait
	x"FF01", -- R1 IDLE=1
	
	-- CMD41 FF690000004001
	x"FFFF", -- 49
	x"69FF",
	x"40FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"77FF",
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0

	-- CMD58 FF7A0000000001
	x"FFFF", -- 58
	x"7AFF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"FDFF",
	x"FFFF", -- Wait
	x"FF00", -- R3 IDLE=0
	x"FF40", -- OCR b30=1 => SDHC
	x"FF00",
	x"FF00",
	x"FF00",
	
	-- CMD59 FF7B0000000101 (Enable CRC)
	x"FFFF", -- 71
	x"7BFF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"01FF",
	x"83FF",
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FFFF", -- IDLE
	
	-- CMD17 FF510000000055
	x"FFFF", -- 80
	x"51FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"55FF",
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FFFF", -- Token
	x"FFFF", -- Token
	x"FFFE", -- Token
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF09",x"FF39",
	x"FFFF",
	
	-- CMD17 FF510000000055
	x"FFFF",
	x"51FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"55FF",
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FFFE", -- Token
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF09",x"FF39",
	x"FFFF",

	-- CMD18 FF5200000000E1
	x"FFFF",
	x"52FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"E1FF",
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FFFE", -- Token
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF09",x"FF39",
	x"FFFF",x"FFFF",x"FFFF",x"FFFF",x"FFFF",
	x"FFFE", -- Token
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",
	x"4C0C",x"000D",x"000E",x"000F",x"0010",x"6111", -- CMD12 to stop 4C0000000061
	x"FF12", -- Last reception byte - NOT R1
	x"FFFF",x"FF00", -- Delay then R1b
	x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF07", -- Busy signal

	-- CMD18 FF5200000000E1
	x"FFFF",
	x"52FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"E1FF",
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FFFE", -- Token
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF00",x"FF01",x"FF02",x"FF03",x"FF04",x"FF05",x"FF06",x"FF07",x"FF08",x"FF09",x"FF0A",x"FF0B",x"FF0C",x"FF0D",x"FF0E",x"FF0F",
	x"FF10",x"FF11",x"FF12",x"FF13",x"FF14",x"FF15",x"FF16",x"FF17",x"FF18",x"FF19",x"FF1A",x"FF1B",x"FF1C",x"FF1D",x"FF1E",x"FF1F",
	x"FF20",x"FF21",x"FF22",x"FF23",x"FF24",x"FF25",x"FF26",x"FF27",x"FF28",x"FF29",x"FF2A",x"FF2B",x"FF2C",x"FF2D",x"FF2E",x"FF2F",
	x"FF30",x"FF31",x"FF32",x"FF33",x"FF34",x"FF35",x"FF36",x"FF37",x"FF38",x"FF39",x"FF3A",x"FF3B",x"FF3C",x"FF3D",x"FF3E",x"FF3F",
	x"FF09",x"FF39",
	x"FFFF",x"4CFE",x"0000",x"0001",x"0002",x"0003",x"6104",
	x"FF05",x"FF00", -- Delay then R1b
	x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF7F", -- Busy signal

	-- CMD24 FF5800000000000
	x"FFFF", --
	x"58FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"6FFF", --
	x"FFFF", -- Wait
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FEFF", -- Token
	x"00FF",x"01FF",x"02FF",x"03FF",x"04FF",x"05FF",x"06FF",x"07FF",x"08FF",x"09FF",x"0AFF",x"0BFF",x"0CFF",x"0DFF",x"0EFF",x"0FFF",
	x"10FF",x"11FF",x"12FF",x"13FF",x"14FF",x"15FF",x"16FF",x"17FF",x"18FF",x"19FF",x"1AFF",x"1BFF",x"1CFF",x"1DFF",x"1EFF",x"1FFF",
	x"20FF",x"21FF",x"22FF",x"23FF",x"24FF",x"25FF",x"26FF",x"27FF",x"28FF",x"29FF",x"2AFF",x"2BFF",x"2CFF",x"2DFF",x"2EFF",x"2FFF",
	x"30FF",x"31FF",x"32FF",x"33FF",x"34FF",x"35FF",x"36FF",x"37FF",x"38FF",x"39FF",x"3AFF",x"3BFF",x"3CFF",x"3DFF",x"3EFF",x"3FFF",
	x"40FF",x"41FF",x"42FF",x"43FF",x"44FF",x"45FF",x"46FF",x"47FF",x"48FF",x"49FF",x"4AFF",x"4BFF",x"4CFF",x"4DFF",x"4EFF",x"4FFF",
	x"50FF",x"51FF",x"52FF",x"53FF",x"54FF",x"55FF",x"56FF",x"57FF",x"58FF",x"59FF",x"5AFF",x"5BFF",x"5CFF",x"5DFF",x"5EFF",x"5FFF",
	x"60FF",x"61FF",x"62FF",x"63FF",x"64FF",x"65FF",x"66FF",x"67FF",x"68FF",x"69FF",x"6AFF",x"6BFF",x"6CFF",x"6DFF",x"6EFF",x"6FFF",
	x"70FF",x"71FF",x"72FF",x"73FF",x"74FF",x"75FF",x"76FF",x"77FF",x"78FF",x"79FF",x"7AFF",x"7BFF",x"7CFF",x"7DFF",x"7EFF",x"7FFF",
	x"80FF",x"81FF",x"82FF",x"83FF",x"84FF",x"85FF",x"86FF",x"87FF",x"88FF",x"89FF",x"8AFF",x"8BFF",x"8CFF",x"8DFF",x"8EFF",x"8FFF",
	x"90FF",x"91FF",x"92FF",x"93FF",x"94FF",x"95FF",x"96FF",x"97FF",x"98FF",x"99FF",x"9AFF",x"9BFF",x"9CFF",x"9DFF",x"9EFF",x"9FFF",
	x"A0FF",x"A1FF",x"A2FF",x"A3FF",x"A4FF",x"A5FF",x"A6FF",x"A7FF",x"A8FF",x"A9FF",x"AAFF",x"ABFF",x"ACFF",x"ADFF",x"AEFF",x"AFFF",
	x"B0FF",x"B1FF",x"B2FF",x"B3FF",x"B4FF",x"B5FF",x"B6FF",x"B7FF",x"B8FF",x"B9FF",x"BAFF",x"BBFF",x"BCFF",x"BDFF",x"BEFF",x"BFFF",
	x"C0FF",x"C1FF",x"C2FF",x"C3FF",x"C4FF",x"C5FF",x"C6FF",x"C7FF",x"C8FF",x"C9FF",x"CAFF",x"CBFF",x"CCFF",x"CDFF",x"CEFF",x"CFFF",
	x"D0FF",x"D1FF",x"D2FF",x"D3FF",x"D4FF",x"D5FF",x"D6FF",x"D7FF",x"D8FF",x"D9FF",x"DAFF",x"DBFF",x"DCFF",x"DDFF",x"DEFF",x"DFFF",
	x"E0FF",x"E1FF",x"E2FF",x"E3FF",x"E4FF",x"E5FF",x"E6FF",x"E7FF",x"E8FF",x"E9FF",x"EAFF",x"EBFF",x"ECFF",x"EDFF",x"EEFF",x"EFFF",
	x"F0FF",x"F1FF",x"F2FF",x"F3FF",x"F4FF",x"F5FF",x"F6FF",x"F7FF",x"F8FF",x"F9FF",x"FAFF",x"FBFF",x"FCFF",x"FDFF",x"FEFF",x"FFFF",
	x"00FF",x"01FF",x"02FF",x"03FF",x"04FF",x"05FF",x"06FF",x"07FF",x"08FF",x"09FF",x"0AFF",x"0BFF",x"0CFF",x"0DFF",x"0EFF",x"0FFF",
	x"10FF",x"11FF",x"12FF",x"13FF",x"14FF",x"15FF",x"16FF",x"17FF",x"18FF",x"19FF",x"1AFF",x"1BFF",x"1CFF",x"1DFF",x"1EFF",x"1FFF",
	x"20FF",x"21FF",x"22FF",x"23FF",x"24FF",x"25FF",x"26FF",x"27FF",x"28FF",x"29FF",x"2AFF",x"2BFF",x"2CFF",x"2DFF",x"2EFF",x"2FFF",
	x"30FF",x"31FF",x"32FF",x"33FF",x"34FF",x"35FF",x"36FF",x"37FF",x"38FF",x"39FF",x"3AFF",x"3BFF",x"3CFF",x"3DFF",x"3EFF",x"3FFF",
	x"40FF",x"41FF",x"42FF",x"43FF",x"44FF",x"45FF",x"46FF",x"47FF",x"48FF",x"49FF",x"4AFF",x"4BFF",x"4CFF",x"4DFF",x"4EFF",x"4FFF",
	x"50FF",x"51FF",x"52FF",x"53FF",x"54FF",x"55FF",x"56FF",x"57FF",x"58FF",x"59FF",x"5AFF",x"5BFF",x"5CFF",x"5DFF",x"5EFF",x"5FFF",
	x"60FF",x"61FF",x"62FF",x"63FF",x"64FF",x"65FF",x"66FF",x"67FF",x"68FF",x"69FF",x"6AFF",x"6BFF",x"6CFF",x"6DFF",x"6EFF",x"6FFF",
	x"70FF",x"71FF",x"72FF",x"73FF",x"74FF",x"75FF",x"76FF",x"77FF",x"78FF",x"79FF",x"7AFF",x"7BFF",x"7CFF",x"7DFF",x"7EFF",x"7FFF",
	x"80FF",x"81FF",x"82FF",x"83FF",x"84FF",x"85FF",x"86FF",x"87FF",x"88FF",x"89FF",x"8AFF",x"8BFF",x"8CFF",x"8DFF",x"8EFF",x"8FFF",
	x"90FF",x"91FF",x"92FF",x"93FF",x"94FF",x"95FF",x"96FF",x"97FF",x"98FF",x"99FF",x"9AFF",x"9BFF",x"9CFF",x"9DFF",x"9EFF",x"9FFF",
	x"A0FF",x"A1FF",x"A2FF",x"A3FF",x"A4FF",x"A5FF",x"A6FF",x"A7FF",x"A8FF",x"A9FF",x"AAFF",x"ABFF",x"ACFF",x"ADFF",x"AEFF",x"AFFF",
	x"B0FF",x"B1FF",x"B2FF",x"B3FF",x"B4FF",x"B5FF",x"B6FF",x"B7FF",x"B8FF",x"B9FF",x"BAFF",x"BBFF",x"BCFF",x"BDFF",x"BEFF",x"BFFF",
	x"C0FF",x"C1FF",x"C2FF",x"C3FF",x"C4FF",x"C5FF",x"C6FF",x"C7FF",x"C8FF",x"C9FF",x"CAFF",x"CBFF",x"CCFF",x"CDFF",x"CEFF",x"CFFF",
	x"D0FF",x"D1FF",x"D2FF",x"D3FF",x"D4FF",x"D5FF",x"D6FF",x"D7FF",x"D8FF",x"D9FF",x"DAFF",x"DBFF",x"DCFF",x"DDFF",x"DEFF",x"DFFF",
	x"E0FF",x"E1FF",x"E2FF",x"E3FF",x"E4FF",x"E5FF",x"E6FF",x"E7FF",x"E8FF",x"E9FF",x"EAFF",x"EBFF",x"ECFF",x"EDFF",x"EEFF",x"EFFF",
	x"F0FF",x"F1FF",x"F2FF",x"F3FF",x"F4FF",x"F5FF",x"F6FF",x"F7FF",x"F8FF",x"F9FF",x"FAFF",x"FBFF",x"FCFF",x"FDFF",x"FEFF",x"FFFF",
	x"40FF",x"DAFF", -- CRC
	x"FF05", -- Accepted
	x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF0F", -- Working
	
	-- CMD25 FF5900000000000
	x"FFFF",x"FFFF",
	x"59FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"03FF", --
	x"FFFF", -- Wait
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FCFF", -- Token
	x"00FF",x"01FF",x"02FF",x"03FF",x"04FF",x"05FF",x"06FF",x"07FF",x"08FF",x"09FF",x"0AFF",x"0BFF",x"0CFF",x"0DFF",x"0EFF",x"0FFF",
	x"10FF",x"11FF",x"12FF",x"13FF",x"14FF",x"15FF",x"16FF",x"17FF",x"18FF",x"19FF",x"1AFF",x"1BFF",x"1CFF",x"1DFF",x"1EFF",x"1FFF",
	x"20FF",x"21FF",x"22FF",x"23FF",x"24FF",x"25FF",x"26FF",x"27FF",x"28FF",x"29FF",x"2AFF",x"2BFF",x"2CFF",x"2DFF",x"2EFF",x"2FFF",
	x"30FF",x"31FF",x"32FF",x"33FF",x"34FF",x"35FF",x"36FF",x"37FF",x"38FF",x"39FF",x"3AFF",x"3BFF",x"3CFF",x"3DFF",x"3EFF",x"3FFF",
	x"40FF",x"41FF",x"42FF",x"43FF",x"44FF",x"45FF",x"46FF",x"47FF",x"48FF",x"49FF",x"4AFF",x"4BFF",x"4CFF",x"4DFF",x"4EFF",x"4FFF",
	x"50FF",x"51FF",x"52FF",x"53FF",x"54FF",x"55FF",x"56FF",x"57FF",x"58FF",x"59FF",x"5AFF",x"5BFF",x"5CFF",x"5DFF",x"5EFF",x"5FFF",
	x"60FF",x"61FF",x"62FF",x"63FF",x"64FF",x"65FF",x"66FF",x"67FF",x"68FF",x"69FF",x"6AFF",x"6BFF",x"6CFF",x"6DFF",x"6EFF",x"6FFF",
	x"70FF",x"71FF",x"72FF",x"73FF",x"74FF",x"75FF",x"76FF",x"77FF",x"78FF",x"79FF",x"7AFF",x"7BFF",x"7CFF",x"7DFF",x"7EFF",x"7FFF",
	x"80FF",x"81FF",x"82FF",x"83FF",x"84FF",x"85FF",x"86FF",x"87FF",x"88FF",x"89FF",x"8AFF",x"8BFF",x"8CFF",x"8DFF",x"8EFF",x"8FFF",
	x"90FF",x"91FF",x"92FF",x"93FF",x"94FF",x"95FF",x"96FF",x"97FF",x"98FF",x"99FF",x"9AFF",x"9BFF",x"9CFF",x"9DFF",x"9EFF",x"9FFF",
	x"A0FF",x"A1FF",x"A2FF",x"A3FF",x"A4FF",x"A5FF",x"A6FF",x"A7FF",x"A8FF",x"A9FF",x"AAFF",x"ABFF",x"ACFF",x"ADFF",x"AEFF",x"AFFF",
	x"B0FF",x"B1FF",x"B2FF",x"B3FF",x"B4FF",x"B5FF",x"B6FF",x"B7FF",x"B8FF",x"B9FF",x"BAFF",x"BBFF",x"BCFF",x"BDFF",x"BEFF",x"BFFF",
	x"C0FF",x"C1FF",x"C2FF",x"C3FF",x"C4FF",x"C5FF",x"C6FF",x"C7FF",x"C8FF",x"C9FF",x"CAFF",x"CBFF",x"CCFF",x"CDFF",x"CEFF",x"CFFF",
	x"D0FF",x"D1FF",x"D2FF",x"D3FF",x"D4FF",x"D5FF",x"D6FF",x"D7FF",x"D8FF",x"D9FF",x"DAFF",x"DBFF",x"DCFF",x"DDFF",x"DEFF",x"DFFF",
	x"E0FF",x"E1FF",x"E2FF",x"E3FF",x"E4FF",x"E5FF",x"E6FF",x"E7FF",x"E8FF",x"E9FF",x"EAFF",x"EBFF",x"ECFF",x"EDFF",x"EEFF",x"EFFF",
	x"F0FF",x"F1FF",x"F2FF",x"F3FF",x"F4FF",x"F5FF",x"F6FF",x"F7FF",x"F8FF",x"F9FF",x"FAFF",x"FBFF",x"FCFF",x"FDFF",x"FEFF",x"FFFF",
	x"00FF",x"01FF",x"02FF",x"03FF",x"04FF",x"05FF",x"06FF",x"07FF",x"08FF",x"09FF",x"0AFF",x"0BFF",x"0CFF",x"0DFF",x"0EFF",x"0FFF",
	x"10FF",x"11FF",x"12FF",x"13FF",x"14FF",x"15FF",x"16FF",x"17FF",x"18FF",x"19FF",x"1AFF",x"1BFF",x"1CFF",x"1DFF",x"1EFF",x"1FFF",
	x"20FF",x"21FF",x"22FF",x"23FF",x"24FF",x"25FF",x"26FF",x"27FF",x"28FF",x"29FF",x"2AFF",x"2BFF",x"2CFF",x"2DFF",x"2EFF",x"2FFF",
	x"30FF",x"31FF",x"32FF",x"33FF",x"34FF",x"35FF",x"36FF",x"37FF",x"38FF",x"39FF",x"3AFF",x"3BFF",x"3CFF",x"3DFF",x"3EFF",x"3FFF",
	x"40FF",x"41FF",x"42FF",x"43FF",x"44FF",x"45FF",x"46FF",x"47FF",x"48FF",x"49FF",x"4AFF",x"4BFF",x"4CFF",x"4DFF",x"4EFF",x"4FFF",
	x"50FF",x"51FF",x"52FF",x"53FF",x"54FF",x"55FF",x"56FF",x"57FF",x"58FF",x"59FF",x"5AFF",x"5BFF",x"5CFF",x"5DFF",x"5EFF",x"5FFF",
	x"60FF",x"61FF",x"62FF",x"63FF",x"64FF",x"65FF",x"66FF",x"67FF",x"68FF",x"69FF",x"6AFF",x"6BFF",x"6CFF",x"6DFF",x"6EFF",x"6FFF",
	x"70FF",x"71FF",x"72FF",x"73FF",x"74FF",x"75FF",x"76FF",x"77FF",x"78FF",x"79FF",x"7AFF",x"7BFF",x"7CFF",x"7DFF",x"7EFF",x"7FFF",
	x"80FF",x"81FF",x"82FF",x"83FF",x"84FF",x"85FF",x"86FF",x"87FF",x"88FF",x"89FF",x"8AFF",x"8BFF",x"8CFF",x"8DFF",x"8EFF",x"8FFF",
	x"90FF",x"91FF",x"92FF",x"93FF",x"94FF",x"95FF",x"96FF",x"97FF",x"98FF",x"99FF",x"9AFF",x"9BFF",x"9CFF",x"9DFF",x"9EFF",x"9FFF",
	x"A0FF",x"A1FF",x"A2FF",x"A3FF",x"A4FF",x"A5FF",x"A6FF",x"A7FF",x"A8FF",x"A9FF",x"AAFF",x"ABFF",x"ACFF",x"ADFF",x"AEFF",x"AFFF",
	x"B0FF",x"B1FF",x"B2FF",x"B3FF",x"B4FF",x"B5FF",x"B6FF",x"B7FF",x"B8FF",x"B9FF",x"BAFF",x"BBFF",x"BCFF",x"BDFF",x"BEFF",x"BFFF",
	x"C0FF",x"C1FF",x"C2FF",x"C3FF",x"C4FF",x"C5FF",x"C6FF",x"C7FF",x"C8FF",x"C9FF",x"CAFF",x"CBFF",x"CCFF",x"CDFF",x"CEFF",x"CFFF",
	x"D0FF",x"D1FF",x"D2FF",x"D3FF",x"D4FF",x"D5FF",x"D6FF",x"D7FF",x"D8FF",x"D9FF",x"DAFF",x"DBFF",x"DCFF",x"DDFF",x"DEFF",x"DFFF",
	x"E0FF",x"E1FF",x"E2FF",x"E3FF",x"E4FF",x"E5FF",x"E6FF",x"E7FF",x"E8FF",x"E9FF",x"EAFF",x"EBFF",x"ECFF",x"EDFF",x"EEFF",x"EFFF",
	x"F0FF",x"F1FF",x"F2FF",x"F3FF",x"F4FF",x"F5FF",x"F6FF",x"F7FF",x"F8FF",x"F9FF",x"FAFF",x"FBFF",x"FCFF",x"FDFF",x"FEFF",x"FFFF",
	x"40FF",x"DAFF", -- CRC
	x"FF05", -- Accepted
	x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00", -- Working
	x"FFFF", -- Finished
	x"FDFF", -- End Token
	x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00", -- Working
	x"FFFF", -- Finished

	-- CMD25 FF5900000000000
	x"FFFF",
	x"59FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"00FF",
	x"03FF", --
	x"FFFF", -- Wait
	x"FFFF", -- Wait
	x"FF00", -- R1 IDLE=0
	x"FCFF", -- Token
	x"00FF",x"01FF",x"02FF",x"03FF",x"04FF",x"05FF",x"06FF",x"07FF",x"08FF",x"09FF",x"0AFF",x"0BFF",x"0CFF",x"0DFF",x"0EFF",x"0FFF",
	x"10FF",x"11FF",x"12FF",x"13FF",x"14FF",x"15FF",x"16FF",x"17FF",x"18FF",x"19FF",x"1AFF",x"1BFF",x"1CFF",x"1DFF",x"1EFF",x"1FFF",
	x"20FF",x"21FF",x"22FF",x"23FF",x"24FF",x"25FF",x"26FF",x"27FF",x"28FF",x"29FF",x"2AFF",x"2BFF",x"2CFF",x"2DFF",x"2EFF",x"2FFF",
	x"30FF",x"31FF",x"32FF",x"33FF",x"34FF",x"35FF",x"36FF",x"37FF",x"38FF",x"39FF",x"3AFF",x"3BFF",x"3CFF",x"3DFF",x"3EFF",x"3FFF",
	x"40FF",x"41FF",x"42FF",x"43FF",x"44FF",x"45FF",x"46FF",x"47FF",x"48FF",x"49FF",x"4AFF",x"4BFF",x"4CFF",x"4DFF",x"4EFF",x"4FFF",
	x"50FF",x"51FF",x"52FF",x"53FF",x"54FF",x"55FF",x"56FF",x"57FF",x"58FF",x"59FF",x"5AFF",x"5BFF",x"5CFF",x"5DFF",x"5EFF",x"5FFF",
	x"60FF",x"61FF",x"62FF",x"63FF",x"64FF",x"65FF",x"66FF",x"67FF",x"68FF",x"69FF",x"6AFF",x"6BFF",x"6CFF",x"6DFF",x"6EFF",x"6FFF",
	x"70FF",x"71FF",x"72FF",x"73FF",x"74FF",x"75FF",x"76FF",x"77FF",x"78FF",x"79FF",x"7AFF",x"7BFF",x"7CFF",x"7DFF",x"7EFF",x"7FFF",
	x"80FF",x"81FF",x"82FF",x"83FF",x"84FF",x"85FF",x"86FF",x"87FF",x"88FF",x"89FF",x"8AFF",x"8BFF",x"8CFF",x"8DFF",x"8EFF",x"8FFF",
	x"90FF",x"91FF",x"92FF",x"93FF",x"94FF",x"95FF",x"96FF",x"97FF",x"98FF",x"99FF",x"9AFF",x"9BFF",x"9CFF",x"9DFF",x"9EFF",x"9FFF",
	x"A0FF",x"A1FF",x"A2FF",x"A3FF",x"A4FF",x"A5FF",x"A6FF",x"A7FF",x"A8FF",x"A9FF",x"AAFF",x"ABFF",x"ACFF",x"ADFF",x"AEFF",x"AFFF",
	x"B0FF",x"B1FF",x"B2FF",x"B3FF",x"B4FF",x"B5FF",x"B6FF",x"B7FF",x"B8FF",x"B9FF",x"BAFF",x"BBFF",x"BCFF",x"BDFF",x"BEFF",x"BFFF",
	x"C0FF",x"C1FF",x"C2FF",x"C3FF",x"C4FF",x"C5FF",x"C6FF",x"C7FF",x"C8FF",x"C9FF",x"CAFF",x"CBFF",x"CCFF",x"CDFF",x"CEFF",x"CFFF",
	x"D0FF",x"D1FF",x"D2FF",x"D3FF",x"D4FF",x"D5FF",x"D6FF",x"D7FF",x"D8FF",x"D9FF",x"DAFF",x"DBFF",x"DCFF",x"DDFF",x"DEFF",x"DFFF",
	x"E0FF",x"E1FF",x"E2FF",x"E3FF",x"E4FF",x"E5FF",x"E6FF",x"E7FF",x"E8FF",x"E9FF",x"EAFF",x"EBFF",x"ECFF",x"EDFF",x"EEFF",x"EFFF",
	x"F0FF",x"F1FF",x"F2FF",x"F3FF",x"F4FF",x"F5FF",x"F6FF",x"F7FF",x"F8FF",x"F9FF",x"FAFF",x"FBFF",x"FCFF",x"FDFF",x"FEFF",x"FFFF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",x"00FF",
	x"3EFF",x"8EFF", -- CRC
	x"FF0b", -- Rejected
	x"FDFF", -- End Token
	x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00",x"FF00", -- Working
	x"FFFF", -- Finished

	others=>x"FFFF");

function slv_to_string(slv: std_logic_vector) return string is
    use Std.TextIO.all;
    variable bv: bit_vector(slv'range) := to_bitvector(slv);
    variable cv: line;
  begin
    write(cv, bv);
    return cv.all;
  end;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sd_controller PORT MAP (
          cs => cs,
          mosi => mosi,
          miso => miso,
          sclk => sclk,
			 card_present => '1',
			 card_write_prot => '0',
          sd_type => sd_state,
          sd_fsm => sd_fsm,
			 sd_error => sd_error,
			 sd_error_code => sd_error_code,
			 sd_busy => sd_busy,
          rd => rd,
          rd_multiple => rd_multiple,
          wr => wr,
          wr_multiple => wr_multiple,
          addr => addr,
          reset => reset,
          din => din,
          din_valid => din_valid,
          din_taken => din_taken,
          dout => dout,
          dout_avail => dout_avail,
          dout_taken => dout_taken,
          clk => clk
        );

   -- Clock process definitions
--   sclk_process :process
--   begin
--		sclk <= '0';
--		wait for sclk_period/2;
--		sclk <= '1';
--		wait for sclk_period/2;
--   end process;
 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process to drive the sd_controller
   stim_proc: process
	variable b : integer;
	variable vec9 : std_logic_vector(8 downto 0);
   begin
		dout_taken <= '0';
      -- hold reset state for 100 ns. then initialise
      wait for 100 ns;	
		reset <= '0';
      wait for 100 ns;	
      wait until sd_busy='0';
		assert sd_error='0' report "Error in initialisation";
		
		wait for 30 us;

		report "Starting Read 1 at byte_counter=" & integer'image(rx_byte_counter);
		-- Read from address 0
		addr <= (others=>'0');
		rd <= '1';
		for b in 0 to 511 loop
			wait until dout_avail='1';
			-- report slv_to_string(dout);
			wait for 101ns;
			assert conv_integer(dout)=(b mod 64) report "Read 1 mismatch " & slv_to_string(dout);
			dout_taken <= '1';
			wait until dout_avail='0';
			wait for 21ns;
			dout_taken <= '0';
		end loop;
		rd <= '0';
		wait until sd_busy='0';
		assert sd_error='0' report "Error in Read 1";
		wait for 500ns;

		report "Starting Read 2 at byte_counter=" & integer'image(rx_byte_counter);
		-- Read from address 0, but stop after receiving 11 bytes
		rd <= '1';
		for b in 0 to 10 loop
			wait until dout_avail='1';
			-- report slv_to_string(dout);
			wait for 21ns;
			assert conv_integer(dout)=(b mod 64) report "Read 2 mismatch " & slv_to_string(dout);
			dout_taken <= '1';
			wait until dout_avail='0';
			wait for 21ns;
			dout_taken <= '0';
		end loop;
		rd <= '0';
		wait until sd_busy='0';
		assert sd_error='0' report "Error in Read 2";
		wait for 500ns;
		
		report "Starting Read 3 at byte_counter=" & integer'image(rx_byte_counter);
		-- Read Multiple from address 0, but stop after receiving 522 bytes
		rd_multiple <= '1';
		for b in 0 to 521 loop
			wait until dout_avail='1';
			-- report slv_to_string(dout);
			wait for 21ns;
			assert conv_integer(dout)=(b mod 64) report "Read 3 mismatch " & slv_to_string(dout);
			dout_taken <= '1';
			wait until dout_avail='0';
			wait for 21ns;
			dout_taken <= '0';
		end loop;
		rd_multiple <= '0';
		wait until sd_busy='0';
		assert sd_error='0' report "Error in Read 3";
		wait for 500ns;
		
		report "Starting Read 4 at byte_counter=" & integer'image(rx_byte_counter);
		-- Read Multiple from address 0, but stop after receiving 512 bytes
		rd_multiple <= '1';
		for b in 0 to 511 loop
			wait until dout_avail='1';
			-- report slv_to_string(dout);
			wait for 21ns;
			assert conv_integer(dout)=(b mod 64) report "Read 4 mismatch " & slv_to_string(dout);
			dout_taken <= '1';
			wait until dout_avail='0';
			wait for 21ns;
			dout_taken <= '0';
		end loop;
		rd_multiple <= '0';
		wait until sd_busy='0';
		assert sd_error='0' report "Error in Read 4";
		wait for 500ns;
		
		-- Write to address 0
		-- Contents are 00-FF twice
		report "Starting Write 1 at byte_counter=" & integer'image(rx_byte_counter);
		wr <= '1';
		for b in 0 to 511 loop
			vec9 := STD_LOGIC_VECTOR(to_unsigned(b,9));
			din <= vec9(7 downto 0);
			din_valid <= '1';
			wait until din_taken='1';
			wait for 20ns;
			din_valid <= '0';
			wait until din_taken='0';
			wait for 20ns;
			-- report slv_to_string(din);
		end loop;
		wr <= '0';
		wait until sd_busy='0';
		assert sd_error='0' report "Error in Write 1";
		wait for 500ns;
		
		-- Write Multiple to address 0
		-- Contents are 00-FF twice
		report "Starting Write 2 at byte_counter=" & integer'image(rx_byte_counter);
		wr_multiple <= '1';
		for b in 0 to 511 loop
			vec9 := STD_LOGIC_VECTOR(to_unsigned(b,9));
			din <= vec9(7 downto 0);
			din_valid <= '1';
			wait until din_taken='1';
			wait for 20ns;
			din_valid <= '0';
			wait until din_taken='0';
			wait for 20ns;
			-- report slv_to_string(din);
		end loop;
		wr_multiple <= '0';
		wait until sd_busy='0';
		assert sd_error='0' report "Error in Write 2";
		wait for 500ns;
		
		-- Write Multiple to address 0, stop after 256 bytes
		-- Contents are 00-FF twice
		report "Starting Write 3 at byte_counter=" & integer'image(rx_byte_counter);
		wr_multiple <= '1';
		for b in 0 to 255 loop
			vec9 := STD_LOGIC_VECTOR(to_unsigned(b,9));
			din <= vec9(7 downto 0);
			din_valid <= '1';
			wait until din_taken='1';
			wait for 20ns;
			din_valid <= '0';
			wait until din_taken='0';
			wait for 20ns;
			-- report slv_to_string(din);
		end loop;
		wr_multiple <= '0';
		wait until sd_busy='0';
		assert sd_error='1' and sd_error_code="011" report "Missing Error in Write 3";
		wait for 500ns;
		
		assert sd_fsm=x"11" report "Not in Idle2 state at end";
		
		wait for 100us;
		report "Simulation finished";
      wait;

   end process;

clk_pol <= sclk xor CPOL;

-- This process receives data sent to the card and compares it with the receive portion of the list
sd_card_rx: process (clk_pol,cs)
begin
if cs='1' then
	rx_bit_counter <= 0;
elsif rising_edge(clk_pol) then -- CPOL = 0, CPHA = 0
	rx_byte <= rx_byte(6 downto 0) & mosi;
	if rx_bit_counter=7 then
		rx_bit_counter <= 0;
		rx_byte_counter <= rx_byte_counter + 1;
		assert (rx_byte(6 downto 0) & mosi)=input_output_bytes(rx_byte_counter)(15 downto 8) or input_output_bytes(rx_byte_counter)(15 downto 8)="11111111"
					report "Receive at byte " & integer'image(rx_byte_counter) & ": Expected " & slv_to_string(input_output_bytes(rx_byte_counter)(15 downto 8)) & " received " &  slv_to_string(rx_byte(6 downto 0) & mosi);
	else
		rx_bit_counter <= rx_bit_counter + 1;
	end if;
end if;
end process;

-- This process generates data from the card based on the transmit portion of the list
sd_card_tx: process (clk_pol,cs,tx_byte)
begin
if cs='1' then
	tx_bit_counter <= 0;
	tx_byte <= input_output_bytes(tx_byte_counter)(7 downto 0);
	miso <= '1';
else
	miso <= tx_byte(7); -- CPHA = 0
	if falling_edge(clk_pol) then -- CPOL = 0, CPHA = 0
		tx_byte <= tx_byte(6 downto 0) & '1';
		if tx_bit_counter=7 then
			tx_bit_counter <= 0;
			tx_byte_counter <= tx_byte_counter + 1;
			tx_byte <= input_output_bytes(tx_byte_counter + 1)(7 downto 0);
		else
			tx_bit_counter <= tx_bit_counter + 1;
		end if;
	end if;
end if;
end process;

END;
