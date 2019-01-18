-- libraries
library  ieee;
use  ieee.std_logic_1164.all;
use  ieee.numeric_std.all;
use  work.DividerConstants.all; 

----------------------------------------------------------------------------
--  
--  16-bit serial divider for EE 119 serial divider board (HW8)
--  
--  SerialDivider
--
--  The entity takes input from the keypad and display it on the 7-segment
--  LEDs.  When the calculate button is pressed, the quotient is calculated
--  and displayed. The quotient, divisor, and dividend are displayed
--  in hexadecimal. The divisor/dividend switch (DivisorSel) switches between 
--  inputs for he divisor and dividend.
--
--  Inputs:
--     nCalculate             - calculate the quotient (active low)
--     DivisorSel             - input the divisor when high, dividend when low 
--     KeypadRdy              - keypad ready signal, high when key is available
--     Keypad(3 downto 0)     - keypad input (from keypad decoder)
--     CLK                    - clock input signal
--
--  Outputs:
--     HexDigit(3 downto 0)   - hex digit to display (to segment decoder)
--     DecoderEn              - enable for the 4:12 digit decoder
--     DecoderBit(3 downto 0) - digit to display (to 4:12 decoder)
--
--  Revision History:
--     23 Nov 18  Glen George       initial revision
--     27 Nov 18  Sophia Liu 	      modified for division
--     29 Nov 18  Sophia Liu        modified division algorithm 
--     2  Dec 18  Sophia Liu        working key input modifications
--     3  Dec 18  Sophia Liu        updated comments
----------------------------------------------------------------------------

entity  SerialDivider  is
    port (
			-- calculate the quotient (active low)
        nCalculate  :  in   std_logic;
		  -- input the divisor when high, dividend when low 
        DivisorSel  :  in   std_logic; 
		  -- keypad ready signal, high when key is available
        KeypadRdy   :  in   std_logic;
		  -- keypad input (from keypad decoder)
        Keypad      :  in   std_logic_vector(3 downto 0);
		  -- hex digit to display (to segment decoder)
        HexDigit    :  out  std_logic_vector(3 downto 0);
		  -- enable for the 4:12 digit decoder
        DecoderEn   :  out  std_logic;
		  -- digit to display (to 4:12 decoder)
        DecoderBit  :  out  std_logic_vector(3 downto 0); --std_logic_vector
		  -- clock input signal
        CLK         :  in   std_logic;
		  -- division done, high when finished with division 
		  Done        :  out  std_logic
    );

end  SerialDivider;

--
--  SerialDivider architecture
--

architecture  Behavioral  of  SerialDivider  is

	 -- signals for remainder and quotient calculations
	 signal Remainder      :   std_logic_vector(NUM_BITS downto 0);
	 signal NextRemainder  :   std_logic_vector(NUM_BITS - 1 downto 0);
	 signal Quotient       :   std_logic_vector(NUM_BITS - 1 downto 0);
	 
	 -- signals for divisor and dividend input
	 signal Divisor        :   std_logic_vector(NUM_BITS - 1 downto 0);
	 signal Dividend       :   std_logic_vector(NUM_BITS - 1 downto 0);

    -- keypad signals
	 -- have a key from the keypad
    signal  HaveKey     :  std_logic;
	 -- keypad ready synchronization
    signal  KeypadRdyS  :  std_logic_vector(2 downto 0); 

    -- LED multiplexing signals
	 -- multiplex counter to divide down to 1 Khz
    signal  MuxCntr     :  unsigned(9 downto 0) := (others => '0');     
	 -- enable for the digit clock 
    signal  DigitClkEn  :  std_logic;
	 -- current mux digit 
    signal CurDigit    : unsigned(3 downto 0) := (others => '0'); --too  much TODO
     
    --  adder/subtracter signals
    signal  CalcResultBit  :  std_logic;        -- sum/difference output
    signal  CalcCarryOut   :  std_logic;        -- carry/borrow out
    signal  CarryFlag      :  std_logic;        -- stored carry flag
	 
	 -- signals used during division calculations
	 -- subtracting flag 
	 signal Subtract       :   std_logic; -- subtract when = 1 , add when 0 
	 -- sign bit for next remainder
	 signal SignResultBit  :   std_logic;  
	 -- synchronous signal, indicates when division needs to happen
	 signal CalculateQ     :   std_logic; 
	 signal nCalculateQ    :   std_logic;
	 -- flag for when division is in progress/has been completed
	 signal DivideDone     :   std_logic := '0'; 

begin

    -- one-bit adder/subtracter (operation determined by Divisor input)
    -- adds/subtracts low bits of the divisor and reminder generating
    --    CalcResultBit and CalcCarryOut
    CalcResultBit <= Divisor(0) xor Subtract xor Remainder(0) xor CarryFlag;
    CalcCarryOut  <= (Remainder(0) and CarryFlag) or
                     ((Divisor(0) xor Subtract) and Remainder(0)) or
                     ((Divisor(0) xor Subtract) and CarryFlag);
							
							
	 -- partial adder for calculating the next remainder sign bit
    SignResultBit <= Remainder(NUM_BITS) xor Subtract xor CarryFlag;


    -- counter for mux rate of 1 KHz (1 MHz / 1024)
    process(CLK)
    begin
        -- count on the rising edge 
        if rising_edge(CLK) then
            MuxCntr <= MuxCntr + 1;
        end if;

    end process;
	 
	 -- logic for when to change display digit 
	 DigitClkEn  <=  '1'  when (MuxCntr = (MuxCntr'range => '1')) else  --"1111111111")  else
                     '0'; 
 
    -- storage for when calculation button has been pressed, 
	 -- clears once division has completed
	 process(CLK) 
	 begin 
		if rising_edge(CLK) then 
			if nCalculate = '0' then 
				nCalculateQ <= '1'; -- store active low calculate input
			end if; 
			if DivideDone = '1' then 
				nCalculateQ <= '0'; -- stop dividing only after finished operation 
			end if; 
		end if; 
	 end process; 
	 
	 -- second DFF to synchronize calculate signal 
	 process(CLK) 
	 begin 
		if rising_edge(CLK) then 
			if nCalculateQ = '1' then 
				CalculateQ <= '1'; -- store active low calculate input
			end if; 
			if nCalculateQ = '0' then 
				CalculateQ <= '0'; -- stop dividing only after finished operation 
			end if; 
		end if; 
	 end process; 
	 
	-- main process for changing muxed digit, dividing, and inputting values from keypad
	process(CLK)	
	begin 
		if rising_edge(clk) then 
			if (DigitClkEn = '1' and not (CurDigit = NUM_DIGITS)) then 
				-- shift to next displayed digit 
				-- TODO  
				Dividend <= Divisor(3 downto 0) & Dividend(NUM_BITS - 1 downto 4); 
				Divisor <= Quotient(3 downto 0) & Divisor (NUM_BITS - 1 downto 4); 
				Quotient <= Dividend (3 downto 0) & Quotient(NUM_BITS - 1 downto 4); 
				
				DivideDone <= '0'; 
			elsif (MuxCntr = NUM_BITS * (NUM_BITS +  2) and CalculateQ = '1' and CurDigit = NUM_DIGITS) then --MuxCntr = "1000000000"
				-- finished dividing, set division flag
				DivideDone <= '1';  
				
			elsif (MuxCntr = (MuxCntr'range => '0') and CalculateQ = '1'and CurDigit = NUM_DIGITS) then 
			    -- count 0 
				-- start dividing (on digit 12, when no digit is outputted to display), reset signals
				if (Divisor = (Divisor'range => '0')) then -- display error when dividing by zero
					Quotient <= (others => '0');     -- 0s displayed
					DivideDone <= '1';                  -- can stop dividing process
				end if; 
				CarryFlag <= '1'; -- initial subtraction settings for division
				Subtract <= '1';
                NextRemainder <= (others => '0'); -- reset remainder signals
				--Remainder <= "0000000000000000" & Dividend(NUM_BITS - 1); -- shift in highest dividend bit 
				Remainder <= (0     => Dividend(NUM_SIZE), 
				            others  => '0');  
				
			elsif  (MuxCntr < NUM_BITS * (NUM_BITS + 2) and MuxCntr mod (NUM_BITS + 2) = 0
			     and CalculateQ = '1'and CurDigit = NUM_DIGITS) then  --std_match(MuxCntr, "0----00000")
				-- have finished with current dividend bit, shift in next bit 
				-- count 18 = 0 
				Remainder <= Remainder(NUM_SIZE downto 0) & Dividend(NUM_SIZE);
				
			elsif (CalculateQ = '1' and CurDigit = NUM_DIGITS and MuxCntr < NUM_BITS * (NUM_BITS + 2) and 
			         MuxCntr mod (NUM_BITS + 2) > 0 and MuxCntr mod (NUM_BITS + 2) < NUM_BITS + 1) then 
						--(std_match(MuxCntr, "0----0----") or std_match(MuxCntr, "0----10000"))) then -- up to 16
	                   -- if counter % bits+1 !=  0 
	                   -- count 1 to 16
				-- rotate divisor and add or subtract, saving to next remainder
				CarryFlag <= CalcCarryOut; -- save carry flag
				-- rotate remainder, saving sign bit 
				Remainder <= Remainder(NUM_BITS) & Remainder(0) & Remainder(NUM_BITS - 1 downto 1); 
				-- get next divisor bit by rotating 
				Divisor <= std_logic_vector(unsigned(Divisor) ror 1); 
				-- save the sum or difference for the next remainder to use 
				NextRemainder <= CalcResultBit & NextRemainder(NUM_SIZE downto 1); 
				
			elsif (CalculateQ = '1' and CurDigit = NUM_DIGITS and  MuxCntr < NUM_BITS * (NUM_BITS + 2) and 
			         MuxCntr mod (NUM_BITS + 2) = NUM_BITS + 1) then 
			--std_match(MuxCntr, "0----10001")) then 
			    -- if counter % bits+1 = 0  
			    -- count 17
                Subtract <= not SignResultBit; -- use the final sign bit to determine 
				                               -- whether to add or subtract (add until >0)
				Dividend <= Dividend(NUM_SIZE - 1 downto 0) & Remainder(0); -- shift dividend bit back in 
				Remainder <= SignResultBit & NextRemainder;       -- set next remainder buffer 
				Quotient <= Quotient(NUM_SIZE - 1 downto 0) & (not SignResultBit); -- add to quotient buffer
				
			elsif (MuxCntr = "1100000000" and --TODO idk why 
					(HaveKey = '1') and (((CurDigit = DIVIDEND_DIGIT) and (DivisorSel = '0')) or
                                       ((CurDigit = DIVISOR_DIGIT) and (DivisorSel = '1')))) then 
			   -- shift in key input to dividend or divisor
			   Dividend <= Dividend(NUM_SIZE - 4 downto 0) & Keypad; 
			end if;
		end if; 	  
	 end process; 
	 
	 
	 -- handle key input 
	 
	 -- edge (and key) detection on KeypadRdy
    process(CLK)
    begin

        if rising_edge(CLK) then

            -- shift the keypad ready signal to synchronize and edge detect
            KeypadRdyS  <=  KeypadRdyS(1 downto 0) & KeypadRdy;

            -- have a key if have one already that hasn't been processed or a
            -- new one is coming in (rising edge of KeypadRdy), reset if on
            -- the last clock of Digit 3 or Digit 7 (depending on position of
            -- Divisor switch) and held otherwise
            if  (std_match(KeypadRdyS, "01-")) then
                -- set HaveKey on rising edge of synchronized KeypadRdy
                HaveKey <=  '1';
      --TODO---------------------------------------------------------------------------------------
            elsif ((DigitClkEn = '1') and (CurDigit = DIVIDEND_DIGIT) and (DivisorSel = '0')) then
                -- reset HaveKey if on Dividend and current digit is 3
                HaveKey <=  '0';
            elsif ((DigitClkEn = '1') and (CurDigit = DIVISOR_DIGIT) and (DivisorSel = '1')) then
                -- reset HaveKey if on Divisor and current digit is 7
                HaveKey <=  '0';
            else
                -- otherwise hold the value
                HaveKey <=  HaveKey;
            end if;

        end if;

    end process;	 	 
	 
--TODO 
    -- create the counter for output the current digit
    -- order is 0 to NUM_DIGITS, with calculations done on MSB
    -- only increment if DigitClkEn is active
	 -- changed digit order: dividend LSB 0, MSB NUM_NIBBLES - 1; divisor -> dividend + NUM_NIBBLES
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            -- create the appropriate count sequence
            if (DigitClkEN = '1') then 
                CurDigit <= CurDigit + 1; 
                if CurDigit = NUM_DIGITS then  
                    CurDigit <= (others => '0');  
                end if; 
            else 
                CurDigit <= CurDigit; 
            end if; 
        end if;  
     end process;

    -- always enable the digit decoder
    DecoderEn  <=  '1';

    -- output the current digit to the digit decoder
    DecoderBit <= std_logic_vector(CurDigit);

    -- the hex digit to output is just the low nibble of the shift register
    HexDigit  <=  Dividend(3 downto 0); 

	 Done <= DivideDone; 

end Behavioral;
