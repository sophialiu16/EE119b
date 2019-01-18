----------------------------------------------------------------------------
--
--  Test Bench for SerialDivider
--
--  This is a test bench for the SerialDivider entity. The test bench
--  thoroughly tests the entity by exercising it and checking the outputs
--  through the use of an array of test values (TestVector). The test bench
--  entity is called SerialDividerTB.
--
--  Revision History:
--      4/4/00   Automated/Active-VHDL    Initial revision.
--      11/21/18 Sophia Liu 			      Updated for bit serial multiplier testing
--      11/22/18 Sophia Liu 					Updated comments 
--
----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; 
use work.DividerConstants.all; 


entity SerialDividerTB is
end SerialDividerTB;

architecture TB_ARCHITECTURE of SerialDividerTB is

    -- Component declaration of the tested unit
    component SerialDivider
		 port (
        nCalculate  :  in   std_logic;
        DivisorSel  :  in   std_logic; 
        KeypadRdy   :  in   std_logic;
        Keypad      :  in   std_logic_vector(3 downto 0);
        HexDigit    :  out  std_logic_vector(3 downto 0);
        DecoderEn   :  out  std_logic;
        DecoderBit  :  out  std_logic_vector(3 downto 0);
        CLK         :  in   std_logic; 
		  Done        :  out  std_logic
		 );
    end component;


    -- Stimulus signals - signals mapped to the input and inout ports of tested entity
	 signal DivisorSel   : std_logic; 
	 signal KeypadRdy    : std_logic; 
	 signal Keypad       : std_logic_vector(3 downto 0); 
    signal Calculate  	: std_logic;
	 signal DecoderEn   	: std_logic; 
	 signal DecoderBit  	: std_logic_vector(3 downto 0); 
    signal CLK  			: std_logic;
	 signal Done 			: std_logic; 
	 
	 
    -- Observed signals - signals mapped to the output ports of tested entity
    signal  HexDigit		:  std_logic_vector(3 downto 0);

    -- Signal used to stop clock signal generators
    signal  END_SIM  :  BOOLEAN := FALSE;

	 -- test vectors 
	 signal Divisor 	: std_logic_vector(NUM_SIZE downto 0); 
	 signal Dividend 	: std_logic_vector(NUM_SIZE downto 0);
	 signal Quotient 	: std_logic_vector(NUM_SIZE downto 0); 
	 signal TestQuotient 	: std_logic_vector(NUM_SIZE downto 0); 
	
	 type DivCases is array (0 to 5) of std_logic_vector(NUM_SIZE downto 0);
	 signal DivisorCases : DivCases; 
	 signal DividendCases : DivCases; 
	 signal QuotientCases : DivCases;
	 
begin
    -- Serial Divider Unit Under Test port map
	UUT : SerialDivider
        port map  (
            nCalculate 		=> Calculate,
				DivisorSel     => DivisorSel,
				KeypadRdy      => KeypadRdy, 
				Keypad         => Keypad,
            HexDigit			=> HexDigit, 
				DecoderEn 		=> DecoderEn, 
				DecoderBit		=> DecoderBit, 
				CLK				=> CLK,
				Done				=> Done
        );

    -- now generate the stimulus and test the design
    process
		  variable  i  :  integer;        -- general loop indices
		  variable  j  :  integer; 
		  
		  -- for random number generator 
		  variable Seed1, Seed2: positive; 
		  variable Rand : real; 				-- real number between (0, 1)
		  variable RandRange : real := 16.0;  
		  variable RandNibble : std_logic_vector(3 downto 0); 
		  
		  begin 
		  
		  -- comment out appropriate case -- 
		  -------------------------------------------------------------------
--		  -- edge cases for 20 
--		  -- both 0, divisor 0, large dividend and small divisor, 
--		  -- largest dividend, divide by 1, small dividend, large divisor
--		  DivisorCases <= (X"00000", X"00000", X"00002", X"00001", X"FFFFF");
--		  DividendCases <= (X"00000", X"FFFFF", X"FFBCD", X"FFFFF", X"00001");
--		  QuotientCases <= (X"00000", X"00000", X"7FDE6", X"FFFFF", X"00000");
		 
		  -- edge cases for 16 
		  -- both 0, divisor 0, large dividend and small divisor, 
		  -- largest dividend, divide by 1, small dividend, large divisor
		  DivisorCases <= (X"0000", X"0000", X"0002", X"0001", X"FFFF", X"A3C3");
		  DividendCases <= (X"0000", X"FFFF", X"FFBC", X"FFFF", X"0001", X"78C3");
		  QuotientCases <= (X"0000", X"0000", X"7FDE", X"FFFF", X"0000", X"0000");  
		  
		  
		  -- initially everything is X, have not started
		  	DivisorSel  <= 'X';  
			KeypadRdy   <= 'X';
			Keypad      <= "XXXX";
			Calculate  	<= 'X';
			wait for 100 ns; 
			
			-- test edge cases
			----------------------------------------------- 
			for j in 0 to 5 loop 
				-- input divisor 
				DivisorSel <= '1'; 	-- set DivisorSel high for divisor
				for i in 0 to NUM_NIBBLES - 1 loop
					KeypadRdy <= '0'; 
					Keypad <= (DivisorCases(j)(NUM_SIZE downto NUM_SIZE - 3)); 
					wait for DIGIT_COUNT;  -- load keypad input 
					KeypadRdy <= '1';      -- assert key is ready 
					-- rotate divisor for next key input 
					DivisorCases(j) <= DivisorCases(j)(NUM_SIZE - 4 downto 0) & DivisorCases(j)(NUM_SIZE downto NUM_SIZE - 3);  
					wait for DIGIT_COUNT;  -- wait for enough time, make sure got to divisor input digit 
				end loop; 
				
				-- input dividend
				DivisorSel <= '0'; -- set DivisorSel low for dividend
				for i in 0 to NUM_NIBBLES - 1 loop
					KeypadRdy <= '0';      
					Keypad <= (DividendCases(j)(NUM_SIZE downto NUM_SIZE - 3)); 
					wait for DIGIT_COUNT;  -- load keypad input
					KeypadRdy <= '1';      -- assert key is ready 
					-- rotate dividend for next key input 
					DividendCases(j) <= DividendCases(j)(NUM_SIZE - 4 downto 0) & DividendCases(j)(NUM_SIZE downto NUM_SIZE - 3);  
					wait for DIGIT_COUNT;  -- wait for enough time, make sure got to dividend input digit
				end loop; 
				
				-- assert calculate 
				Calculate <= '1'; 
				wait for CLK_PERIOD; 
				Calculate <= '0';
				wait for CLK_PERIOD*2; -- wait for enough time for signal to latch 
				Calculate <= '1'; 
			  
--				if Done /= '1' then    -- wait until division complete 
--					wait until Done = '1'; 
--				end if; 
				wait for DIGIT_COUNT;
				
				-- get quotient 
				for i in 0 to NUM_NIBBLES loop
				   -- get quotient digits (beginning at digit QUOTIENT_DIGIT) 
					-- and save to TestQuotient
					if unsigned(DecoderBit)/= QUOTIENT_DIGIT + i then 
						wait until unsigned(DecoderBit)= QUOTIENT_DIGIT + i; 
					end if; 
					-- shift in each digit 
					TestQuotient <= HexDigit & TestQuotient(NUM_SIZE downto 4);
				end loop; 
				
				-- check that quotient is correct
				assert (std_match(TestQuotient, QuotientCases(j)))
					report  "Edge case failure"
					severity  ERROR;
					
				wait for DIGIT_COUNT; -- let divider cycle through digits 
				--TestQuotient <= (Others => 'X'); -- reset for simulation 
			end loop; 
			----------------------------------------------------------------------
		  
		  
		   wait for DIGIT_COUNT; -- place for breakpoint, if desired
			
		   -- test random signals--
			----------------------------------------------- 
			for j in 0 to RAND_COUNT loop 
				-- input divisor 
				DivisorSel <= '1'; 	-- set DivisorSel high for divisor
				for i in 0 to NUM_NIBBLES - 1 loop
					KeypadRdy <= '0'; 
					
					-- generate random nibble
					uniform(Seed1, Seed2, Rand); 
					RandNibble := std_logic_vector(to_unsigned(integer(trunc(Rand * RandRange)), RandNibble'length)); 
					wait for CLK_PERIOD; 
					
					-- save random nibble in divisor
					Divisor <= Divisor(NUM_SIZE - 4 downto 0) & RandNibble; 
					Keypad <= RandNibble;
					wait for DIGIT_COUNT;  -- load keypad input 
					KeypadRdy <= '1';      -- assert key is ready 
					wait for DIGIT_COUNT;  -- wait for enough time, make sure got to divisor input digit 
				end loop; 
				
				-- input dividend
				DivisorSel <= '0'; -- set DivisorSel low for dividend
				for i in 0 to NUM_NIBBLES - 1 loop
					KeypadRdy <= '0';      
					-- generate random nibble
					uniform(Seed1, Seed2, Rand); 
					RandNibble := std_logic_vector(to_unsigned(integer(trunc(Rand * RandRange)), RandNibble'length));  
					wait for CLK_PERIOD; 
					
					-- save random nibble in dividend
					Dividend <= Dividend(NUM_SIZE - 4 downto 0) & RandNibble; 
					Keypad <= RandNibble;
					wait for DIGIT_COUNT;  -- load keypad input
					KeypadRdy <= '1';      -- assert key is ready  
					wait for DIGIT_COUNT;  -- wait for enough time, make sure got to dividend input digit
				end loop; 
				
				-- assert calculate 
				Calculate <= '1'; 
				wait for CLK_PERIOD; 
				Calculate <= '0';
				wait for CLK_PERIOD*2; -- wait for enough time for signal to latch 
				Calculate <= '1'; 
			  
--				if Done /= '1' then    -- wait until division complete 
--					wait until Done = '1'; 
--				end if; 
				wait for DIGIT_COUNT; 
				
				-- calculate correct quotient 
				Quotient <= std_logic_vector(unsigned(Dividend) / unsigned(Divisor)); 
				--wait for CLK_PERIOD; -- possibly unnecessary wait 

				-- get quotient 
				for i in 0 to NUM_NIBBLES loop
				   -- get quotient digits (beginning at digit QUOTIENT_DIGIT) 
					-- and save to TestQuotient
					if unsigned(DecoderBit)/= QUOTIENT_DIGIT + i then 
						wait until unsigned(DecoderBit)= QUOTIENT_DIGIT + i; 
					end if; 
					-- shift in each digit 
					TestQuotient <= HexDigit & TestQuotient(NUM_SIZE downto 4);
				end loop; 
				
				-- check that quotient is correct
				assert (std_match(TestQuotient, Quotient))
					report  "Random case failure"
					severity  ERROR;
				
				wait for DIGIT_COUNT; -- let divider cycle through digits 
				TestQuotient <= (Others => 'X'); -- reset for simulation 
				Quotient <= (Others => 'X'); -- reset for simulation 
			end loop; 
			----------------------------------------------------------------------
		  
		  
		  
					 
        END_SIM <= TRUE;        -- end of stimulus events
        wait;                   -- wait for simulation to end

    end process; -- end of stimulus process
    

    CLOCK_CLK : process
    begin

        -- this process generates a 20 ns 50% duty cycle clock
        -- stop the clock when the end of the simulation is reached
        if END_SIM = FALSE then
            CLK <= '0';
            wait for CLK_PERIOD/2;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK <= '1';
            wait for CLK_PERIOD/2;
        else
            wait;
        end if;

    end process;


end TB_ARCHITECTURE;


configuration TESTBENCH_FOR_SerialDivider of SerialDividerTB is
    for TB_ARCHITECTURE 
		  for UUT : SerialDivider
            use entity work.SerialDivider;
        end for;
    end for;
end TESTBENCH_FOR_SerialDivider;
