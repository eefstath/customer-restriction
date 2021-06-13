-- Author:	Efstathiou Emmanouil
-- File:		7 segment Decoder
-- Usage:	This file selects a 7-bit binary output, depending on a 4-bit binary, used in 7              
--				segment led to display a decimal digit.
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity seven_segment_display is 
	port(
		bin: in std_logic_vector(3 downto 0);
		hout: out std_logic_vector(6 downto 0)
	);
end seven_segment_display;

architecture impl of seven_segment_display is
begin
	process(bin) begin
		case(bin) is
			when "0000" =>  hout <= "1000000"; --0--
			when "0001" =>  hout <= "1111001"; --1--
   		when "0010" =>  hout <= "0100100"; --2--
  			when "0011" =>  hout <= "0110000"; --3--
   		when "0100" =>  hout <= "0011001"; --4-- 
   		when "0101" =>  hout <= "0010010"; --5--    
			when "0110" =>  hout <= "0000010"; --6--
			when "0111" =>  hout <= "1111000"; --7--   
			when "1000" =>  hout <= "0000000"; --8--
			when "1001" =>  hout <= "0010000"; --9--
			when "1010" =>  hout <= "0001000"; --a--
			when "1011" =>  hout <= "0000011"; --b--
			when "1100" =>  hout <= "1000110"; --c--
			when "1101" =>  hout <= "0100001"; --d--
			when "1110" =>  hout <= "0000100"; --e--
			when "1111" =>  hout <= "0001110"; --f--
			when others =>  hout <= "0111111"; --fault
		end case;
	end process;
end impl;

