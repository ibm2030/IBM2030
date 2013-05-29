---------------------------------------------------------------------------
---------------------------------------------------------------------------
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
--    File: sd_spi.vhd
--    Creation Date: 2013-02-08
--    Description:
--    Interface to SD/SDHC card via SPI
--
--    Revision History:
--    Revision 1.0 2013-05-03
--    Initial Release
--

-- This SD Card interface was based on the one by Steven J Merrifield
-- http://stevenmerrifield.com/tools/sd.vhd or https://github.com/sjm126/vhdl
-- Rewritten for SD V2 and SDHC by Lawrence Wilkinson, Feb 2013
-- to add:
-- * Support for SD V2 and SDHC.
-- * Sector-based addressing only (512 byte blocks.)
-- * CRC computation and checking - CRC is enabled for SPI transfers
-- * Timeouts and status checks where appropriate
-- * Low-speed initialisation
--
-- The FSM is implemented as two processes with a large number of state variables.
-- In the interests of providing glitch-free outputs, the SD card outputs are
-- registered along with the state variables.
--
-- CalcStateVariables asynchronously calculates the updated state values, and the
-- outputs values, from the current state and asynchronous inputs.  The calculated
-- values have names prefixed with new_ .  The default value of the new_X variable
-- is generally X (i.e. the current value) to imply a register.  For state variable
-- that are updated rarely, there is a companion variable prefixed with set_ which
-- is used to gate the calculated value into the state variable.  The theory of this
-- is to make use of the ClockEnable input to the state registers, and when the set_X
-- variable is false then the calculated new_X value is irrelevant (typically 0) to
-- simplify the logic.
--
-- UpdateStateVariables synchronously updates the state and output variables from the
-- values provided by CalcStateVariables. 
--
-- sd_busy:
-- Inactive when the card can accept a Read or Write command
-- Goes active for the duration of the command, input address is latched at this time
-- Goes inactive when Rd or Wr is dropped, or when command is complete, whichever is later
--
-- sd_error:
-- Goes active immediately when an error is detected
-- Resets when RD or WR is raised for the next command (except for 110 or 111 status)
-- 
-- sd_error_code:
-- 000 No error (operation complete)
-- 001 SD Card R1 error (R1 bit 6-0)
-- 010 Read CRC error or Write Timeout error
-- 011 Data Response Token error (Token bit 3)
-- 100 Data Error Token error (Token bit 3-0)
-- 101 SD Card Write Protect switch
-- 110 Unusable SD card
-- 111 No SD card (no response from CMD0)
--
-- sd_type:
-- 00 No card
-- 01 SD V1
-- 10 SD V2
-- 11 SDHC
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sd_controller is
generic (
	clockRate : integer := 50000000;		-- Incoming clock is 50MHz (can change this to 2000 to test Write Timeout)
	slowClockDivider : integer := 64;	-- Basic clock is 25MHz, slow clock for startup is 25/64 = 390kHz
	R1_TIMEOUT : integer := 10;			-- Number of bytes to wait before giving up on receiving R1 response
	WRITE_TIMEOUT : integer range 0 to 999 := 500		-- Number of ms to wait before giving up on write completing
	);
port (
	cs : out std_logic;
	mosi : out std_logic;
	miso : in std_logic;
	sclk : out std_logic;
	card_present : in std_logic;	-- Can be fixed to '1' if no switch is present
	card_write_prot : in std_logic;	-- Can be fixed to '0' if no switch is present, or '1' to make a Read-Only interface

	rd : in std_logic;
	rd_multiple : in std_logic;
	dout : out std_logic_vector(7 downto 0);
	dout_avail : out std_logic;
	dout_taken : in std_logic;
	
	wr : in std_logic;
	wr_multiple : in std_logic;
	din : in std_logic_vector(7 downto 0);
	din_valid : in std_logic;
	din_taken : out std_logic;
	
	addr : in std_logic_vector(31 downto 0);

	sd_error : out std_logic;	-- '1' if an error occurs, reset on next RD or WR
	sd_busy : out std_logic;	-- '0' if a RD or WR can be accepted
	sd_error_code : out std_logic_vector(2 downto 0); -- See above, 000=No error
	
	
	reset : in std_logic;
	clk : in std_logic;	-- twice the SPI clk (max 50MHz)
	
	-- Optional debug outputs
	sd_type : out std_logic_vector(1 downto 0);
	sd_fsm : out std_logic_vector(7 downto 0) := "11111111"
);

end sd_controller;

architecture rtl of sd_controller is
type states is (
	RST, RST2,						-- Initial FSM resetting
	INIT,								-- Send initial clock pulses
	CMD0,								-- Send CMD0
	CMD8, CMD8R1, CMD8B2, CMD8B3, CMD8B4, CMD8GOTB4,	-- Send CMD8
	CMD55,							-- Send CMD55
	CMD41,							-- Send ACMD41
	POLL_CMD,						-- Wait for card initialised
	CMD58, CMD58R1, CMD58B2, CMD58B3, CMD58B4,	-- Send CMD58
	CMD59, CMD59R1,				-- Send CMD59
  
	IDLE, IDLE2,					-- wait for read or write pulse
	READ_BLOCK,						-- Initiate Read command
	READ_MULTIPLE_BLOCK,			-- Initiate Read Multiple command
	READ_BLOCK_R1, READ_BLOCK_WAIT_CHECK,	-- Wait for data to appear
	READ_BLOCK_DATA,				-- Receive bytes and output
	READ_BLOCK_SKIP,				-- Skip remaining data if read is aborted
	READ_BLOCK_CRC,				-- Receive CRC bytes
	READ_BLOCK_CHECK_CRC,		-- Check final CRC=0
	READ_BLOCK_FINISH,			-- Wait until RD drops
	READ_MULTIPLE_BLOCK_STOP,
	READ_MULTIPLE_BLOCK_STOP_2,
	
	SEND_RCV,
	SEND_RCV_CLK1,
	SEND_CMD,
	SEND_CMD_1,
	SEND_CMD_2,
	SEND_CMD_3,
	SEND_CMD_4,
	SEND_CMD_5,
	
	WRITE_BLOCK_CMD,				-- Initiate Write command
	WRITE_MULTIPLE_BLOCK_CMD,	-- Initiate Write Multiple command
	WRITE_BLOCK_INIT,
	WRITE_BLOCK_DATA_TOKEN,		-- Send data token
	START_WRITE_BLOCK_DATA,		-- Set up for data loop
	WRITE_BLOCK_DATA,				-- Start sending write data
	WRITE_BLOCK_SEND_CRC2,		-- Send second byte of CRC
	WRITE_BLOCK_GET_RESPONSE,	-- Get R1 following data
	WRITE_BLOCK_CHECK_RESPONSE,-- Check response after data sent
	WRITE_BLOCK_WAIT,				-- Wait for write to complete
	WRITE_BLOCK_FINISH			-- Wait until WR drops
);

subtype t_error_code is std_logic_vector(2 downto 0);
constant ec_NoError	: t_error_code := "000";
constant ec_R1Error	: t_error_code := "001";
constant ec_CRCError	: t_error_code := "010";
constant ec_WriteTimeout	: t_error_code := "010";
constant ec_DataRespError	: t_error_code := "011";
constant ec_DataError	: t_error_code := "100";
constant ec_WPError	: t_error_code := "101";
constant ec_SDError	: t_error_code := "110";
constant ec_NoSDError	: t_error_code := "111";

subtype t_card_type is std_logic_vector(1 downto 0);
constant ct_None : t_card_type := "00";
constant ct_SDV1 : t_card_type := "01";
constant ct_SDV2 : t_card_type := "10";
constant ct_SDHC : t_card_type := "11";

constant R1_IDLE : integer := 0;
constant R1_ERASE_RESET : integer := 1;
constant R1_ILLEGALCOMMAND : integer := 2;
constant R1_COMMANDCRCERROR : integer := 3;
constant R1_ERASESEQUENCEERROR : integer := 4;
constant R1_ADDRESSERROR : integer := 5;
constant R1_PARAMETERERROR : integer := 6;
constant R1_ZERO : integer := 7;
constant OCR1_CCS : integer := 6;

signal state, new_state, return_state, new_return_state, sr_return_state, new_sr_return_state : states := RST;
signal set_return_state, set_sr_return_state : boolean := false;

-- Output signals to SD Card
signal new_sclk : std_logic := '0';
signal sCs, new_cs : std_logic := '1';

-- Output signals to higher level
signal set_davail : boolean := false;
signal sDavail : std_logic := '0';
signal transfer_data_out, new_transfer_data_out : boolean := false;
signal card_type, new_card_type : t_card_type := ct_None;
signal error, new_error : std_logic := '0';
signal error_code, new_error_code : t_error_code := ec_NoError;
signal new_busy : std_logic := '1';
signal sDin_taken, new_din_taken : std_logic := '0';

-- Shift registers
signal cmd_out, new_cmd_out : std_logic_vector(39 downto 0) := (others=>'1');
signal set_cmd_out : boolean := false;
signal data_in, new_data_in : std_logic_vector(7 downto 0);
signal new_crc7, crc7 : std_logic_vector(6 downto 0);
signal new_in_crc16, in_crc16 : std_logic_vector(15 downto 0);
signal new_out_crc16, out_crc16 : std_logic_vector(15 downto 0);
signal new_crcLow, crcLow : std_logic_vector(7 downto 0);
signal data_out, new_data_out : std_logic_vector(7 downto 0) := x"00";

signal address, new_address : std_logic_vector(31 downto 0);
signal set_address : boolean := false;
signal byte_counter, new_byte_counter : integer range 0 to 512 := 0;
signal set_byte_counter : boolean := false;
signal bit_counter, new_bit_counter : integer range 0 to 160 := 0;
signal slow_clock, new_slow_clock : boolean := true;
signal clock_divider, new_clock_divider : integer range 0 to slowClockDivider := 0;
signal multiple, new_multiple : boolean := false;
signal skipFirstR1Byte, new_skipFirstR1Byte : boolean := false;

begin
	-- This process updates all the state variables from the values calculated
	-- by the calcStateVariables process
	updateStateVariables: process(clk)
	begin
		if rising_edge(clk) then
			if (reset='1') then
				state <= RST;
				return_state <= RST;
				sr_return_state <= RST;
				cmd_out <= (others=>'1');
				data_in <= (others=>'0');
				dout <= (others=>'0');
				address <= (others=>'0');
				data_out <= (others=>'1');
				card_type <= ct_None;
				byte_counter <= 0;
				bit_counter <= 0;
				crc7 <= (others => '0');
				in_crc16 <= (others => '0');
				out_crc16 <= (others => '0');
				crcLow <= (others => '0');
				error <= '1';
				error_code <= ec_NoSDError;
				sdAvail <= '0';
				error <= '0';
				slow_clock <= true;
				clock_divider <= 0;
				transfer_data_out <= false;
				sCs <= '1';
				sDin_taken <= '0';
				-- SD outputs
				sclk <= '0';
				cs <= '1';
				mosi <= '1';
				-- Interface outputs
				sd_type <= "00";
				sd_busy <= '1';
				sd_error <= '1';
				sd_error_code <= ec_NoSDError;
				dout <= "00000000";
				dout_avail <= '0';
				din_taken <= '0';
				multiple <= false;
				skipFirstR1Byte <= false;
			else
				-- State variables
				state <= new_state;
				if (set_return_state) then return_state <= new_return_state; end if;
				if (set_sr_return_state) then sr_return_state <= new_sr_return_state; end if;
				if (set_cmd_out) then cmd_out <= new_cmd_out; end if;
				data_in <= new_data_in;
				if (set_address) then address <= new_address; end if;
				data_out <= new_data_out;
				if (set_byte_counter) then byte_counter <= new_byte_counter; end if;
				bit_counter <= new_bit_counter;
				error <= new_error;
				error_code <= new_error_code;
				card_type <= new_card_type;
				slow_clock <= new_slow_clock;
				clock_divider <= new_clock_divider;
				crc7 <= new_crc7;
				in_crc16 <= new_in_crc16;
				out_crc16 <= new_out_crc16;
				crcLow <= new_crcLow;
				transfer_data_out <= new_transfer_data_out;
				sCs <= new_cs;
				sDin_taken <= new_din_taken;
				-- SD outputs
				sclk <= new_sclk;
				cs <= new_cs;
				mosi <= new_data_out(7);
				-- Interface outputs
				sd_type <= new_card_type;
				sd_busy <= new_busy;
				sd_error <= new_error;
				sd_error_code <= new_error_code;
				if set_davail then -- NB can't do this at the same cycle as we set data_in
					sDavail <= '1';
					dout <= data_in;
					dout_avail <= '1';
				elsif sDavail='1' and dout_taken='1' then
					sDavail <= '0';
					dout_avail <= '0';
				end if;
				din_taken <= new_din_taken;
				multiple <= new_multiple;
				skipFirstR1Byte <= new_skipFirstR1Byte;
			end if;
		end if;
  end process;

	-- This process calculates all of the state variables
	-- It should not generate any latches
	-- Some values are initialised to a fixed value, and overridden later (new_X <= '0')
	-- Some values are initialised to their current values (new_X <= X)
	-- Some values are initialised to Don't Care (new_X <= '-')
	-- Updating of the latter values is under control of the set_X signal
	calcStateVariables: process(miso,rd,rd_multiple,wr,wr_multiple,
		state,bit_counter,card_type,byte_counter,data_in,data_out,
		address,addr,dout_taken,error,cmd_out,return_state,clock_divider,
		error_code,crc7,in_crc16,out_crc16,slow_clock,card_present,
		card_write_prot,SDin_Taken,sCS,transfer_data_out,din_valid,din,
		crcLow,sDavail,sr_return_state,multiple,skipFirstR1Byte)
	constant WriteTimeoutCount : integer := clockRate/18000 * WRITE_TIMEOUT;
	begin
		assert(WriteTimeoutCount > 0) report "WriteTimeoutCount is 0" severity failure ;
		new_state <= state;
		new_return_state <= RST;
		set_return_state <= false;
		new_sr_return_state <= RST;
		set_sr_return_state <= false;
		new_bit_counter <= bit_counter;
		new_card_type <= card_type;
		new_cmd_out <= (others=>'-');
		set_cmd_out <= false;
		new_byte_counter <= byte_counter;
		set_byte_counter <= false;
		new_data_in <= data_in;
		set_davail <= false;
		new_din_taken <= sDin_taken;
		new_data_out <= data_out;
		new_address <= (others=>'-');
		set_address <= false;
		new_sclk <= '0';
		new_cs <= sCs;
		new_error <= error;
		new_error_code <= error_code;
		new_busy <= '1';
		new_crc7 <= crc7;
		new_in_crc16 <= in_crc16;
		new_out_crc16 <= out_crc16;
		new_crcLow <= crcLow;
		new_slow_clock <= slow_clock;
		new_clock_divider <= clock_divider;
		new_transfer_data_out <= transfer_data_out;
		new_multiple <= multiple;
		new_skipFirstR1Byte <= skipFirstR1Byte;
		
		case state is
		
		when RST =>
			-- Reset, including error codes
			new_error_code <= ec_NoSDError;
			new_error <= '1';
			new_state <= RST2;
			
		when RST2 =>
			-- Reset, retaining error codes
			new_card_type <= ct_None;
			new_cs <= '1';
			new_slow_clock <= true;
			new_clock_divider <= slowClockDivider;
			new_byte_counter <= 20; set_byte_counter <= true;
			new_data_out <= "11111111";
			new_transfer_data_out <= false;
			new_sr_return_state <= INIT; set_sr_return_state <= true;
			if card_present='1' then
			-- Wait for card present indication before attempting initialisation
				new_state <= SEND_RCV;
			end if;
			
		when INIT =>
			if byte_counter=0 then
				new_state <= CMD0;
			else
				new_state <= SEND_RCV;
			end if;
			
		when CMD0 =>
			new_cs <= '0';
			new_address <= (others=>'0'); set_address <= true;
			new_cmd_out <= x"4000000000"; set_cmd_out <= true;
			new_return_state <= CMD8; set_return_state <= true;
			new_state <= SEND_CMD;
			
		when CMD8 =>
			if data_in="00000001" then
				new_cmd_out <= x"48000001AA"; set_cmd_out <= true; -- Voltage is 1, Check pattern is AA
				new_return_state <= CMD8R1; set_return_state <= true;
				new_state <= SEND_CMD;
			else
				new_card_type <= ct_None;
				new_error <= '1';
				new_error_code <= ec_R1Error;
				new_state <= RST2;
			end if;
			
		when CMD8R1 =>
			-- Check R1 response to CMD8
			if data_in(R1_ILLEGALCOMMAND)='1' then -- Illegal command?
				new_card_type <= ct_SDV1; -- Yes, must be SD1
				new_state <= CMD55;
			else
				new_card_type <= ct_SDV2; -- No, could be SD2 (10) or SDHC (11)
				new_sr_return_state <= CMD8B2; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;
			
		when CMD8B2 =>
			new_sr_return_state <= CMD8B3; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when CMD8B3 =>
			new_sr_return_state <= CMD8B4; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when CMD8B4 =>
			-- Check operating voltage
			if data_in(3 downto 0) /= "0001" then
				new_state <= RST;
			end if;
			-- Get byte 4 (check pattern)
			new_sr_return_state <= CMD8GOTB4; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when CMD8GOTB4 =>
			-- Check pattern
			if data_in = x"AA" then
				new_state <= CMD55;
			else
				new_state <= RST;
			end if;
			
		when CMD55 =>
			new_return_state <= CMD41; set_return_state <= true;
			new_cmd_out <= x"7700000000"; set_cmd_out <= true;
			new_state <= SEND_CMD;
			
		when CMD41 =>
			new_return_state <= POLL_CMD; set_return_state <= true;
			if card_type=ct_SDV1 then
				new_cmd_out <= x"6900000000";
			else
				new_cmd_out <= x"6940000000";
			end if;
			set_cmd_out <= true;
			new_state <= SEND_CMD;
			
		when POLL_CMD =>
			if (data_in(R1_IDLE) = '0') then -- In idle state?
				if (card_type=ct_SDV1) then
					new_state <= CMD59; -- SD1 ready now
				else
					new_state <= CMD58; -- SD2, SDHC determine
				end if;
			else
				new_state <= CMD55; -- Still in idle, repeat ACMD41
			end if;
			
		when CMD58 =>
			new_return_state <= CMD58R1; set_return_state <= true;
			new_cmd_out <= x"7A00000000"; set_cmd_out <= true;
			new_state <= SEND_CMD;
			
		when CMD58R1 =>
			-- Check R1 response to CMD58
			if data_in(R1_ILLEGALCOMMAND)='1' then
				-- Illegal command - not an SD card
				new_card_type <= ct_None;
				new_error_code <= ec_SDError;
				new_error <= '1';
				new_state <= RST2;
			else
				-- Go fetch byte 1
				new_sr_return_state <= CMD58B2; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;
			
		when CMD58B2 =>
			-- Check CCS: 0=SD2 1=SDHC
			-- card_type already set to ct_SDV2 (10) in CMD8R1
			if (data_in(OCR1_CCS)='1') then -- OCR(30) = CCS
				new_card_type <= ct_SDHC; -- SDHC
			end if;
			-- Go fetch byte 2
			new_sr_return_state <= CMD58B3; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when CMD58B3 =>
			-- Go fetch byte 3
			new_sr_return_state <= CMD58B4; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when CMD58B4 =>
			-- Go fetch byte 4
			new_sr_return_state <= CMD59; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when CMD59 =>
			new_return_state <= CMD59R1; set_return_state <= true;
			new_cmd_out <= x"7B00000001"; set_cmd_out <= true; -- Enable CRC
			new_state <= SEND_CMD;
			
		when CMD59R1 =>
			if data_in/="00000000" then
				new_state <= RST;
			end if;
			-- Don't enter IDLE until Rd and Wr are down
			if (rd='0') and (wr='0') and (rd_multiple='0') and (wr_multiple='0') then
				new_error_code <= ec_NoError;
				new_error <= '0';
				new_state <= IDLE;
			end if;
			
		when IDLE =>
			-- Generate 8 clocks when entering idle
			new_slow_clock <= false;	-- Can run at full speed now
			new_data_out <= "11111111";
			new_bit_counter <= 7;
			new_transfer_data_out <= false;
			new_sr_return_state <= IDLE2; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when IDLE2 =>
			-- Sits in this state when idle
			if card_present='0' then
				new_state <= RST;
			elsif data_in=x"00" then
				-- Card still busy
				new_state <= IDLE;
			elsif rd='1' then
				new_cs <= '0';
				new_error <= '0';
				new_error_code <= ec_NoError;
				new_address <= addr; set_address <= true;
				new_multiple <= false;
				new_state <= READ_BLOCK;
			elsif rd_multiple='1' then
				new_cs <= '0';
				new_error <= '0';
				new_error_code <= ec_NoError;
				new_address <= addr; set_address <= true;
				new_multiple <= true;
				new_state <= READ_MULTIPLE_BLOCK;
			elsif wr='1' or wr_multiple='1' then
				if card_write_prot='0' then
					new_cs <= '0';
					new_error <= '0';
					new_error_code <= ec_NoError;
					new_address <= addr; set_address <= true;
					if wr='1' then
						new_multiple <= false;
						new_state <= WRITE_BLOCK_CMD;
					else
						new_multiple <= true;
						new_state <= WRITE_MULTIPLE_BLOCK_CMD;
					end if;
				else
					new_error <= '1';
					new_error_code <= ec_WPError;
				end if;
			else
				new_cs <= '1';
				new_busy <= '0';
			end if;
			
		when READ_BLOCK =>
			if card_type=ct_SDHC then
				-- SDHC: Use block address
				new_cmd_out <= x"51" & address(31 downto 0);
			else
				-- SDV1,2: Use byte address
				new_cmd_out <= x"51" & address(22 downto 0) & "000000000";
			end if;
			set_cmd_out <= true;
			new_return_state <= READ_BLOCK_R1; set_return_state <= true;
			new_state <= SEND_CMD;
			
		when READ_MULTIPLE_BLOCK =>
			if card_type=ct_SDHC then
				-- SDHC: Use block address
				new_cmd_out <= x"52" & address(31 downto 0);
			else
				-- SDV1,2: Use byte address
				new_cmd_out <= x"52" & address(22 downto 0) & "000000000";
			end if;
			set_cmd_out <= true;
			new_return_state <= READ_BLOCK_R1; set_return_state <= true;
			new_state <= SEND_CMD;
			
		when READ_BLOCK_R1 => -- Get R1 response
			if data_in/="00000000" then -- Some error
				new_error <= '1';
				new_error_code <= ec_R1Error;
				new_state <= READ_BLOCK_FINISH;
			else
				new_sr_return_state <= READ_BLOCK_WAIT_CHECK; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;
			
		when READ_BLOCK_WAIT_CHECK => -- Wait for Read token, or Error token
			new_in_crc16 <= (others=>'0');
			if rd='0' and rd_multiple='0' then
				-- Abort transfer
				new_state <= READ_BLOCK_FINISH; -- And then to IDLE
			elsif (data_in="11111110") then
				new_transfer_data_out <= true;
				new_byte_counter <= 512; set_byte_counter <= true;
				new_sr_return_state <= READ_BLOCK_DATA; set_sr_return_state <= true; -- Wait for dout_taken to drop
				new_state <= SEND_RCV;
			elsif (data_in(7 downto 4)="0000") then
				-- Check for error token 0000XXXX
				-- Flag error and wait for RD to drop
				new_error <= '1';
				new_error_code <= ec_DataError;
				new_state <= READ_BLOCK_FINISH;
			else
				new_state <= SEND_RCV;
			end if;
			
		when READ_BLOCK_DATA =>
			if rd='0' and rd_multiple='0' then
				-- Abort transfer
				new_state <= READ_BLOCK_SKIP; -- And then to IDLE
			else
				if byte_counter=0 then
					new_transfer_data_out <= false;
					new_sr_return_state <= READ_BLOCK_CRC;
				else
					new_sr_return_state <= READ_BLOCK_DATA;
				end if;
				set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;
			
		when READ_BLOCK_SKIP => -- Skip all remaining bytes without transferring them
			new_transfer_data_out <= false;
			if multiple then
				new_state <= READ_MULTIPLE_BLOCK_STOP;
			elsif (byte_counter=0) then
				new_sr_return_state <= READ_BLOCK_CRC; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			else
				new_sr_return_state <= READ_BLOCK_SKIP; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;
			
		when READ_BLOCK_CRC =>
			new_sr_return_state <= READ_BLOCK_CHECK_CRC; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when READ_BLOCK_CHECK_CRC =>
			-- After reading all the data and the two CRC bytes, the result should be zero
			if in_crc16/="0000000000000000" then
				new_error <= '1';
				new_error_code <= ec_CRCError;
				new_state <= READ_BLOCK_FINISH;
			elsif multiple and rd_multiple='1' then
				-- Start looking for a further data block
				new_sr_return_state <= READ_BLOCK_WAIT_CHECK; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			else
				new_state <= READ_BLOCK_FINISH;
			end if;
			
		when READ_BLOCK_FINISH =>
			new_transfer_data_out <= false;
			-- Wait for RD to fall after last byte has been transferred
			if (rd='0') and (rd_multiple='0') then
				if multiple then
					new_state <= READ_MULTIPLE_BLOCK_STOP;
				else
					new_state <= IDLE;
				end if;
			end if;
			
		when READ_MULTIPLE_BLOCK_STOP =>
			-- Send CMD12
			new_skipFirstR1Byte <= true;
			new_return_state <= READ_MULTIPLE_BLOCK_STOP_2; set_return_state <= true;
			new_cmd_out <= x"4C00000000"; set_cmd_out <= true;
			new_state <= SEND_CMD;
			
		when READ_MULTIPLE_BLOCK_STOP_2 =>
			-- Check R1 and wait for not-busy when we get to IDLE
			if data_in/="00000000" then
				new_state <= RST;
			else
				if rd_multiple='0' then
					new_state <= IDLE;
				end if;
			end if;
			
		when WRITE_BLOCK_CMD =>
			if (card_type=ct_SDHC) then
				new_cmd_out <= x"58" & address(31 downto 0);
			else
				new_cmd_out <= x"58" & address(22 downto 0) & "000000000";
			end if;
			set_cmd_out <= true;
			new_return_state <= WRITE_BLOCK_INIT; set_return_state <= true;
			new_state <= SEND_CMD;
			
		when WRITE_MULTIPLE_BLOCK_CMD =>
		
		when WRITE_BLOCK_INIT =>
			if data_in/="00000000" then
				new_error <= '1';
				new_error_code <= ec_R1Error;
				new_state <= WRITE_BLOCK_FINISH;
			else
				new_state <= WRITE_BLOCK_DATA_TOKEN;
			end if;
			
		when WRITE_BLOCK_DATA_TOKEN =>
			if wr='0' then
				-- Abort writing - raise CS*
				new_state <= WRITE_BLOCK_FINISH;
			else
				new_data_out <= x"FE"; -- start byte, single block
				new_sr_return_state <= START_WRITE_BLOCK_DATA; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;

		when START_WRITE_BLOCK_DATA =>
				new_byte_counter <= 512; set_byte_counter <= true;
				new_out_crc16 <= (others=>'0');
				new_state <= WRITE_BLOCK_DATA;

		when WRITE_BLOCK_DATA =>
			if byte_counter = 0 then
				new_data_out <= out_crc16(15 downto 8);
				new_crcLow <= out_crc16(7 downto 0);
				new_sr_return_state <= WRITE_BLOCK_SEND_CRC2; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			elsif wr='0' then
				-- Abort writing - raise CS*
				new_state <= WRITE_BLOCK_FINISH;
			elsif din_valid='1' then
				new_data_out <= din;
				new_din_taken <= '1';
				new_sr_return_state <= WRITE_BLOCK_DATA; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;

		when WRITE_BLOCK_SEND_CRC2 =>
			new_data_out <= crcLow;
			new_sr_return_state <= WRITE_BLOCK_GET_RESPONSE; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when WRITE_BLOCK_GET_RESPONSE =>
			new_byte_counter <= R1_TIMEOUT; set_byte_counter <= true;
			new_sr_return_state <= WRITE_BLOCK_CHECK_RESPONSE; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when WRITE_BLOCK_CHECK_RESPONSE =>
			if (data_in(4) /= '0') or (data_in(0) /= '1') then
				if byte_counter=0 then
					new_error <= '1';
					new_error_code <= ec_R1Error;
					new_state <= WRITE_BLOCK_FINISH;
				else
					new_byte_counter <= byte_counter - 1; set_byte_counter <= true;
					new_state <= SEND_RCV; -- Wait for Data Response token
				end if;
			elsif data_in(3 downto 1) /= "010" then
				-- Data not accepted
				new_error <= '1';
				new_error_code <= ec_DataRespError;
				new_state <= WRITE_BLOCK_FINISH;
			else
				-- Receive a byte and poll for write complete
				-- Use cmd_out to time 2ms (50000 clocks @ 25MHz)
				new_cmd_out <= std_logic_vector(to_unsigned(WriteTimeoutCount,40)); set_cmd_out <= true;
				new_sr_return_state <= WRITE_BLOCK_WAIT; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;

		when WRITE_BLOCK_WAIT =>
			if data_in=x"00" then
				if cmd_out=x"0000000000" then
					new_error <= '1';
					new_error_code <= ec_WriteTimeout;
					new_state <= WRITE_BLOCK_FINISH;
				else
					new_cmd_out <= STD_LOGIC_VECTOR(unsigned(cmd_out) - 1); set_cmd_out <= true;
					new_state <= SEND_RCV; -- Will come back here, loop until write complete
				end if;
			else
				new_busy <= '0';
				new_state <= WRITE_BLOCK_FINISH;
			end if;

		when WRITE_BLOCK_FINISH =>
			-- Wait for WR to fall after last byte has been transferred
			if (WR='0') then
				new_state <= IDLE;
			end if;
		
		when SEND_RCV =>
			-- Send the byte in data_out while simultaneously receiving one into data_in
			-- ** Must enter with bit_counter = 7 **
			-- Update CRC7 and CRC16 from output stream
			-- Update CRC16 from input stream
			-- Decrement byte_counter
			-- Leave data_out as 11111111
			-- Leave bit_counter as 7 for next time
			
			-- When we enter SPI Clock should be low, we set the output data, wait half a cycle, raise
			-- the clock, latch the input data, then wait a further half cycle before dropping the clock
			-- The output data (MOSI) follows data_out(7)
			
			-- Clock is low, output data is set
			if slow_clock=false or clock_divider=0 then
				new_clock_divider <= slowClockDivider;
				new_sclk <= '1';
				-- Update output CRCs
				new_crc7 <= crc7(5 downto 3) & (crc7(2) xor crc7(6) xor data_out(7)) & crc7(1 downto 0) & (crc7(6) xor data_out(7));
				new_out_crc16 <= out_crc16(14 downto 12) & (data_out(7) xor out_crc16(15) xor out_crc16(11)) & out_crc16(10 downto 5) &
				(data_out(7) xor out_crc16(15) xor out_crc16(4)) & out_crc16(3 downto 0) & (data_out(7) xor out_crc16(15));
				-- Update input data
				new_data_in <= data_in(6 downto 0) & miso;
				-- Update input CRC
				new_in_crc16 <= in_crc16(14 downto 12) & (miso xor in_crc16(15) xor in_crc16(11)) & in_crc16(10 downto 5) &
					(miso xor in_crc16(15) xor in_crc16(4)) & in_crc16(3 downto 0) & (miso xor in_crc16(15));
				new_state <= SEND_RCV_CLK1;
			else
				new_clock_divider <= clock_divider - 1;
			end if;
			-- Transmission handshaking - drop DinTaken when DinValid drops
			if sDin_taken='1' then
				if din_valid='0' then
					new_din_taken <= '0';
				end if;
			end if;

		when SEND_RCV_CLK1 =>
			if slow_clock=false or clock_divider=0 then
				new_clock_divider <= slowClockDivider;
				if (bit_counter = 0) then
					-- Return
					new_bit_counter <= 7;
					-- Reception handling - if DAvail and DTaken are down, transfer new byte into output register and raise DAvail
					if transfer_data_out and (rd='1' or rd_multiple='1') then
						if sDavail='0' and dout_taken='0' then
							-- If we're ok to transfer data, then do it
							-- otherwise wait here until dout_taken rises
							set_davail <= true;
							new_byte_counter <= byte_counter - 1; set_byte_counter <= true;
							new_state <= sr_return_state;
						end if;
					else
						new_state <= sr_return_state;
						new_byte_counter <= byte_counter - 1; set_byte_counter <= true;
					end if;
				else
					new_bit_counter <= bit_counter - 1;
					new_data_out <= data_out(6 downto 0) & '1';
					new_state <= SEND_RCV;
				end if;
			else
				new_sclk <= '1';
				new_clock_divider <= clock_divider - 1;
			end if;

		when SEND_CMD =>
			-- Send FF byte first
			new_bit_counter <= 7;
			new_data_out <= "11111111";
			new_sr_return_state <= SEND_CMD_1; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when SEND_CMD_1 =>
			-- Initialise CRC and byte counter
			new_crc7 <= "0000000";
			new_byte_counter <= 5; set_byte_counter <= true; -- 5 bytes are CC NN NN NN NN
			new_state <= SEND_CMD_2;
			
		when SEND_CMD_2 =>
			-- Send one byte of the command and parameter
			if byte_counter=0 then
				new_state <= SEND_CMD_3;
			else
				new_data_out <= cmd_out(39 downto 32);
				new_cmd_out <= cmd_out(31 downto 0) & x"FF"; set_cmd_out <= true;
				new_sr_return_state <= SEND_CMD_2; set_sr_return_state <= true;
				new_state <= SEND_RCV;
			end if;
	
		when SEND_CMD_3 =>
			-- Send the CRC
			new_data_out <= crc7 & '1';
			new_sr_return_state <= SEND_CMD_4; set_sr_return_state <= true;
			new_state <= SEND_RCV;

		when SEND_CMD_4 =>
			-- Receive the first byte, maybe R1
			new_byte_counter <= R1_TIMEOUT; set_byte_counter <= true;
			new_sr_return_state <= SEND_CMD_5; set_sr_return_state <= true;
			new_state <= SEND_RCV;
			
		when SEND_CMD_5 =>
			-- Check for R1 response, receive another byte if not
			if skipFirstR1Byte then
				-- If doing a CMD12 then skip a byte before looking for R1
				new_skipFirstR1Byte <= false;
				new_state <= SEND_RCV;
			elsif data_in(R1_ZERO)='0' then
				new_state <= return_state;
			else
				if byte_counter=0 then
--					new_state <= RST2;
					new_card_type <= ct_None;
					new_error <= '1';
					new_error_code <= ec_NoSDError;
				else
					new_state <= SEND_RCV; -- Will come back to SEND_CMD_5
				end if;
			end if;
			
	end case;

	end process calcStateVariables;
	
	calcDebugOutputs: block
	begin
		with state select sd_fsm <=
			x"00" when RST,
			x"00" when RST2,
			x"01" when INIT,
			x"02" when CMD0,
			x"03" when CMD8,
			x"04" when CMD8R1,
			x"04" when CMD8B2,
			x"04" when CMD8B3,
			x"04" when CMD8B4,
			x"04" when CMD8GOTB4,
			x"05" when CMD55,
			x"06" when CMD41,
			x"07" when POLL_CMD,
			x"08" when CMD58,
			x"08" when CMD58R1,
			x"08" when CMD58B2,
			x"08" when CMD58B3,
			x"08" when CMD58B4,
			x"09" when CMD59,
			x"0A" when CMD59R1,
			x"10" when IDLE,
			x"11" when IDLE2,
			x"20" when READ_BLOCK,
			x"20" when READ_MULTIPLE_BLOCK,
			x"21" when READ_BLOCK_R1,
			x"22" when READ_BLOCK_WAIT_CHECK,
			x"23" when READ_BLOCK_DATA,
			x"24" when READ_BLOCK_SKIP,
			x"25" when READ_BLOCK_CRC,
			x"26" when READ_BLOCK_CHECK_CRC,
			x"27" when READ_BLOCK_FINISH,
			x"28" when READ_MULTIPLE_BLOCK_STOP,
			x"29" when READ_MULTIPLE_BLOCK_STOP_2,
			x"30" when SEND_RCV,
			x"31" when SEND_RCV_CLK1,
			x"32" when SEND_CMD,
			x"33" when SEND_CMD_1,
			x"34" when SEND_CMD_2,
			x"35" when SEND_CMD_3,
			x"36" when SEND_CMD_4,
			x"37" when SEND_CMD_5,
			x"40" when WRITE_BLOCK_CMD,
			x"40" when WRITE_MULTIPLE_BLOCK_CMD,
			x"41" when WRITE_BLOCK_INIT,
			x"42" when WRITE_BLOCK_DATA,
			x"43" when WRITE_BLOCK_DATA_TOKEN,
			x"44" when START_WRITE_BLOCK_DATA,
			x"45" when WRITE_BLOCK_SEND_CRC2,
			x"46" when WRITE_BLOCK_GET_RESPONSE,
			x"47" when WRITE_BLOCK_CHECK_RESPONSE,
			x"48" when WRITE_BLOCK_WAIT,
			x"49" when WRITE_BLOCK_FINISH
			;
	end block calcDebugOutputs;
end rtl;

