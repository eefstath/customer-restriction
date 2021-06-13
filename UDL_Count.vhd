-- Author:	Efstathiou Emmanouil
-- File:	Multibit binary Up/Down/Load Counter
-- Usage:	A counter that holds, increments, decrements or loads a multibit(n) input(input) in a   
--		buffer(output).
---------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.ff.all;
											
entity UDL_Count is
	generic(n: integer := 4);
	port(
		--clock, reset signals	
		clk, rst: in std_logic;	
		-- up: increment, down: decrement signals	
		up, down: in std_logic;			
		output: buffer std_logic_vector(n-1 downto 0)
	);
end UDL_Count;

architecture impl of UDL_count is
	--Component Declaration
	component MUX4 is
		generic(k: integer := 1);
		port(
			-- inputs
			a3, a2, a1, a0: in std_logic_vector(k-1 downto 0);	
			-- one-hot select signal
			s: in std_logic_vector(3 downto 0);	
			-- selected output				
			b: out std_logic_vector(k-1 downto 0)			
		);
	end component;

	--Signal Declaration
	-- result: holds the result of  increment/decrement
	-- nxt:    holds multiplexer decision
	signal result, nxt: std_logic_vector(n-1 downto 0);	
begin
	-- component used to load value of nxt to output on each clock cycle
	REG: vDFF generic map(n) port map(clk, nxt, output);	
	
	-- results holds the value of output + ..001 (increment) OR output + ..111 (decrement)
	-- because ..111 equals -1 (2's complement).
	result <= output + ((n-2 downto 0 => (not up)) & '1');	

	-- "1000" picks output as is
	-- "0100" picks increment/decrement of output(signal result)
	-- "0010" picks 0
	-- "0001" picks output as is (not needed)
	MUX: MUX4 generic map(n) port map(output, result, (n-1 downto 0 => '0'), output,
		((not rst) AND (not up) AND (not down)) &				
		((not rst) AND (up OR down)) &	
		rst &										
		'0',
		nxt);	
end impl;
