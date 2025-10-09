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


entity storage is
    Port ( -- Physical storage I/O from FPGA (S3BOARD)
--				phys_address : out std_logic_vector(16 downto 0);
--				phys_data : inout std_logic_vector(8 downto 0);
--				phys_CE : out std_logic;
--				phys_OE : out std_logic;
--				phys_WE : out std_logic;
--				phys_UB,phys_LB : out std_logic;

				-- Other inputs
				clk : in STD_LOGIC; -- 50MHz
				
				-- Interface to config ROM (S3BOARD)
				din : in STD_LOGIC;
				reset_prom : out STD_LOGIC;
				cclk : out STD_LOGIC;
				
				-- Inteface to AXI (ZYBO)
				-- Address bram1 00000-0FFFF are main storage (64k)
				--               10000-17FFF is extension storage (32k) if used
				--         bram2 000-7FF is local storage (2k)
				bram1 : in BRAM1_PORT;
				bram1_rddata : out std_logic_vector(31 downto 0);
				bram2 : in BRAM2_PORT;
				bram2_rddata : out std_logic_vector(31 downto 0);
--				bram_addr : in std_logic_vector(17 downto 0);
--				bram_clk : in std_logic;
--				bram_wrdata : in std_logic_vector(31 downto 0);
--				bram_rddata : out std_logic_vector(31 downto 0);
--				bram_en : in std_logic;
--				bram_rst : in std_logic;
--				bram_we : in std_logic_vector(3 downto 0);

				-- Storage interface to CPU
				StorageIn : out STORAGE_IN_INTERFACE;
				StorageOut : in STORAGE_OUT_INTERFACE;
				debug : out STD_LOGIC
           );
end storage;

architecture DigilentZybo of storage is

COMPONENT blk_mem_2k_9
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
  );
END COMPONENT;

COMPONENT blk_mem_64k_9
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
  );
END COMPONENT;

signal MS_RDDATA, MS_RDDATA_0, MS_RDDATA_1, MS_WRDATA, LS_RDDATA, LS_WRDATA : std_logic_vector(0 to 8);
signal MS_EN, MS_WE : std_logic;
signal LS_EN, LS_WE : std_logic;
signal MS_ADDR : std_logic_vector(1 to 16); -- 64k range
signal LS_ADDR : std_logic_vector(1 to 11); -- 2k range
signal AXI1_with_Parity, AXI2_with_Parity : std_logic_vector(35 downto 0);
signal MS_Data : std_logic_vector(35 downto 0);
signal LS_Data : std_logic_vector(35 downto 0);

begin

MS_RDDATA <= MS_RDDATA_0 when StorageOut.MSAR(0)='0' else MS_RDDATA_1;
StorageIn.ReadData <= MS_RDDATA when StorageOut.MainStorage='1' else LS_RDDATA;

MS_WRDATA <= StorageOut.WriteData;
MS_EN <= storageOut.MainStorage and (StorageOut.ReadPulse or StorageOut.WritePulse);
MS_WE <= StorageOut.MainStorage and StorageOut.WritePulse;
MS_ADDR <= StorageOut.MSAR(0 to 15);

LS_WRDATA <= StorageOut.WriteData;
LS_EN <= not StorageOut.MainStorage and (StorageOut.ReadPulse or StorageOut.WritePulse);
LS_WE <= not StorageOut.MainStorage and StorageOut.WritePulse;
LS_ADDR <= StorageOut.MSAR(1 to 3) & StorageOut.MSAR(8 to 15);

-- Converting 9b bytes to/from 32b for AXI
-- Generate parity during writes
-- Is the parity vector the right way around? See Table 1-16 in the BRAM document UG473
AXI1_with_Parity <= 
      EvenParity(bram1.wrdata(31 downto 24)) & bram1.wrdata(31 downto 24)
    & EvenParity(bram1.wrdata(23 downto 16)) & bram1.wrdata(23 downto 16)
    & EvenParity(bram1.wrdata(15 downto  8)) & bram1.wrdata(15 downto  8)
    & EvenParity(bram1.wrdata( 7 downto  0)) & bram1.wrdata( 7 downto  0);
AXI2_with_Parity <= 
      EvenParity(bram2.wrdata(31 downto 24)) & bram2.wrdata(31 downto 24)
    & EvenParity(bram2.wrdata(23 downto 16)) & bram2.wrdata(23 downto 16)
    & EvenParity(bram2.wrdata(15 downto  8)) & bram2.wrdata(15 downto  8)
    & EvenParity(bram2.wrdata( 7 downto  0)) & bram2.wrdata( 7 downto  0);
-- Strip parity during reads
bram1_rddata <= MS_Data(34 downto 27) & MS_Data(25 downto 18) & MS_Data(16 downto 9) & MS_Data(7 downto 0);
bram2_rddata <= LS_Data(34 downto 27) & LS_Data(25 downto 18) & LS_Data(16 downto 9) & LS_Data(7 downto 0);

MainStorage: blk_mem_64k_9
    port map(
        CLKA => clk,
        ADDRA => MS_ADDR,
        ENA => MS_EN, WEA(0) => MS_WE, 
        DINA => MS_WRDATA,-- DIADI(31 downto 1) => (others=>'0'),
        DOUTA => MS_RDDATA,-- DOADO(31 downto 1) => open,
        -- AXI ports
        CLKB => bram1.clk,
        DINB => AXI1_with_Parity,
        DOUTB => MS_Data, -- We ignore parity on reads
        ADDRB => bram1.addr,
        ENB => bram1.en,
        WEB => bram1.we    );
    
LocalStorage: blk_mem_2k_9
    port map (
        CLKA => clk,
        ADDRA => LS_ADDR,
        ENA => LS_EN, WEA(0) => LS_WE,
        DINA => LS_WRDATA,
        DOUTA => LS_RDDATA,
        -- AXI ports
        CLKB => bram2.clk,
        DINB => AXI2_with_Parity,
        DOUTB => LS_Data,
        ADDRB => bram2.addr,
        ENB => bram2.en,
        WEB => bram2.we    );
  
end DigilentZybo;

