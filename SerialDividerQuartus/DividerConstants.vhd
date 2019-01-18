----------------------------------------------------------------------------------
--
-- Constants for Serial Divider 
-- 
-- DividerConstants.vhd
-- 
-- This file contains constants for the SerialDivider entity and testbench. 
-- Only NUM_NIBBLES, the number of nibbles (or digits) in the divisor, dividend,
-- and quotient, should be changed to perform 16 or 20 bit division.
--
--  Revision History:
--     01/16/19	Sophia Liu	initial revision
--     01/17/19   Sophia Liu  added testbench constants, updated comments
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package DividerConstants is

    -- number of nibbles (digits) in divisor, dividend, and quotient  
	 -- change only this value to change number of bits to divide
    constant NUM_NIBBLES    : natural   := 5;  
	 
	 -- number of bits in divisor, dividend, and quotient
    constant NUM_BITS       : natural   := NUM_NIBBLES * 4; 
	 -- vector size for divisor, dividend, and quotient
    constant NUM_SIZE       : natural   := NUM_BITS - 1;
	 -- total number of digits to display (total digits in divisor, dividend, quotient
    constant NUM_DIGITS     : natural   := NUM_NIBBLES * 3;  
    
	 -- digit the dividend begins on 
    constant DIVIDEND_DIGIT : integer   := 0;
	 -- digit the divisor begins on 
    constant DIVISOR_DIGIT  : integer   := NUM_NIBBLES;  
	 -- digit the quotient begins on 
	 constant QUOTIENT_DIGIT : integer   := NUM_NIBBLES * 2; 

	 -- timing constants for testing 
	 constant CLK_PERIOD : time := 20 ns;
	 constant MUX_COUNT  : time := CLK_PERIOD * 2000; 
	 constant DIGIT_COUNT: time := MUX_COUNT * NUM_DIGITS;
	 
	 -- number of times to perform random testing 
	 constant RAND_COUNT : natural := 50; 

end package DividerConstants;
