---------------------------------------------------------------------------
--    Copyright  2010 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: ibm2030-storage.vhd
--    Creation Date: 19:55:00 20/07/10
--    Description:
--    360/30 Storage Handling - Main and Local (Bump) Storage
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-20 Initial Release
--    Revision 1.1 2012-03-06 Modified to parse PCH files from Hercules (ESD/TXT/TXT/TXT/RLD/RLD/END)
--    
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;
library UNISIM;
use UNISIM.vcomponents.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity storage is
    Port ( -- Physical storage I/O from FPGA (S3BOARD)
				phys_address : out std_logic_vector(16 downto 0);
				phys_data : inout std_logic_vector(8 downto 0);
				phys_CE : out std_logic;
				phys_OE : out std_logic;
				phys_WE : out std_logic;
				phys_UB,phys_LB : out std_logic;

				-- Other inputs
				clk : in STD_LOGIC; -- 50MHz
				
				-- Interface to config ROM (S3BOARD)
				din : in STD_LOGIC;
				reset_prom : out STD_LOGIC;
				cclk : out STD_LOGIC;
				
				-- Inteface to AXI (ZYBO)
				BRAM_MS_WRDATA: out std_logic_vector(8 downto 0);
				BRAM_MS_RDDATA : in std_logic_vector(8 downto 0);
				BRAM_MS_ADDR : out std_logic_vector(15 downto 0);
				BRAM_MS_EN : out std_logic;
				BRAM_MS_WE : out std_logic;
				BRAM_MS_CLK : out std_logic;
				BRAM_LS_WRDATA: out std_logic_vector(8 downto 0);
                BRAM_LS_RDDATA : in std_logic_vector(8 downto 0);
                BRAM_LS_ADDR : out std_logic_vector(15 downto 0);
                BRAM_LS_EN : out std_logic;
                BRAM_LS_WE : out std_logic;
                BRAM_LS_CLK : out std_logic;

				-- Storage interface to CPU
				StorageIn : out STORAGE_IN_INTERFACE;
				StorageOut : in STORAGE_OUT_INTERFACE;
				debug : out STD_LOGIC
           );
end storage;

architecture DigilentS3BOARD of storage is

--
-- declaration of serial configuration PROM reading interface
--
  component prom_reader_serial
    generic(    length : integer := 5;                      --sync pattern 2^length
             frequency : integer := 50 );                   --system clock speed in MHz
    port(        clock : in std_logic; 
                 reset : in std_logic;                      --active high
                  read : in std_logic;                      --active low single cycle pulse
             next_sync : in std_logic;                      --active low single cycle pulse
                   din : in std_logic;
          sync_pattern : in std_logic_vector((2**length) - 1 downto 0);
                  cclk : out std_logic;
                  sync : out std_logic;                     --active low single cycle pulse
            data_ready : out std_logic;                     --active low single cycle pulse
            reset_prom : out std_logic;                     --active high to /OE of PROM (reset when high)
                  dout : out std_logic_vector(7 downto 0));
  end component;

-- Signals for RAM clearing and initialisation purposes (at startup)
signal drive_out : std_logic;
signal addr : std_logic_vector(15 downto 0) := "0000000000000000";
signal len  : std_logic_vector(15 downto 0) := "0000000000000000";
signal init_CE : std_logic;
signal init_WE : std_logic;
signal init_OE : std_logic;
signal init_drive_out, clear_data_out, clear_local_data_out, init_data_out: std_logic;
signal clear_data : std_logic_vector(7 downto 0) := "00000000"; -- Value written into storage locations when clearing
signal init_data : std_logic_vector(7 downto 0);
type init_state is (
	initClearMainStorage,initClearLocalStorage,
	resetProm,resetProm2,
	wait_for_first_high_length_byte,wait_for_high_length_byte,got_high_length_byte,wait_for_low_length_byte,got_low_length_byte,
	wait_for_high_address_byte,got_high_address_byte,wait_for_low_address_byte,got_low_address_byte,
	wait_for_data_byte, write_byte, written_byte, finished);
signal state : init_state := initClearMainStorage;

--
-- Signals for serial PROM reader 
--
signal     reset_prom_reader : std_logic;
signal       prom_read_pulse : std_logic;
signal       prom_sync_pulse : std_logic;
signal prom_data_ready_pulse : std_logic;

begin

-- See Xilinx XAPP694 for how to store user data in the platform flash
-- Input file format is
--    Header 8F9FAFBF (see XAPP694)
-- 	LL		High byte of data segment length
-- 	LL		Low byte of data segment length
-- 	AA		High byte of destination address
--		AA		Low byte of destination address
--		DD		Data byte (repeated a total of LLLL times)
--		LL LL AA AA DD DD ... DD repeated as required
--		00	00	Length of 0000 to terminate

Initialise: process(clk) is
begin
	-- Initialise storage
		if clk'event and clk='1' then	-- Wait for rising edge of 50MHz clock
			case state is
				-- Clear the 64k of main storage space
				when initClearMainStorage =>
					init_data_out <= '0';	-- '1' if we're initialising RAM from PROM
					clear_data_out <= '1';	-- '1' if we're clearing the 64k main storage space
					clear_local_data_out <= '0';	-- '1' if we're clearing the local storage space
					addr <= (others=>'0');	-- Start clearing at 0000
					len <= (others=>'0'); -- Clear 64k
					state <= write_byte; -- Will come back to initClearLocalStorage
				-- Clear 64k of local storage space, though only a small portion is actually used
				when initClearLocalStorage =>
					clear_data_out <= '0';	-- Done with clearing main storage...
					clear_local_data_out <= '1';	-- ... so on to clearing local storage
					addr <= (others=>'0');	-- Start clearing at 0000
					len <= (others=>'0'); -- Clear 64k
					state <= write_byte; -- Will come back to resetProm
				when resetProm =>
					clear_data_out <= '0';	-- Done with clearing main storage...
					clear_local_data_out <= '0';	-- ...and local storage...
					init_data_out <= '1';	-- ...so on to initialising storage from PROM
					state <= resetProm2;
				when resetProm2 =>
					state <= wait_for_first_high_length_byte;
				when wait_for_first_high_length_byte =>
				-- Wait until we get the first data byte, which is the high byte of the length
				-- Note we don't need to assert the PROM read pulse in this state
				-- as the first byte following the sync pattern is automatically read
					if (prom_data_ready_pulse = '0') then
						len(15 downto 8) <= init_data;
						state <= got_high_length_byte;
					else
						state <= wait_for_high_length_byte;
					end if;
				when wait_for_high_length_byte =>
				-- Wait until we get a high length byte
					if (prom_data_ready_pulse = '0') then
						-- Store it in len (high)
						len(15 downto 8) <= init_data;
						state <= got_high_length_byte;
					else
						state <= wait_for_high_length_byte;
					end if;
				when got_high_length_byte =>
					state <= wait_for_low_length_byte;
				when wait_for_low_length_byte =>
				-- Wait until we get a low length byte
					if (prom_data_ready_pulse = '0') then
						-- Store it in len (low)
						len(7 downto 0) <= init_data;
						-- Check if both bytes are 00, finish if so
						-- Note: Can't check len(7 downto 0) as it isn't in there yet
						if len(15 downto 8)="00000000" and init_data="00000000" then
							state <= finished;
						else
						-- Not 0 length, go on to getting address & data bytes
							state <= got_low_length_byte;
						end if;
					else
						state <= wait_for_low_length_byte;
					end if;
				when got_low_length_byte =>
					state <= wait_for_high_address_byte;
				when wait_for_high_address_byte =>
				-- Wait until we get the high address byte
					if (prom_data_ready_pulse = '0') then
						-- Store it in addr (high)
						addr(15 downto 8) <= init_data;
						state <= got_high_address_byte;
					else
						state <= wait_for_high_address_byte;
					end if;
				when got_high_address_byte =>
--					prom_read_pulse <= '0';
					state <= wait_for_low_address_byte;
				when wait_for_low_address_byte =>
				-- Wait until we get the low address byte
					if (prom_data_ready_pulse = '0') then
						-- Store it in addr (low)
						addr(7 downto 0) <= init_data;
						state <= got_low_address_byte;
					else
						state <= wait_for_low_address_byte;
					end if;
				when got_low_address_byte =>
					state <= wait_for_data_byte;
				when wait_for_data_byte =>
					-- Wait until we get one of our data bytes from the PROM
					if (prom_data_ready_pulse = '0') then
						state <= write_byte;
					else
						state <= wait_for_data_byte;
					end if;
				when write_byte =>
					-- WE* is asserted during this state and does the actual write
					state <= written_byte;
				when written_byte =>
					-- Bump address and count
					addr <= addr + "0000000000000001";
					len <= len - "0000000000000001";
					-- Compare length to 1 (not 0) as it is about to be decremented
					if (len="0000000000000001") then
						-- Ok, have done all the bytes now
						if clear_data_out='1' then
							-- If we were clearing main storage, go on to clearing local storage
							state <= initClearLocalStorage;
						else if clear_local_data_out='1' then
								-- If we were clearing local storage, go on to initialising storage
								state <= resetProm;
							else
								-- Doing initialisation, so look for a further length value
								state <= wait_for_high_length_byte;
							end if;
						end if;
					else
						-- Not finished yet
						if clear_data_out='1' or clear_local_data_out='1' then
							-- Clearing storage can go straight back and do another byte
							state <= write_byte;
						else
							-- Initialising storage needs to fetch a byte from PROM
							state <= wait_for_data_byte;
						end if;
					end if;
				when finished =>
					-- Make sure we can't interfere with CPU operation
					init_data_out <= '0';
				when others =>
			end case;
		end if;
end process;

-- Outputs generated as a function of the initialisation machine state:
init_drive_out <= '0' when state=finished else '1';
init_ce <= '0' when state=wait_for_data_byte or state=write_byte or state=written_byte else '1';
init_oe <= '1';
init_we <= '0' when state=write_byte else '1'; -- Only assert WE* from the one state
reset_prom_reader <= '1' when state=resetProm or state=resetProm2 else '0';
-- reset_prom_reader <= '1' when state=resetProm else '0';
prom_read_pulse <= '0' when state=wait_for_high_length_byte
	or state=wait_for_low_length_byte
	or state=wait_for_high_address_byte
	or state=wait_for_low_address_byte
	or state=wait_for_data_byte; -- Trigger a further PROM read when in these states

phys_CE <= init_ce when init_drive_out='1' else '0' when StorageOut.ReadPulse='1' or StorageOut.WritePulse='1' else '1'; -- Select which CE* to use
phys_WE <= init_we when init_drive_out='1' else '0' when StorageOut.WritePulse='1' else '1'; -- Select which WE* to use
phys_UB <= '0'; -- Always select upper byte
phys_LB <= '0'; -- Always select lower byte
phys_OE <= init_oe when init_drive_out='1' else '0' when StorageOut.ReadPulse='1' or StorageOut.WritePulse='0' else '1'; -- Assert OE* if reading
drive_out <= '1' when init_drive_out='1' else '0' when StorageOut.ReadPulse='1' else '1'; -- Whether data bus is driving out, or tristated for input
-- Read in and latch data when doing a real memory read (note - this does not erase the memory as real core would)
StorageIn.ReadData <= phys_data when StorageOut.ReadPulse='1';

-- Select initialisation data or real (R reg) data to go out when writing
phys_data <= init_data & evenParity(init_data) when init_drive_out='1' and init_data_out='1'
	else clear_data & evenParity(clear_data) when init_drive_out='1' and (clear_data_out='1' or clear_local_data_out='1')
	else StorageOut.WriteData when drive_out='1'
	else "ZZZZZZZZZ";
-- Select initialisation address or real (MN reg) address to go out
-- Top bit is 0 for Local Storage and 1 for Main Storage
phys_address <= (not clear_local_data_out) & addr when init_drive_out='1' else StorageOut.MainStorage & StorageOut.MSAR;

-- This turns the debug light on during initialisation
-- (if configured in the higher-level blocks)
debug <= init_drive_out;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Serial configuration PROM reader  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- This macro enables data stored afater the Spartan-3 configuration data to be located and then read
  -- sequentially.
  --

  prom_access: prom_reader_serial
  generic map(    length => 5,                      --Synchronisation pattern is 2^5 = 32 bits
               frequency => 50)                     --System clock rate is 50MHz
  port map(        clock => clk,  
                   reset => reset_prom_reader,      --reset reader and initiates search for sync pattern         
                    read => prom_read_pulse,        --active low pulse initiates retrieval of next byte
               next_sync => '1',                    --would be used to find another sync pattern
                     din => din,                    --from XCF04S device
            sync_pattern => X"8F9FAFBF",            --32bit synchronisation pattern is constant in this application
                    cclk => cclk,                   --to XCF04S device
                    sync => prom_sync_pulse,        --active low pulse indicates sync pattern located
              data_ready => prom_data_ready_pulse,  --active low pulse indicates data byte received
              reset_prom => reset_prom,             --to XCF04S device
                    dout => init_data);             --byte received from serial prom

end DigilentS3BOARD;

architecture DigilentZybo of storage is

--
-- declaration of serial configuration PROM reading interface
--
  component prom_reader_serial
    generic(    length : integer := 5;                      --sync pattern 2^length
             frequency : integer := 50 );                   --system clock speed in MHz
    port(        clock : in std_logic; 
                 reset : in std_logic;                      --active high
                  read : in std_logic;                      --active low single cycle pulse
             next_sync : in std_logic;                      --active low single cycle pulse
                   din : in std_logic;
          sync_pattern : in std_logic_vector((2**length) - 1 downto 0);
                  cclk : out std_logic;
                  sync : out std_logic;                     --active low single cycle pulse
            data_ready : out std_logic;                     --active low single cycle pulse
            reset_prom : out std_logic;                     --active high to /OE of PROM (reset when high)
                  dout : out std_logic_vector(7 downto 0));
  end component;

-- Signals for RAM clearing and initialisation purposes (at startup)
signal drive_out : std_logic;
signal addr : std_logic_vector(15 downto 0) := "0000000000000000";
signal len  : std_logic_vector(15 downto 0) := "0000000000000000";
signal init_CE : std_logic;
signal init_WE : std_logic;
signal init_OE : std_logic;
signal init_drive_out, clear_data_out, clear_local_data_out, init_data_out: std_logic;
signal clear_data : std_logic_vector(7 downto 0) := "00000000"; -- Value written into storage locations when clearing
signal init_data : std_logic_vector(7 downto 0);

-- Signals for Block RAM
signal b : integer range 0 to 8;
signal CascadeA, CascadeB : STD_ULOGIC_VECTOR(0 to 8);
signal LSaddress : STD_LOGIC_VECTOR(13 downto 0);
signal LSDataIn : STD_LOGIC_VECTOR(0 to 8);
signal MSDataIn : STD_LOGIC_VECTOR(0 to 8);
signal MSRead, MSWrite, LSRead, LSWrite : STD_LOGIC;
signal MSWEA : STD_LOGIC_VECTOR(3 downto 0);
signal MSWEB : STD_LOGIC_VECTOR(7 downto 0);
signal LSWEA : STD_LOGIC_VECTOR(1 downto 0);
signal LSWEB : STD_LOGIC_VECTOR(3 downto 0);
signal LSDI : STD_LOGIC_VECTOR(15 downto 0);
signal DIA : STD_LOGIC_VECTOR(31 downto 0);

--
-- Signals for serial PROM reader 
--
signal     reset_prom_reader : std_logic;
signal       prom_read_pulse : std_logic;
signal       prom_sync_pulse : std_logic;
signal prom_data_ready_pulse : std_logic;



begin

-- Unused external storage
PHYS_CE <= 'X';
PHYS_OE <= 'X';
PHYS_WE <= 'X';
PHYS_UB <= 'X';
PHYS_LB <= 'X';
phys_address <= (others=>'X');
phys_data <= (others=>'X');



StorageIn.ReadData <= MSDataIn when StorageOut.MainStorage='1' else LSDataIn;
MSWrite <= StorageOut.WritePulse and StorageOut.MainStorage;
MSRead <= StorageOut.ReadPulse and StorageOut.MainStorage;
LSAddress <= "000" & StorageOut.MSAR(1 to 3) & StorageOut.MSAR(8 to 15);
LSWrite <= StorageOut.WritePulse and not StorageOut.MainStorage;
LSRead <= StorageOut.ReadPulse and not StorageOut.MainStorage;
MSWEA <= "000" & MSWrite;
LSWEA <= "0" & LSWrite;
MSWEB <= "00000000";
LSWEB <= "0000";
LSDI <= "0000000" & StorageOut.WriteData;
    
-- Block RAM for Main storage 64kx9 & Local storage 2kx9, RAM blocks are 36Kb, or 4kB
GENBRAM: FOR b IN 0 TO 8 GENERATE
    FIRST32K:   RAMB36E1
    generic map(
        READ_WIDTH_A => 1, WRITE_WIDTH_A => 1,
        RAM_EXTENSION_A => "LOWER", RAM_EXTENSION_B => "LOWER"
    ) 
    port map(
        CASCADEINA => 'X', CASCADEINB => 'X',
        CASCADEOUTA => CascadeA(b), CASCADEOUTB => CascadeB(b),
        CLKARDCLK => clk,
        ADDRARDADDR => StorageOut.MSAR,
        ENARDEN => MSRead, 
        WEA => MSWEA, 
        DIADI(0) => StorageOut.WriteData(b), DIADI(31 downto 1) => (others=>'0'),
        -- AXI ports
        ENBWREN => '0', WEBWE => MSWEB, ADDRBWRADDR => "XXXXXXXXXXXXXXXX", DIBDI => (31 downto 0 => 'X'), CLKBWRCLK => '0',
        -- Unused ports...
        DIPADIP => "XXXX", DIPBDIP => "XXXX", INJECTDBITERR => 'X', INJECTSBITERR => 'X',
        REGCEAREGCE => 'X', REGCEB => 'X', RSTRAMARSTRAM => 'X', RSTRAMB => 'X',
        RSTREGARSTREG => 'X', RSTREGB => 'X'
    );
    SECOND32K:  RAMB36E1
    generic map(
        READ_WIDTH_A => 1, WRITE_WIDTH_A => 1,
        RAM_EXTENSION_A => "UPPER", RAM_EXTENSION_B => "UPPER"
    ) 
    port map(
        CASCADEINA => CascadeA(b), CASCADEINB => CascadeB(b),
        CLKARDCLK => clk,
        ADDRARDADDR => StorageOut.MSAR,
        DIADI(0) => StorageOut.WriteData(b), DIADI(31 downto 1) => (others=>'0'),
        ENARDEN => MSRead, WEA => MSWEA,
        DOADO(0) => MSDataIn(b), DOADO(31 downto 1) => open,
        -- AXI ports
        ENBWREN => '0', WEBWE => MSWEB, ADDRBWRADDR => "XXXXXXXXXXXXXXXX",  DIBDI => (31 downto 0 => 'X'), CLKBWRCLK => 'X',
        -- Unused ports...
        DIPADIP => "XXXX", DIPBDIP => "XXXX", INJECTDBITERR => 'X', INJECTSBITERR => 'X',
        REGCEAREGCE => 'X', REGCEB => 'X', RSTRAMARSTRAM => 'X', RSTRAMB => 'X',
        RSTREGARSTREG => 'X', RSTREGB => 'X'
    );
END GENERATE;

LocalStorage: RAMB18E1
    generic map(
        READ_WIDTH_A => 9, WRITE_WIDTH_A => 9
    )
    port map (
        CLKARDCLK => clk,
        ADDRARDADDR => LSAddress,
        DIADI(7 downto 0) => LSDI(7 downto 0), DIADI(15 downto 8) => "00000000",
        DIPADIP(0) => LSDI(8), DIPADIP(1) => '0',
        ENARDEN => LSRead, WEA => LSWEA,
        DOADO(7 downto 0) => LSDataIn(0 to 7), DOADO(15 downto 8) => open,
        DOPADOP(0 to 0) => LSDataIn(8 to 8), DOPADOP(1 to 1) => open,
        -- AXI ports
        ENBWREN => '0', WEBWE => LSWEB, CLKBWRCLK => '0', DIBDI => "XXXXXXXXXXXXXXXX",  ADDRBWRADDR => "XXXXXXXXXXXXXX",
        -- Unused
        DIPBDIP => "XX",
        
        REGCEAREGCE => 'X', REGCEB => 'X', RSTRAMARSTRAM => 'X', RSTRAMB => 'X', RSTREGARSTREG => 'X', RSTREGB => 'X'

    );
    
-- Link to AXI interface for MS (BRAM_MS)
end DigilentZybo;
