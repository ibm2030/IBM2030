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
--    File: FMD2030_5-06C-D.vhd
--    Creation Date:          11/08/05
--    Description:
--    R Register and assembly, Main and Local (Auxiliary, Bump) Storage
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
--    Revision 1.1 2012-04-07
--		Implement external 64k + aux storage using StorageIn / StorageOut
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;

ENTITY RREG_STG IS
	port
	(
		-- Inputs        
		SALS : IN SALS_Bus;
		CTRL : IN CTRL_REG;
		SX2_RD_CYCLE : IN STD_LOGIC; -- 14D
		SEL_T3 : IN STD_LOGIC;
		GT_DETECTORS_TO_HR : IN STD_LOGIC; -- 14D
		SEL_DATA_READY : IN STD_LOGIC; -- 03B
		SEL_R_W_CTRL : IN STD_LOGIC; -- 12C
		SX2_WR_CYCLE : IN STD_LOGIC; -- 14D
		SX1_RD_CYCLE : IN STD_LOGIC; -- 12D
		SX1_WR_CYCLE : IN STD_LOGIC; -- 12D
		GT_DETECTORS_TO_GR : IN STD_LOGIC; -- 12D
		EVEN_HR_0_7_BITS : IN STD_LOGIC; -- 13A
		EVEN_GR_0_7_BITS : IN STD_LOGIC; -- 11A
		HR_REG_0_7 : IN STD_LOGIC_VECTOR(0 TO 7); -- 13C
		GR_REG_0_7 : IN STD_LOGIC_VECTOR(0 TO 7); -- 11C
		DR_CORR_P_BIT : IN STD_LOGIC := '0'; -- HSMPX
		HR_REG_P_BIT : IN STD_LOGIC; -- 13A
		GR_REG_P_BIT : IN STD_LOGIC; -- 11A
		STORE_HR : IN STD_LOGIC; -- 14D
		STORE_GR : IN STD_LOGIC; -- 12D
		STORE_R : IN STD_LOGIC; -- 03D
		MEM_SELECT : IN STD_LOGIC; -- 03D
		MAN_STORE_PWR : IN STD_LOGIC; -- 03D
		E_SW_SEL_R : IN STD_LOGIC; -- 04C
		GT_HSMPX_INTO_R_REG : IN STD_LOGIC := '0'; -- HSMPX
		HSMPX_BUS : IN STD_LOGIC_VECTOR(0 to 8) := "000000000"; -- HSMPX
		COMPUTE_CY_LCH : IN STD_LOGIC; -- 01C
		CLOCK_OFF : IN STD_LOGIC; -- 08A
		ALLOW_WRITE_1 : IN STD_LOGIC; -- 03D
		PROT_LOC_CPU_OR_MPX : IN STD_LOGIC; -- 08B
		USE_R : IN STD_LOGIC; -- 04D
		MANUAL_DISPLAY : IN STD_LOGIC; -- 03D
		MAN_STORE : IN STD_LOGIC; -- 03D
		DATA_READY : IN STD_LOGIC; -- 03A
		MACH_RST_SET_LCH_DLY : IN STD_LOGIC; -- 04B
		SEL_SHARE_CYCLE : IN STD_LOGIC; -- 12D
		MN_REG_CHK_SMPLD : IN STD_LOGIC; -- 07A
		MEM_WRAP : IN STD_LOGIC; -- 03B
		MAIN_STG : IN STD_LOGIC; -- 04D
		MACH_RST_2A : IN STD_LOGIC; -- 06B
		MACH_RST_6 : IN STD_LOGIC; -- 03D
		ALLOW_WRITE : IN STD_LOGIC; -- 03D
--		STORAGE_BUS : IN STD_LOGIC_VECTOR(0 TO 8); -- 06D/07D -- Included here
		CPU_SET_ALLOW_WR_LCH : IN STD_LOGIC; -- 03D
		N1401_MODE : IN STD_LOGIC; -- 05A
		MACH_RST_SW : IN STD_LOGIC; -- 03D
		MN : IN STD_LOGIC_VECTOR(0 to 15); -- 07B
		N_Z_BUS : IN STD_LOGIC_VECTOR(0 to 8);
		USE_MAIN_MEM,USE_LOC_MAIN_MEM : IN STD_LOGIC; -- 05D
		READ_1,READ_2,WRITE_1,WRITE_2 : IN STD_LOGIC := '0'; -- 05D Unused
		PHASE_RD_1,PHASE_RD_2,PHASE_WR_1,PHASE_WR_2 : IN STD_LOGIC; -- 05D

		-- Outputs
		R_0 : OUT STD_LOGIC; -- 02A
		R_REG_BUS : OUT STD_LOGIC_VECTOR(0 TO 8); -- 05C
		P_8F_DETECTED : OUT STD_LOGIC; -- 03A
      ALLOW_PROTECT : OUT STD_LOGIC; -- 03A7
		STORE_BITS : OUT STD_LOGIC_VECTOR(0 TO 8); -- 11C

      -- Interface to hardware
		StorageIn : IN STORAGE_IN_INTERFACE;
		StorageOut : OUT STORAGE_OUT_INTERFACE;
		
		-- Clocks
--		P3 : IN STD_LOGIC;
		T1,T2,T3,T4 : IN STD_LOGIC;
		clk : IN STD_LOGIC
	
	);
END RREG_STG;

ARCHITECTURE FMD OF RREG_STG IS 

TYPE MAIN_STG_TYPE is ARRAY(0 to 1023) of STD_LOGIC_VECTOR(0 to 8);
-- TYPE MAIN_STG_TYPE is ARRAY(0 to 8191) of STD_LOGIC_VECTOR(0 to 8);
TYPE LOCAL_STG_TYPE is ARRAY(0 to 511) of STD_LOGIC_VECTOR(0 to 8);

SIGNAL SX1_STOR,SX2_STOR : STD_LOGIC;
SIGNAL INPUT_CORRECTED_P_BIT : STD_LOGIC;
SIGNAL GRP, HRP : STD_LOGIC;
SIGNAL INH_Z_BUS_SET_R : STD_LOGIC;
SIGNAL PROTECT_MEMORY : STD_LOGIC;
SIGNAL STORE_MAN : STD_LOGIC;
SIGNAL FORCE_Z_SET_R, FORCE_Z_SET_R2 : STD_LOGIC;
SIGNAL GT_R_1,GT_R : STD_LOGIC;
SIGNAL R_REG : STD_LOGIC_VECTOR(0 TO 8) := "000000001";
SIGNAL DET0F : STD_LOGIC;
SIGNAL GMWM_DETECTED : STD_LOGIC;
SIGNAL FORCE_MEM_SET_R,MEM_SET_R, MEM_SET_R2 : STD_LOGIC;
SIGNAL R_MUX,STORAGE_BUS : STD_LOGIC_VECTOR(0 to 8);
SIGNAL sALLOW_PROTECT : STD_LOGIC;
signal sSTORE_BITS : STD_LOGIC_VECTOR(0 to 8);
signal SX1_STOR_INPUT_DATA_Set,SX1_STOR_INPUT_DATA_Reset,SX2_STOR_INPUT_DATA_Set,SX2_STOR_INPUT_DATA_Reset,
	PROT_MEM_Set,PROT_MEM_Reset,P_8F_DETECT_Set,P_8F_DETECT_Reset : STD_LOGIC;
SIGNAL LOCAL_STG_ARRAY : LOCAL_STG_TYPE;
SIGNAL MAIN_STG_ARRAY : MAIN_STG_TYPE := (
16#000# => "000000001", -- 00
16#001# => "000000010", -- 01
16#002# => "000000001", -- 00
16#003# => "000000001", -- 00
16#004# => "000000001", -- 00
16#005# => "000000001", -- 00
16#006# => "000000010", -- 01
16#007# => "000000001", -- 00
16#008# => "110100110", -- L
16#009# => "110100011", -- J
16#00A# => "111001100", -- W
16#00B# => "111100100", -- 2
16#00C# => "111100001", -- 0
16#00D# => "111100110", -- 3
16#00E# => "111100001", -- 0

-- The following program is from p73 of the System/360 programming tutorial
-- The "Indian" problem
-- Compound interest on $24 (price of Manhattan) at 3% for 338 years = $523998.22
16#100# => "000001011", -- 05 BALR 11,0
16#101# => "101100000", -- B0
16#102# => "111100100", -- F2
16#103# => "011000111", -- 63
16#104# => "101100000", -- B0
16#105# => "010010100", -- 4A
16#106# => "101100000", -- B0
16#107# => "010000000", -- 40
16#108# => "111100100", -- F2
16#109# => "000100101", -- 12
16#10A# => "101100000", -- B0
16#10B# => "010100010", -- 51
16#10C# => "101100000", -- B0
16#10D# => "010001001", -- 44
16#10E# => "111100100", -- F2
16#10F# => "011100101", -- 72

16#110# => "101100000", -- B0
16#111# => "010101101", -- 56
16#112# => "101100000", -- B0
16#113# => "010001111", -- 47
16#114# => "010011110", -- 4F
16#115# => "010000000", -- 40
16#116# => "101100000", -- B0
16#117# => "010101101", -- 56
16#118# => "111111001", -- FC
16#119# => "011000010", -- 61
16#11A# => "101100000", -- B0
16#11B# => "010010100", -- 4A
16#11C# => "101100000", -- B0
16#11D# => "010100010", -- 51
16#11E# => "111110101", -- FA
16#11F# => "011000010", -- 61

16#120# => "101100000", -- B0
16#121# => "010010100", -- 4A
16#122# => "101100000", -- B0
16#123# => "010111100", -- 5E
16#124# => "110100011", -- D1
16#125# => "000000001", -- 00
16#126# => "101100000", -- B0
16#127# => "010011110", -- 4F
16#128# => "101100000", -- B0
16#129# => "010100001", -- 50
16#12A# => "110100101", -- D2
16#12B# => "000001011", -- 05
16#12C# => "101100000", -- B0
16#12D# => "011000001", -- 60
16#12E# => "101100000", -- B0
16#12F# => "010010100", -- 4A

16#130# => "111110000", -- F8
16#131# => "011001011", -- 65
16#132# => "101100000", -- B0
16#133# => "010010100", -- 4A
16#134# => "101100000", -- B0
16#135# => "011000001", -- 60
16#136# => "010001100", -- 46
16#137# => "010000000", -- 40
16#138# => "101100000", -- B0
16#139# => "000101100", -- 16
16#13A# => "111100111", -- F3
16#13B# => "100001100", -- 86
16#13C# => "101100000", -- B0
16#13D# => "011001101", -- 66
16#13E# => "101100000", -- B0
16#13F# => "010010100", -- 4A

16#140# => "000001110", -- 07 BCR 15,11
16#141# => "111110110", -- FB
16#142# => "111100100", -- F2
16#143# => "111101000", -- F4
16#144# => "111100001", -- F0
16#145# => "110000001", -- C0
16#146# => "111100010", -- F1
16#147# => "111100001", -- F0
16#148# => "110000111", -- C3
16#149# => "111100111", -- F3
16#14A# => "111100111", -- F3
16#14B# => "110010000", -- C8

16#160# => "000001011", -- 05
16#161# => "000011001", -- 0C

others => "000000001"
);
signal dT1 : STD_LOGIC;

BEGIN
-- Fig 5-06C
SX2_STOR_INPUT_DATA_Set <= SX2_RD_CYCLE and SEL_T3;
SX2_STOR_INPUT_DATA_Reset <= (GT_DETECTORS_TO_HR and SEL_DATA_READY) or (not SEL_R_W_CTRL and not SX2_WR_CYCLE);
SX2_STOR_INPUT_DATA: FLL port map(SX2_STOR_INPUT_DATA_Set,SX2_STOR_INPUT_DATA_Reset,SX2_STOR); -- AE1G3,AE1L3
SX1_STOR_INPUT_DATA_Set <= SX1_RD_CYCLE and SEL_T3;
SX1_STOR_INPUT_DATA_Reset <= (GT_DETECTORS_TO_GR and SEL_DATA_READY) or (not SEL_R_W_CTRL and not SX1_WR_CYCLE);
SX1_STOR_INPUT_DATA: FLL port map(SX1_STOR_INPUT_DATA_Set,SX1_STOR_INPUT_DATA_Reset,SX1_STOR); -- AD2E4,AD2G4
INPUT_CORRECTED_P_BIT <= (SX2_STOR and EVEN_HR_0_7_BITS) or (SX1_STOR and EVEN_GR_0_7_BITS) or DR_CORR_P_BIT; -- AD2G4,AA1E7

HRP <= not SX2_STOR and HR_REG_P_BIT and STORE_HR; -- AA1F7
GRP <= not SX1_STOR and GR_REG_P_BIT and STORE_GR; -- AA1F7

sSTORE_BITS <= ((HR_REG_0_7 & INPUT_CORRECTED_P_BIT) and (0 TO 8 => STORE_HR)) or -- AA1G7
					((GR_REG_0_7 & INPUT_CORRECTED_P_BIT) and (0 TO 8 => STORE_GR)) or -- AA1G6
					("00000000" & HRP) or
					("00000000" & GRP) or
					(R_REG and (0 to 8 => STORE_R)); -- AA1G5
STORE_BITS <= sSTORE_BITS;

R_REG_BUS <= R_REG;
R_0 <= R_REG(0); -- AA3K6

INH_Z_BUS_SET_R <= CLOCK_OFF or (ALLOW_WRITE_1 and PROT_LOC_CPU_OR_MPX) or (USE_R and PROTECT_MEMORY); -- AB3D5
FORCE_Z_SET_R <= STORE_HR or STORE_GR or STORE_MAN or (not T1 and COMPUTE_CY_LCH and not INH_Z_BUS_SET_R) or (SALS.SALS_CM(1) and not INH_Z_BUS_SET_R); -- AA1F7,AA1J5
Delay_ZSetR: AR port map(FORCE_Z_SET_R,clk,FORCE_Z_SET_R2);

STORE_MAN <= (MEM_SELECT and MAN_STORE_PWR) or (MAN_STORE_PWR and E_SW_SEL_R); -- AA1H6
GT_R_1 <= '1' when STORE_MAN='1' or (CTRL.CTRL_CD="0111" and not INH_Z_BUS_SET_R='1') else '0'; -- AA1H7,AA1J4
GT_R <= (GT_R_1 and T4) or (GT_R_1 and MAN_STORE) or (DATA_READY and MEM_SET_R) or MACH_RST_SET_LCH_DLY; -- AA1G4
-- Temp debug replacing above line - without this the diags stop at B96 because ASCII latch never gets set
-- GT_R <= (GT_R_1 and T4) or (GT_R_1 and MAN_STORE) or (DATA_READY and MEM_SET_R and MANUAL_DISPLAY) or (DATA_READY and MEM_SET_R and P3) or MACH_RST_SET_LCH_DLY; -- AA1G4
RREG: PHV port map(R_MUX,GT_R,R_REG); -- AA1H4

sALLOW_PROTECT <= '1' when ((SALS.SALS_CM="010") or (SALS.SALS_CD="0111")) else '0'; -- AA2J3,AA2G5,AA2K4 ?? Extra inverter not required ??
ALLOW_PROTECT <= sALLOW_PROTECT;

PROT_MEM_Set <= MN_REG_CHK_SMPLD or (T2 and MEM_WRAP and MAIN_STG);
PROT_MEM_Reset <= MACH_RST_6 or (not ALLOW_WRITE and T4);
PROT_MEM: FLL port map(PROT_MEM_Set,PROT_MEM_Reset,PROTECT_MEMORY); -- AB3F5,AB3H6

-- If we have a protection violation, we must retain the location's value in R so that it can be written back, even if
-- R contained a new value destined for that location
FORCE_MEM_SET_R <= MANUAL_DISPLAY or (PROT_LOC_CPU_OR_MPX and sALLOW_PROTECT) or (USE_R and PROTECT_MEMORY and sALLOW_PROTECT); -- AA3L5

-- The following line determines whether the storage output data is actually gated into the R register
-- If you can understand this then you can understand anything in the 2030
-- By the time DATA_READY is active, the next CCROS word has been read in and it is this word which controls the gating
-- The next cycle after a storage read must always be a WRITE, COMPUTE or STORE (i.e. it can't be another READ)
-- If it is a STORE then the data is NOT gated to R, as R is about to be written into to storage
-- As the following cycle is not a read then the Alt CU decode is used, and if it is "GR" then the data is NOT gated to R (but to GR/HR instead)
-- However, if storage protection is activated, then the storage value is ALWAYS put into R so it can be rewritten by the subsequent WRITE or STORE
-- (this is what FORCE_MEM_SET_R does)
-- So MEM_SET_R<='1' when CU=X0|1X (i.e. not 01=GR) and CM/=X1X (i.e. not 010=STORE)
MEM_SET_R <= (FORCE_MEM_SET_R or SALS.SALS_CU(0) or not SALS.SALS_CU(1)) and (not SALS.SALS_CM(1) or FORCE_MEM_SET_R) and not SEL_SHARE_CYCLE; -- AA1J5
Delay_MemSetR: AR port map(MEM_SET_R,clk,MEM_SET_R2);

-- Input data (0 to 7) is inverted
R_MUX(0 to 7) <= ((0 to 7 => FORCE_Z_SET_R2) and not N_Z_BUS(0 to 7)) or ((0 to 7 => GT_HSMPX_INTO_R_REG) and HSMPX_BUS(0 to 7)) or ((0 to 7 => MEM_SET_R2) and STORAGE_BUS(0 to 7)); -- AA1G2 AA1H4
-- Input parity (8) is not inverted
R_MUX(8) <= (FORCE_Z_SET_R2 and N_Z_BUS(8)) or (GT_HSMPX_INTO_R_REG and HSMPX_BUS(8)) or (MEM_SET_R2 and STORAGE_BUS(8)) or MACH_RST_2A; -- AA1G2,AA1H4,AA1H2

-- Word Mark detection for 1401 usage
DET0F <= '1' when (STORAGE_BUS(1 to 7) = "0001111") and (DATA_READY='1') else '0'; -- AA1B7
GMWM: FLL port map(DET0F,CPU_SET_ALLOW_WR_LCH,GMWM_DETECTED); -- AA1F5
P_8F_DETECT_Set <= STORAGE_BUS(0) and MAIN_STG and N1401_MODE and DET0F;
P_8F_DETECT_Reset <= MACH_RST_SW or GMWM_DETECTED;
P_8F_DETECT: FLL port map(P_8F_DETECT_Set,P_8F_DETECT_Reset,P_8F_DETECTED); -- AA1F5

StorageOut.WriteData <= sSTORE_BITS;
StorageOut.MainStorage <= USE_MAIN_MEM;
StorageOut.ReadPulse <= PHASE_RD_1 and not DATA_READY; -- Drop ReadPulse when Data Ready goes active, this will latch input data
StorageOut.WritePulse <= PHASE_WR_1;
StorageOut.MSAR <= MN;
STORAGE_BUS <= StorageIn.ReadData when PHASE_RD_1='1' else "000000000"; -- Data is retained a bit after DATA_READY falls

STG_Wr: process (PHASE_WR_1)
begin
	if (PHASE_WR_1'EVENT AND PHASE_WR_1='1') then
		if (USE_MAIN_MEM='1') then
--			MAIN_STG_ARRAY(TO_INTEGER(UNSIGNED(MN(3 to 15)))) <= sSTORE_BITS;
		else
--			LOCAL_STG_ARRAY(TO_INTEGER(UNSIGNED(MN(3) & MN(8 to 15)))) <= sSTORE_BITS;
		end if;
	end if;
end process;

STG_Rd: process (PHASE_RD_1,USE_MAIN_MEM,MAIN_STG_ARRAY,LOCAL_STG_ARRAY,MN,StorageIn.ReadData)
begin
	if (PHASE_RD_1='1') then
		if (USE_MAIN_MEM='1') then
--			STORAGE_BUS <= StorageIn.ReadData;
--			STORAGE_BUS <= MAIN_STG_ARRAY(TO_INTEGER(UNSIGNED(MN(3 to 15))));
		else
--			STORAGE_BUS <= StorageIn.ReadData;
--			STORAGE_BUS <= LOCAL_STG_ARRAY(TO_INTEGER(UNSIGNED(MN(3) & MN(8 to 15))));
		end if;
	else
--		STORAGE_BUS <= "000000000";
	end if;		
end process;

END FMD; 
