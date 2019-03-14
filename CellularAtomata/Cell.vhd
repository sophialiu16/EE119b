-- EE119b HW8 Sophia Liu

----------------------------------------------------------------------------
--
-- Cell for Conway's game of life, cellular atomaton
--
-- Description
--
--
-- shift priority over next time tick
--
-- Generic:
--
-- Inputs:
--
-- Outputs:
--
-- Revision History:
-- 03/13/19 Sophia Liu Initial revision
-- 03/13/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.CellConstants.all;

entity Cell is
    port(
        Clk     : in std_logic;     -- system clock
        Neighbors : in std_logic_vector(7 downto 0); -- 8 neighboring cells
        Shift   : in std_logic;     -- active to shift data in and out
        CellDataIn  : in std_logic;     -- data to shift in
        NextTimeTick    : in std_logic;
        CellDataOut : out std_logic     -- output status of self
    );
end Cell;

architecture CellArch of Cell is
    signal Self : std_logic;
    signal NeighborCount : integer;
    begin

        process(clk)
            begin
    		if rising_edge(clk) then
                -- if shift is active, shift in datain, shift out dataout
                if Shift = '1' then
                    Self <= CellDataIn;
                elsif NextTimeTick = '1' then
                    -- otherwise calculate self status based on neighbors
                    -- add neighbors together (TODO blocks of 4 bits)
                    if NeighborCount = 3 then
                        Self <= '1';
                    elsif NeighborCount /=2 then
                        Self <= '0';
                    else 
                        Self <= Self;
                    end if;
                end if;
            end if;
            CellDataOut <= Self;
        end process;

        -- TODO
        NeighborCount <= to_integer(unsigned(Neighbors));--(0)) + unsigned(Neighbors(1))-- +
--                                    unsigned(Neighbors(2)) + unsigned(Neighbors(3)) +
--                                    unsigned(Neighbors(4)) + unsigned(Neighbors(5)) +
--                                    unsigned(Neighbors(6)) + unsigned(Neighbors(7)));

end CellArch;

----------------------------------------------------------------------------
--
-- Cell mesh for Conway's game of life, cellular atomaton
--
-- Description
--
-- Generic:
--
-- Inputs:
--
-- Outputs:
--
-- Revision History:
-- 03/13/19 Sophia Liu Initial revision
-- 03/13/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.CellConstants.all;

entity CellMesh is
    port(
        Clk     : in std_logic;     -- system clock
        Shift   : in std_logic;     -- active to shift data in and out
        DataIn  : in std_logic;     -- data to shift in
        NextTimeTick    : in std_logic;
        DataOut : out std_logic     -- serial data output from cells
    );
end CellMesh;

architecture CellMeshArch of CellMesh is

    component Cell is
        port(
            Clk     : in std_logic;     -- system clock
            Neighbors : in std_logic_vector(NSIZE downto 0); -- 8 neighboring cells
            Shift   : in std_logic;     -- active to shift data in and out
            CellDataIn  : in std_logic;     -- data to shift in
            NextTimeTick    : in std_logic;
            CellDataOut : out std_logic
        );
    end component;

    signal CurNeighbors : std_logic_vector(NSIZE downto 0);  -- intermediate datain signal
    signal CellData : std_logic_vector((ROWSIZE * COLSIZE - 1) downto 0);
    signal CurDataIn : std_logic;
    begin

        -- rowsize x rowsize mesh of cells
        rowGen: for r in 0 to ROWSIZE-1 generate
            colGen : for c in 0 to COLSIZE-1 generate
                -- current cell is number r * ROWSIZE + c
                -- TODO comparison size
                CurNeighbors(0) <= '0' when (r-1) < 0 or (c-1) < 0 else -- edge case
                                    CellData((r-1)*ROWSIZE + (c-1));

                CurNeighbors(1) <= '0' when (r-1) < 0 else -- edge case
                                    CellData((r-1)*ROWSIZE + c);

                CurNeighbors(2) <= '0' when (r-1) < 0 or (c+1) >= COLSIZE else -- edge case
                                    CellData((r-1)*ROWSIZE + (c+1));

                CurNeighbors(3) <= '0' when (c-1) < 0 else -- edge case
                                    CellData((r)*ROWSIZE + (c-1));
            
                CurNeighbors(4) <= '0' when (c+1) >= COLSIZE else -- edge case
                                    CellData(r*ROWSIZE + (c+1));

                CurNeighbors(5) <= '0' when (r+1) >= ROWSIZE or (c-1) < 0 else -- edge case
                                    CellData((r+1)*ROWSIZE + (c-1));

                CurNeighbors(6) <= '0' when (r+1) >= ROWSIZE  else -- edge case
                                    CellData((r+1)*ROWSIZE + c);

                CurNeighbors(7) <= '0' when (r+1) >= ROWSIZE or (c+1) >= COLSIZE else -- edge case
                                    CellData((r+1)*ROWSIZE + (c+1));
                                    
                CurDataIn <=  DataIn when r + c = 0 else  
                                CellData(r * ROWSIZE + c - 1); 
                Celli : Cell
                port map (
                    Clk         => Clk,
                    Neighbors   => CurNeighbors,
                    Shift       => Shift,
                    CellDataIn      => CurDataIn,
                    NextTimeTick    => NextTimeTick,
                    CellDataOut     => CellData(r*ROWSIZE + c)
                );
            end generate colGen;
        end generate rowGen;

        DataOut <= CellData(ROWSIZE * COLSIZE - 1);

end CellMeshArch;
