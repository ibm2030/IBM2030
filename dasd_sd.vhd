---------------------------------------------------------------------------
--    Copyright (c) 2013 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    Creation Date: 2013-01-27
--    Description:
--    Channel interface to SD/SDHC card via SPI
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2013-03-30
--    Initial Release
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;


-- Status byte
-- 0 Attention
-- 1 Status Modifier
-- 2 Control Unit End
-- 3 Busy
-- 4 Channel End
-- 5 Device End
-- 6 Unit Check
-- 7 Unit Exception


-- CCW opcodes:
-- Command bytes
--             01234567
-- Test IO		00000000
-- Sense       XXXX0100
-- Read Bkwd	XXXX1100
-- Write			XXXXXX01
-- Read			XXXXXX10
-- Control		XXXXXX11

-- 	DASD
--    02 = Read IPL (CC=00,Hh=00, Read R1 Data)
--		03 = NOP
--    13 = Restore
--    ?? = Recalibrate
--    07 = Seek BBCCHH
--    0B = Seek xxCCHH
--    1B = Seek xxxxHH
--    1A = Read Head Address (*)
--    12 = Read Count (*)
--    16 = Read R0 (*)
--    06 = Read Data (*)
--    0E = Read Key & Data (*)
--    1E = Read Count, Key & Data (*)
-- (*) = Can add x'80' for multi-track
--
-- Initially all Seeks are ignored, and all Reads read the SD card from the start (Adr=0)
-- Initially all Reads return incrementing values starting with 00
--

--
-- IG Reg
-- 0 Write Latch
-- 1 Reset Operational In latch
-- 2 Read Latch
-- 3 Queued Latch
-- 4 Poll Enable Latch
-- 5 Status In
-- 6 Non-suppressible Polling Interrupt enable
-- 7 Operational In
--
-- ER Reg
-- 0 SERDES Error
-- 1 Address Out from channel
-- 2 Bus Out Parity Error
-- 3 CU End
-- 4 ALU parity error
-- 5
-- 6
-- 7 Halt IO
--
-- Basic file-writing algorithm:
-- 0. N <= byteOffset / 512, byteIndex = byteOffset % 512, look up first cluster and sector
-- 1. If byteIndex>0 then ReadSector N into buffer
-- 2. Start writing data into buffer starting at byteIndex, byteIndex points to next byte to be written
-- 3. If writing reaches end of sector (byteIndex=512) then:
-- 3a. Write sector N, then N=N+1, byteIndex=0, if (N % sectorsPerCluster) == 0 then look up new cluster and sector, goto (2)
-- 4. When writing finishes, if byteIndex>0 then FillSector with skip_offset=byteIndex, then WriteSector

-- To find partition sector number given fileSectorNumber
-- cluster = firstClusterIndex[dev], sec=fileSectorNumber
-- while (cluster != 0) && (sec > sectorsPerCluster)
--   sec = sec - sectorsPerCluster
--   cluster = FAT(cluster)
-- if cluster != 0
--   partitionSectorNumber = clusterZeroOffset + cluster*sectorsPerCluster + sec 


entity CU is
	port (
		-- Channel interface
		-- Fig 2-34a
		bc_COMMO : in std_logic;
		bc_SERVO : in std_logic;
		bc_SUPPO : in std_logic;
		bc_SELTO : in std_logic;
		bc_SORSP : in std_logic;
		BUS_OUT_PARITY_ERROR : in std_logic;
		LOGIC_START : out std_logic; -- Reset Hold Out latch
		A_BUS : in std_logic_vector(0 to 7); -- A Bus on CU
		MACH_RESET : out std_logic;
		ER_7 : in std_logic;
		CA_EQ_15 : out std_logic;
		-- Fig 2-34b
		ROS_ERROR : out std_logic;
		D_BUS_1_BIT : out std_logic; -- To reset Op In latch
		SCAN : out std_logic; -- Reset Op In latch
		LOCAL : out std_logic; -- Resets 'Enabled'
		ER_3 : in std_logic; -- From CU End
		BUS_IN : out std_logic_vector(0 to 7); -- DW Reg 0-7
		BUS_IN_P : out std_logic; -- DW Reg P
		-- Fig 2-34c
		IG_Reg : out std_logic_vector(0 to 7); -- 0=Write Latch 2=Read Latch 3=Queued 4=Poll Enable 5=Status_In 6=IG_6 7=Address_In
		-- IG_Reg replaces the following 3 lines:
		-- CD_15 : out std_logic; -- Gate D bus to IG reg at D_TIME
		-- REG_RESET : out std_logic; -- Reset IG reg
		-- D_BUS : out std_logic_vector(0 to 7); -- 0=Write Latch 2=Read Latch 3=Queued 4=Poll Enable 5=Status_In 6=IG_6 7=Address_In
		-- Fig 2-34d
--		A_BUS_EQ_DR : out std_logic; -- Set 'Transfer Control' during Read operation (data from CU to channel)
--		A_BUS_EQ_IH : out std_logic; -- Set 'Transfer Control' during Write operation (data from channel into CU)
--		A_TIME : out std_logic; -- Gate Service Request reset
--		B_TIME : out std_logic; -- Gate Service Request set
--		C_TIME : out std_logic;
--		D_TIME : out std_logic; -- Gates A_BUS_EQ_DR and A_BUS_EQ_IH
		Transfer_Control_1 : out std_logic;
		A_BUS_TO_ER : out std_logic;
		CHECK_STOP : out std_logic; -- not CHECK_STOP gates General Reset
		SELECTIVE_RESET : in std_logic;
		GENERAL_RESET : in std_logic;
		
		-- External interface
		cs : out std_logic;
		mosi : out std_logic;
		miso : in std_logic;
		sclk : out std_logic;

		-- Debugging
		DEBUG : INOUT DEBUG_BUS;

		clk : in std_logic	-- 50MHz
	);
	end entity CU;

architecture behavioural of CU is

	component  sd_controller is
	port (
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
	sd_error_code : out std_logic_vector(2 downto 0); -- See above, 000=No error
	
	din : in std_logic_vector(7 downto 0);
	din_valid : in std_logic;
	din_taken : out std_logic;
	
	dout : out std_logic_vector(7 downto 0);
	dout_avail : out std_logic;
	dout_taken : in std_logic;
	
	clk : in std_logic;	-- twice the SPI clk
	
	-- Debug stuff
	sd_type : out std_logic_vector(1 downto 0);
	sd_fsm : out std_logic_vector(7 downto 0) := "11111111"
	);
	end component sd_controller;

	type devicestate is (	dev_deselected,
									dev_check_device,
									dev_wait_for_command_file_ok,
									dev_wait_for_command_file_bad,
									dev_bus_out_parity,
									dev_unit_check,
									dev_got_command,
									dev_tio_command,
									dev_seek_command,
									dev_seek_command_2,
									dev_seek_command_3,
									dev_seek_command_4,
									dev_ipl_command,
									dev_ipl_command_2,
									dev_ipl_command_3,
									dev_read_raw_command,
									dev_read_raw_command_2,
									dev_read_data_command,
									dev_read_data_command_2,
									dev_read_data_command_3,
									dev_read_data_command_4,
									dev_read_data_command_5,
									dev_read_data_command_6,
									dev_write_data_command,
									dev_write_data_command_2,
									dev_write_data_command_3,
									dev_write_data_command_4,
									dev_write_data_command_5,
									dev_write_data_command_6,
									dev_present_CE_DE,
									dev_invalid_command,
									dev_initial_device_end, 
									dev_sense_command,
									dev_sense_command_2,
									dev_sense_command_3,
									dev_sense_command_4,
									dev_sense_command_5,
									dev_sense_command_6,
									dev_sense_command_7,
									dev_present_status,
									dev_present_status_2,
									dev_present_status_3,
									dev_disconnect,
									dev_stack_status,
									dev_stack_status_2,
									dev_reset,
									dev_reset2,
									
									-- FAT I/O Subroutines
									fat_initPartition,
									fat_findPartition,
									fat_findPartition_2,
									fat_findPartition_3,
									fat_checkForPartition,
									fat_foundPartition,
									fat_foundPartition_2,
									fat_readPartitionBootSector,
									fat_parseBootSector,
									fat_checkBPS,
									fat_checkBPS_2,
									fat_getSectorsPerCluster,
									fat_CalcClusterSize,
									fat_getReservedSectors,
									fat_getFATCopies,
									fat_getRootCount,
									fat_getFATSize16,
									fat_getFATSize16_2,
									fat_getFATSize32,
									fat_FindRootDir16,
									fat_CalcClusterZero16,
									fat_FindFiles16,
									fat_getRootCluster32,
									fat_FindClusterZero32,
									fat_FindRootDir32,
									fat_FindFiles32,
									fat_ScanDir32ReadSector,
									fat_UnusablePartition,
									fat_ScanDirSector,
									fat_ScanDirSector_1,
									fat_ScanDirSector_2,
									fat_ScanDirSector_3,
									fat_ScanDirSector_4,
									fat_ScanDirSector_5,
									fat_ScanDirSector_6,
									fat_ScanDirSector_7,
									fat_ScanDirSector_8,
									fat_ScanDirSector_9,
--									fat_ScanDir16Sector_10,
--									fat_ScanDir16Sector_11,
									fat_ScanDirNextEntry,
									fat_ScanDirNextSector,
									fat_ScanDirFinished,
									fat_fileOffsetToClusterSectorOffset,
									fat_fileOffsetToClusterSectorOffset_2,
									fat_fileOffsetToClusterSectorOffset_3,
									fat_fileOffsetToClusterSectorOffset_4,
									fat_fileOffsetToClusterSectorOffset_5,
									fat_fileOffsetToClusterSectorOffset_6,
									fat_fileOffsetToClusterSectorOffset_7,
									
									-- SD I/O Subroutines
									sd_ReadTrack,
									sd_ReadSector,
									sd_ReadFatSector,
									sd_ReadSectorGetByte,
									sd_FillSector,
									sd_FillSector_2,
									sd_ReadSectorComplete,
									sd_ReadSectorGotLastByte,
									sd_ReadSectorGotByte,
									sd_WriteSector,
									sd_WriteSectorPutByte,
									sd_WriteSectorComplete,
									sd_WriteSectorAckLastByte,
									sd_WriteSectorAckByte
									);
	signal DASD_state : devicestate := dev_reset;
	signal fat_return_state : devicestate := dev_reset;
	signal sd_return_state : devicestate := dev_reset;
	signal DASD_state_vector : STD_LOGIC_VECTOR(7 downto 0);
	
	-- Controller based on flowcharts in 2841 FETOM p3-9 onwards
	signal selected_addr : std_logic_vector(0 to 7);
	signal command : std_logic_vector(0 to 7);
	signal command_parity_error : std_logic;

	subtype deviceNumber is natural range 0 to 15;

	type attentionArray is array(deviceNumber) of boolean;
	signal device_attention : attentionArray := (others => false);


	type senseArray is array(0 to 5) of std_logic_vector(0 to 7);
	signal sense : senseArray := (others => "00000000");

	subtype cylinderNumber is std_logic_vector(15 downto 0); -- Allow for CC
	type cylinderArray is array(deviceNumber) of cylinderNumber;
	signal currentCylinder : cylinderArray := (others=>(others=>'0')); -- Where they all are now

	subtype headNumber is std_logic_vector(7 downto 0); -- Allow for H
	type headArray is array(deviceNumber) of headNumber;
	signal currentHead : headArray := (others=>(others=>'0')); -- Head set by Seek

	type seekArray is array(0 to 5) of std_logic_vector(0 to 7); -- BBCCHH
	signal seekVector : seekArray := (others=>"00000000"); -- Set by Seek command

	-- SD-SPI signals
	signal divider : std_logic_vector(23 downto 0) := (others=>'0');
	signal sd_reset : STD_LOGIC := '0';
	signal sd_rd : STD_LOGIC := '0';
	signal sd_rd_multiple : STD_LOGIC := '0';
	signal sd_data_in : STD_LOGIC_VECTOR(7 downto 0);
	signal sd_data_avail : STD_LOGIC;
	signal sd_data_taken : STD_LOGIC := '0';
	signal sd_wr : STD_LOGIC := '0';
	signal sd_wr_multiple : STD_LOGIC := '0';
	signal sd_data_out : STD_LOGIC_VECTOR(7 downto 0);
	signal sd_dout_avail : STD_LOGIC;
	signal sd_dout_taken : STD_LOGIC;
	signal sd_block_address : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	signal sd_busy : STD_LOGIC := '0';
	signal sd_error : STD_LOGIC := '0';
	signal sd_error_code : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal sd_card_type : STD_LOGIC_VECTOR(1 downto 0); -- 00=None 01=SD1 10=SD2 11=SDHC
	signal sd_fsm_state : STD_LOGIC_VECTOR(7 downto 0);

	-- FAT-to-SD I/O
	constant trackBufferSize : integer := 4095; -- Length-1
	type t_TrackBuffer is array (0 to trackBufferSize) of STD_LOGIC_VECTOR(7 downto 0);
	type t_FATBuffer is array (0 to 511) of STD_LOGIC_VECTOR(7 downto 0);
	signal sectorBuffer : t_TrackBuffer;
	signal fatBuffer : t_FATBuffer;
	signal skipOffset : integer range 0 to trackBufferSize;
	signal byte_counter : integer range 0 to trackBufferSize;
	signal byte_index : integer range 0 to trackBufferSize;
	signal readFat : boolean := false;

	-- Filesystem type definitions
	subtype t_sectorNumber is STD_LOGIC_VECTOR(31 downto 0);
	subtype t_clusterNumber is STD_LOGIC_VECTOR(31 downto 0); -- FAT16 only uses bottom 16 bits, FAT32 only bottom 28 bits
	subtype t_clusterRelative is STD_LOGIC_VECTOR(15 downto 0); -- Cluster within file, 0 is first cluster
	subtype t_clusterOffset is STD_LOGIC_VECTOR(5 downto 0); -- Position of a sector within a cluster
	subtype t_byteOffset is STD_LOGIC_VECTOR(8 downto 0); -- Position within a 512-byte sector
	type t_ClusterIndex is array(deviceNumber) of t_clusterNumber;
	type t_ClusterOffsetIndex is array(deviceNumber) of t_clusterOffset;
	type t_SectorOffsetIndex is array(deviceNumber) of t_byteOffset;
--	type t_SectorIndex is array(deviceNumber) of t_sectorNumber;
	type t_FSType is (None, FAT16, FAT32);
	type t_FatError is (fatE_None, fatE_BootSectorError, fatE_BootSector55Error, fatE_BootSectorAAError, 
		fatE_NoPartition, fatE_InvalidPartition, fatE_UnusablePartition, fatE_ReadError, fatE_FATReadError);
	
	-- Signals set upon mounting the FAT partition
	signal fat_Error : t_FatError := fatE_None;
	signal fat_FSType : t_FSType := None;
	signal fat_partitionStartSector, fat_partitionLength : t_sectorNumber := (others=>'0');
	signal fat_reservedSectors : std_logic_vector(15 downto 0) := (others=>'0');
	signal fat_FAT_StartSector : t_sectorNumber := (others=>'0');
	signal fat_sectorsPerCluster : std_logic_vector(7 downto 0); -- sec/cluster = 1,2,4,8,16,*32*,64
	signal fat_clusterMask : t_clusterOffset; -- sectorsPerCluster - 1 = 0,1,3,7,15,*31*,63
	signal fat_clusterSize : integer range 0 to 7; -- 1,2,4,8,16,32,64 sectors/cluster => 0,1,2,3,4,*5*,6
	signal fat_FATCopies : std_logic_vector(7 downto 0);
	signal fat_ClusterZeroSector : t_ClusterNumber;
	signal fat_RootCount : std_logic_vector(15 downto 0); -- FAT16 only
	signal fat_FATSize : t_sectorNumber;
	signal fat_RootCluster : t_clusterNumber := (others=>'0'); -- FAT32 only
	signal fat_RootDirSector : t_sectorNumber := (others=>'0'); -- FAT16 & FAT32
	
	-- Signals set upon finding device files
	signal fat_firstClusterIndex : t_ClusterIndex := (others=>(others=>'0'));
	
	-- Signals set by device accesses
	-- The following signals relate to sectorBuffer
	signal fat_fileOffset : STD_LOGIC_VECTOR(31 downto 0); -- The position within the file to read
	signal fat_currentFileCluster, fat_ClusterCounter : t_ClusterRelative; -- Cluster number within file (0=first)
	signal fat_currentCluster : t_ClusterNumber; -- 0 if the buffer doesn't contain a cluster's sector
	signal fat_currentSector : t_SectorNumber; -- 111111... if the buffer doesn't contain a valid sector
	signal fat_currentClusterSector : t_clusterOffset; -- Where the sector is within the cluster
	signal fat_currentSectorByte : t_byteOffset; -- Where the position is within the sector
	
	-- The following signal relates to fatBuffer
	signal fat_currentFATSector : t_SectorNumber; -- 111111... if no valid FAT sector in the buffer
	
	-- The following values relate to the currentCylinder & currentHead values set by Seek
	-- fat_currentTrackStartByte points to the byte in the sector corresponding to
	--		the start of the track
	signal fat_currentTrackFirstCluster : t_ClusterIndex := (others=>(others=>'0'));
	signal fat_currentTrackFirstSector : t_ClusterOffsetIndex := (others=>(others=>'0'));
	signal fat_currentTrackStartByte : t_SectorOffsetIndex := (others=>(others=>'0'));
	
	subtype nybble is integer range 0 to 16; -- 16=Invalid

	function Hex_to_Int(char : std_logic_vector(7 downto 0)) return nybble is
	variable result : integer;
	begin
		case char is
			when x"30" => result := 0;
			when x"31" => result := 1;
			when x"32" => result := 2;
			when x"33" => result := 3;
			when x"34" => result := 4;
			when x"35" => result := 5;
			when x"36" => result := 6;
			when x"37" => result := 7;
			when x"38" => result := 8;
			when x"39" => result := 9;
			when x"41" => result := 10;
			when x"42" => result := 11;
			when x"43" => result := 12;
			when x"44" => result := 13;
			when x"45" => result := 14;
			when x"46" => result := 15;
			when x"61" => result := 10;
			when x"62" => result := 11;
			when x"63" => result := 12;
			when x"64" => result := 13;
			when x"65" => result := 14;
			when x"66" => result := 15;
			when others => result := 16;
		end case;
		return result;
	end Hex_to_Int;

function ShiftBVLeft(bv : STD_LOGIC_VECTOR(31 downto 0); shift: integer range 0 to 7) return STD_LOGIC_VECTOR is
variable res1,res2,res4 : STD_LOGIC_VECTOR(31 downto 0);
variable b0,b1,b2 : boolean;
begin
	if (shift=1) or (shift=3) or (shift=5) or (shift=7) then
		res1 := bv(30 downto 0) & '0';
	else
		res1 := bv;
	end if;
	if (shift=2) or (shift=3) or (shift=6) or (shift=7) then
		res2 := res1(29 downto 0) & "00";
	else
		res2 := res1;
	end if;
	if (shift=4) or (shift=5) or (shift=6) or (shift=7) then
		res4 := res2(27 downto 0) & "0000";
	else
		res4 := res2;
	end if;
	return res4;
end ShiftBVLeft;

signal DriveNumber : deviceNumber;
-- The following 2 declarations are a bug-fix (I think)
signal writeSectorBuffer, writeABUStoSectorBuffer, writeSDtoSectorBuffer : boolean;
signal sectorBufferInput : std_logic_vector(7 downto 0);
-- End bug-fix

begin

dasd : process (clk, dasd_state, BUS_OUT_PARITY_ERROR, sd_error, sd_data_avail, skipOffset, readFat, A_BUS, sd_data_in) is
variable newSector : t_sectorNumber;
begin
-- The following 10 lines are a bug-fix
	writeABUStoSectorBuffer <= dasd_state=dev_write_data_command_3 and BUS_OUT_PARITY_ERROR='0';
	writeSDtoSectorBuffer <= dasd_state=sd_ReadSectorGetByte and sd_error='0' and sd_data_avail='1' and skipOffset=0 and not readFat;
	writeSectorBuffer <= writeABUStoSectorBuffer or writeSDtoSectorBuffer;
	if writeABUStoSectorBuffer then
		sectorBufferInput <= A_BUS;
	elsif writeSDtoSectorBuffer then
		sectorBufferInput <= sd_data_in;
	else
		sectorBufferInput <= (others=>'0');
	end if;
-- End bug-fix	
	if rising_edge(clk) then
-- The following 3 lines are a bug-fix
		if writeSectorBuffer then
			SectorBuffer(byte_index) <= sectorBufferInput;
		end if;
-- End bug-fix
		case dasd_state is
			when dev_reset =>
				IG_Reg <= "00000000";
				MACH_RESET <= '1';
				sd_rd <= '0';
				sd_wr <= '0';
				sd_reset <= '1';
				A_BUS_TO_ER <= '0';
				Transfer_Control_1 <= '0';
				CHECK_STOP <= '0';
				ROS_ERROR <= '0';
				D_BUS_1_BIT <= '0';
				SCAN <= '0';
				LOCAL <= '0';
				LOGIC_START <= '0';
				CA_EQ_15 <= '0';
				dasd_state <= dev_reset2;
			when dev_reset2 =>
				MACH_RESET <= '0';
				sd_reset <= '0';
-- TEMP
				dasd_state <= fat_InitPartition;
				fat_return_state <= dev_deselected;
--				dasd_state <= dev_deselected; -- TEMP
				-- Here we should do the following:
				-- Check for SD card attached and initialised
				-- Initialise filesystem
				-- Scan for CKD files of the form "CNM" where
				--  C=Any digit (0,1,2)
				--  N=Digit matching our address (8,9)
				--  M=Any digit 0-F
				-- Store the address of the first FAT entry for each device's file
			when dev_deselected =>
				IG_Reg <= "00000000";
				D_BUS_1_BIT <= '0';
--				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
--					dasd_state <= dev_reset;
--				els
				if bc_SELTO='1' then
					-- Address Out, Select Out and address matches
					-- Store address
					selected_addr <= A_BUS;
					dasd_state <= dev_check_device;
				end if;
			when dev_check_device =>
				-- Place address on Bus In
				BUS_IN <= A_BUS;
				BUS_IN_P <= EvenParity(A_BUS);
				-- Raise Operational In by setting IG7
				-- This will also raise Address In when Address Out drops
				IG_Reg <= "00000001";
				if sd_card_type="00" then
					dasd_state <= dev_wait_for_command_file_bad;
				else
					DriveNumber <= conv_integer(selected_addr(4 to 7));
					dasd_state <= dev_wait_for_command_file_ok;
				end if;
			when dev_wait_for_command_file_ok =>
				-- Wait for Command Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
					IG_Reg <= "00000000"; -- Drop Address In
					command <= A_BUS;
					command_parity_error <= BUS_OUT_PARITY_ERROR;
					dasd_state <= dev_got_command;
				end if;
			when dev_wait_for_command_file_bad =>
				-- Wait for Command Out - must only be Sense
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
					IG_Reg(7) <= '0'; -- Drop Address In
					command <= A_BUS;
					command_parity_error <= BUS_OUT_PARITY_ERROR;
					if (command(0) & command(4 to 7))="00100" then -- 0XXX0100
						dasd_state <= dev_got_command;
					else
						dasd_state <= dev_tio_command;
					end if;
				end if;
			when dev_bus_out_parity =>
				-- Put BUS OUT PARITY in sense data
				Transfer_Control_1 <= '0'; -- Just in case
				sense(0)(2) <= '1'; -- Set Bus Out Parity in Sense0
				dasd_state <= dev_unit_check;
			when dev_unit_check =>
				BUS_IN <= "00000010"; -- Unit Check
				BUS_IN_P <= '0';
				dasd_state <= dev_present_status;
			when dev_present_status =>
				-- Wait for Command Out to fall
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='0' then
					dasd_state <= dev_present_status_2;
				end if;
			when dev_present_status_2 =>
				IG_Reg <= "00000100"; -- IG5=Status In
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					-- If Device End was signalled, reset Attention
					device_attention(CONV_INTEGER(selected_addr(4 to 7))) <= false;
					dasd_state <= dev_present_status_3;
				elsif bc_COMMO='1' then
					-- Stack Status
					dasd_state <= dev_stack_status;
				end if;
			when dev_present_status_3 =>
				-- Drop Status In
				IG_Reg <= "00000000";
				-- Wait for Select Out to drop
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SELTO='0' then
					dasd_state <= dev_disconnect;
				end if;
			when dev_disconnect =>
				D_BUS_1_BIT <= '1'; -- Reset Operational In
				IG_Reg <= "00000000";
				dasd_state <= dev_deselected;
			when dev_stack_status =>
				-- Drop Status In
				IG_Reg <= "00000000";
				-- Wait for Select Out to drop
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SELTO='0' then
					dasd_state <= dev_stack_status_2;
				end if;
			when dev_stack_status_2 =>
				D_BUS_1_BIT <= '1'; -- Reset Operational In
				dasd_state <= dev_deselected;
			when dev_got_command =>
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
				-- Wait for Command Out to drop
				
				-- Check for file operable
-- TEMP				
				elsif sd_card_type="00" then
					dasd_state <= dev_tio_command;
				-- Check for Device End
				elsif device_attention(CONV_INTEGER(selected_addr(4 to 7))) then
					dasd_state <= dev_tio_command;
				-- Decode command
				else
					if (command=x"00") then
						dasd_state <= dev_tio_command;
					elsif (command=x"07") or (command=x"0b") or (command=x"1b") then
						dasd_state <= dev_seek_command;
					elsif (command=x"02") then
						dasd_state <= dev_ipl_command;
					elsif (command=x"06") then
						dasd_state <= dev_read_data_command;
					elsif (command=x"16") then
						dasd_state <= dev_read_raw_command;
					elsif ((command(0) & command(4 to 7)) = "00100") then
						dasd_state <= dev_sense_command;
-- TEMP						
					elsif (command=x"05") then
						dasd_state <= dev_write_data_command;
					else
						dasd_state <= dev_invalid_command;
					end if;
				end if;
			when dev_invalid_command =>
				sense(0)(0) <= '1';
				dasd_state <= dev_unit_check;
				
			when dev_initial_device_end =>
				BUS_IN <= "00000100"; -- Device End
				BUS_IN_P <= '0';
				dasd_state <= dev_present_status;
			when dev_tio_command =>
				-- See p3-41 for various status checks
				-- Check device operable
				if sd_card_type="00" then
					-- No card - inoperable
					sense(0)(3) <= '1'; -- Equipment Check
						-- Set Intervention Required in Sense
					dasd_state <= dev_unit_check;
				elsif false then
					-- Busy
					BUS_IN <= "00010000"; -- Busy
					BUS_IN_P <= '0';
					dasd_state <= dev_present_status;
				elsif false then
					-- Unsafe
					dasd_state <= dev_unit_check;
				elsif false then
					-- Seek Incomplete
					dasd_state <= dev_unit_check;
				elsif false then
					-- End Of Cylinder
					dasd_state <= dev_unit_check;
				elsif device_attention(CONV_INTEGER(selected_addr(4 to 7))) then
					-- Attention from device
					if command="00000000" then
						BUS_IN <= "00000100"; -- Device End
						BUS_IN_P <= '0';
					else
						BUS_IN <= "00010100"; -- Device End and Busy
						BUS_IN_P <= '1';
					end if;
					dasd_state <= dev_present_status;
				else
					BUS_IN <= "00000000";
					BUS_IN_P <= '1';
					dasd_state <= dev_present_status;
				end if;
			when dev_sense_command =>
				BUS_IN <= "00000000";
				BUS_IN_P <= '1';
				IG_Reg(5) <= '1'; -- Status In
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					dasd_state <= dev_sense_command_2;
				end if;
			when dev_sense_command_2 =>
				IG_Reg <= "00100000";	-- Drop Status In, Set Read Latch
				byte_counter <= 6;
				dasd_state <= dev_sense_command_3;
			when dev_sense_command_3 =>
				-- Put byte on Bus In and raise Service In
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='0' then
					-- Wait for Service Out to drop, and then transfer to channel
					-- (Service Out is dropped when both Status In and Service In are down)
					BUS_IN <= sense(byte_index);
					BUS_IN_P <= EvenParity(sense(byte_index));
					Transfer_Control_1 <= '1'; -- Raise Service In
					dasd_state <= dev_sense_command_4;
				end if;
			when dev_sense_command_4 =>
				-- Wait for Service Out to rise
				Transfer_Control_1 <= '0';
				-- Wait for Transfer_Control_1 to propagate to bc_SORSP
				-- via SVC_Request (also via Transfer_Control_2 and Service_In)
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SORSP='1' then
					-- SVC Request (Service In) up - now wait for it to drop
					dasd_state <= dev_sense_command_5;
				end if;
			when dev_sense_command_5 =>
				-- Wait for Service In to drop, or Command Out to rise
				-- Service In is dropped by Service Out rising
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
					-- Command Out up => Stop
					-- Reset Service In latch
					A_BUS_TO_ER <= '1';
					dasd_state <= dev_sense_command_6;
				elsif bc_SORSP='0' then
					-- Service In down (=Service Out up) => Continue
					if byte_counter=0 then
						dasd_state <= dev_sense_command_7;
					else
						byte_index <= byte_index + 1;
						byte_counter <= byte_counter - 1;
						dasd_state <= dev_sense_command_3;
					end if;
				end if;
			when dev_sense_command_6 =>
				-- Remove Service In reset signal
				A_BUS_TO_ER <= '0';
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				else
					dasd_state <= dev_sense_command_7;
				end if;				
			when dev_sense_command_7 =>
				-- Final status
				IG_Reg <= "00000000"; -- Drop Service In and reset Read Latch
				BUS_IN <= "00001100"; -- Channel End & Device End
				BUS_IN_P <= '1';
				if bc_SERVO='0' then
					dasd_state <= dev_present_status; -- Wait for Command Out to drop then present status
				end if;

				
			when dev_ipl_command =>
				BUS_IN <= "00000000"; -- Status 0
				BUS_IN_P <= '1';
				IG_Reg <= "00000100"; -- IG5=Status In
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					dasd_state <= dev_ipl_command_2;
				end if;
			when dev_ipl_command_2 =>
				fat_fileOffset <= (others=>'0');
				-- Drop Status In, initiate read from SD
				IG_Reg <= "00100000"; -- Drop Status In, Set Read Latch
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='0' then
					sd_return_state <= dev_ipl_command_3;
--					dasd_state <= sd_ReadSector;
				end if;
			when dev_ipl_command_3 =>
				IG_Reg <= "00000000"; -- Drop Status In
				byte_counter <= 24;
				byte_index <= 0;
				-- Wait for Seek to Cyl0 to complete
				if true then
					dasd_state <= dev_read_data_command_3;
					IG_Reg <= "00100000"; -- Set Read Latch
				end if;

			when dev_seek_command =>
				-- Send 00 initial status, then wait for Service Out
				BUS_IN <= "00000000"; -- Status 0
				BUS_IN_P <= '1';
				IG_Reg <= "00000100"; -- Status In

				byte_counter <= 5;
				byte_index <= 0;
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					dasd_state <= dev_seek_command_2;
				end if;
			when dev_seek_command_2 =>
				-- Drop Status In, start transferring data
				IG_Reg <= "10000000"; -- Drop Status In (will reset Service Out) and set Write Latch (will raise Service In)
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
					-- Stop
					dasd_state <= dev_present_CE_DE;
				elsif bc_SORSP='1' then
					-- Service Out raised - go get data
					dasd_state <= dev_seek_command_3;
				end if;
			when dev_seek_command_3 =>
				-- Get data
				seekVector(byte_index) <= A_BUS;
				Transfer_Control_1 <= '1'; -- Reset Service In
				if (BUS_OUT_PARITY_ERROR='1') then
					IG_Reg <= "00000000"; -- Reset Write Latch (prevents Service In rising again)
					dasd_state <= dev_bus_out_parity;
				else
					if byte_counter=0 then
						IG_Reg <= "00000000"; -- Reset Write Latch (prevents Service In rising again)
						dasd_state <= dev_present_CE_DE;
					else
						dasd_state <= dev_seek_command_4;
					end if;
				end if;
			when dev_seek_command_4 =>
				Transfer_Control_1 <= '0';
				if bc_SORSP='0' then
					byte_index <= byte_index + 1;
					byte_counter <= byte_counter - 1;
					dasd_state <= dev_seek_command_2;
				end if;
				
				-- Look up device, check for CKD file
				-- Get seek data
				-- Compute file address
				-- Look up Cluster and Sector numbers for start of track
				-- Set Orientation to None
				
			when dev_read_raw_command =>
				-- Send 00 initial status, then wait for Service Out
				BUS_IN <= "00000000"; -- Status 0
				BUS_IN_P <= '1';
				IG_Reg <= "00000100"; -- Status In
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					-- Set read address (temporary) using BBCCHH is sector offset
					fat_currentSector <= (seekVector(2) & seekVector(3) & seekVector(4) & seekVector(5));
					dasd_state <= dev_read_raw_command_2;
				end if;
			when dev_read_raw_command_2 =>
				-- Drop Status In, initiate read from SD
				IG_Reg <= "00100000"; -- Drop Status In (will reset Service Out) and set Read Latch
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='0' then
					fat_Error <= fatE_None;
					sd_return_state <= dev_read_data_command_3;
					dasd_state <= sd_ReadTrack;
--					dasd_state <= dev_read_data_command_3; -- TEMP
--					byte_index <= 0; -- TEMP
				end if;
			when dev_read_data_command =>
				-- Send 00 initial status, then wait for Service Out
				BUS_IN <= "00000000"; -- Status 0
				BUS_IN_P <= '1';
				IG_Reg <= "00000100"; -- Status In
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					-- Set read address (temporary) using BBCCHH is sector offset
					fat_fileOffset <= (seekVector(2) & seekVector(3) & seekVector(4) & seekVector(5));
					-- Convert fileOffset to cluster/sector/offset
					dasd_state <= dev_read_data_command_2;
				end if;
			when dev_read_data_command_2 =>
				-- Drop Status In, initiate read from SD
				IG_Reg <= "00100000"; -- Drop Status In (will reset Service Out) and set Read Latch
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='0' then
					fat_return_state <= dev_read_data_command_3;
					dasd_state <= fat_fileOffsetToClusterSectorOffset;
--					dasd_state <= dev_read_data_command_3; -- TEMP
--					byte_index <= 0; -- TEMP
				end if;
			when dev_read_data_command_3 =>
				-- Check for SD read error
				-- Put byte on Bus In and raise Service In
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif fat_Error /= fatE_None then
					-- Error during read
					sense(0)(4) <= '1'; -- Data Check
					dasd_state <= dev_unit_check;
				elsif bc_SERVO='0' then
					-- Wait for Service Out to drop, and then transfer to channel
					-- (Service Out is dropped when both Status In and Service In are down)
					BUS_IN <= sectorBuffer(byte_index);
					BUS_IN_P <= EvenParity(sectorBuffer(byte_index));
					Transfer_Control_1 <= '1'; -- Raise Service In
					dasd_state <= dev_read_data_command_4;
				end if;
			when dev_read_data_command_4 =>
				-- Wait for Service Out to rise
				Transfer_Control_1 <= '0';
				-- Wait for Transfer_Control_1 to propagate to bc_SORSP
				-- via SVC_Request (also via Transfer_Control_2 and Service_In)
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SORSP='1' then
					-- SVC Request (Service In) up - now wait for it to drop
					dasd_state <= dev_read_data_command_5;
				end if;
			when dev_read_data_command_5 =>
				-- Wait for Service In to drop, or Command Out to rise
				-- Service In is dropped by Service Out rising
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
					-- Command Out up => Stop
					-- Reset Service In latch
					A_BUS_TO_ER <= '1';
					dasd_state <= dev_present_CE_DE;
				elsif bc_SORSP='0' then
					-- Service In down (=Service Out up) => Continue
					if byte_counter=0 then
						dasd_state <= dev_present_CE_DE;
					else
						byte_index <= byte_index + 1;
						byte_counter <= byte_counter - 1;
						dasd_state <= dev_read_data_command_3;
					end if;
				end if;
			when dev_read_data_command_6 =>
			when dev_present_CE_DE =>
				A_BUS_TO_ER <= '0'; -- Just in case it's needed
				Transfer_Control_1 <= '0'; -- Just in case
				-- Final status
				IG_Reg <= "00000000"; -- Drop Service In and reset Read Latch
				BUS_IN <= "00001100"; -- Channel End & Device End
				BUS_IN_P <= '1';
				if bc_SERVO='0' then
					dasd_state <= dev_present_status; -- Wait for Command Out to drop then present status
				end if;
				
			when dev_write_data_command =>
				-- Send 00 initial status, then wait for Service Out
				BUS_IN <= "00000000"; -- Status 0
				BUS_IN_P <= '1';
				IG_Reg <= "00000100"; -- Status In

				byte_counter <= 511;
				byte_index <= 0;
				-- Wait for Service Out
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_SERVO='1' then
					dasd_state <= dev_write_data_command_2;
				end if;
			when dev_write_data_command_2 =>
				-- Drop Status In, start transferring data
				IG_Reg <= "10000000"; -- Drop Status In (will reset Service Out) and set Write Latch (will raise Service In)
				if GENERAL_RESET='1' or SELECTIVE_RESET='1' then
					dasd_state <= dev_reset;
				elsif bc_COMMO='1' then
					-- Stop
					dasd_state <= dev_write_data_command_5;
				elsif bc_SORSP='1' then
					-- Service Out raised - go get data
					dasd_state <= dev_write_data_command_3;
				end if;
			when dev_write_data_command_3 =>
				-- Get data
				Transfer_Control_1 <= '1'; -- Reset Service In
				if (BUS_OUT_PARITY_ERROR='1') then
					IG_Reg <= "00000000"; -- Reset Write Latch (prevents Service In rising again)
					dasd_state <= dev_bus_out_parity;
				else
-- The following line is replaced by bug-fix lines at the top of this process
--					sectorBuffer(byte_index) <= A_BUS;
-- End bug-fix					
					if byte_counter=0 then
						IG_Reg <= "00000000"; -- Reset Write Latch (prevents Service In rising again)
						dasd_state <= dev_write_data_command_5;
					else
						dasd_state <= dev_write_data_command_4;
					end if;
				end if;
			when dev_write_data_command_4 =>
				Transfer_Control_1 <= '0';
				if bc_SORSP='0' then
					byte_index <= byte_index + 1;
					byte_counter <= byte_counter - 1;
					dasd_state <= dev_write_data_command_2;
				end if;
			when dev_write_data_command_5 =>
				if byte_counter=0 then
					if fat_currentSector = x"ffffffff" then
						-- No sector - can't write
						dasd_state <= dev_unit_check;
					else
						sd_return_state <= dev_write_data_command_6;
						dasd_state <= sd_WriteSector;
					end if;
				else
					-- Didn't get a full buffer - ignore
					dasd_state <= dev_present_CE_DE;
				end if;
			when dev_write_data_command_6 =>
				if sd_error='0' then
					dasd_state <= dev_present_CE_DE;
				else
					dasd_state <= dev_unit_check;
				end if;
			

			-- State subroutines
			-- Read track into buffer
			when sd_ReadTrack =>
			-- Read Sectors to fill track buffer: given fat_currentSector
			-- Returns sd_error, byte_index=0, byte_counter=readLength
			-- NOTE: Needs modifying to cope with reaching end of cluster
			skipOffset <= 0;
			byte_counter <= trackBufferSize;
			sd_block_address <= fat_currentSector;
			readFat <= false;
			if sd_busy='0' then
				DASD_state <= sd_FillSector_2;
				sd_rd_multiple <= '1';
			end if;
			
			-- Read sector into buffer
			when sd_ReadSector =>
			-- Read Sector: given fat_currentSector
			-- Returns sd_error, byte_index=0, byte_counter=511
			skipOffset <= 0;
			byte_counter <= 511;
			sd_block_address <= fat_currentSector;
			readFat <= false;
			if sd_busy='0' then
				DASD_state <= sd_FillSector_2;
				sd_rd <= '1';
			end if;

			when sd_ReadFATSector =>
			-- Read Sector into FATbuffer: given fat_currentFATSector
			-- Returns sd_error, byte_index=0, byte_counter=511
			byte_counter <= 511;
			skipOffset <= 0;
			sd_block_address <= fat_currentFATSector;
			readFat <= true;
			if sd_busy='0' then
				DASD_state <= sd_FillSector_2;
				sd_rd <= '1';
			end if;

			when sd_FillSector =>
			-- Read Partial Sectors into trackBuffer: given fat_currentSector, skip_offset
			-- Returns sd_error, byte_index=0, byte_counter=511
			byte_counter <= trackBufferSize;
			sd_block_address <= fat_currentSector;
			readFat <= false;
			if sd_busy='0' then
				DASD_state <= sd_FillSector_2;
				sd_rd <= '1';
			end if;

			when sd_FillSector_2 =>
			byte_index <= 0;
			if sd_busy='1' then
				-- Wait for Rd to take effect and reset Error
				DASD_state <= sd_ReadSectorGetByte;
			end if;
			
			when sd_ReadSectorGetByte =>
			if sd_error='1' then
				 sd_rd <= '0';
				 sd_rd_multiple <= '0';
				 DASD_state <= sd_ReadSectorComplete;
			elsif sd_busy='0' then
				-- SD finished
				DASD_state <= sd_ReadSectorGotLastByte;
			elsif sd_data_avail='1' then
				if skipOffset=0 then
					if readFat then
						FATbuffer(byte_index) <= sd_data_in;
					else
-- The following line is replaced by bug-fix lines at the top of this process
--						sectorBuffer(byte_index) <= sd_data_in;
-- End bug-fix
					end if;
				else
					skipOffset <= skipOffset - 1;
				end if;
				sd_data_taken <= '1';
				if byte_counter=0 then
					DASD_state <= sd_ReadSectorGotLastByte;
				else
					DASD_state <= sd_ReadSectorGotByte;
				end if;
			end if;

			when sd_ReadSectorGotByte =>
			if sd_error='1' then
				sd_data_taken <= '0';
				sd_rd <= '0';
				sd_rd_multiple <= '0';
				if readFat then
					fat_currentFATSector <= (others => '1');
				else
					fat_currentSector <= (others => '1');
				end if;
				DASD_state <= sd_ReadSectorComplete;
			elsif sd_busy='0' then
				-- SD finished
				DASD_state <= sd_ReadSectorGotLastByte;
			elsif sd_data_avail='0' then
				byte_index <= byte_index + 1;
				byte_counter <= byte_counter - 1;
				sd_data_taken <= '0';
				DASD_state <= sd_ReadSectorGetByte;
			end if;

			when sd_ReadSectorGotLastByte =>
			-- Tidy up and finish
			if sd_data_avail='0' then
				byte_index <= 0;
				byte_counter <= 511;
				sd_data_taken <= '0';
				sd_rd <= '0';
				sd_rd_multiple <= '0';
				DASD_state <= sd_ReadSectorComplete;
			end if;

			when sd_ReadSectorComplete =>
			if sd_busy='0' then
				DASD_state <= sd_return_state;
			end if;


			when sd_WriteSector =>
			-- Write Sector, given fat_currentSector, returns sd_error
			sd_block_address <= fat_currentSector;
			byte_counter <= 511;
			byte_index <= 0;
			sd_wr <= '1';
			if sd_busy='1' then
				DASD_state <= sd_WriteSectorPutByte;
			end if;

			when sd_WriteSectorPutByte =>
			if sd_error='1' then
				 sd_wr <= '0';
				 DASD_state <= sd_WriteSectorComplete;
			elsif sd_dout_taken='0' then
				 sd_data_out <= sectorBuffer(byte_index);
				 sd_dout_avail <= '1';
				  DASD_state <= sd_WriteSectorAckByte;
			end if;

			when sd_WriteSectorAckByte =>
			if sd_error='1' then
				 sd_dout_avail <= '0';
				 sd_wr <= '0';
				 DASD_state <= sd_WriteSectorComplete;
			elsif sd_dout_taken='1' then
				 byte_counter <= byte_counter - 1;
				 byte_index <= byte_index + 1;
				 sd_dout_avail <= '0';
				 if byte_counter=0 then
					  DASD_state <= sd_WriteSectorAckLastByte;
				else
					DASD_state <= sd_WriteSectorPutByte;
				 end if;
			end if;

			when sd_WriteSectorAckLastByte =>
			-- Tidy up and finish
			if sd_dout_taken='0' then
				 sd_dout_avail <= '0';
				 sd_wr <= '0';
				 DASD_state <= sd_WriteSectorComplete ;
			end if;

			when sd_WriteSectorComplete =>
			if sd_busy='0' then
				 DASD_state <= sd_return_state;
			end if;
			
			-- FAT subroutines
			
			when fat_initPartition =>
				fat_CurrentSector <= (others => '0');
				sd_return_state <= fat_findPartition;
				-- Wait for SD card to come ready
				if sd_busy='0' then
					DASD_state <= sd_ReadSector;
				end if;

			when fat_findPartition =>
				byte_index <= 510;
				if sd_error='1' then
					 fat_Error <= fatE_bootSectorError;
--					 DASD_state <= fat_return_state;
				else
					DASD_state <= fat_findPartition_2;
				end if;
			when fat_findPartition_2 =>
				if sectorBuffer(byte_index)/="01010101" then
					 fat_Error <= fatE_bootSector55Error;
--					 DASD_state <= fat_return_state;
				else
					 byte_index <= byte_index+1;
					 DASD_state <= fat_findPartition_3;
				end if;

			when fat_findPartition_3 =>
				if sectorBuffer(byte_index)/="10101010" then
					 fat_Error <= fatE_bootSectorAAError;
--					 DASD_state <= fat_return_state;
				else
					 byte_index <= 16#1c2#;
					 DASD_state <= fat_checkForPartition;
				end if;

			-- Partition entries start at 0x1be,0x1ce,0x1de,0x1ee
			-- Check buffer[4] (ox1c2,0x1d2,0x1e2,0x1f2)
			-- buffer[4] is type 0x00=Empty 0x06=FAT16 0x0b=FAT32
			when fat_checkForPartition =>
				if sectorBuffer(byte_index)="00000110" then
					fat_FSType <= FAT16;
					byte_index <= byte_index + 4;
					DASD_state <= fat_foundPartition;
				elsif sectorBuffer(byte_index)="00001011" then
					fat_FSType <= FAT32;
					byte_index <= byte_index + 4;
					DASD_state <= fat_foundPartition;
				elsif byte_index=16#1f2# then
					fat_FSType <= None;
					fat_Error <= fatE_NoPartition;
--					DASD_state <= fat_return_state;
				else
					byte_index <= byte_index + 16;
				end if;

				-- Look up partition start and size, byte index is 1X6 (buffer[8])
				-- buffer[8,9,10,11] is start offset
				-- buffer[12,13,14,15] is length
			when fat_foundPartition =>
				fat_partitionStartSector <= sectorBuffer(byte_index) & fat_partitionStartSector(31 downto 8);
				byte_index <= byte_index + 1;
				if STD_MATCH(STD_LOGIC_VECTOR(to_unsigned(byte_index,9)),"-----1001") then
					DASD_state <= fat_foundPartition_2;
				end if;

			when fat_foundPartition_2 =>
				fat_partitionLength <= sectorBuffer(byte_index) & fat_partitionLength(31 downto 8);
				byte_index <= byte_index + 1;
				if STD_MATCH(STD_LOGIC_VECTOR(to_unsigned(byte_index,9)),"-----1101") then
					DASD_state <= fat_readPartitionBootSector;
				end if;

			when fat_readPartitionBootSector =>
				 fat_CurrentSector <= fat_PartitionStartSector;
				 sd_return_state <= fat_parseBootSector;
				 DASD_state <= sd_ReadSector;

			when fat_parseBootSector =>
				byte_index <= 11;
				DASD_state <= fat_checkBPS;
				
			when fat_checkBPS =>
				-- Check that sector size = 512, can't cope with anything else
				byte_index <= byte_index + 1; -- 12
				if sectorBuffer(byte_index)/="00000000" then -- Check BPB(11)
--					DASD_state <= fat_UnusablePartition;
				else
					DASD_state <= fat_checkBPS_2;
				end if;
				
			when fat_checkBPS_2 =>
				byte_index <= byte_index + 1; -- 13
				if sectorBuffer(byte_index)/="00000010" then -- Check BPB(12) = 02 (512 bytes)
--					DASD_state <= fat_UnusablePartition;
				else
					DASD_state <= fat_getSectorsPerCluster;
				end if;
			
			when fat_getSectorsPerCluster =>
				-- Read in sectors-per-cluster, must be 1,2,4,8,16,32,64
				fat_SectorsPerCluster <= sectorBuffer(byte_index);
				fat_ClusterMask <= "000000";
				fat_clusterSize <= 0;
				DASD_state <= fat_calcClusterSize;
			
			when fat_calcClusterSize =>
				-- Can't be 128 as that would be a 64k cluster size, and 32k is the maximum
				-- Convert 1,2,4,8,16,32,64 to 0,1,2,3,4,5,6
				if fat_SectorsPerCluster(fat_ClusterSize) = '1' then
					DASD_state <= fat_getReservedSectors;
					byte_index <= byte_index + 1; -- 14
				elsif fat_ClusterSize=6 then
--					DASD_state <= fat_UnusablePartition;
				else
					fat_ClusterSize <= fat_ClusterSize + 1; -- 1,2,3,4,5,6
					fat_ClusterMask <= fat_ClusterMask(4 downto 0) & '1'; -- 1,3,7,15,31,63
				end if;
				
			when fat_getReservedSectors =>
				-- Number of sectors from start of partition to first FAT
				byte_index <= byte_index + 1; -- 15,16
				fat_ReservedSectors <= sectorBuffer(byte_index) & fat_ReservedSectors(15 downto 8); -- 14,15
				if byte_index=15 then
					DASD_state <= fat_getFATCopies;
				end if;

			when fat_getFATCopies =>
				-- Do FAT Offset calculation
				fat_FAT_StartSector <= fat_PartitionStartSector + fat_ReservedSectors;
				-- Number of copies of the FAT, needed to calculate start of data area
				byte_index <= byte_index + 1; -- 17
				fat_FATCopies <= sectorBuffer(byte_index);
				DASD_state <= fat_getRootCount;
		
			when fat_getRootCount =>
				-- Number of entries in the root directory for FAT16
				fat_RootCount <= sectorBuffer(byte_index) & fat_RootCount(15 downto 8); -- 17,18
				if byte_index=18 then
					if fat_FSType=FAT16 then
						byte_index <= byte_index + 4; -- 22
						DASD_state <= fat_getFATSize16;
					else
						byte_index <= byte_index + 18; -- 36
						DASD_state <= fat_getFATSize32;
					end if;
				else
					byte_index <= byte_index + 1; -- 18
				end if;
				
			when fat_getFATSize16 =>
				-- Size of FAT in sectors (for FAT16 only)
				byte_index <= byte_index + 1; -- 23,24
				fat_FATSize <= sectorBuffer(byte_index) & fat_FATSize(31 downto 8); -- 22,23
				if byte_index=23 then
					DASD_state <= fat_getFATSize16_2;
				end if;
			
			when fat_getFATSize16_2 =>
				fat_RootDirSector <= fat_FAT_StartSector;
				-- Shift FATSize right 16 bits
				byte_index <= byte_index + 1; -- 25,26
				fat_FATSize <= "00000000" & fat_FATSize(31 downto 8);
				if byte_index=25 then
					byte_index <= 1;
					DASD_state <= fat_FindRootDir16;
				end if;
			
-- FAT16: Compute rootDirOffset = FAToffset + FATcopies*sectorsPerFAT, clusterZeroOffset = rootDirOffset + maxRootEntries*32
			when fat_FindRootDir16 =>
				byte_index <= byte_index + 1;
				fat_RootDirSector <= fat_RootDirSector + fat_FATSize;
				if byte_index = FAT_FATCopies then
					DASD_state <= fat_CalcClusterZero16;
				end if;

			when fat_CalcClusterZero16 =>
				-- ClusterZeroSector <= RootDirSector + roundup(RootCount / 16) - 2 * SectorsPerCluster
				-- Note: The first cluster after the root directory is Cluster 2, so we adjust back to a notional Cluster 0
				-- Or-ing the bottom 4 bits of the RootCount performs the roundup() operation
				fat_ClusterZeroSector <= fat_RootDirSector
					+ ("00000000" & "00000000" & "0000" & fat_RootCount(15 downto 4))
					+ ("00000000" & "00000000" & "00000000" & "0000000" & (fat_RootCount(3) or fat_RootCount(2) or fat_RootCount(1) or fat_RootCount(0)))
					- ("00000000" & "00000000" & "0000000" & fat_SectorsPerCluster & '0');
				DASD_state <= fat_FindFiles16;
			
-- FAT32: Compute clusterZeroOffset = FAToffset - 2 * sectorsPerCluster, will add on FAT size later
-- Read in FATSize (4 bytes)
			when fat_getFATSize32 =>
				fat_ClusterZeroSector <= fat_FAT_StartSector
					- ("00000000" & "00000000" & "0000000" & fat_SectorsPerCluster & '0');
				-- Size of FAT in sectors (for FAT32 only)
				fat_FATSize <= sectorBuffer(byte_index) & fat_FATSize(31 downto 8); -- 36,37,38,39
				if byte_index=39 then
					DASD_state <= fat_getRootCluster32;
					byte_index <= byte_index + 5; -- 44
				else
					byte_index <= byte_index + 1; -- 37,38,39
				end if;
				
			when fat_getRootCluster32 =>
				fat_RootCluster <= sectorBuffer(byte_index) & fat_RootCluster(31 downto 8); -- 44,45,46,47
				if byte_index=47 then
					byte_index <= 1;
					DASD_state <= fat_FindClusterZero32;
				else
					byte_index <= byte_index + 1; -- 45,46,47
				end if;

-- FAT32: Compute clusterZeroOffset = FAToffset - 2 * sectorsPerCluster + FATcopies*sectorsPerFAT
			when fat_FindClusterZero32 =>
				byte_index <= byte_index + 1;
				fat_ClusterZeroSector <= fat_ClusterZeroSector + fat_FATSize;
				if byte_index = FAT_FATCopies then
					DASD_state <= fat_FindRootDir32;
				end if;

			when fat_FindRootDir32 =>
				fat_RootDirSector <= fat_ClusterZeroSector + STD_LOGIC_VECTOR(unsigned(fat_RootCluster) sll fat_ClusterSize);
				DASD_state <= fat_FindFiles32;

			when fat_UnusablePartition =>
				fat_Error <= fatE_UnusablePartition;
				fat_FSType <= None;
				DASD_state <= fat_return_state;

			when fat_FindFiles16 =>
				-- Read first directory sector into SectorBuffer
				 fat_CurrentSector <= fat_RootDirSector;
				 sd_return_state <= fat_ScanDirSector;
				 DASD_state <= sd_ReadSector; -- Sets byte_index to 0
				 
			when fat_FindFiles32 =>
				-- Read first directory sector into SectorBuffer
				fat_CurrentCluster <= fat_RootCluster;
				fat_CurrentClusterSector <= "000000";
				DASD_state <= fat_ScanDir32ReadSector;

			when fat_ScanDir32ReadSector =>
				fat_CurrentSector <= fat_ClusterZeroSector + shiftBVLeft(fat_currentCluster,fat_clusterSize) + fat_currentClusterSector;
				-- Assume root dir is one cluster giving SectorsPerCluster * 16 entries (e.g. 256 or 512)
				fat_RootCount <= "0000" & fat_SectorsPerCluster & "0000";
				sd_return_state <= fat_ScanDirSector;
				DASD_state <= sd_ReadSector;

			when fat_ScanDirSector =>
				fat_RootCount <= fat_RootCount - x"0001";
				if sectorBuffer(byte_index)=x"00" or fat_RootCount=x"0000" then
					DASD_state <= fat_ScanDirFinished;
				elsif sectorBuffer(byte_index)=x"E5" then
					-- Deleted directory entry - skip on
					DASD_state <= fat_ScanDirNextEntry;
				else
					byte_index <= byte_index + 8; -- Point to extension e.g. "190"
					DASD_state <= fat_ScanDirSector_1;
				end if;
				
			when fat_ScanDirSector_1 =>
				-- Check for digit
				if Hex_to_Int(sectorBuffer(byte_index))<16 then
					byte_index <= byte_index + 1; -- On to second character of extension
					DASD_state <= fat_ScanDirSector_2;
				else
					DASD_state <= fat_ScanDirNextEntry;
				end if;
				
			when fat_ScanDirSector_2 =>
				-- Check for digit
				if Hex_to_Int(sectorBuffer(byte_index))<16 then
					byte_index <= byte_index + 1; -- On to third character of extension
					DASD_state <= fat_ScanDirSector_3;
				else
					DASD_state <= fat_ScanDirNextEntry;
				end if;
				
			when fat_ScanDirSector_3 =>
				-- Check for digit
				if Hex_to_Int(sectorBuffer(byte_index))<16 then
					driveNumber <= Hex_to_Int(sectorBuffer(byte_index));
					byte_index <= byte_index + 1; -- On to attribute byte
					DASD_state <= fat_ScanDirSector_4;
				else
					DASD_state <= fat_ScanDirNextEntry;
				end if;
				
			when fat_ScanDirSector_4 =>
				-- Check attribute byte indicates a usable file
				if std_match(sectorBuffer(byte_index),"---0000-") then -- Not DIR,VOLID,SYS or HIDDEN
					byte_index <= byte_index + 10; -- 21 = Cluster Hi word (high byte)
					DASD_state <= fat_ScanDirSector_5;
				else
					DASD_state <= fat_ScanDirNextEntry;
				end if;
				
			when fat_ScanDirSector_5 =>
				fat_FirstClusterIndex(DriveNumber) <= fat_FirstClusterIndex(DriveNumber)(23 downto 0) & sectorBuffer(byte_index);
				byte_index <= byte_index - 1; -- 20 = Cluster Hi word (low byte)
				DASD_state <= fat_ScanDirSector_6;
				
			when fat_ScanDirSector_6 =>
				fat_FirstClusterIndex(DriveNumber) <= fat_FirstClusterIndex(DriveNumber)(23 downto 0) & sectorBuffer(byte_index);
				byte_index <= byte_index + 7; -- 28 = Cluster Lo word (high byte)
				DASD_state <= fat_ScanDirSector_7;
				
			when fat_ScanDirSector_7 =>
				fat_FirstClusterIndex(DriveNumber) <= fat_FirstClusterIndex(DriveNumber)(23 downto 0) & sectorBuffer(byte_index);
				byte_index <= byte_index - 1; -- 27 = Cluster Lo word (low byte)
				DASD_state <= fat_ScanDirSector_8;
				
			when fat_ScanDirSector_8 =>
				-- Fill in last byte of start cluster
				fat_FirstClusterIndex(DriveNumber) <= fat_FirstClusterIndex(DriveNumber)(23 downto 0) & sectorBuffer(byte_index);
				DASD_state <= fat_ScanDirSector_9;
				
			when fat_ScanDirSector_9 =>
				-- Check that the first cluster is non-0 (check for zero-length file)
				-- Then check that the file starts with "CKD_P"
				-- Temporary
--				fat_CurrentTrackFirstCluster(DriveNumber) <= fat_FirstClusterIndex(DriveNumber);
				fat_CurrentTrackFirstSector(DriveNumber) <= "000000";
				fat_CurrentTrackStartByte(DriveNumber) <= "000000000";
--				fat_CurrentTrackFirstSector(DriveNumber) <= fat_ClusterZeroSector + STD_LOGIC_VECTOR(unsigned(fat_FirstClusterIndex(DriveNumber)) sll fat_ClusterSize);
				DASD_state <= fat_ScanDirNextEntry;

			when fat_ScanDirNextEntry =>
				byte_index <= conv_integer(STD_LOGIC_VECTOR(to_unsigned(byte_index+32,9)) and "111100000"); -- On to next entry
				if (STD_LOGIC_VECTOR(to_unsigned(byte_index+32,9)) and "111100000") = "000000000" then
					DASD_state <= fat_ScanDirNextSector;
				else
					DASD_state <= fat_ScanDirSector;
				end if;
				
			when fat_ScanDirNextSector =>
				fat_CurrentSector <= fat_CurrentSector + x"00000001";
				sd_return_state <= fat_ScanDirSector;
				DASD_state <= sd_ReadSector;
			
			when fat_ScanDirFinished =>
				DASD_state <= fat_return_state;
				

-- Things we haven't bothered doing:		
-- Compute dataSectorCount = sectorCount - reservedSectors - sectorsPerFAT32*FATcopies - roundUp(maxRootEntries*32/bytesPerSector)
-- Compute dataClusterCount = dataSectorCount / sectorsPerCluster
-- Work out FS type (FAT16,32)
-- Compute FATsize = (dataClusterCount+2)*(FS==FAT16?2:4)

			when fat_fileOffsetToClusterSectorOffset =>
				-- Convert DriveNumber, fileOffset to Cluster, Sector and Offset
				fat_clusterCounter <= fat_fileOffset(24+fat_ClusterSize downto 9+fat_ClusterSize);
				fat_currentFileCluster <= fat_fileOffset(24+fat_ClusterSize downto 9+fat_ClusterSize);
				fat_currentClusterSector <= fat_fileOffset(14 downto 9) and fat_clusterMask; -- 0 to SectorsPerCluster-1
				fat_currentSectorByte <= fat_fileOffset(8 downto 0); -- 0 to 511
				-- Now convert fat_currentFileCluster to fat_CurrentCluster by iteratively looking up FAT
				fat_currentCluster <= fat_firstClusterIndex(DriveNumber); -- Start here
				DASD_state <= fat_fileOffsetToClusterSectorOffset_2;
				
			when fat_fileOffsetToClusterSectorOffset_2 =>
				if fat_currentCluster=x"00000000" then
					-- Empty file
					DASD_state <= fat_fileOffsetToClusterSectorOffset_5;
				elsif fat_clusterCounter=x"0000" then
					-- Have the cluster number we want
					DASD_state <= fat_fileOffsetToClusterSectorOffset_4;
				else
					-- Calculate FAT sector from cluster number - 256 clus/sec for FAT16, 128 clus/sec for FAT32
					if fat_FSType=FAT16 then
						if fat_currentCluster(15 downto 3)="1111111111111" then
						-- End of chain x"FFF8" to x"FFFF"
							DASD_state <= fat_fileOffsetToClusterSectorOffset_5;
						else
							newSector := ("00000000" & fat_currentCluster(31 downto 8)) + fat_FAT_StartSector;
							if fat_currentFATSector = (("00000000" & fat_currentCluster(31 downto 8)) + fat_FAT_StartSector) then
								fat_CurrentCluster <= x"00000000";
								byte_index <= conv_integer(fat_currentCluster(7 downto 0) & '1');
								DASD_state <= fat_fileOffsetToClusterSectorOffset_3;
							else
								-- Read in new FAT sector then come back here
								fat_currentFATSector <= (("00000000" & fat_currentCluster(31 downto 8)) + fat_FAT_StartSector);
								sd_return_state <= fat_fileOffsetToClusterSectorOffset_7;
								DASD_state <= sd_ReadFATSector;
							end if;
						end if;
					else -- FAT32
						if fat_currentCluster(27 downto 3)="1111111111111111111111111" then
						-- End of chain x"-FFFFFF8" to x"-FFFFFFF"
							DASD_state <= fat_fileOffsetToClusterSectorOffset_5;
						else
							newSector := ("0000000" & fat_currentCluster(31 downto 7)) + fat_FAT_StartSector;
							if fat_currentFATSector = newSector then
								fat_CurrentCluster <= x"00000000";
								byte_index <= conv_integer(fat_currentCluster(6 downto 0) & "11");
								DASD_state <= fat_fileOffsetToClusterSectorOffset_3;
							else
								-- Read in new FAT sector then come back here
								fat_currentFATSector <= newSector;
								sd_return_state <= fat_fileOffsetToClusterSectorOffset_7;
								DASD_state <= sd_ReadFATSector;
							end if;
						end if;
					end if;
				end if;
				
			when fat_fileOffsetToClusterSectorOffset_3 =>
				-- Copy 2 or 4 bytes into fat_currentCluster, then decrement currentFileCluster
				fat_currentCluster <= fat_currentCluster(23 downto 0) & FATBuffer(byte_index);
				if ((fat_FSType=FAT16) and ((byte_index mod 2)=0)) or ((byte_index mod 4)=0) then
					-- Done all 2 or 4 bytes - decrement currentFileCluster and see if we've got to our cluster
					fat_clusterCounter <= fat_clusterCounter - x"0001";
					DASD_state <= fat_fileOffsetToClusterSectorOffset_2;
				end if;
				byte_index <= byte_index - 1;
			
			
			when fat_fileOffsetToClusterSectorOffset_4 =>
				-- Now convert fat_currentCluster & fat_currentClusterSector to fat_currentSector
				newSector := fat_ClusterZeroSector + shiftBVLeft(fat_currentCluster,fat_clusterSize) + fat_currentClusterSector;
				
				-- Now read the sector
				if fat_currentSector = newSector then
					-- Already have it
					DASD_state <= fat_fileOffsetToClusterSectorOffset_6;
				else
					fat_currentSector <= newSector;
					sd_return_state <= fat_fileOffsetToClusterSectorOffset_6;
					DASD_state <= sd_ReadTrack;
				end if;
				
			when fat_fileOffsetToClusterSectorOffset_5 =>
				-- Past end of file
				fat_currentSector <= x"FFFFFFFF";
				DASD_state <= fat_return_state;
			
			when fat_fileOffsetToClusterSectorOffset_6 =>
				byte_index <= conv_integer(fat_currentSectorByte);
				byte_counter <= trackBufferSize - conv_integer(fat_currentSectorByte);
				if fat_currentSector = x"FFFFFFFF" then
					fat_Error <= fatE_ReadError;
				else
					fat_Error <= fatE_None;
				end if;
				DASD_state <= fat_return_state;
				
			when fat_fileOffsetToClusterSectorOffset_7 =>
				-- Check for FAT read error
				if fat_currentFATSector = x"FFFFFFFF" then
					fat_Error <= fatE_FATReadError;
					DASD_state <= fat_return_state;
				else
					DASD_state <= fat_fileOffsetToClusterSectorOffset_2;
				end if;
				
		end case;
	end if;
end process dasd;

-- SD card via SPI
sd_access : sd_controller port map(
	cs => cs,
	mosi => mosi,
	miso => miso,
	sclk => sclk,
	card_present => '1',
	card_write_prot => '0',
	
	rd => sd_rd,
	rd_multiple => sd_rd_multiple,
	wr => sd_wr,
	wr_multiple => '0',
	addr => sd_block_address,
	reset => sd_reset,
	sd_busy => sd_busy,
	sd_error => sd_error,
	sd_error_code => sd_error_code,
	dout => sd_data_in,
	dout_avail => sd_data_avail,
	dout_taken => sd_data_taken,
	din => sd_data_out,
	din_valid => sd_dout_avail,
	din_taken => sd_dout_taken,
	clk => clk,
	sd_type => sd_card_type,
	sd_fsm => sd_fsm_state
);

-- Debug stuff
with DEBUG.Selection select
	DEBUG.Probe <=
		'1' when others;
		
with DASD_state select DASD_state_vector <= 
	 x"00" when dev_reset,
	 x"01" when dev_reset2,
	 x"02" when dev_deselected,
	 x"03" when dev_check_device,
	 x"03" when dev_wait_for_command_file_ok,
	 x"03" when dev_wait_for_command_file_bad,
	 x"04" when dev_got_command,
	 x"05" when dev_tio_command,
	 x"06" when dev_initial_device_end,
	 x"07" when dev_present_status,
	 x"08" when dev_present_status_2,
	 x"09" when dev_present_status_3,
--	 x"0a" when dev_present_status_4,
	 x"0b" when dev_stack_status,
	 x"0c" when dev_stack_status_2,
	 x"0d" when dev_disconnect,
	 x"0f" when dev_present_CE_DE,
	 x"11" when dev_read_data_command,
	 x"12" when dev_read_data_command_2,
	 x"13" when dev_read_data_command_3,
	 x"14" when dev_read_data_command_4,
	 x"15" when dev_read_data_command_5,
	 x"16" when dev_read_data_command_6,
	 x"17" when dev_read_raw_command,
	 x"18" when dev_read_raw_command_2,
	 x"21" when dev_seek_command,
	 x"22" when dev_seek_command_2,
	 x"23" when dev_seek_command_3,
	 x"24" when dev_seek_command_4,
	 x"31" when dev_ipl_command,
	 x"32" when dev_ipl_command_2,
	 x"33" when dev_ipl_command_3,
	 x"41" when dev_sense_command,
	 x"42" when dev_sense_command_2,
	 x"43" when dev_sense_command_3,
	 x"44" when dev_sense_command_4,
	 x"45" when dev_sense_command_5,
	 x"46" when dev_sense_command_6,
	 x"47" when dev_sense_command_7,
	 x"51" when dev_write_data_command,
	 x"52" when dev_write_data_command_2,
	 x"53" when dev_write_data_command_3,
	 x"54" when dev_write_data_command_4,
	 x"55" when dev_write_data_command_5,
	 x"56" when dev_write_data_command_6,
	 x"80" when sd_ReadSector,
	 x"80" when sd_ReadFatSector,
	 x"80" when sd_ReadTrack,
	 x"81" when sd_ReadSectorGetByte,
	 x"82" when sd_FillSector,
	 x"82" when sd_FillSector_2,
	 x"83" when sd_ReadSectorComplete,
	 x"84" when sd_ReadSectorGotLastByte,
	 x"85" when sd_ReadSectorGotByte,
	 x"90" when sd_WriteSector,
	 x"91" when sd_WriteSectorPutByte,
	 x"92" when sd_WriteSectorComplete,
	 x"93" when sd_WriteSectorAckLastByte,
    x"94" when sd_WriteSectorAckByte,
	 x"A0" when fat_InitPartition,
	 x"A1" when fat_FindPartition,
	 x"A2" when fat_FindPartition_2,
	 x"A3" when fat_FindPartition_3,
	 x"A4" when fat_CheckForPartition,
	 x"A5" when fat_FoundPartition,
	 x"A6" when fat_FoundPartition_2,
	 x"A7" when fat_ReadPartitionBootSector,
	 x"A8" when fat_ParseBootSector,
	 x"A9" when fat_checkBPS,
	 x"AA" when fat_checkBPS_2,
	 x"AB" when fat_getSectorsPerCluster,
	 x"AB" when fat_CalcClusterSize,
	 x"AC" when fat_getReservedSectors,
	 x"AD" when fat_getFATCopies,
	 x"AE" when fat_getRootCount,
	 x"AF" when fat_getFATSize16,
	 x"B0" when fat_getFATSize16_2,
	 x"B1" when fat_FindRootDir16,
	 x"B2" when fat_CalcClusterZero16,
	 x"B3" when fat_getFATSize32,
	 x"B4" when fat_getRootCluster32,
	 x"B5" when fat_FindClusterZero32,
	 x"B6" when fat_FindRootDir32,
	 x"B7" when fat_FindFiles16,
	 x"B8" when fat_FindFiles32,
	 x"B9" when fat_ScanDir32ReadSector,
	 x"BF" when fat_UnusablePartition,
	 x"C0" when fat_ScanDirSector,
	 x"C1" when fat_ScanDirSector_1,
	 x"C2" when fat_ScanDirSector_2,
	 x"C3" when fat_ScanDirSector_3,
	 x"C4" when fat_ScanDirSector_4,
	 x"C5" when fat_ScanDirSector_5,
	 x"C6" when fat_ScanDirSector_6,
	 x"C7" when fat_ScanDirSector_7,
	 x"C8" when fat_ScanDirSector_8,
	 x"C9" when fat_ScanDirSector_9,
    x"CB" when fat_ScanDirNextEntry,
	 x"CC" when fat_ScanDirNextSector,
	 x"CD" when fat_ScanDirFinished,
	 x"D0" when fat_fileOffsetToClusterSectorOffset,
	 x"D2" when fat_fileOffsetToClusterSectorOffset_2,
	 x"D3" when fat_fileOffsetToClusterSectorOffset_3,
	 x"D4" when fat_fileOffsetToClusterSectorOffset_4,
	 x"D5" when fat_fileOffsetToClusterSectorOffset_5,
	 x"D6" when fat_fileOffsetToClusterSectorOffset_6,
	 x"D7" when fat_fileOffsetToClusterSectorOffset_7,
	 x"F0" when dev_bus_out_parity,
	 x"F1" when dev_unit_check,
	 x"F2" when dev_invalid_command
		;

with DEBUG.Selection select
DEBUG.SevenSegment <=
	sd_rd & sd_rd_multiple & sd_wr & sd_wr_multiple & "0" & SD_Error_Code & DASD_State_vector when 2,
  	sd_data_in & sd_fsm_state when 3,
	fat_PartitionStartSector(15 downto 0) when 6,
	fat_PartitionLength(15 downto 0) when 7,
	STD_LOGIC_VECTOR(to_unsigned(t_FSType'pos(fat_FSType),8)) & STD_LOGIC_VECTOR(to_unsigned(t_fatError'pos(fat_Error),8)) when 8,
	STD_LOGIC_VECTOR(to_unsigned(byte_index,8)) & sectorBuffer(byte_index) when 9,
	fat_currentCluster(31 downto 16) when 10,
	fat_currentCluster(15 downto 0) when 11,
	fat_currentFileCluster(7 downto 0) & "00" & fat_CurrentClusterSector when 12,
	fat_CurrentSector(15 downto 0) when 13,
	fat_CurrentSector(31 downto 16) when 14,
	fat_CurrentFATSector(15 downto 0) when 15,
	"1111111111111111" when others;
END behavioural; 
