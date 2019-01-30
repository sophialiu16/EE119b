----------------------------------------------------------------------------------
--
-- Constants for ALU
-- 
-- ALUConstants.vhd
-- 
-- This file contains constants for the ALU entity and testbench.
--
--  Revision History:
--     01/29/19	Sophia Liu initial revision
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

package ALUConstants is
    constant REGSIZE    : natural := 8; 

    -- F-block operands 
    constant OP_ZERO    : std_logic_vector(5 downto 0) := "0000--"; -- zeros
    constant OP_NOR     : std_logic_vector(5 downto 0) := "0001--"; -- A nor B
    constant OP_NOTA    : std_logic_vector(5 downto 0) := "0011--"; -- not A
    constant OP_NOTB    : std_logic_vector(5 downto 0) := "0101--"; -- not B
    constant OP_XOR     : std_logic_vector(5 downto 0) := "0110--"; -- A xor B
    constant OP_NAND    : std_logic_vector(5 downto 0) := "0111--"; -- A nand B
    constant OP_AND     : std_logic_vector(5 downto 0) := "1000--"; -- A and B
    constant OP_XNOR    : std_logic_vector(5 downto 0) := "1001--"; -- A xnor B 
    constant OP_OR      : std_logic_vector(5 downto 0) := "1110--"; -- A or B
    constant OP_ONE     : std_logic_vector(5 downto 0) := "1111--"; -- true     
    
    -- Shifter/Rotator operands 
    -- abcde -> abc = high bit, d = middle bits, ef = low bit 
    constant OP_LSR     : std_logic_vector(5 downto 0) := "011110"; -- Logical shift right 
    constant OP_ASR     : std_logic_vector(5 downto 0) := "001110"; -- Arithmetic shift right
    --constant OP_ASL     : std_logic_vector(5 downto 0) := "000001"; -- Arithmetic shift left -- left shift instructions??
    constant OP_ROR     : std_logic_vector(5 downto 0) := "010110"; -- Rotate right
    
    -- Adder/Subtractor operands 
    constant OP_ADD     : std_logic_vector(5 downto 0) := "0----";
    constant OP_SUB     : std_logic_vector(5 downto 0) := "1----";
    constant OP_CARRY   : std_logic_vector(5 downto 0) := "-1---"; 
    constant OP_NOCARRY   : std_logic_vector(5 downto 0) := "-0---";
    
    -- timing constants for testing  
    constant CLK_PERIOD : time := 20 ns;

end package ALUConstants;
