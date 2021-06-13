-- Author:	Efstathiou Emmanouil
-- File:	Declarations Package of Customer Restriction
-- Usage:	This file contains all the constants(states, bit lengths) of project Customer Restriction. 
---------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package CustomerRestrictionDeclarations is
	-- #bits needed for the number of customers declaration
	constant CWIDTH: integer := 7;						
	-- #limitation of customers inside (40)
	constant limit: std_logic_vector(CWIDTH-1 downto 0) := "0110011";	
	-- #bits needed for state declaration
	constant SWIDTH: integer := 2;				
	subtype state_type is std_logic_vector(SWIDTH-1 downto 0);
	constant IDLE: state_type := "00";
	constant PASS: state_type := "01";
	constant STOP: state_type := "10";
end package;
