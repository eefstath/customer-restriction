-- Author:	Efstathiou Emmanouil
-- File:		Flip Flop Package
-- Usage:	This file contains a multibit(n) D Flip Flop(vDFF) and a single-bit D Flip                   
--				Flop(sDFF).
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package ff is
	component vDFF is
		generic(n : integer := 1);
		port(	clk : in std_logic;
			D : in std_logic_vector(n-1 downto 0);
			Q : out std_logic_vector(n-1 downto 0));
	end component;

	component sDFF is
		port(	clk : in std_logic;
			D : in std_logic;
			Q : out std_logic);
	end component;
end package;
		
library ieee;
use ieee.std_logic_1164.all;

entity vDFF is
	generic(n : integer := 1);
	port(	clk : in std_logic;
		D : in std_logic_vector(n-1 downto 0);
		Q : out std_logic_vector(n-1 downto 0));
end vDFF;

architecture impl of vDFF is
	--integer clock counter
	signal v_count: integer range 0 to 50000000:= 0;
begin
	process(clk) begin
		if rising_edge(clk) then
			--1/4 second clock cycle (50 MHZ clock)
			if(v_count = 12499999) then
				v_count <= 0;
				Q <= D;
			else
				v_count <= v_count + 1;
			end if;
		end if;
	end process;
end impl;

library ieee;
use ieee.std_logic_1164.all;
entity sDFF is
	port(	clk : in std_logic;
		D : in std_logic;
		Q : out std_logic);
end sDFF;

architecture impl of sDFF is
	--integer clock counter
	signal s_count: integer range 0 to 50000000:= 0;
begin
	process(clk) begin
		if rising_edge(clk) then
			--1/4 second clock cycle (50 MHZ clock)
			if(s_count = 12499999) then
				s_count <= 0;
				Q <= D;
			else
				s_count <= s_count + 1;
			end if;
		end if;
	end process;
end impl;

