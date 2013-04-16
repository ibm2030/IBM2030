---------------------------------------------------------------------------
--    Copyright © 2010 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: FMD2030_5-01C-D.vhd
--    Creation Date: 
--    Description:
--    CCROS storage, SALS (Sense Amplifier Latches), CTRL register
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-13
--    Initial Release
--    
--
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE std.textio.all;

library work;
use work.Gates_package.all;
use work.Buses_package.all;

ENTITY CCROS IS 
	port
	(
		-- Inputs
		WX : IN STD_LOGIC_VECTOR(0 to 12);  -- 01B
		MACH_RST_SW : IN STD_LOGIC;         -- 03D
		MANUAL_STORE : IN STD_LOGIC;        -- 03D
		ANY_PRIORITY_LCH : IN STD_LOGIC;    -- 03A
		COMPUTE : IN STD_LOGIC;             -- 04D
		MACH_RST_MPX : IN STD_LOGIC;        -- 08C

		CROS_STROBE : IN STD_LOGIC;         -- 01B
		CROS_GO_PULSE : IN STD_LOGIC;       -- 01B

		-- Outputs
		SALS: OUT SALS_Bus;
		CTRL : OUT CTRL_REG;
		CTRL_REG_RST : OUT STD_LOGIC;            -- 07B
		CK_SAL_P_BIT_TO_MPX : OUT STD_LOGIC;        -- ?

		-- Clocks
		T1 : IN STD_LOGIC;
		P1 : IN STD_LOGIC;
		Clk : IN STD_LOGIC		-- 50MHz
	);
END CCROS;

ARCHITECTURE FMD OF CCROS IS 

subtype CCROS_Address_Type is integer range 0 to 4095;
subtype CCROS_Word_Type is std_logic_vector(0 to 54);
type CCROS_Type is array(CCROS_Address_Type) of CCROS_Word_Type;
impure function readCCROS return CCROS_Type is

	variable fileCCROS : CCROS_Type := (others => (others => '0'));
	variable Cline : line;
	variable addr : natural;
	variable CCROSaddr : CCROS_Address_Type;
	file CCROS_lines : text open read_mode is "ccros20100715.txt";

	function fmHex(c : in character) return integer is
	  begin
	  if (c>='0') and (c<='9') then return character'pos(c)-character'pos('0');
	  elsif (c>='A') and (c<='F') then return character'pos(c)-character'pos('A')+10;
	  elsif (c>='a') and (c<='f') then return character'pos(c)-character'pos('a')+10;
	  else 
	  	report "Invalid hex address:" & c severity note;
		return 0;
	  end if;
	  end;

	function fmBin(c : in character) return STD_LOGIC is
	  begin
	  if c='0' then return '0';
	  elsif c='1' then return '1';
	  elsif c='?' then return '0';
	  else
	  	report "Invalid bit:" & c severity note;
		return '0';
	  end if;
	  end;

	-- parity() function returns 1 if the vector has even parity
	function parity(v : STD_LOGIC_VECTOR) return STD_LOGIC is
	variable p : STD_LOGIC;
		begin
			p := '1';
			for i in v'range loop
				p := p xor v(i);
			end loop;
			return p;
		end;
		
	function toString(v : STD_LOGIC_VECTOR) return string is
	variable s : string(1 to 55);
		begin
		for i in v'range loop
			if v(i)='1' then s(i+1):='1';
			else s(i+1):='0'; end if;
		end loop;
		return s;
		end;

	variable char : character;
	variable field : integer;
	variable newC : CCROS_Word_Type;
	variable version : string(1 to 3);
	variable eol : boolean;
	variable cstr3 : string(1 to 3);
	variable cstr8 : string(1 to 8);
	variable cstr55 : string(1 to 55);
	begin
	for i in 1 to 8192 loop
		exit when endfile(CCROS_lines);
		readline(CCROS_lines,Cline);
		exit when endfile(CCROS_lines);
		-- 1-3 = address (hex)
		-- 5-6 = CN hex (ignore 2 lower bits)
		-- 8-11 = CH
		-- 13-16 = CL
		-- 18-20	= CM
		-- 22-23 = CU
		-- 25-28 = CA
		-- 30-31 = CB
		-- 33-36 = CK
		-- 38-41 = CD
		-- 43-45 = CF
		-- 47-48 = CG
		-- 50-51 = CV
		-- 53-55 = CC
		-- 57-60 = CS
		-- 62 = AA
		-- 64 = AS
		-- 66 = AK
		-- 68	= PK
--    File layout:		
--		#AAA  CN CH   CL   CM  CU CA   CB CK   CD   CF  CG CV CC  CS   AAASAKPK

		read(Cline,char);
		if char='#' then next; end if;
		addr := fmHex(char);
		cstr3(1) := char;
		read(Cline,char);	addr := addr*16+fmhex(char);
		cstr3(2) := char;
		read(Cline,char); addr := addr*16+fmhex(char);
		cstr3(3) := char;
		CCROSaddr := CCROS_Address_Type(addr);
--	report "Addr: " & cstr3 severity note;

		-- PN (0) omitted for now
		-- CN
--		read(Cline,char); -- 4
		read(Cline,char); field := fmHex(char);
		read(Cline,char); field := field*16+fmhex(char);
		field := field / 4;
		newC(1 to 6) := conv_std_logic_vector(field,6);
		-- PS (7) and PA (8) omitted for now
		-- CH
--		read(Cline,char);
		read(Cline,char);  newc( 9) := fmBin(char);
		read(Cline,char);  newc(10) := fmBin(char);
		read(Cline,char);  newc(11) := fmBin(char);
		read(Cline,char);  newc(12) := fmBin(char);
		-- CL
--		read(Cline,char);
		read(Cline,char);  newc(13) := fmBin(char);
		read(Cline,char);  newc(14) := fmBin(char);
		read(Cline,char);  newc(15) := fmBin(char);
		read(Cline,char);  newc(16) := fmBin(char);
		-- CM
--		read(Cline,char);
		read(Cline,char);  newc(17) := fmBin(char);
		read(Cline,char);  newc(18) := fmBin(char);
		read(Cline,char);  newc(19) := fmBin(char);
		-- CU
--		read(Cline,char);
		read(Cline,char);  newc(20) := fmBin(char);
		read(Cline,char);  newc(21) := fmBin(char);
 		-- CA
--		read(Cline,char);
		read(Cline,char);  newc(22) := fmBin(char);
		read(Cline,char);  newc(23) := fmBin(char);
		read(Cline,char);  newc(24) := fmBin(char);
		read(Cline,char);  newc(25) := fmBin(char);
 		-- CB
--		read(Cline,char);
		read(Cline,char);  newc(26) := fmBin(char);
		read(Cline,char);  newc(27) := fmBin(char);
  		-- CK
--		read(Cline,char);
		read(Cline,char);  newc(28) := fmBin(char);
		read(Cline,char);  newc(29) := fmBin(char);
		read(Cline,char);  newc(30) := fmBin(char);
		read(Cline,char);  newc(31) := fmBin(char);
		-- PK (32) and PC (33) omitted for now
		-- CD
--		read(Cline,char);
		read(Cline,char);  newc(34) := fmBin(char);
		read(Cline,char);  newc(35) := fmBin(char);
		read(Cline,char);  newc(36) := fmBin(char);
		read(Cline,char);  newc(37) := fmBin(char);
		-- CF
--		read(Cline,char);
		read(Cline,char);  newc(38) := fmBin(char);
		read(Cline,char);  newc(39) := fmBin(char);
		read(Cline,char);  newc(40) := fmBin(char);
		-- CG
--		read(Cline,char);
		read(Cline,char);  newc(41) := fmBin(char);
		read(Cline,char);  newc(42) := fmBin(char);
		-- CV
--		read(Cline,char);
		read(Cline,char);  newc(43) := fmBin(char);
		read(Cline,char);  newc(44) := fmBin(char);
		-- CC
--		read(Cline,char);
		read(Cline,char);  newc(45) := fmBin(char);
		read(Cline,char);  newc(46) := fmBin(char);
		read(Cline,char);  newc(47) := fmBin(char);
		-- CS
--		read(Cline,char);
		read(Cline,char);  newc(48) := fmBin(char);
		read(Cline,char);  newc(49) := fmBin(char);
		read(Cline,char);  newc(50) := fmBin(char);
		read(Cline,char);  newc(51) := fmBin(char);
		-- AA
--		read(Cline,char);
		read(Cline,char);  newc(52) := fmBin(char);
		-- AS
--		read(Cline,char);
		read(Cline,char);  newc(53) := fmBin(char);
		-- AK
--		read(Cline,char);
		read(Cline,char);  newc(54) := fmBin(char);
		-- PK
--		read(Cline,char);
		read(Cline,char);  newc(32) := fmBin(char);
		-- Now fill in PN,PA,PS,PC
		newc(0) := parity(newc(1 to 6)); -- PN = CN
		newc(8) := parity(CONV_STD_LOGIC_VECTOR(CCROSAddr,13)); -- PA = ADDR
--		if (newc(13 to 16)="0010") then
--			newc(32) := parity(newc(22 to 25)); -- PK = CA
--		else
--			newc(32) := parity(newc(28 to 31)); -- PK = CK
--		end if;
		newc(7) := parity(newc(8 to 32) & newc(52) & newc(54)); -- PS = PA CH CL CM CU CA CB CK PK AA AK
		newc(33) := parity(newc(34 to 51) & newc(53)); -- PC = CD CF CG CV CC CS AS

--		Bodge to generate incorrect parity for some locations
		if addr=unsigned'(x"BA0") then -- BA0 has parity change "7" = PS PA PC
--			newc(7) := not newc(7); -- Already doing PA so no need to flip PS
			newc(8) := not newc(8); -- PA
			newc(33) := not newc(33); -- PC
			end if;
		if addr=unsigned'(x"B60") then -- B60 has parity change "B" = PN PA PC
			newc(0) := not newc(0); -- PN
			newc(7) := not newc(7); -- Need to flip PS to keep it correct when PA is flipped
			newc(8) := not newc(8); -- PA
			newc(33) := not newc(33); -- PC
			end if;

		-- Skip over page/location
		read(Cline,char);read(Cline,cstr8);
--		report "Loc: " & cstr8 severity note;
--		for i in newC'range loop
--			if newC(i)='1' then
--				report "1" severity note;
--			else
--				report "0" severity note;
--			end if;
--		end loop;
		-- See if there is a version
		read(Cline,char,eol);
		read(Cline,version,eol);
		if char='-' then
--			report "Version: "&version severity note;
		else
			version := "   ";
		end if;
		
		-- Check for acceptable versions
		-- 000/Blank = Basic
		-- 004 = 64k
		-- 005 = 224UCWs
		-- 006 = Storage Protect
		-- 007 = Decimal Option
		-- 010 = 1050 Console
		-- 014 = Selector Channel #1
		-- 025 = 50Hz timer
		-- A20 = 64k + Storage Protect
		-- Omitted:
		-- 015 = Selector Channel 2
		-- 031 = ??
		-- 906 = Storage Protect Diagnostic
		-- 914 = Selector Channel Diagnostic
		-- 994 = ??
		-- 995 = Local Storage Dump
		-- 996 = Storage Diagnostic
		-- 997 = Mpx Diagnostic
		if version="   " or version="000" or version="004" or version="005" or version="006" or
		version="007" or version="010" or version="014" or version="025" or version="A20" then
			if fileCCROS(CCROSaddr) = (newC'range => '0') then
				fileCCROS(CCROSaddr) := newC;
			else
				report "Duplicate CCROS " & integer'image(CCROSAddr) & " Ver " & version severity note;
			end if;
		else
			report "CCROS " & integer'image(CCROSAddr) & " Ver " & version & " skipped" severity note;
		end if;
--		report "CCROS " & integer'image(CCROSAddr) & ": " & toString(newC);
		end loop;
	return fileCCROS;
	end;


signal SALS_Word : STD_LOGIC_VECTOR(0 to 54) := (others=>'1');

alias  SALS_PN : STD_LOGIC is SALS_Word(0);
alias  SALS_CN : STD_LOGIC_VECTOR(0 to 5) is SALS_Word(1 to 6);
alias  SALS_PS : STD_LOGIC is SALS_Word(7);
alias  SALS_PA : STD_LOGIC is SALS_Word(8);
alias  SALS_CH : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(9 to 12);
alias  SALS_CL : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(13 to 16);
alias  SALS_CM : STD_LOGIC_VECTOR(0 to 2) is SALS_Word(17 to 19);
alias  SALS_CU : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(20 to 21);
alias  SALS_CA : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(22 to 25);
alias  SALS_CB : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(26 to 27);
alias  SALS_CK : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(28 to 31);
alias  SALS_PK : STD_LOGIC is SALS_Word(32);
alias  SALS_PC : STD_LOGIC is SALS_Word(33);
alias  SALS_CD : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(34 to 37);
alias  SALS_CF : STD_LOGIC_VECTOR(0 to 2) is SALS_Word(38 to 40);
alias  SALS_CG : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(41 to 42);
alias  SALS_CV : STD_LOGIC_VECTOR(0 to 1) is SALS_Word(43 to 44);
alias  SALS_CC : STD_LOGIC_VECTOR(0 to 2) is SALS_Word(45 to 47);
alias  SALS_CS : STD_LOGIC_VECTOR(0 to 3) is SALS_Word(48 to 51);
alias  SALS_AA : STD_LOGIC is SALS_Word(52);
alias  SALS_SA : STD_LOGIC is SALS_Word(53);
alias  SALS_AK : STD_LOGIC is SALS_Word(54);

constant CCROS : CCROS_Type := readCCROS;

signal AUX_CTRL_REG_RST : STD_LOGIC;
signal SET_CTRL_REG : STD_LOGIC;
signal sCTRL : CTRL_REG;
signal sCTRL_REG_RST : STD_LOGIC;

signal CD_LCH_Set,CD_LCH_Reset,CS_LCH_Set,CS_LCH_Reset : STD_LOGIC_VECTOR(0 to 3);
signal STRAIGHT_LCH_Set,CROSSED_LCH_Set,CC2_LCH_Set,CC2_LCH_Reset,GTAHI_LCH_Set,GTAHI_LCH_Reset,
		GTALO_LCH_Set,GTALO_LCH_Reset,COMPCY_LCH_Set,COMPCY_LCH_Reset,CG0_Set,CG1_Set,CG_Reset : STD_LOGIC;
signal CV_LCH_Set,CV_LCH_Reset,CC01_LCH_Set,CC01_LCH_Reset : STD_LOGIC_VECTOR(0 to 1);
signal CROS_STROBE_DELAY : STD_LOGIC_VECTOR(1 to 5) := "00000";
BEGIN
-- Page 5-01C
sCTRL_REG_RST <= MACH_RST_SW or MANUAL_STORE or ANY_PRIORITY_LCH;
CTRL_REG_RST <= sCTRL_REG_RST;
AUX_CTRL_REG_RST <= T1 or sCTRL_REG_RST;
SET_CTRL_REG <= not ANY_PRIORITY_LCH and P1;

CD_LCH_Set <= SALS_CD and (0 to 3 => SET_CTRL_REG);
CD_LCH_Reset <= (0 to 3 => T1 or sCTRL_REG_RST);
CD_LCH: FLVL port map(CD_LCH_Set,CD_LCH_Reset,sCTRL.CTRL_CD); -- AA2C6

STRAIGHT_LCH_Set <= sCTRL_REG_RST or (SET_CTRL_REG and not SALS_CF(0));
STRAIGHT_LCH: FLL port map(STRAIGHT_LCH_Set, T1, sCTRL.STRAIGHT);
CROSSED_LCH_Set <= SET_CTRL_REG and SALS_CF(0);
CROSSED_LCH: FLL port map(CROSSED_LCH_Set, AUX_CTRL_REG_RST, sCTRL.CROSSED);

CC2_LCH_Set <= SET_CTRL_REG and SALS_CC(2);
CC2_LCH_Reset <= T1 or sCTRL_REG_RST;
CC2_LCH: FLL port map(CC2_LCH_Set, CC2_LCH_Reset, sCTRL.CTRL_CC(2));
GTAHI_LCH_Set <= SET_CTRL_REG and SALS_CF(1);
GTAHI_LCH_Reset <= T1 or sCTRL_REG_RST;
GTAHI_LCH: FLL port map(GTAHI_LCH_Set, GTAHI_LCH_Reset, sCTRL.GT_A_REG_HI);
GTALO_LCH_Set <= SET_CTRL_REG and SALS_CF(2);
GTALO_LCH_Reset <= T1 or sCTRL_REG_RST;
GTALO_LCH: FLL port map(GTALO_LCH_Set, GTALO_LCH_Reset, sCTRL.GT_A_REG_LO);
COMPCY_LCH_Set <= SET_CTRL_REG and COMPUTE;
COMPCY_LCH_Reset <= T1 or sCTRL_REG_RST;
COMPCY_LCH: FLL port map(COMPCY_LCH_Set, COMPCY_LCH_Reset, sCTRL.COMPUTE_CY_LCH);

CG0_Set <= MANUAL_STORE or (SET_CTRL_REG and SALS_CG(0));
CG_Reset <= T1 or (MACH_RST_SW or ANY_PRIORITY_LCH); -- ?? Required to prevent simultaneous Set & Reset of CG by MANUAL_STORE
CG0: FLL port map(CG0_Set, CG_Reset, sCTRL.CTRL_CG(0)); sCTRL.GT_B_REG_HI <= sCTRL.CTRL_CG(0);
CG1_Set <= MANUAL_STORE or (SET_CTRL_REG and SALS_CG(1));
CG1: FLL port map(CG1_Set, CG_Reset, sCTRL.CTRL_CG(1)); sCTRL.GT_B_REG_LO <= sCTRL.CTRL_CG(1);

CV_LCH_Set <= SALS_CV and (0 to 1 => SET_CTRL_REG);
CV_LCH_Reset <= (0 to 1 => T1 or sCTRL_REG_RST);
CV_LCH: FLVL port map(CV_LCH_Set,CV_LCH_Reset,sCTRL.CTRL_CV); -- AA2D6
CC01_LCH_Set <= SALS_CC(0 to 1) and (0 to 1 => SET_CTRL_REG);
CC01_LCH_Reset <= (0 to 1 => T1 or sCTRL_REG_RST);
CC01_LCH: FLVL port map(CC01_LCH_Set,CC01_LCH_Reset,sCTRL.CTRL_CC(0 to 1)); -- AA2D6

CS_LCH_Set <= SALS_CS and (0 to 3 => SET_CTRL_REG);
CS_LCH_Reset <= (0 to 3 => T1 or sCTRL_REG_RST);
CS_LCH: FLVL port map(CS_LCH_Set,CS_LCH_Reset,sCTRL.CTRL_CS); -- AA2D7
CTRL <= sCTRL;

CK_SAL_P_BIT_TO_MPX <= SALS_PK and not MACH_RST_MPX;

-- Page 5-01D
-- CCROS microcode storage
-- Start of read is CROS_GO_PULSE
-- End of read is CCROS_STROBE
-- Should use falling edge of CCROS_STROBE to gate data from CCROS into SALS (actually happens earlier)
CCROS_RESET_SET: process (Clk,CROS_STROBE,CROS_GO_PULSE,WX)
begin
-- Reset SALS when CROS_GO_PULSE goes Low
-- Set SALS 100ns after CROS_STROBE goes High (start of T3)
-- ROAR should have been set during T1 so we have a 1.5 minor cycle (~280ns) access time
	if (Clk'Event and Clk='1') then
--		if (CROS_STROBE='1' and CROS_STROBE_DELAY="10000") then
			--SALS_Word <= (others => '0');
--		else 
		if (CROS_STROBE='1' and CROS_STROBE_DELAY="11110") then
			SALS_Word <= CCROS(CCROS_Address_Type(conv_integer(unsigned(WX(1 to 12)))));
--		end if;
		end if;
		CROS_STROBE_DELAY <= CROS_STROBE & CROS_STROBE_DELAY(1 to 4);
		end if;
end process;

SALS.SALS_PN <= SALS_PN;
SALS.SALS_CN <= SALS_CN;
SALS.SALS_PS <= SALS_PS;
SALS.SALS_PA <= SALS_PA;
SALS.SALS_CH <= SALS_CH;
SALS.SALS_CL <= SALS_CL;
SALS.SALS_CM <= SALS_CM;
SALS.SALS_CU <= SALS_CU;
SALS.SALS_CA <= SALS_CA;
SALS.SALS_CB <= SALS_CB;
SALS.SALS_CK <= SALS_CK;
SALS.SALS_PK <= SALS_PK;
SALS.SALS_PC <= SALS_PC;
SALS.SALS_CD <= SALS_CD;
SALS.SALS_CF <= SALS_CF;
SALS.SALS_CG <= SALS_CG;
SALS.SALS_CV <= SALS_CV;
SALS.SALS_CC <= SALS_CC;
SALS.SALS_CS <= SALS_CS;
SALS.SALS_AA <= SALS_AA;
SALS.SALS_SA <= SALS_SA;
SALS.SALS_AK <= SALS_AK;

END FMD; 

