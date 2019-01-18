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
--      11/21/18 Sophia Liu 			Updated for bit serial multiplier testing
--      11/22/18 Sophia Liu 					Updated comments 
--
----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    signal  Calculate  	:  std_logic;
	 signal  DecoderEn   :  std_logic; 
	 signal  DecoderBit  :  std_logic_vector(3 downto 0); 
    signal  CLK   :  std_logic;
	 signal Done : std_logic; 
	 
	 
    -- Observed signals - signals mapped to the output ports of tested entity
    signal  HexDigit		:  std_logic_vector(3 downto 0);

    -- Signal used to stop clock signal generators
    signal  END_SIM  :  BOOLEAN := FALSE;

    -- Test Input Vector, largely randomly generated 
    --signal  TestVector  : std_lo
	 signal Divisor : std_logic_vector(
	
begin

    -- Unit Under Test port maps
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

			variable  i  :  integer;        -- general loop index
			
			-- variables for checking for successful tests 
			variable  QMatch   	:  std_logic_vector(15 downto 0);
		  
		  begin 
		  
		  -- initially everything is X, have not started
		  	DivisorSel  <= 'X';  
			KeypadRdy   <= 'X';
			Keypad      <= "XXXX";
			Calculate  	<= 'X';
			DecoderEn   <= 'X'; 
		   DecoderBit  <= "XXXX"; 
			wait for 100 ns; 
			
			-- test edge cases 
			
			
		  Calculate <= '1'; 
        wait for 100 ns;	
		  
		  --Reset <= '1'; 
		  
		  Calculate <= '0';
		  wait for 100 ns; 
		  Calculate <= '1'; 
		  
		  if Done /= '1' then 
			wait until Done = '1'; 
		  end if; 
		  
		  
		  -- test random signals
		  
		  -- shift through test vector to test random cases 
--        for i in 0 to TestVector'high loop
--			A <= TestVector(15 downto 0); -- assign multiplicand and multiplier
--			B <= TestVector(18 downto 3); 
--			
--			wait for 100 ns; 
--			-- assign correct products for 2, 4, 16 bit multipliers
--			Q2Match := std_logic_vector(unsigned(A(1 downto 0)) * unsigned(B(1 downto 0))); 
--			Q4Match := std_logic_vector(unsigned(A(3 downto 0)) * unsigned(B(3 downto 0))); 
--			Q16Match := std_logic_vector(unsigned(A(15 downto 0)) * unsigned(B(15 downto 0))); 		
--			
--         START <='1'; 				-- start multiplier
--			wait for 20 ns;   		-- hold start signal for 1 clock 
--			START <= '0';
--			if DONE /= '1' then 		-- wait for largest multiplier to finish 
--				wait until DONE = '1';
--			end if; 
--			
--			-- check for successful multiplication 
--			assert (std_match(Q2, Q2Match))
--                report  "Q2 failure"
--                severity  ERROR;
--			
--			assert (std_match(Q4, Q4Match))
--                report  "Q4 failure"
--                severity  ERROR;
--			
--			assert (std_match(Q16, Q16Match))
--                report  "Q16 failure"
--                severity  ERROR;
--			-- rotate through test vector 
--			TestVector <= std_logic_vector(unsigned(TestVector) ror 2); 
--			
--			wait for 10 ns; 
--			
--			end loop; 
					 
        END_SIM <= TRUE;        -- end of stimulus events
        wait;                   -- wait for simulation to end

    end process; -- end of stimulus process
    

    CLOCK_CLK : process
    begin

        -- this process generates a 20 ns 50% duty cycle clock
        -- stop the clock when the end of the simulation is reached
        if END_SIM = FALSE then
            CLK <= '0';
            wait for 10 ns;
        else
            wait;
        end if;

        if END_SIM = FALSE then
            CLK <= '1';
            wait for 10 ns;
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