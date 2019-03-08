----------------------------------------------------------------------------------
--
-- Constants for ALU
--
-- ALUConstants.vhd
--
-- This file contains constants for the ALU entity and testbench.
--
--  Revision History:
--     01/29/19 Sophia Liu initial revision
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gcdConstants is
    constant CLK_PERIOD : time := 100 ns;
    constant TEST_SIZE : natural := 1000; 
    
    constant NUMBITS_TEST : natural := 15; 
    constant NUMBITST_TEST : natural := 40; --??? 

end package gcdConstants;


----------------------------------------------------------------------------
--
--  1 Bit Full Subtracter
--
--  Implementation of a full adder. This entity takes the one bit
--  inputs A and B with a carry in input and outputs the sum and carry
--  out bits, using combinational logic.
--
-- Inputs:
--      A: std_logic - 1 bit adder input
--      B: std_logic - 1 bit adder input
--      Cin: std_logic - 1 bit carry in input
--
-- Outputs:
--      Sum: std_logic - 1 bit sum of A, B, and Cin
--      Cout: std_logic - 1 bit carry out value
--
--  Revision History:
--      11/21/18  Sophia Liu    Initial revision.
--      11/22/18  Sophia Liu    Updated comments.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fullSub is
    port(
        A           :  in      std_logic;  -- adder input
        B           :  in      std_logic;  -- adder input
        Cin         :  in      std_logic;  -- borrow in value
        Cout        :  out     std_logic;  -- carry out value
        Diff         :  out     std_logic   -- sum of A, B with carry in
      );
end fullSub;

architecture fullSub of fullSub is
    begin
        -- combinational logic for calculating A-B with carry in and out bits
        Diff <= A xor B xor Cin;
        Cout <= (A and B) or (A and (not Cin)) or (B and (not Cin));
end fullSub;
