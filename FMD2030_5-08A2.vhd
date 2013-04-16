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
--    File: FMD2030_5-08A2.vhd
--    Creation Date: 22:26:31 18/04/05
--    Description:
--    Multiplexor Channel Indicators
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MpxInd is Port (
			  -- Mpx Indicator stuff
				TEST_LAMP : in std_Logic; -- 04A
				OPNL_IN,ADDR_IN,STATUS_IN,SERVICE_IN,
				SELECT_OUT,ADDR_OUT,COMMAND_OUT,SERVICE_OUT,
				SUPPRESS_OUT : in std_logic; -- 08D
				FO_P : in std_logic; -- 08C
				FO : in std_logic_vector(0 to 7); -- 08C
				IND_OPNL_IN, IND_ADDR_IN,IND_STATUS_IN,IND_SERV_IN,
				IND_SEL_OUT,IND_ADDR_OUT,IND_CMMD_OUT,IND_SERV_OUT,
				IND_SUPPR_OUT,IND_FO_P : out std_logic;
				IND_FO : out std_logic_vector(0 to 7)
			  );
end MpxInd;

architecture FMD of MpxInd is
begin
-- The indicator drivers for the Multiplexor channel are here
IND_OPNL_IN <= OPNL_IN or TEST_LAMP;
IND_ADDR_IN <= ADDR_IN or TEST_LAMP;
IND_STATUS_IN <= STATUS_IN or TEST_LAMP;
IND_SERV_IN <= SERVICE_IN or TEST_LAMP;
IND_SEL_OUT <= SELECT_OUT or TEST_LAMP;
IND_ADDR_OUT <= ADDR_OUT or TEST_LAMP;
IND_CMMD_OUT <= COMMAND_OUT or TEST_LAMP;
IND_SERV_OUT <= SERVICE_OUT or TEST_LAMP;
IND_SUPPR_OUT <= SUPPRESS_OUT or TEST_LAMP;
IND_FO_P <= FO_P or TEST_LAMP;
IND_FO <= FO or (FO'range => TEST_LAMP);

end FMD;
