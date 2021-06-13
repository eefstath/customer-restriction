-- Author:	Efstathiou Emmanouil
-- File:	Multibit binary Adder/Subtractor
-- Usage:	This file computes a multibit(n) addition/subtraction of 2 signals, a and b depending  
-- 		on the sub input.
---------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity AddSub is
	generic(n: integer := 8);
	port(
		a, b: in std_logic_vector(n-1 downto 0);
		-- subtract if sub=1 else add
		sub: in std_logic;				
		s: out std_logic_vector(n-1 downto 0);
		-- 1 if overflow
		ovf: out std_logic					
);
end AddSub;

architecture impl of AddSub is
	--Component Declaration
	component Adder is
		generic(n: integer := 8);
		port(
			a, b: in std_logic_vector(n-1 downto 0);
			cin: in std_logic;
			cout: out std_logic;
			s: out std_logic_vector(n-1 downto 0)
		);
	end component;
	
	--Signal Declaration
	-- carry out of last two bits
	signal c1, c2: std_logic;					
begin
	-- overflow if signs don't match
	ovf <= c1 xor c2;	
				
	--Add/Sub non sign bits
	Ai: Adder generic map(n-1)
		port map(a(n-2 downto 0), b(n-2 downto 0) xor (n-2 downto 0 => sub), sub, c1, s(n-2 downto 0));
	--Add/Sub sign bits
	As: Adder generic map(1)
		port map(a(n-1 downto n-1), b(n-1 downto n-1) xor (0 downto 0 => sub), c1, c2, s(n-1 downto n-1));
end impl;

