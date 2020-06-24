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
--    File: gates2030.vhd
--    Creation Date: 
--    Description:
--    Definitions of the various types of gate, latches and flipflops used in the 2030.
--    
--    Page references like "5-01A" refer to the IBM Maintenance Diagram Manual (MDM)
--    for the 360/30 R25-5103-1
--    References like "02AE6" refer to coordinate "E6" on page "5-02A"
--    Logic references like "AB3D5" refer to card "D5" in board "B3" in gate "A"
--    Gate A is the main logic gate, B is the second (optional) logic gate,
--    C is the core storage and X is the CCROS unit
--
--    Revision History:
--    Revision 1.0
--    Initial release
--    Revision 1.1 2012-04-07
--		Add SingleShot (SS) and XilinxIOVector
--		Revise DelayRisingEdgeX implementation
---------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Gates_package is
component PH is port(D,L: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component PHV is port(D : in STD_LOGIC_VECTOR; L: in STD_LOGIC; signal Q:out STD_LOGIC_VECTOR); end component;
component PHR is port(D,L,R: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component PHRV is port(D : in STD_LOGIC_VECTOR; L,R: in STD_LOGIC; signal Q:out STD_LOGIC_VECTOR); end component;
component PHSR is port(D,L,S,R: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component FLE is port(S,R,clock: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component FLL is port(S,R: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component FLV is port(S,R: in STD_LOGIC_VECTOR; clock: in STD_LOGIC; signal Q:out STD_LOGIC_VECTOR); end component;
component FLVL is port(S,R: in STD_LOGIC_VECTOR; signal Q:out STD_LOGIC_VECTOR); end component;
--component FLAO is port( S1,S2,S3,R1,R2: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
function mux(sel : in STD_LOGIC; D : in STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
function EvenParity(v : in STD_LOGIC_VECTOR) return STD_LOGIC;
function AddByteParityToVector( I : std_logic_vector ) return std_logic_vector;
function RemoveByteParityFromVector( I : std_logic_vector ) return std_logic_vector;
component AddParity is port( I : in std_logic_vector; signal O : out std_logic_vector); end component;
component AR is port( D,Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component SS is port( Clk : in STD_LOGIC; Count : in integer; D: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
--component DEGLITCH is port( D,Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
--component DEGLITCH2 is port( D,Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component DelayEdge is port( D : in STD_LOGIC; Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end component;
component XilinxIOVector is port( I : in STD_LOGIC_VECTOR; T : in STD_LOGIC; O : out STD_LOGIC_VECTOR; IO : inout STD_LOGIC_VECTOR); end component;
type LED_DEVICE_TYPE is (MAX6951, MAX7219);
end Gates_package;


-- FL is no longer an edge-triggered SR flip-flop
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity FLE is port(S,R,clock: in STD_LOGIC; signal Q:inout STD_LOGIC); end;

architecture slt of FLE is
begin
process (S,R)
begin
if (R='1') then -- Reset takes priority
	Q<='0' after 1ns;
elsif (S='1') then
	Q<='1' after 1ns;
else
    Q<=Q;
end if;
end process;
end slt;

-- FLL is a level-triggered SR flip-flop
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity FLL is port(S,R: in STD_LOGIC; signal Q:inout STD_LOGIC); end;

architecture slt of FLL is
begin
process(S,R)
begin
if (S='1') then -- Set takes priority
	Q<='1' after 1ns;
elsif (R='1') then
	Q<='0' after 1ns;
else
    Q<=Q;
end if;
end process;
end slt;

-- Simple PH (polarity hold) latch - Transparent Latch
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity PH is port(D: in STD_LOGIC; L: in STD_LOGIC; signal Q:inout STD_LOGIC); end;

architecture slt of PH is
begin
process (L,D)
begin
if (L='1') then
	Q <= D;
else
    Q <= Q;
end if;
end process;
end slt;

-- Simple PH (polarity hold) latch - Transparent Latch, STD_LOGIC_VECTOR version
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity PHV is port(D: in STD_LOGIC_VECTOR; L: in STD_LOGIC; signal Q:inout STD_LOGIC_VECTOR); end;

architecture slt of PHV is
alias D1 : STD_LOGIC_VECTOR(Q'range) is D;
begin
process (L,D)
begin
for i in Q'range loop
if (L='1') then
	Q(i) <= D1(i);
else
    Q(i) <= Q(i);
end if;
end loop;
end process;
end slt;

-- PH Latch with asynchronous reset - Reset has priority
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity PHR is port( D: in STD_LOGIC; L,R: in STD_LOGIC; signal Q:inout STD_LOGIC); end;

architecture slt of PHR is
begin
process (L,D,R)
begin
if (R='1') then
	Q <= '0';
elsif (L='1') then
	Q <= D;
else
    Q <= Q;
end if;
end process;
end slt;

-- PH Latch with asynchronousreset, STD_LOGIC_VECTOR version
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity PHRV is port(D: in STD_LOGIC_VECTOR; L,R: in STD_LOGIC; signal Q:inout STD_LOGIC_VECTOR); end;

architecture slt of PHRV is
alias D1 : STD_LOGIC_VECTOR(Q'range) is D;
begin
process (L,R,D1)
begin
for i in Q'range loop
if (R='1') then
   Q(i) <= '0';
elsif (L='1') then
	Q(i)<=D1(i);
else
    Q(i)<=Q(i);
end if;
end loop;
end process;
end slt;

--- PH Latch with asynchronous set & reset, Reset has priority, then Set, then input
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity PHSR is port(D,L,S,R: in STD_LOGIC; signal Q:inout STD_LOGIC); end;

architecture slt of PHSR is
begin
process (L,D,S,R)
begin
if (R='1') then
	Q <= '0';
elsif (S='1') then
	Q <= '1';
elsif (L='1') then
	Q <= D;
else
    Q <= Q;
end if;
end process;
end slt;

-- Simple FL (SR) flipflops, edge-triggered S,R inputs
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity FLV is port( S,R: in STD_LOGIC_VECTOR; signal clock: STD_LOGIC; signal Q:inout STD_LOGIC_VECTOR); end;

architecture slt of FLV is
alias S1 : STD_LOGIC_VECTOR(Q'range) is S;
alias R1 : STD_LOGIC_VECTOR(Q'range) is R;
signal S2,R2 : STD_LOGIC_VECTOR(Q'range) := (others=>'0');
begin
process (S1,R1,clock)
begin
if (rising_edge(clock)) then
	for i in Q'range loop
		if (R(i)/=R2(i) and R(i)='1') then
			Q(i) <= '0';
		elsif (S(i)/=S2(i) and S(i)='1') then
			Q(i) <= '1';
		else
		    Q(i) <= Q(i);
		end if;
		R2 <= R1;
		S2 <= S1;
	end loop;
end if;
end process;
end slt;

-- FL vector, level triggered S,R inputs
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity FLVL is port( S,R: in STD_LOGIC_VECTOR; signal Q:inout STD_LOGIC_VECTOR); end;

architecture slt of FLVL is
alias S1 : STD_LOGIC_VECTOR(Q'range) is S;
alias R1 : STD_LOGIC_VECTOR(Q'range) is R;
begin
process (S1,R1)
begin
for i in Q'range loop
if (S1(i)='1') then -- Set takes priority
	Q(i)<='1';
elsif (R1(i)='1') then
	Q(i)<='0';
else
    Q(i) <= Q(i);
end if;
end loop;
end process;
end slt;

-- Simple 1 cycle delay from line driver (AR)
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity AR is port( D,Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end;

architecture slt of AR is
signal Q1 : std_logic;
begin
process(D,Clk)
begin
if (rising_edge(Clk)) then
	Q <= Q1;
	Q1 <= D;
end if;
end process;
end slt;

-- Simple single-shot (SS)
LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity SS is port( Clk : in STD_LOGIC; Count : in integer; D: in STD_LOGIC; signal Q:out STD_LOGIC); end;

architecture slt of SS is
signal C : integer;
begin
process(D,Clk)
begin
if (rising_edge(Clk)) then
	if (C = 0) then
		if D='1' then
			C <= Count;
			Q <= '1';
		else
			Q <= '0';
		end if;
	else
		if (C = 1) then
			Q <= '0';
			if D='0' then
				C <= 0;
			end if;
		else
			C <= C - 1;
			Q <= '1';
		end if;
	end if;
end if;
end process;
end slt;

-- Simple 1 cycle de-glitch
-- LIBRARY ieee;
-- USE ieee.std_logic_1164.all;
-- entity DEGLITCH is port( D,Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end;

-- architecture slt of DEGLITCH is
-- signal DD : std_logic_vector(0 to 1);
-- begin
-- process(D,Clk)
-- begin
-- if (rising_edge(Clk)) then
-- 	DD <= DD(1) & D;
-- end if;
-- end process;
-- with DD select
-- 	Q <= '0' when "00"|"01", '1' when others ;
-- end slt;

-- Simple 2 cycle de-glitch
-- LIBRARY ieee;
-- USE ieee.std_logic_1164.all;
-- entity DEGLITCH2 is port( D,Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end;

-- architecture slt of DEGLITCH2 is
-- signal DD : std_logic_vector(0 to 2);
-- begin
-- process(D,Clk)
-- begin
-- if (rising_edge(Clk)) then
-- 	DD <= DD(1 to 2) & D;
-- end if;
-- end process;
-- with DD select
-- 	Q <= '0' when "000"|"001"|"010"|"011", '1' when others ;
-- end slt;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity DelayEdge is port( D : in STD_LOGIC; Clk: in STD_LOGIC; signal Q:out STD_LOGIC); end;

architecture slt of DelayEdge is
signal Q1 : std_logic_vector(1 to 4) := "0000";
begin
process(Clk)
begin
if (rising_edge(Clk)) then
	if (D='0') then
		Q <= '0';
		Q1 <= "0000";
	else
	   if (Q1="1111") then
		  Q <= '1';
		  Q1 <= "1111";
	   else
		  Q <= '0';
		  Q1 <= Q1(2 to 4) & '1';
	   end if;
	end if;
end if;
end process;
end slt;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
entity XilinxIOVector is port( I : in STD_LOGIC_VECTOR(0 to 8); T : in STD_LOGIC; O : out STD_LOGIC_VECTOR(0 to 8); IO : inout STD_LOGIC_VECTOR(0 to 8)); end;

architecture slt of XilinxIOVector is
component IOBUF port (I, T: in std_logic; O: out std_logic; IO: inout std_logic); end component;
begin
word_generator: for b in 0 to 8 generate
	begin
		U1: IOBUF port map (I => I(b), T => T, O => O(b), IO => IO(b));
	end generate;
end slt;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY logic;
USE logic.Gates_package.all;
entity AddParity is port ( I : in STD_LOGIC_VECTOR; O : out STD_LOGIC_VECTOR); end;
architecture behavioral of AddParity is
begin
O <= AddByteParityToVector(I);
end behavioral;  

LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY logic;
USE logic.Gates_package.all;
entity RemoveParity is port ( I : in STD_LOGIC_VECTOR; O : out STD_LOGIC_VECTOR); end;
architecture behavioral of RemoveParity is
begin
O <= RemoveByteParityFromVector(I);
end behavioral;  


package body Gates_package is
--type LED_DEVICE_TYPE is (MAX6951, MAX7219);

-- Variable width AND-OR multiplexor component
function mux(sel : in STD_LOGIC; D : in STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
alias D2:STD_LOGIC_VECTOR(1 to D'LENGTH) is D;
variable Q : STD_LOGIC_VECTOR(1 to D'LENGTH);
begin
	if (sel = '1') then
		Q := D;
	else
		Q := (others=>'0');
	end if;
return Q;
end function mux;

function EvenParity(v : in STD_LOGIC_VECTOR) return STD_LOGIC is
variable p : STD_LOGIC;
begin
	p := '1';
	for m in v'range loop
		p := p xor v(m);
	end loop;
	return p;
end;

function AddByteParityToVector( I : std_logic_vector ) return std_logic_vector is
variable O : std_logic_vector(I'length + ((I'length+7)/8) downto 0);
variable inBit : integer range I'range;
variable outBit : integer range 0 to I'length + ((I'length+7)/8);
variable by : integer range 0 to ((I'length+7)/8);
variable bi : integer range 0 to 7;
variable p : std_logic;
begin
    inBit := I'low;
    outbit := 0;
    for by in 1 to (I'length+7)/8 loop
        p := '0';
        for bi in 0 to 7 loop
            if (inBit <= I'high) then
                O(outBit) := I(inBit);
                p := p xor I(inBit);
                inBit := inBit + 1;
                outBit := outBit + 1;
            end if;
        end loop;
        O(outBit) := p;
        outBit := outBit + 1;
    end loop;
    return O;
end function;

function RemoveByteParityFromVector( I : std_logic_vector ) return std_logic_vector is
variable O : std_logic_vector(I'length - ((I'length+8)/9) downto 0);
variable inBit : integer range I'range;
variable outBit : integer range 0 to I'length + ((I'length+7)/8);
variable by : integer range 0 to ((I'length+7)/8);
variable bi : integer range 0 to 7;
begin
    inBit := I'low;
    outbit := 0;
    for by in 1 to (I'length+7)/8 loop
        for bi in 0 to 7 loop
            if (inBit <= I'high) then
                O(outBit) := I(inBit);
                inBit := inBit + 1;
                outBit := outBit + 1;
            end if;
        end loop;
        inBit := inBit + 1;
end loop;
return O;
end function;


end Gates_package;
