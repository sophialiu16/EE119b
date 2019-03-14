----------------------------------------------------------------------------------
--
-- Constants for cellular atomaton
--
-- CellConstants.vhd
--
-- This file contains constants for the Cell entity and testbench.
--
--  Revision History:
--     03/13/19 Sophia Liu initial revision
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CellConstants is

    -- rowsize x colsize mesh of cells
    constant ROWSIZE : natural := 3;
    constant COLSIZE : natural := 3;
    
    -- number of cell neighbors
    constant NSIZE : natural := 7;

end package CellConstants;
