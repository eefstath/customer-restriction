-- Author:	Efstathiou Emmanouil
-- File:		Customer Restriction
-- Usage:	This project counts the number of customers inside a space and depending on the
-- 			limit declared, allows or disallows the entrance of new ones by displaying a                
--				green/red light and 2 seven segment led digits which contain the amount of customers 
--     		allowed to enter.
---------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.CustomerRestrictionDeclarations.all;
use work.ff.all;

entity Customer_Restriction is
	port(
		-- clock and reset input
		clk, rst: in std_logic;		
		
		-- entrance and exit sensors input		
		front_sensor, back_sensor: in std_logic;			
		
		-- 7-segment digit enable
		enable_digit1, enable_digit2: out std_logic;
		
		-- 7-segment binaries for 7-segment led digits
		hex: out std_logic_vector(6 downto 0);		

		-- red and green led indicators for the entrance restriction		
		green_led, red_led: out std_logic					
	);
end Customer_Restriction;

architecture impl of Customer_Restriction is
	--Component Declaration Counter
	component UDL_Count is
		generic(n: integer := 4);
		port(
			-- clock, reset signals
			clk, rst: in std_logic;		
	
			-- up: increment, down: decrement signals
			up, down: in std_logic;			
			output: buffer std_logic_vector(n-1 downto 0)
		);
	end component;

	--Component Declaration Adder/Subtractor
	component AddSub is
		generic(n: integer := 8);
		port(
			a, b: in std_logic_vector(n-1 downto 0);
			-- subtract if sub=1 else add
			sub: in std_logic;				
			s: out std_logic_vector(n-1 downto 0);
			-- 1 if overflow
			ovf: out std_logic						
		);
	end component;

	--Component Declaration 7-segment Decoder
	component seven_segment_display is
		port(
			bin: in std_logic_vector(3 downto 0);
			hout: out std_logic_vector(6 downto 0)
		);
	end component;

	--Function Declaration BCD Converter
	function to_bcd( bin: std_logic_vector(CWIDTH-1 downto 0)) return std_logic_vector is
		variable i: integer := 0;
		variable bcd: std_logic_vector(11 downto 0) := (others => '0');
		variable bint: std_logic_vector(CWIDTH-1 downto 0) := bin;
	begin
		for i in 0 to CWIDTH-1 loop  
			bcd(11 downto 1) := bcd(10 downto 0);  		
			--shifting the bits	
			bcd(0) := bint(CWIDTH-1);
			bint(CWIDTH-1 downto 1) := bint(CWIDTH-2 downto 0);
			bint(0) :='0';
			
			-- add 3 if BCD digit is greater than 4
			if(i < CWIDTH-1 and bcd(3 downto 0) > "0100") then 	
				bcd(3 downto 0) := bcd(3 downto 0) + "0011";
			end if;

			if(i < CWIDTH-1 and bcd(CWIDTH-1 downto 4) > "0100") then 	
  			-- add 3 if BCD digit is greater than 4
				bcd(7 downto 4) := bcd(CWIDTH-1 downto 4) + "0011";
			end if;

			-- add 3 if BCD digit is greater than 4
			if(i < CWIDTH-1 and bcd(11 downto 8) > "0100") then  
				bcd(11 downto 8) := bcd(11 downto 8) + "0011";
			end if;
		end loop;
		return bcd;
	end to_bcd;
 
	--Signal Declaration
	-- signals for state transition(declared in declaration's file)
	signal current_state, next_state, next_one: state_type;				

	-- #customers currently in the premises
	signal amount: std_logic_vector(CWIDTH-1 downto 0) := (others => '0');	

	-- #customers allowed to enter	
	signal allowed: std_logic_vector(CWIDTH-1 downto 0);				

	-- full or empty space when high
	signal full, empty:  std_logic;	

	-- increase/decrease signals						
	signal inc, dec: std_logic;	

	-- one-hot signal for the inc/dec operation						
	signal operation_select: std_logic_vector(1 downto 0);	

	-- overflow signal of Adder/Subtractor component			
	signal ovf: std_logic;								

	-- bcd binary of allowed customers
	signal bcd_display: std_logic_vector(11 downto 0);				
	
	-- 7-segment digits
	signal digit_0, digit_1: std_logic_vector(6 downto 0);				

	--signal hex
	signal hex_signal: std_logic_vector(6 downto 0);
	
	-- signals for disabling the sensor inputs when high for more than one clock cycle.
	signal first_front, nfirst_front: std_logic;					
	signal first_back, nfirst_back: std_logic;	

	-- signals to reverse inputs
	signal not_fs: std_logic;
	signal not_bs: std_logic;
	signal not_rst: std_logic;
	
	--clock counter for seven segment display
	signal clk_cnt: std_logic_vector(12 downto 0);
	
begin

--------Control----------------------------------------------------------------------------------------------------
	
	-- Reverse sensor inputs
	not_fs <= not front_sensor;
	not_bs <= not back_sensor;
	not_rst <= not rst;
	
	-- Front and back sensors count as high only on first clock cycle so no that a delayed 
	-- entrance/exit will not count as 2 or more.
	nfirst_front <= not not_fs;						
	nfirst_back <= not not_bs;							
	FRONT_SENSOR_CHECK: sDFF port map(clk, nfirst_front, first_front);		
	BACK_SENSOR_CHECK: sDFF port map(clk, nfirst_back, first_back);

	--Increase/Decrease Operations
	-- Inc or dec goes high when a customer enters or leaves.
	-- If both go high at the same time there is no need for an operation. (example: 30 +1 -1 = 30)
	inc <= not_fs AND first_front;						
	dec <= not_bs AND (not empty) AND first_back;				
	operation_select <= (inc AND (not dec)) & ((not inc) AND dec);			

	--State Transition
	-- Component used for state transition on each clock cycle,	
	-- when reset is high the system restarts at IDLE state
	-- else next_one will become the current_state at next cycle
	STATE_REG: vDFF generic map(SWIDTH) port map(clk, next_state, current_state);
	next_one <= STOP when (full='1') else PASS;						
	next_state <= IDLE when (not_rst='1') else next_one;
											
	--Led Indicators
	-- At state PASS : green light.
	-- At all other states: red light.
	green_led <= '0' when current_state = PASS else '1';				
	red_led <= '1' when current_state = PASS else '0';	
			
	--7-Segment Led Digits
	-- When either the premises are full or reset is on, led digits will show 0. Else the customers 
	-- allowed to enter.
	--hex <= "1000000" when (full='1' or not_rst='1') else digit_0;	

	process(clk) begin
		if(not_rst='1') then
			clk_cnt <= (others => '0');
		elsif(rising_edge(clk)) then
			clk_cnt <= clk_cnt + 1;
		end if;
	end process;
	
	enable_digit1 <= '0' when clk_cnt(clk_cnt'high) = '1' else '1';
	enable_digit2 <= '0' when clk_cnt(clk_cnt'high) = '0' else '1';
	hex_signal <= digit_0 when clk_cnt(clk_cnt'high) = '1' else digit_1;
	hex <= hex_signal when not_rst = '0' else "0111111"; 
						
--------Data-------------------------------------------------------------------------------------------------------

	--Comparators.
	-- When amount equals or surpasses limit the space is full.
	-- When amount equals 0 the space is empty.
	full <= '1' when amount >= limit else '0';					
	empty <= '1' when amount = (amount'range => '0') else '0';			

	--Counter
	-- Counter of customers currently in the premises.
	UDL: UDL_Count generic map(CWIDTH)
			port map(clk, not_rst, operation_select(1), operation_select(0), amount);	
			
	--Subtractor	
	-- Subtraction of limit and customers currently inside to determine customers allowed to enter.
	AS: AddSub generic map(CWIDTH)							
			port map(limit, amount, '1', allowed, ovf);			
	
	--BCD Converter
	-- Convert binary to bcd.
	bcd_display <= to_bcd(allowed);							

	--7-segment Decoder
	-- Convert each bcd digit to seven segment display
	DEC_0: seven_segment_display port map(bcd_display(3 downto 0), digit_0);
	DEC_1: seven_segment_display port map(bcd_display(7 downto 4), digit_1);

end impl;
