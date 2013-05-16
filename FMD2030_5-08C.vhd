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
--    File: FMD2030_5-08C.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Multiplexor Channel registers FO & FB
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
--		Revise XH & XL BU latches amd MPX_INTRPT signal
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MpxFOFB is
    Port ( MPX_ROS_LCH : in  STD_LOGIC;
           S_REG_0 : in  STD_LOGIC;
           SET_FW : in  STD_LOGIC;
           S_REG_1 : in  STD_LOGIC;
           S_REG_2 : in  STD_LOGIC;
           T3 : in  STD_LOGIC;
           CK_SALS : in  STD_LOGIC_VECTOR (0 to 3);
			  PK_SALS : in STD_LOGIC;
           FBK_T2 : in  STD_LOGIC;
           MACH_RST_SET_LCH : in  STD_LOGIC;
           SALS_CS : in  STD_LOGIC_VECTOR (0 to 3);
           SALS_SA : in  STD_LOGIC;
           CK_0_PWR : in  STD_LOGIC;
           R_REG : in  STD_LOGIC_VECTOR (0 to 8);
           T1,T2 : in  STD_LOGIC;
           XXH : out  STD_LOGIC;
           XH : out  STD_LOGIC;
           XL : out  STD_LOGIC;
           FT_7_BIT_MPX_CHNL_INTRP : out  STD_LOGIC;
           FT_2_BIT_MPX_OPN_LCH : out  STD_LOGIC;
           SUPPR_CTRL_LCH : out  STD_LOGIC;
           OP_OUT_SIG : out  STD_LOGIC;
           MPX_OPN_LT_GATE : out  STD_LOGIC;
			  MACH_RST_MPX : out STD_LOGIC;
           MPX_INTRPT : out  STD_LOGIC;
           SX1_MASK : out  STD_LOGIC;
           EXT_TRAP_MASK_ON : out  STD_LOGIC;
           SX2_MASK : out  STD_LOGIC;
           FAK : out  STD_LOGIC;
           SET_BUS_O_CTRL_LCH : out  STD_LOGIC;
           MPX_BUS_O_REG : out  STD_LOGIC_VECTOR (0 to 8);
			  clk : in STD_LOGIC);
end MpxFOFB;

architecture FMD of MpxFOFB is
signal	sXXH,sXH,sXL,T3SET,X_SET : STD_LOGIC;
signal	XXH_IN,XH_IN,XL_IN : STD_LOGIC;
signal	XXHBU,XHBU,XLBU : STD_LOGIC;
signal	sMACH_RST_MPX : STD_LOGIC;
signal	CK11XX, CKX11X,CKX1X1,CK1X1X,CKXX11 : STD_LOGIC;
signal	CHNL_L,OPN_L,SUPPR_L,OUT_L : STD_LOGIC;
signal	notOP_OUT_SIG,MpxMask : STD_LOGIC;
alias		KP is PK_SALS;
signal	sFAK,sSET_BUS_O_CTRL : STD_LOGIC;
signal	BusO_Set,BusO_Reset : STD_LOGIC_VECTOR (0 to 8);
signal	sFT_7_BIT_MPX_CHNL_INTRP,sFT_2_BIT_MPX_OPN_LCH,sSUPPR_CTRL_LCH : STD_LOGIC;
begin

-- XL, XH and XXL bits and backup

XXH_BU: entity PH port map (D=>sXXH, L=>SET_FW, C=>clk, Q=> XXHBU);
XXH_IN <= (XXHBU and MPX_ROS_LCH) or (S_REG_0 and not MPX_ROS_LCH);
X_SET <= T3SET or sMACH_RST_MPX;
XXH_PH: entity PH port map (D=>XXH_IN, L=>X_SET, C=>clk, Q=> sXXH);
XXH <= sXXH;

XH_BU: entity PH port map (D=>sXH, L=>SET_FW, C=>clk, Q=> XHBU);
-- XH_IN <= (XHBU and MPX_ROS_LCH) or (not S_REG_1 and not MPX_ROS_LCH);
XH_IN <= (XHBU and MPX_ROS_LCH) or (S_REG_1 and not MPX_ROS_LCH);
XH_PH: entity PH port map (D=>XH_IN, L=>X_SET, C=>clk, Q=>sXH);
XH <= sXH;

XL_BU: entity PH port map (D=>sXL, L=>SET_FW, C=>clk, Q=> XLBU);
-- XL_IN <= (XLBU and MPX_ROS_LCH) or (not S_REG_2 and not MPX_ROS_LCH);
XL_IN <= (XLBU and MPX_ROS_LCH) or (S_REG_2 and not MPX_ROS_LCH);
XL_PH: entity PH port map (D=>XL_IN, L=>X_SET, C=>clk, Q=>sXL);
XL <= sXL;

-- MPX Flags

T3SET <= (MPX_ROS_LCH and T3) or (FBK_T2 and CK_SALS(0) and CK_SALS(3));
sMACH_RST_MPX <= MACH_RST_SET_LCH;
MACH_RST_MPX <= sMACH_RST_MPX;

CK11XX <= CK_SALS(0) and CK_SALS(1) and FBK_T2;
CHNL_L <= sMACH_RST_MPX or CK11XX;
MPX_CHNL: entity PH port map (D=>KP,L=>CHNL_L,C=>clk, Q=>sFT_7_BIT_MPX_CHNL_INTRP);
FT_7_BIT_MPX_CHNL_INTRP <= sFT_7_BIT_MPX_CHNL_INTRP;

CKX11X <= CK_SALS(1) and CK_SALS(2) and FBK_T2;
OPN_L <= sMACH_RST_MPX or CKX11X;
MPX_OPN: entity PH port map (D=>KP,L=>OPN_L,C=>clk, Q=>sFT_2_BIT_MPX_OPN_LCH);
FT_2_BIT_MPX_OPN_LCH <= sFT_2_BIT_MPX_OPN_LCH;

CK1X1X <= CK_SALS(0) and CK_SALS(2) and FBK_T2;
SUPPR_L <= sMACH_RST_MPX or CK1X1X;
SUPPR_CTRL: entity PH port map (D=>KP,L=>SUPPR_L,C=>clk, Q=>sSUPPR_CTRL_LCH);
SUPPR_CTRL_LCH <= sSUPPR_CTRL_LCH;

CKX1X1 <= CK_SALS(1) and CK_SALS(3) and FBK_T2;
OUT_L <= sMACH_RST_MPX or CKX1X1;
OP_OUT_CTRL: entity PH port map (D=>KP,L=>OUT_L,C=>clk, Q=>notOP_OUT_SIG);
OP_OUT_SIG <= not notOP_OUT_SIG;

MPX_OPN_LT_GATE <= CKX11X;

-- External Interrupt Masks
-- ?? Should the R_REG bits be inverted before use?
CKXX11 <= CK_SALS(2) and CK_SALS(3) and FBK_T2;
MPX_MASK: entity PH port map (D=>R_REG(0),L=>CKXX11,C=>clk, Q=>MPXMask);
MPX_INTRPT <= sFT_7_BIT_MPX_CHNL_INTRP and MPXMask;
SX1MASK: entity PH port map (D=>R_REG(1),L=>CKXX11,C=>clk, Q=>SX1_MASK);
EXT_MASK: entity PH port map (D=>R_REG(7),L=>CKXX11,C=>clk, Q=>EXT_TRAP_MASK_ON);
SX2MASK: entity PH port map (D=>R_REG(2),L=>CKXX11,C=>clk, Q=>SX2_MASK);

-- MPX BUS OUT REGISTER

sFAK <= SALS_CS(0) and SALS_CS(1) and SALS_CS(2) and SALS_CS(3) and not SALS_SA;
FAK <= sFAK;

sSET_BUS_O_CTRL <= sFAK and CK_0_PWR;
SET_BUS_O_CTRL_LCH <= sSET_BUS_O_CTRL;

BusO_Set <= R_REG and (0 to 8=>(sSET_BUS_O_CTRL and T2)); -- ??? "and T2" added to prevent incorrect setting of BUS_O
BusO_Reset <= (0 to 8=>sSET_BUS_O_CTRL and T1);
MPX_BUSO: entity FLVC port map (S=>BusO_Set,R=>BusO_Reset,C=>clk,Q=>MPX_BUS_O_REG);

end FMD;

