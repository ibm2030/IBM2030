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
--    File: FMD2030_5-08D.vhd
--    Creation Date: 21:39:37 03/22/2010
--    Description:
--    Multiplexor Channel Controls - FA Register - Indicators
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
--		Revise Mpx and 1050 signals
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.Gates_package.all;
USE work.Buses_package.all;
USE work.FLL;

entity MpxFA is
    Port ( BUS_O_REG : in  STD_LOGIC_VECTOR (0 to 8);
           DIAG_SW : in  STD_LOGIC;
			  -- External MPX connections:
           MPX_BUS_OUT_BITS : out  STD_LOGIC_VECTOR (0 to 8);
           MPX_BUS_IN_BITS : in  STD_LOGIC_VECTOR (0 to 8);
           TAGS_OUT : out  MPX_TAGS_OUT;
           TAGS_IN : in  MPX_TAGS_IN;
			  --
			  FI : out STD_LOGIC_VECTOR(0 to 8); -- Mpx Bus In to CPU
           FAK : in  STD_LOGIC;
           RECYCLE_RST : in  STD_LOGIC;
           CK_P_BIT : in  STD_LOGIC;
           ALU_CHK_LCH : in  STD_LOGIC;
           CHK_SW_PROC_SW : in  STD_LOGIC;
           N1050_REQ_IN : in  STD_LOGIC;
           ROS_SCAN : in  STD_LOGIC;
           FBK_T2 : in  STD_LOGIC;
           FT5_BIT_SEL_IN : out  STD_LOGIC;
           SERV_IN_SIGNAL : out  STD_LOGIC;
           STATUS_IN_SIGNAL : out  STD_LOGIC;
           FT3_BIT_MPX_SHARE_REQ : out  STD_LOGIC;
           MPX_SHARE_REQ : out  STD_LOGIC;
           T1,T2,T3 : in  STD_LOGIC;
           ANY_PRIORITY_LCH : in  STD_LOGIC;
           CK_SALS_PWR : in  STD_LOGIC_VECTOR (0 to 3);
           SET_BUS_O_CTRL_LCH : in  STD_LOGIC;
           N1401_MODE : in  STD_LOGIC;
           N1050_OP_IN : in  STD_LOGIC;
           N1050_CE_MODE : in  STD_LOGIC;
           MPX_METERING_IN : out  STD_LOGIC;
           FT7_MPX_CHNL_IN : in  STD_LOGIC;
           LOAD_IND : in  STD_LOGIC;
           SUPPR_CTRL_LCH : in  STD_LOGIC;
           OP_OUT_SIGNAL : in  STD_LOGIC;
           OP_OUT_SIG : in  STD_LOGIC;
           SEL_O_FT6 : out  STD_LOGIC;
			  N1050_SEL_IN : out STD_LOGIC;
			  n1050_SEL_O : in STD_LOGIC;
			  P_1050_SEL_IN : out STD_LOGIC;
           P_1050_SEL_OUT : out STD_LOGIC;
			  N1050_INSTALLED : in STD_LOGIC;
           SUPPR_O : out  STD_LOGIC;
			  DEBUG : inout DEBUG_BUS;
           METERING_OUT : in  STD_LOGIC;
           CLOCK_OUT : in  STD_LOGIC;
			  CLK : in STD_LOGIC;
			  -- Mpx Indicators
				OPNL_IN,ADDR_IN,STATUS_IN,SERVICE_IN,
				SELECT_OUT,ADDR_OUT,COMMAND_OUT,SERVICE_OUT,
				SUPPRESS_OUT : out std_logic); -- 08A

end MpxFA;

architecture FMD of MpxFA is
signal	sSERV_IN_SIGNAL, sSTATUS_IN_SIGNAL, sADDR_OUT, sSUPPR_O, sOP_OUT : STD_LOGIC;
signal	SIS1,SIS2,SIS3 : STD_LOGIC;
signal	OP_INLK_SET, OP_INLK : STD_LOGIC;
signal	SERV_OUT, CMD_OUT : STD_LOGIC;
signal	sTAGS_OUT : MPX_TAGS_OUT;
signal	sTAGS_IN : MPX_TAGS_IN;
signal	sFT5_BIT_SEL_IN, Reset_SELO : STD_LOGIC;
signal	sn1050_SEL_OUT : STD_LOGIC;
signal	sn1050_SEL_IN : STD_LOGIC;
signal	CMD_STT_Set, RST_CMD_RSTT_ADDR_OUT, CMD_STT : STD_LOGIC;
signal	sFT3_BIT_MPX_SHARE_REQ, sSEL_O_FT6, sSUPPR_O_FT0 : STD_LOGIC;
signal	FAK_T2 : STD_LOGIC;
signal	SetAdrO2, ADDR_OUT_2, SetAdrOut, SetCmdO, RstCmdO, SetSrvO, RstSrvO : STD_LOGIC;
signal	SetCUBusyInlk, ResetCUBusyInlk, CUBusy, RST_STT_SEL_OUT : STD_LOGIC;
signal	ResetBusOCtrl, BUSOCtrl : STD_LOGIC;
signal	SetStartSelO, ResetStartSelO, StartSelO : STD_LOGIC;
signal	NO_1050_SEL_O : STD_LOGIC;
signal	SetSelReq, ResetSelReq, SetSelOInlk, SelOInlk : STD_LOGIC;
signal	SS_RECYCLE_RST : STD_LOGIC;
signal	NOT_OPL_IN : STD_LOGIC;
begin

STATUS_IN <= sTAGS_IN.STA_IN;
SERVICE_IN <= sTAGS_IN.SRV_IN;
ADDR_IN <= sTAGS_IN.ADR_IN; -- AA3F3
OPNL_IN <= sTAGS_IN.OPL_IN; -- AA3F2 AA3F5

SIS1 <= (not SERV_OUT and not CMD_OUT and sTAGS_IN.SRV_IN) or OP_INLK; -- AA3F2 AA3E2
sSERV_IN_SIGNAL <= SIS1 and (not sTAGS_IN.STA_IN or not sTAGS_IN.SRV_IN); -- Wire-AND, not sure about the OR bit
SERV_IN_SIGNAL <= sSERV_IN_SIGNAL;

SIS3 <= (not SERV_OUT and not CMD_OUT and sTAGS_IN.STA_IN) or (OP_INLK and not sTAGS_OUT.ADR_OUT); -- AA3D7 AA3E2
sSTATUS_IN_SIGNAL <= SIS3 and (not sTAGS_IN.STA_IN or not sTAGS_IN.SRV_IN); -- Wire-AND, not sure about the OR bit
STATUS_IN_SIGNAL <= sSTATUS_IN_SIGNAL;

OP_INLK_SET <= not sTAGS_IN.OPL_IN and T2;
OP_INLK_FL: entity FLL port map (S=>OP_INLK_SET, R=> T1, Q=>OP_INLK); -- AA3E4 ?? R=> NOT T1 ??

sn1050_SEL_IN <= sTAGS_IN.SEL_IN;
n1050_SEL_IN <= sn1050_SEL_IN;
sFT5_BIT_SEL_IN <= (sn1050_SEL_IN and not n1050_INSTALLED) or sn1050_SEL_IN; -- AA3E5 AA3E2
FT5_BIT_SEL_IN <= sFT5_BIT_SEL_IN;

Reset_SELO <= RECYCLE_RST or FBK_T2 or sFT5_BIT_SEL_IN; -- AA3D7 AA3E7

CMD_STT_Set <= CK_P_BIT and FAK_T2; -- ?? FMD has FAK not FAK_T2
RST_CMD_RSTT_ADDR_OUT <= (FAK and T1) or RECYCLE_RST; -- AA3E6 AA3E2
CMD_STT_FL: entity FLL port map (S=>CMD_STT_Set, R=>RST_CMD_RSTT_ADDR_OUT, Q=>CMD_STT); -- AA3D7 AA3E7
sFT3_BIT_MPX_SHARE_REQ <= (ROS_SCAN or not CMD_STT) and (N1050_REQ_IN or sTAGS_IN.REQ_IN or (ALU_CHK_LCH and CHK_SW_PROC_SW) or sTAGS_IN.OPL_IN); -- AA3F2 AA3E5 AA3G4

MPX_SHARE_REQ <= sFT3_BIT_MPX_SHARE_REQ;
FT3_BIT_MPX_SHARE_REQ <= sFT3_BIT_MPX_SHARE_REQ;

sTAGS_IN.OPL_IN <= TAGS_IN.OPL_IN or (DIAG_SW and BUS_O_REG(7)); -- AA3B4
sTAGS_IN.ADR_IN <= TAGS_IN.ADR_IN or (DIAG_SW and BUS_O_REG(6)); -- AA3B4
sTAGS_IN.STA_IN <= TAGS_IN.STA_IN or (DIAG_SW and BUS_O_REG(4)); -- AA3B4
sTAGS_IN.SRV_IN <= TAGS_IN.SRV_IN or (DIAG_SW and BUS_O_REG(5)); -- AA3B4
sTAGS_IN.SEL_IN <= TAGS_IN.SEL_IN or (DIAG_SW and BUS_O_REG(0)); -- AA3B4
sTAGS_IN.REQ_IN <= TAGS_IN.REQ_IN;
sTAGS_IN.MTR_IN <= TAGS_IN.MTR_IN;

MPX_BUS_OUT_BITS <= BUS_O_REG;

FAK_T2 <= FAK and (T2 and not ANY_PRIORITY_LCH); -- AA3B7 AA3F4 AA3E6

SetAdrO2 <= T3 and sADDR_OUT;
ADDR_OUT_2_FL: entity FLL port map (S=>SetAdrO2, R=>RST_CMD_RSTT_ADDR_OUT, Q=>ADDR_OUT_2); -- AA3E4

SetAdrOut <= FAK_T2 and CK_SALS_PWR(1);
ADDR_OUT_FL: entity FLL port map (S=>SetAdrOut, R=>RST_CMD_RSTT_ADDR_OUT, Q=>sADDR_OUT); -- AA3D7 AA3E7
ADDR_OUT <= sADDR_OUT;

SetCmdO <= FAK_T2 and CK_SALS_PWR(2);
RstCmdO <= not sTAGS_IN.ADR_IN and not sTAGS_IN.SRV_IN and not sTAGS_IN.STA_IN;
CMD_O: entity FLL port map (S=>SetCmdO, R=>RstCmdO, Q=>CMD_OUT); -- AA3E4 AA3E5
sTAGS_OUT.CMD_OUT <= CMD_OUT;

SetSrvO <= FAK_T2 and CK_SALS_PWR(3);
RstSrvO <= not sTAGS_IN.SRV_IN and not sTAGS_IN.STA_IN;
SRV_O: entity FLL port map (S=>SetSrvO, R=>RstSrvO, Q=>SERV_OUT); -- AA3C7

SetCUBusyInlk <= sTAGS_IN.STA_IN and ADDR_OUT_2 and FBK_T2;
ResetCUBusyInlk <= not sADDR_OUT and T2;
CU_BUSY_INLK: entity FLL port map (S=>SetCUBusyInlk, R=>ResetCUBusyInlk, Q=>CUBusy); -- AA3B5
RST_STT_SEL_OUT <= not OP_OUT_SIG or CUBusy; -- AA3F7

ResetBusOCtrl <= not sADDR_OUT and not CMD_OUT and not SERV_OUT; -- AA3D7
BUS_O_CTRL: entity FLL port map (S=>SET_BUS_O_CTRL_LCH, R=>ResetBusOCtrl, Q=>BUSOCtrl); -- AA3J5

SetStartSelO <= ADDR_OUT_2 and T2 and BUSOCtrl; -- AA3E6
ResetStartSelO <= RST_STT_SEL_OUT or (not N1401_MODE and sTAGS_IN.ADR_IN) or (not ADDR_OUT_2 and Reset_SelO); -- AA3F5 AA3K3
START_SEL_O: entity FLL port map (S=>SetStartSelO, R=>ResetStartSelO, Q=>StartSelO); -- AA3L4 AA3E7
sSEL_O_FT6 <= not CUBusy and (StartSelO or NO_1050_SEL_O or sN1050_SEL_OUT); -- AA3E5
SEL_O_FT6 <= sSEL_O_FT6;
NO_1050_SEL_O <= not N1050_INSTALLED and n1050_SEL_O; -- AA3D2

SetSelReq <= not SelOInlk and T2 and sFT3_BIT_MPX_SHARE_REQ;
ResetSelReq <= SelOInlk or not sFT3_BIT_MPX_SHARE_REQ;
SEL_REQ: entity FLL port map (S=>SetSelReq, R=>ResetSelReq, Q=>sN1050_SEL_OUT); -- AA3F4
-- To Select Out Propagation in 10B
P_1050_SEL_OUT <= sN1050_SEL_OUT;

SetSelOInlk <= (sTAGS_IN.ADR_IN and sTAGS_IN.OPL_IN) or (N1050_OP_IN and not N1050_CE_MODE); -- AA3B7
NOT_OPL_IN <= not sTAGS_IN.OPL_IN;
SEL_O_INLK: entity FLL port map (S=>SetSelOInlk, R=>NOT_OPL_IN, Q=>SelOInlk); -- AA3C7
-- sSUPPR_O <= (FT7_MPX_CHNL_IN and not sTAGS_IN.OPL_IN) or not LOAD_IND or SUPPR_CTRL_LCH; -- AA3C7 AA3E5
sSUPPR_O <= (FT7_MPX_CHNL_IN and not sTAGS_IN.OPL_IN) and not LOAD_IND and SUPPR_CTRL_LCH; -- AA3C7 AA3E5 ?? AA3C7 shown as 'OR'
SUPPR_O <= sSUPPR_O;

SS_RECYCLE_RST <= RECYCLE_RST; -- AA3G3 Single Shot ??
sOP_OUT <= OP_OUT_SIGNAL and not SS_RECYCLE_RST; -- AA3D6

sTAGS_OUT.ADR_OUT2 <= ADDR_OUT_2;
sTAGS_OUT.ADR_OUT <= sADDR_OUT;
-- sTAGS_OUT.CMD_OUT <= CMD_OUT;
sTAGS_OUT.SRV_OUT <= SERV_OUT;
sTAGS_OUT.SEL_OUT <= sSEL_O_FT6; -- ??
sTAGS_OUT.MTR_OUT <= METERING_OUT;
sTAGS_OUT.CLK_OUT <= CLOCK_OUT;
sTAGS_OUT.SUP_OUT <= sSUPPR_O;
sTAGS_OUT.OPL_OUT <= sOP_OUT;
-- sTAGS_OUT.SEL_OUT <= '0'; -- ??
sTAGS_OUT.STA_OUT <= '0'; -- ??
sTAGS_OUT.HLD_OUT <= '0'; -- ??

TAGS_OUT <= sTAGS_OUT;

FI <= MPX_BUS_IN_BITS;

-- Output tag indicators not really shown
SELECT_OUT <= sSEL_O_FT6;
ADDR_OUT <= sADDR_OUT;
COMMAND_OUT <= CMD_OUT;
SERVICE_OUT <= SERV_OUT;
SUPPRESS_OUT <= sSUPPR_O;

end FMD;

