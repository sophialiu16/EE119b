----------------------------------------------------------------------------------
-- constants for Serial Divider 
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/16/2019 08:05:34 PM
-- Design Name: 
-- Module Name: DividerConstants - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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
    
	 -- number digit the dividend begins on 
    constant DIVIDEND_DIGIT : integer   := 0;
	 -- number digit the divisor begins on 
    constant DIVISOR_DIGIT  : integer   := NUM_NIBBLES;  

end package DividerConstants;
