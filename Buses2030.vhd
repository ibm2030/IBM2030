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
--    File: buses2030.vhd
--    Creation Date: 
--    Description:
--    This file defines various system-wide buses
--    
--    Revision History:
--    Revision 1.0 2010-07-09
--    Initial Release
--    
--
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- This package defines various common buses and structures
package Buses_package is

-- SALS Bus is the microcode word
type SALS_Bus is record
        SALS_PN : STD_LOGIC;
        SALS_CN : STD_LOGIC_VECTOR(0 to 5);
        SALS_PS : STD_LOGIC;
        SALS_PA : STD_LOGIC;
        SALS_CH : STD_LOGIC_VECTOR(0 to 3);
        SALS_CL : STD_LOGIC_VECTOR(0 to 3);
        SALS_CM : STD_LOGIC_VECTOR(0 to 2);
        SALS_CU : STD_LOGIC_VECTOR(0 to 1);
        SALS_CA : STD_LOGIC_VECTOR(0 to 3);
        SALS_CB : STD_LOGIC_VECTOR(0 to 1);
        SALS_CK : STD_LOGIC_VECTOR(0 to 3);
        SALS_PK : STD_LOGIC;
        SALS_PC : STD_LOGIC;
        SALS_CD : STD_LOGIC_VECTOR(0 to 3);
        SALS_CF : STD_LOGIC_VECTOR(0 to 2);
        SALS_CG : STD_LOGIC_VECTOR(0 to 1);
        SALS_CV : STD_LOGIC_VECTOR(0 to 1);
        SALS_CC : STD_LOGIC_VECTOR(0 to 2);
        SALS_CS : STD_LOGIC_VECTOR(0 to 3);
        SALS_AA : STD_LOGIC;
        SALS_SA : STD_LOGIC;
        SALS_AK : STD_LOGIC;
end record SALS_Bus;        

-- The CTRL register is a subset of the SALS which is maintained
-- after the rest of the SALS is cleared as the next word is read
type CTRL_REG is record
        CTRL_CD : STD_LOGIC_VECTOR(0 to 3);     -- 05C
        STRAIGHT : STD_LOGIC;                   -- Similar to CF(0) inverted
        CROSSED : STD_LOGIC;                    -- Same as CF(0)
        CTRL_CC : STD_LOGIC_VECTOR(0 to 2);     -- CTRL REG BUS
        GT_A_REG_HI : STD_LOGIC;                -- Same as CF(1)
        GT_A_REG_LO : STD_LOGIC;                -- Same as CF(2)
        COMPUTE_CY_LCH : STD_LOGIC;             -- 06C & CTRL REG BUS
        CTRL_CG : STD_LOGIC_VECTOR(0 to 1);     -- 03B,06B & CTRL_REG_BUS
        GT_B_REG_HI : STD_LOGIC;                -- 06B, same as CG(0)
        GT_B_REG_LO : STD_LOGIC;                -- 06B, same as CG(1)
        CTRL_CV : STD_LOGIC_VECTOR(0 to 1);     -- CTRL REG BUS
        CTRL_CS : STD_LOGIC_VECTOR(0 to 3);     -- CTRL REG BUS
end record CTRL_REG;

-- The Priority bus is used to vector the microcode address when an external
-- interrupt occurs
type PRIORITY_BUS_Type is record
        STOP_PULSE : STD_LOGIC;         -- X0
        PROTECT_PULSE : STD_LOGIC;      -- X1
        WRAP_PULSE : STD_LOGIC;         -- X2
        MPX_SHARE_PULSE : STD_LOGIC;    -- X3
        SX_CHAIN_PULSE : STD_LOGIC;     -- X4
        MACH_CHK_PULSE : STD_LOGIC;     -- X5
        IPL_PULSE : STD_LOGIC;          -- X6
        FORCE_IJ_PULSE : STD_LOGIC;     -- X7
        PRIORITY_PULSE : STD_LOGIC;     -- XP
end record PRIORITY_BUS_Type;        

-- The E Switch bus contains the various signals corresponding to the legends on the
-- selector switch.  Only one of these signals will be true.
type E_SW_BUS_Type is record
	-- Inner ring
	I_SEL,J_SEL,U_SEL,V_SEL,L_SEL,T_SEL,D_SEL,R_SEL,S_SEL,G_SEL,H_SEL,FI_SEL,FT_SEL : STD_LOGIC;
	-- Mid ring
	MS_SEL, LS_SEL : STD_LOGIC; -- LS marked as AS on dial
	-- Outer ring
	Q_SEL,C_SEL,F_SEL,TT_SEL,TI_SEL,JI_SEL,
	E_SEL_SW_GS,E_SEL_SW_GT,E_SEL_SW_GUV_GCD,
	E_SEL_SW_HS,E_SEL_SW_HT,E_SEL_SW_HUV_HCD : STD_LOGIC;
end record E_SW_BUS_Type;

-- Mpx Tags Out are the tag signals from the CPU to a peripheral
type MPX_TAGS_OUT is record
	OPL_OUT,
	ADR_OUT,
	ADR_OUT2, -- What is this?
	CMD_OUT,
	STA_OUT,
	SRV_OUT,
	HLD_OUT,
	SEL_OUT,
	SUP_OUT,
	MTR_OUT,
	CLK_OUT : STD_LOGIC;
end record MPX_TAGS_OUT;

-- Mpx Tags In are the tag signals from a peripheral to the CPU
type MPX_TAGS_IN is record
	OPL_IN,
	ADR_IN,
	STA_IN,
	SRV_IN,
	SEL_IN,
	REQ_IN,
	MTR_IN : STD_LOGIC;
end record MPX_TAGS_IN;

-- List of front panel indicators
subtype IndicatorRange is integer range 0 to 249; -- 218 through 249 are temp debug items

end package Buses_package;
