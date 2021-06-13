-- Author:	Efstathiou Emmanouil
-- File:		4 Multibit binary Multiplexer
-- Usage:	This file selects between 4 multibit(k) signals, a3, a2, a1 and a0 depending on                               
-- 			one-hot input s.
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity MUX4 is
	generic(k: integer := 1);
	port(
		-- inputs
		a3, a2, a1, a0: in std_logic_vector(k-1 downto 0);	
		-- one-hot select signal
		s: in std_logic_vector(3 downto 0);	
		-- selected output		
		b: out std_logic_vector(k-1 downto 0)			
	);
end MUX4;

architecture impl of MUX4 is
begin
	b <= 	((k-1 downto 0 => s(3)) and a3) or
			((k-1 downto 0 => s(2)) and a2) or
			((k-1 downto 0 => s(1)) and a1) or
			((k-1 downto 0 => s(0)) and a0) ;
end impl;
