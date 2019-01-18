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

    -- the all important  
    constant NUM_NIBBLES    : natural   := 5;  -- number of nibbles (digits) to divide  
    constant NUM_BITS       : natural   := NUM_NIBBLES * 4;   
    constant NUM_SIZE       : natural   := NUM_BITS - 1; -- vector size 
    constant NUM_DIGITS     : natural   := NUM_NIBBLES * 3; -- number of digits to display 
    
    constant DIVIDEND_DIGIT : integer   := NUM_NIBBLES - 1; -- digit dividend begins on  
    constant DIVISOR_DIGIT  : integer   := NUM_NIBBLES * 2 - 1; 

end package DividerConstants;
