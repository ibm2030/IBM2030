---------------------------------------------------------------------------
--    Copyright � 2015 Lawrence Wilkinson lawrence@ljw.me.uk
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
--    File: panel_LEDs.vhd
--    Creation Date: 16:08:00 16/06/2015
--    Description:
--    360/30 Front Panel LED lamp drivers
--    This drives 256 front panel LEDs via Maxim SPI/I2C multiplexed drivers
--    There are two options:
--    MAX7219 8 x 8 multiplexed LEDs
--    MAX7951 Charlieplexed LEDs
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0 2010-07-09
--    Initial Release
--    
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library logic;
--use logic.Gates_package.LED_DEVICE_TYPE;
library logic,buses;
use logic.Gates_package.all;
use buses.Buses_package.all;
use work.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity panel_LEDs is
	Generic (
--        Device : LED_DEVICE_TYPE := MAX6951;
        Clock_divider : integer := 25 -- Default for 50MHz clock is 2, for 25MHz = 40ns = 20ns + 20ns. 25 gives 2MHz.
        );
    Port (
		-- Panel Lamps
		IND_LP : IN std_logic;       
        W_IND : IN std_logic_vector(3 to 7);
        X_IND : IN std_logic_vector(0 to 7);
        W_IND_P : IN std_logic;
        X_IND_P : IN std_logic;
        IND_SALS : IN SALS_Bus;
        IND_EX,IND_CY_MATCH,IND_ALLOW_WR,IND_1050_INTRV,IND_1050_REQ,IND_MPX,IND_SEL_CHNL : IN STD_LOGIC;
        IND_MSDR : IN STD_LOGIC_VECTOR(0 to 7);
        IND_MSDR_P : IN STD_LOGIC;
        -- MPX
        IND_OPNL_IN : IN STD_LOGIC;
        IND_ADDR_IN : IN STD_LOGIC;
        IND_STATUS_IN : IN STD_LOGIC;
        IND_SERV_IN : IN STD_LOGIC;
        IND_SEL_IN : IN STD_LOGIC;
        IND_SEL_OUT : IN STD_LOGIC;
        IND_ADDR_OUT : IN STD_LOGIC;
        IND_CMMD_OUT : IN STD_LOGIC;
        IND_SERV_OUT : IN STD_LOGIC;
        IND_SUPPR_OUT : IN STD_LOGIC;
        IND_FO : IN STD_LOGIC_VECTOR(0 to 7);
        IND_FO_P: IN STD_LOGIC;
        -- SX1
        IND_COUNT : IN STD_LOGIC_VECTOR(0 to 15);
        IND_COUNT_LP, IND_COUNT_HP : IN STD_LOGIC;
		IND_SX1_DATA : IN STD_LOGIC_VECTOR(0 to 7);
		IND_SX1_DATAP : IN STD_LOGIC;
        IND_SX1_COMMAND : STD_LOGIC_VECTOR(0 to 7);
	    IND_SX1_KEY : STD_LOGIC_VECTOR(0 to 3);
		IND_SX1_KEYP : IN STD_LOGIC;
		IND_SX1_PCI : IN STD_LOGIC;
		IND_SX1_SKIP : IN STD_LOGIC;
		IND_SX1_SLI : IN STD_LOGIC;
		IND_SX1_CD : IN STD_LOGIC;
		IND_SX1_CC : IN STD_LOGIC;
		IND_SX1_DA_CHK : IN STD_LOGIC;
		IND_SX1_PROT_CHK : IN STD_LOGIC;
		IND_SX1_PROG_CHK : IN STD_LOGIC;
		IND_SX1_IL_CHK : IN STD_LOGIC;
		IND_SX1_CHNLDATA_CHK : IN STD_LOGIC;
		IND_SX1_STATIN_TAG : IN STD_LOGIC;
		IND_SX1_ADRIN_TAG : IN STD_LOGIC;
		IND_SX1_OPIN_TAG : IN STD_LOGIC;
		IND_SX1_SUPOUT_TAG : IN STD_LOGIC;
		IND_SX1_SERVOUT_TAG : IN STD_LOGIC;
		IND_SX1_CMMDOUT_TAG : IN STD_LOGIC;
		IND_SX1_ADROUT_TAG : IN STD_LOGIC;
		IND_SX1_SELOUT_TAG : IN STD_LOGIC;
		IND_SX1_IF_CHK : IN STD_LOGIC;
		IND_SX1_CHNLCTRL_CHK : IN STD_LOGIC;
		-- CPU        
        IND_A : IN STD_LOGIC_VECTOR(0 to 8);
        IND_B : IN STD_LOGIC_VECTOR(0 to 8);
        IND_ALU : IN STD_LOGIC_VECTOR(0 to 8);
        IND_M : IN STD_LOGIC_VECTOR(0 to 8);
        IND_N : IN STD_LOGIC_VECTOR(0 to 8);
        IND_MAIN_STG : IN STD_LOGIC;
        IND_LOC_STG : IN STD_LOGIC;
        IND_COMP_MODE : IN STD_LOGIC;
        IND_CHK_A_REG : IN STD_LOGIC;
        IND_CHK_B_REG : IN STD_LOGIC;
        IND_CHK_STOR_ADDR : IN STD_LOGIC;
        IND_CHK_CTRL_REG : IN STD_LOGIC;
        IND_CHK_ROS_SALS : IN STD_LOGIC;
        IND_CHK_ROS_ADDR : IN STD_LOGIC;
        IND_CHK_STOR_DATA : IN STD_LOGIC;
        IND_CHK_ALU : IN STD_LOGIC;
        IND_SYST : IN STD_LOGIC;
        IND_MAN : IN STD_LOGIC;
        IND_WAIT : IN STD_LOGIC;
        IND_TEST : IN STD_LOGIC;
        IND_LOAD : IN STD_LOGIC;		
        
        -- Other inputs
        clk50M : in STD_LOGIC; -- 50MHz
        
        -- Driver outputs
        MAX7219_CLK : out std_logic;
        MAX7219_DIN : out std_logic;	-- LEDs 00-3F
        MAX7219_LOAD : out std_logic;	-- Data latched on rising edge
        
        MAX6951_CLK : out std_logic;
        MAX6951_DIN : out std_logic;
        MAX6951_CS0 : out std_logic;	-- LEDs 00-3F Data latched on rising edge
        MAX6951_CS1 : out std_logic;	-- LEDs 40-7F Data latched on rising edge
        MAX6951_CS2 : out std_logic;	-- LEDs 80-BF Data latched on rising edge
        MAX6951_CS3 : out std_logic 	-- LEDs C0-FF Data latched on rising edge
        );
end panel_LEDs;

architecture behavioral of panel_LEDs is

-- All the signals we handle
signal LEDs : std_logic_vector(IndicatorRange);

signal clk_out : std_logic := '0';
signal shift_reg64 : std_logic_vector(63 downto 0);
signal reg_counter : integer range 0 to 11 := 0;
signal bit_counter16 : integer range 0 to 16 := 0;
signal bit_counter64 : integer range 0 to 64 := 0;

-- MAX7219 data is 8b address and 8b data
-- Address is:
-- 00 No-op (unused)
-- 01 Digit 0 (in position 0)
-- ...
-- 08 Digit 7 (in position 7)
-- 09 Decode mode (fixed 00 in position 8)
-- 0A Intensity (fixed at 0F in position 9)
-- 0B Scan limit (fixed at 07 in position 10)
-- 0C Shutdown (fixed at 01 in position 11)
-- 0F Display test (fixed at 00 in position 12)
type registers7219 is array(0 to 3,0 to 12) of std_logic_vector(15 downto 0);
signal max7219_vector : registers7219 :=
(
0 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"

),
1 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"
),
2 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"
),
3 => ( 
0 =>  "0000000100000000",
1 =>  "0000001000000000",
2 =>  "0000001100000000",
3 =>  "0000010000000000",
4 =>  "0000010100000000",
5 =>  "0000011000000000",
6 =>  "0000011100000000",
7 =>  "0000100000000000",
8 =>  "0000100100000000",
9 =>  "0000101000001111",
10 => "0000101100000111",
11 => "0000110000000001",
12 => "0000111100000000"
)
);
-- MAX6951 data is 8b Address and 8b Data
-- Address is:
-- 00 No-op (unused)
-- 01 Decode mode (fixed at default)
-- 02 Intensity (fixed at 0F in position 8)
-- 03 Scan limit (fixed at 07 in position 9)
-- 04 Configuration (fixed at 01 in position 10)
-- 07 Display test (fixed at 00 in position 11)
-- 60 Digit 0 (in position 0)
-- ...
-- 67 Digit 7 (in position 0)
type registers6951 is array(0 to 3,0 to 11) of std_logic_vector(15 downto 0);
signal max6951_vector : registers6951 :=
(
0 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"

),
1 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"
),
2 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"
),
3 => ( 
0 => "0110000000000000",
1 => "0110000100000000",
2 => "0110001000000000",
3 => "0110001100000000",
4 => "0110010000000000",
5 => "0110010100000000",
6 => "0110011000000000",
7 => "0110011100000000",
8 => "0000001000001111",
9 => "0000001100000111",
10 => "0000010000000001",
11 => "0000011100000000"
)
);
begin

		LEDs <= (
				0 => IND_SALS.SALS_PA,
				1 => IND_SALS.SALS_CN(5),
				2 => IND_SALS.SALS_CN(4),
				3 => IND_SALS.SALS_CN(3),
				4 => IND_SALS.SALS_CN(2),
				5 => IND_SALS.SALS_CN(1),
				6 => IND_SALS.SALS_CN(0),
				7 => IND_SALS.SALS_PN,
				8 => X_IND_P,
				9 => X_IND(7),
				10 => X_IND(6),
				11 => X_IND(5),
				12 => X_IND(4),
				13 => X_IND(3),
				14 => X_IND(2),
				15 => X_IND(1),
				16 => X_IND(0),
				17 => W_IND_P,
				18 => IND_LP,
				19 => W_IND(7),
				20 => W_IND(6),
				21 => W_IND(5),
				22 => W_IND(4),
				23 => W_IND(3),
				24 => IND_SALS.SALS_CL(2),
				25 => IND_SALS.SALS_CL(1),
				26 => IND_SALS.SALS_CL(0),
				27 => IND_SALS.SALS_CH(3),
				28 => IND_SALS.SALS_CH(2),
				29 => IND_SALS.SALS_CH(1),
				30 => IND_SALS.SALS_CH(0),
				31 => IND_SALS.SALS_PS,
				32 => IND_SALS.SALS_CB(1),
				33 => IND_SALS.SALS_CB(0),
				34 => IND_SALS.SALS_CA(3),
				35 => IND_SALS.SALS_CA(2),
				36 => IND_SALS.SALS_CA(1),
				37 => IND_SALS.SALS_CA(0),
				38 => IND_SALS.SALS_AA,
				39 => IND_SALS.SALS_CL(3),
				40 => IND_SALS.SALS_CK(0),
				41 => IND_SALS.SALS_PK,
				42 => IND_SALS.SALS_AK,
				43 => IND_SALS.SALS_CU(1),
				44 => IND_SALS.SALS_CU(0),
				45 => IND_SALS.SALS_CM(2),
				46 => IND_SALS.SALS_CM(1),
				47 => IND_SALS.SALS_CM(0),
				48 => IND_SALS.SALS_CD(3),
				49 => IND_SALS.SALS_CD(2),
				50 => IND_SALS.SALS_CD(1),
				51 => IND_SALS.SALS_CD(0),
				52 => IND_SALS.SALS_PC,
				53 => IND_SALS.SALS_CK(3),
				54 => IND_SALS.SALS_CK(2),
				55 => IND_SALS.SALS_CK(1),
				56 => IND_SALS.SALS_CC(0),
				57 => IND_SALS.SALS_CV(1),
				58 => IND_SALS.SALS_CV(0),
				59 => IND_SALS.SALS_CG(1),
				60 => IND_SALS.SALS_CG(0),
				61 => IND_SALS.SALS_CF(2),
				62 => IND_SALS.SALS_CF(1),
				63 => IND_SALS.SALS_CF(0),
				64 => IND_COUNT_HP, -- Count-P
				65 => IND_SALS.SALS_CS(3),
				66 => IND_SALS.SALS_CS(2),
				67 => IND_SALS.SALS_CS(1),
				68 => IND_SALS.SALS_CS(0),
				69 => IND_SALS.SALS_SA,
				70 => IND_SALS.SALS_CC(2),
				71 => IND_SALS.SALS_CC(1),
				-- Count 72-87,95
				72 => IND_COUNT(8),
				73 => IND_COUNT(6),
				74 => IND_COUNT(5),
				75 => IND_COUNT(4),
				76 => IND_COUNT(3),
				77 => IND_COUNT(2),
				78 => IND_COUNT(1),
				79 => IND_COUNT(0),
				80 => IND_COUNT(15),
				81 => IND_COUNT(14),
				82 => IND_COUNT(13),
				83 => IND_COUNT(12),
				84 => IND_COUNT(11),
				85 => IND_COUNT(10),
				86 => IND_COUNT(9),
				87 => IND_COUNT_LP,
				95 => IND_COUNT(0),
				
				-- SX1
				88 => IND_SX1_DATA(5),
				89 => IND_SX1_DATA(4),
				90 => IND_SX1_DATA(3),
				91 => IND_SX1_DATA(2),
			    92 => IND_SX1_DATA(1),
				93 => IND_SX1_DATA(0),
				94 => IND_SX1_DATAP,
				96 => IND_SX1_COMMAND(4),
				97 => IND_SX1_KEY(3),
				98 => IND_SX1_KEY(2),
				99 => IND_SX1_KEY(1),
				100 => IND_SX1_KEY(0),
				101 => IND_SX1_KEYP,
				102 => IND_SX1_DATA(7),
				103 => IND_SX1_DATA(6),
				104 => IND_SX1_PCI,
				105 => IND_SX1_SKIP,
				106 => IND_SX1_SLI,
				107 => IND_SX1_CD,
				108 => IND_SX1_CC,
				109 => IND_SX1_COMMAND(7),
				110 => IND_SX1_COMMAND(6),
				111 => IND_SX1_COMMAND(5),
				112 => IND_SX1_DA_CHK,
				113 => IND_SX1_PROT_CHK,
				114 => IND_SX1_PROG_CHK,
				115 => IND_SX1_IL_CHK,
				116 => IND_SX1_CHNLDATA_CHK,
				117 => IND_SX1_STATIN_TAG,
				118 => IND_SX1_ADRIN_TAG,
				119 => IND_SX1_OPIN_TAG,
				120 => '0', -- LED5
				121 => IND_SX1_SUPOUT_TAG,
				122 => IND_SX1_SERVOUT_TAG,
				123 => IND_SX1_CMMDOUT_TAG,
				124 => IND_SX1_ADROUT_TAG,
				125 => IND_SX1_SELOUT_TAG,
				126 => IND_SX1_IF_CHK,
				127 => IND_SX1_CHNLCTRL_CHK,
				-- SX2 128-150. 162-167
				
				-- Temporary indicators 152-159
				152 => IND_LOAD,
				153 => IND_TEST,
				154 => IND_WAIT,
				155 => IND_MAN,
				156 => IND_SYST,
				157 => '1', -- Power
				158 => '1',
				159 => '1',

				160 => IND_ADDR_IN,
				161 => IND_OPNL_IN,
				-- 162-167 in SX2
				168 => IND_FO_P,
				169 => IND_SUPPR_OUT,
				170 => IND_SERV_OUT,
				171 => IND_CMMD_OUT,
				172 => IND_ADDR_OUT,
				173 => IND_SEL_OUT,
				174 => IND_SERV_IN,
				175 => IND_STATUS_IN,
				176 => IND_FO(7),
				177 => IND_FO(6),
				178 => IND_FO(5),
				179 => IND_FO(4),
				180 => IND_FO(3),
				181 => IND_FO(2),
				182 => IND_FO(1),
				183 => IND_FO(0),
				184 => IND_M(6),
				185 => IND_M(5),
				186 => IND_M(4),
				187 => IND_M(3),
				188 => IND_M(2),
				189 => IND_M(1),
				190 => IND_M(0),
				191 => IND_M(8),
				192 => IND_N(5),
				193 => IND_N(4),
				194 => IND_N(3),
				195 => IND_N(2),
				196 => IND_N(1),
				197 => IND_N(0),
				198 => IND_N(8),
				199 => IND_M(7),
				200 => IND_MSDR(2),
				201 => IND_MSDR(1),
				202 => IND_MSDR(0),
				203 => IND_MSDR_P,
				204 => IND_LOC_STG,
				205 => IND_MAIN_STG,
				206 => IND_N(7),
				207 => IND_N(6),
				208 => IND_ALU(1),
				209 => IND_ALU(0),
				210 => IND_ALU(8),
				211 => IND_MSDR(7),
				212 => IND_MSDR(6),
				213 => IND_MSDR(5),
				214 => IND_MSDR(4),
				215 => IND_MSDR(3),
				216 => IND_B(0),
				217 => IND_B(8),
				218 => IND_ALU(7),
				219 => IND_ALU(6),
				220 => IND_ALU(5),
				221 => IND_ALU(4),
				222 => IND_ALU(3),
				223 => IND_ALU(2),
				224 => IND_A(8),
				225 => IND_B(7),
				226 => IND_B(6),
				227 => IND_B(5),
				228 => IND_B(4),
				229 => IND_B(3),
				230 => IND_B(2),
				231 => IND_B(1),
				232 => IND_A(7),
				233 => IND_A(6),
				234 => IND_A(5),
				235 => IND_A(4),
				236 => IND_A(3),
				237 => IND_A(2),
				238 => IND_A(1),
				239 => IND_A(0),
				240 => IND_CHK_B_REG,
				241 => IND_1050_REQ,
				242 => IND_1050_INTRV,
				243 => IND_CHK_STOR_DATA,
				244 => IND_CHK_STOR_ADDR,
				245 => IND_ALLOW_WR,
				246 => IND_CY_MATCH,
				247 => IND_EX,
				248 => IND_CHK_CTRL_REG,
				249 => IND_CHK_ROS_SALS,
				250 => IND_CHK_ROS_ADDR,
				251 => IND_COMP_MODE,
				252 => IND_SEL_CHNL,
				253 => IND_MPX,
				254 => IND_CHK_ALU,
				255 => IND_CHK_A_REG,
				others => '0');

gen_clk : process (clk50M) is
	variable divider : integer := Clock_divider;
	begin
		if rising_edge(clk50M) then
			if (divider=0) then
				divider := Clock_divider;
				clk_out <= not clk_out;
				MAX7219_CLK <= not clk_out;
				MAX6951_CLK <= not clk_out;
			else
				divider := divider - 1;
			end if;
		end if;
	end process;

max7219gen : process (clk_out) is
	begin
	if falling_edge(clk_out) then
		if bit_counter64=0 then
			bit_counter64 <= 64;
			case reg_counter is
				when 0 to 7 =>
					-- Mapping is:
					-- b7 = DP = XX7
					-- b6 =  A = XX0
					-- b5 =  B = XX1
					-- b4 =  C = XX2
					-- b3 =  D = XX3
					-- b2 =  E = XX4
					-- b1 =  F = XX5
					-- b0 =  G = XX6
					shift_reg64 <= 
						max7219_vector(3,reg_counter)(15 downto 8) & LEDs(reg_counter*8+192+7) & LEDs(reg_counter*8+192 to reg_counter*8+192+6) &
						max7219_vector(2,reg_counter)(15 downto 8) & LEDs(reg_counter*8+128+7) & LEDs(reg_counter*8+128 to reg_counter*8+128+6) &
						max7219_vector(1,reg_counter)(15 downto 8) & LEDs(reg_counter*8+ 64+7) & LEDs(reg_counter*8+ 64 to reg_counter*8+ 64+6) &
						max7219_vector(0,reg_counter)(15 downto 8) & LEDs(reg_counter*8+  0+7) & LEDs(reg_counter*8+  0 to reg_counter*8+  0+6);
				when others =>
					shift_reg64 <= 
						max7219_vector(3,reg_counter) &
						max7219_vector(2,reg_counter) &
						max7219_vector(1,reg_counter) &
						max7219_vector(0,reg_counter);	
			end case;
			if reg_counter=12 then
				reg_counter <= 0;
			else
				reg_counter <= reg_counter + 1;
			end if;
			MAX7219_DIN <= '0';
			MAX7219_Load <= '1';
		else
			bit_counter64 <= bit_counter64 - 1;
			shift_reg64 <= shift_reg64(62 downto 0) & '0';
			MAX7219_DIN <= shift_reg64(63);
			MAX7219_Load <= '0';
		end if;
	end if;
	end process;

max6951gen : process (clk_out) is
	variable dev_counter : integer range 0 to 3 := 3;
	variable reg_counter : integer range 0 to 11 := 0;
	variable bit_counter : integer range 0 to 16 := 16;
	variable shift_reg : std_logic_vector(16 downto 0);
	begin
	if falling_edge(clk_out) then
		if bit_counter=0 then
			bit_counter := 16;
			case reg_counter is
				when 0 to 7 =>
					shift_reg := '0' & max6951_vector(dev_counter,reg_counter)(15 downto 8) & LEDs((dev_counter*64+reg_counter*8) to (dev_counter*64+reg_counter*8+7)); -- Need to reverse 8bit LED vector
				when others =>
					shift_reg := '0' & max6951_vector(dev_counter,reg_counter);
			end case;
			if reg_counter=11 then
				if dev_counter=0 then
					dev_counter := 3;
				else
					dev_counter := dev_counter - 1;
				end if;
				reg_counter := 0;
			else
				reg_counter := reg_counter + 1;
			end if;
		else
			bit_counter := bit_counter - 1;
			shift_reg := shift_reg(15 downto 0) & '0';
		end if;
		if bit_counter=16 then
			MAX6951_CS0 <= '1';
			MAX6951_CS1 <= '1';
			MAX6951_CS2 <= '1';
			MAX6951_CS3 <= '1';
		else
			if dev_counter=0 then
				MAX6951_CS0 <= '0';
			else
				MAX6951_CS0 <= '1';
			end if;
			if dev_counter=1 then
				MAX6951_CS1 <= '0';
			else
				MAX6951_CS1 <= '1';
			end if;
			if dev_counter=2 then
				MAX6951_CS2 <= '0';
			else
				MAX6951_CS2 <= '1';
			end if;
			if dev_counter=3 then
				MAX6951_CS3 <= '0';
			else
				MAX6951_CS3 <= '1';
			end if;
		end if;
		MAX6951_DIN <= shift_reg(16);
	end if;
	end process;

end behavioral;
