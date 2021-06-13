-- Author:	Efstathiou Emmanouil
-- File:	Multibit binary Adder
-- Usage:	This file computes a multi bit(n) addition of 2 signals, a and b.
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Adder is
	generic(n: integer := 8);
	port(
		a, b: in std_logic_vector(n-1 downto 0);
		-- carry in
		cin: in std_logic;			
		-- carry out
		cout: out std_logic;					
		-- result
		s: out std_logic_vector(n-1 downto 0)				
	);
end Adder;

architecture impl of Adder is
	signal sum: std_logic_vector(n downto 0);
begin
	sum <= ('0' & a) + ('0' & b) + cin;
	cout <= sum(n);
	s <= sum(n-1 downto 0);
end impl;

