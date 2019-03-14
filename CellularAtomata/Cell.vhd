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
                    if NeighborCount = 3 then
                        Self <= '1';
                    elsif NeighborCount /=2 then
                        Self <= '0';
                    else
                        Self <= Self;
                    end if;
                else
                    Self <= Self;
                end if;
            end if;
            CellDataOut <= Self;
        end process;

        -- TODO
        NeighborCount <= sum(Neighbors(3 downto 0)) + sum(Neighbors(7 downto 4));

end CellArch;

----------------------------------------------------------------------------
--
-- Cell mesh for Conway's game of life, cellular atomaton
--
-- Description
--
-- must be at least 3x3
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
    generic(
        RowSize : natural := 3;
        ColSize : natural := 3
    );
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
    type NeighborBus is array((ROWSIZE * COLSIZE - 1) downto 0) of std_logic_vector(NSIZE downto 0);
    signal CurNeighbors : NeighborBus;  -- intermediate neighbor signals
    signal CellData : std_logic_vector((ROWSIZE * COLSIZE - 1) downto 0);
    signal CurDataIn : std_logic_vector(ROWSIZE * COLSIZE - 1 downto 0);
    begin

        -- rowsize x colsize mesh of cells
        rowGen: for r in 0 to ROWSIZE-1 generate
            colGen : for c in 0 to COLSIZE-1 generate
                -- current cell is number r * ROWSIZE + c
                -- TODO comparison size
                CurNeighbors(r*ROWSIZE + c)(0) <= '0' when (r-1) < 0 or (c-1) < 0 else -- edge case
                                    CellData((r-1)*ROWSIZE + (c-1));

                CurNeighbors(r*ROWSIZE + c)(1) <= '0' when (r-1) < 0 else -- edge case
                                    CellData((r-1)*ROWSIZE + c);

                CurNeighbors(r*ROWSIZE + c)(2) <= '0' when (r-1) < 0 or (c+1) >= COLSIZE else -- edge case
                                    CellData((r-1)*ROWSIZE + (c+1));

                CurNeighbors(r*ROWSIZE + c)(3) <= '0' when (c-1) < 0 else -- edge case
                                    CellData((r)*ROWSIZE + (c-1));

                CurNeighbors(r*ROWSIZE + c)(4) <= '0' when (c+1) >= COLSIZE else -- edge case
                                    CellData(r*ROWSIZE + (c+1));

                CurNeighbors(r*ROWSIZE + c)(5) <= '0' when (r+1) >= ROWSIZE or (c-1) < 0 else -- edge case
                                    CellData((r+1)*ROWSIZE + (c-1));

                CurNeighbors(r*ROWSIZE + c)(6) <= '0' when (r+1) >= ROWSIZE  else -- edge case
                                    CellData((r+1)*ROWSIZE + c);

                CurNeighbors(r*ROWSIZE + c)(7) <= '0' when (r+1) >= ROWSIZE or (c+1) >= COLSIZE else -- edge case
                                    CellData((r+1)*ROWSIZE + (c+1));

                CurDataIn(r*ROWSIZE + c) <=  DataIn when r + c = 0 else
                                CellData(r * ROWSIZE + c - 1);
                Celli : Cell
                port map (
                    Clk         => Clk,
                    Neighbors   => CurNeighbors(r*ROWSIZE + c),
                    Shift       => Shift,
                    CellDataIn      => CurDataIn(r*ROWSIZE + c),
                    NextTimeTick    => NextTimeTick,
                    CellDataOut     => CellData(r*ROWSIZE + c)
                );
            end generate colGen;
        end generate rowGen;

        DataOut <= CellData(ROWSIZE * COLSIZE - 1);

end CellMeshArch;
