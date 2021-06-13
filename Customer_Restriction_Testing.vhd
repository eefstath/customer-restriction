-- Author:	Efstathiou Emmanouil
-- File: 	Customer Restriction Testing
-- Usage:	This file contains the testbench of project Customer Restriction
---------------------------------------------------------------------------------------------------------------------
--pragma translate_off
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.CustomerRestrictionDeclarations.all;

entity Customer_Restriction_Testing is
end Customer_Restriction_Testing;

architecture test of Customer_Restriction_Testing is
	--Component Declaration
	component Customer_Restriction is
		port(
			clk, rst: in std_logic;							
			front_sensor, back_sensor: in std_logic;				
			customers: in std_logic_vector(CWIDTH-1 downto 0);			
												

			hex_1, hex_0: out std_logic_vector(6 downto 0);				
			green_led, red_led: out std_logic					
		);
	end component;
	
	--Function Declaration
	function sev_seg_to_integer( bin: std_logic_vector(6 downto 0)) return integer is
		variable digit: integer := 0;	
	begin
		case(bin) is
			when "1000000" => digit := 0;	
			when "1111001" =>  digit := 1;	
   			when "0100100" =>  digit := 2;	
  			when "0110000" =>  digit := 3; 	
   			when "0011001" =>  digit := 4; 	
   			when "0010010" =>  digit := 5; 	   
   			when "0000010" =>  digit := 6; 	
   			when "1111000" =>  digit := 7; 	  
   			when "0000000" =>  digit := 8; 	
   			when "0010000" =>  digit := 9; 	
   			when "0001000" =>  digit := 10; 
   			when "0000011" =>  digit := 11; 
   			when "1000110" =>  digit := 12; 
   			when "0100001" =>  digit := 13; 
   			when "0000110" =>  digit := 14; 
   			when others =>  digit := 15; 	
		end case;
		return digit;
	end sev_seg_to_integer;

	--Signal Declaration
	signal clk, rst, front_sensor, back_sensor: std_logic;						-- inputs	
	signal customers: std_logic_vector(CWIDTH-1 downto 0);
	
	signal hex_1, hex_0: std_logic_vector(6 downto 0);						-- outputs
	signal green_led, red_led: std_logic;	
begin
	DUT: entity work.Customer_Restriction(impl)
		port map(clk, rst, front_sensor, back_sensor, customers, hex_1, hex_0, green_led, red_led);

	--Clock simulation process
	process begin
		wait for 5 ns; clk <= '1';
		wait for 5 ns; clk <= '0';
	end process;

	--Write results to file CRT_results.txt process
	process(clk)
		file file_pointer: text open write_mode is "CRT_results.txt";
		variable line_el: line;
	begin
		if falling_edge(clk) then
			--Time Output
			write(line_el, "Time: "& to_string(now),left, 15);
			
			--Sensors/Reset Output
			if rst then
				write(line_el, string'("RESETING TO ") & to_string(to_integer(unsigned(customers))),left, 30);
			else
				if(front_sensor = '1' AND back_sensor = '1') then
					write(line_el, string'("Entering and Leaving"), left, 30);
				elsif(front_sensor = '1' AND back_sensor = '0') then
					write(line_el, string'("Entering"), left, 30);
				elsif(front_sensor = '0' AND back_sensor = '1') then
					write(line_el, string'("Leaving"), left, 30);
				else
					write(line_el, string'(" "), left, 30);
				end if;
			end if;

			--State Output
			if(<<signal DUT.CURRENT_STATE: std_logic_vector>> = "00") then
				write(line_el, string'("IDLE"), left, 15);
			elsif (<<signal DUT.CURRENT_STATE: std_logic_vector>> = "01") then
				write(line_el, string'("PASS"), left, 15);
			else
				write(line_el, string'("STOP"), left, 15);
			end if;
			
			--Led Output
			if(green_led = '1') then
				write(line_el, string'("GREEN"), left, 15);
			end if;
			if(red_led = '1') then
				write(line_el, string'("RED"), left, 15);
			end if;

			--Allowed Customers Output
			write(line_el,to_string(sev_seg_to_integer(hex_1)) & to_string(sev_seg_to_integer(hex_0)), left, 15);

			--Inside Customers Output
			write(line_el, to_string(to_integer(unsigned(<<signal DUT.AMOUNT: std_logic_vector>>))) & "/" & to_string(to_integer(unsigned(limit))), left, 15);

			writeline(file_pointer, line_el);
		end if;
	end process;

	--Simulation Process
	process begin
		--RESETING
		rst <= '1'; customers <= "0100011";
		(front_sensor, back_sensor) <= std_logic_vector'("00");
		wait for 25 ns; rst <= '0'; wait for 10 ns;

		--1st TEST: 	35 TO FULL STORE SIMULATION
		--		5 customers entering.
		for i in 0 to 4 loop
			(front_sensor, back_sensor) <= std_logic_vector'("10");
			wait for 10 ns;
			(front_sensor, back_sensor) <= std_logic_vector'("00");
			wait for 10 ns;
		end loop;

		--2nd TEST: 	FULL STORE SIMULATION
		--		2 customers entering and leaving an already full store.
		for i in 0 to 1 loop
			(front_sensor, back_sensor) <= std_logic_vector'("10");
			wait for 10 ns;
			(front_sensor, back_sensor) <= std_logic_vector'("00");
			wait for 10 ns;
		end loop;
		for i in 0 to 1 loop
			(front_sensor, back_sensor) <= std_logic_vector'("01");
			wait for 10 ns;
			(front_sensor, back_sensor) <= std_logic_vector'("00");
			wait for 10 ns;
		end loop;

		--RESETING
		rst <= '1'; customers <= "0000000";
		(front_sensor, back_sensor) <= std_logic_vector'("00");
		wait for 25 ns; rst <= '0'; wait for 10 ns;

		--3rd TEST: 	EMPTY STORE SIMULATION
		--		A customer leaving an already empty store.
		(front_sensor, back_sensor) <= std_logic_vector'("01");
		wait for 10 ns;
		(front_sensor, back_sensor) <= std_logic_vector'("00");
		wait for 10 ns;

		--4rth TEST: 	ENTERING AND LEAVING AT THE SAME TIME
		--		2 customers enter and leave at the same time.
		(front_sensor, back_sensor) <= std_logic_vector'("10");
		wait for 10 ns;
		(front_sensor, back_sensor) <= std_logic_vector'("00");
		wait for 10 ns;
		(front_sensor, back_sensor) <= std_logic_vector'("11");
		wait for 10 ns;
		(front_sensor, back_sensor) <= std_logic_vector'("00");
		wait for 10 ns;

		--5th TEST: 	RESETING TO AN OVERFILLED SPACE
		--		Reseting to 42 customers with 40 customer limit 
		--		and 3 customers leaving.
		rst <= '1'; customers <= "0101010";
		(front_sensor, back_sensor) <= std_logic_vector'("00");
		wait for 25 ns; rst <= '0'; wait for 10 ns;
		for i in 0 to 2 loop
			(front_sensor, back_sensor) <= std_logic_vector'("01");
			wait for 10 ns;
			(front_sensor, back_sensor) <= std_logic_vector'("00");
			wait for 10 ns;
		end loop;
		wait for 100 ns;
		std.env.stop(0);

	end process;
end test;
--pragma translate_on
