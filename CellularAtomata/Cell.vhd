-- EE119b HW8 Sophia Liu

----------------------------------------------------------------------------
--
-- Cell for Conway's game of life, cellular atomaton
--
-- Cell processing element used in CellMesh.
-- Each cell has 8 input neighbors. If input NextTimeTick is active, the cells
-- change state based on the state of their neighbor. If shift is active,
-- regardless of NextTimeTick, the cells will serially shift in the state input
-- signal DataIn each clock. It outputs its own state DataOut.
--
-- Inputs:
--        Clk       -- system clock
--
--        Neighbors -- 8 bit signal containing the 8 neighboring cell states
--
--        Shift     -- 1 bit active high control signal to shift data in and out
--
--        CellDataIn    -- 1 bit cell data to shift in serially if Shift is active
--                      '1' for alive, '0' for dead cell
--
--        NextTimeTick  -- 1 bit active high control signal
--                              to enable cell change based on neighbors
-- Outputs:
--        CellDataOut   -- 1 bit cell data, shifted out serially if Shift is active
--                      '1' for alive, '0' for dead cell
--
-- Revision History:
-- 03/13/19 Sophia Liu Initial revision
-- 03/14/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.CellConstants.all;

entity Cell is
    port(
        Clk         : in std_logic;     -- system clock
        Neighbors : in std_logic_vector(7 downto 0); -- neighboring cell states
        Shift       : in std_logic;     -- control signal to shift data in and out
        CellDataIn  : in std_logic;     -- data to shift in serially, from previous cell
        NextTimeTick    : in std_logic; -- control signal to enable cell change
        CellDataOut : out std_logic     -- state data output of this cell
    );
end Cell;

architecture CellArch of Cell is
    signal Self : std_logic;        -- state of self; '0' if dead, '1' if alive
    signal NeighborCount : integer; -- count of living neighboring cells
    begin

        process(clk)
            begin
    		if rising_edge(clk) then
                -- if shift is active, shift in datain, shift out dataout
                if Shift = '1' then
                    Self <= CellDataIn;
                elsif NextTimeTick = '1' then
                    -- otherwise, if NextTimeTick is active,
                    --  calculate self status based on neighbors
                    if NeighborCount = 3 then
                        Self <= '1';    -- always alive if 3 neighbors alive
                    elsif NeighborCount /=2 then
                        Self <= '0';    -- always dead if not (2 or 3) neighbors alive
                    else
                        Self <= Self;   -- persist state if 2 neighbors alive
                    end if;
                else
                    Self <= Self;
                end if;
            end if;
            CellDataOut <= Self;    -- output self state
        end process;

        -- count living neighbors (in groups of 4 to save space)
        NeighborCount <= sum(Neighbors(3 downto 0)) + sum(Neighbors(7 downto 4));

end CellArch;

----------------------------------------------------------------------------
--
-- Cell mesh for Conway's game of life, cellular atomaton
--
-- The cell mesh consists of a 2d mesh of cell processing elements, which
-- can be either alive (data state '1') or dead (state '0').
-- This describes the connections between all the cells in the mesh.
-- Each cell has 8 neighbors (except cells on the edge), which are
-- assigned in the architecture. If input NextTimeTick is active, the cells
-- change state based on the state of their neighbor. If shift is active,
-- regardless of NextTimeTick, the cells will serially shift in the state input
-- signal DataIn each clock, and output DataOut from the last cell.
--
-- Generic:
--        RowSize     -- number of rows in mesh
--
--        ColSize     -- number of columns in mesh
--
-- Inputs:
--        Clk       -- system clock
--
--        Shift     -- 1 bit active high control signal to shift data in and out
--
--        DataIn    -- 1 bit cell data to shift in serially if Shift is active
--                      '1' for alive, '0' for dead cell
--
--        NextTimeTick    -- 1 bit active high control signal
--                              to enable cell change based on neighbors
-- Outputs:
--        DataOut    -- 1 bit cell data, shifted out serially if Shift is active
--                      '1' for alive, '0' for dead cell
--
-- Revision History:
-- 03/13/19 Sophia Liu Initial revision
-- 03/14/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.CellConstants.all;

entity CellMesh is
    generic(
        RowSize : natural := 3;     -- number of rows in mesh
        ColSize : natural := 3      -- number of columns in mesh
    );
    port(
        Clk     : in std_logic;     -- system clock
        Shift   : in std_logic;     -- control signal to shift data in and out
        DataIn  : in std_logic;     -- data to shift in serially
        NextTimeTick    : in std_logic; -- control signal to enable cell change
        DataOut : out std_logic     -- serial data output from cells
    );
end CellMesh;

architecture CellMeshArch of CellMesh is

    component Cell is
        port(
            Clk         : in std_logic;     -- system clock
            Neighbors : in std_logic_vector(7 downto 0); -- neighboring cell states
            Shift       : in std_logic;     -- control signal to shift data in and out
            CellDataIn  : in std_logic;     -- data to shift in serially, from previous cell
            NextTimeTick    : in std_logic; -- control signal to enable cell change
            CellDataOut : out std_logic     -- state data output of this cell
        );
    end component;
    -- interconnect signals
    type NeighborBus is array((ROWSIZE * COLSIZE - 1) downto 0) of std_logic_vector(NSIZE downto 0);
    signal CurNeighbors : NeighborBus;  -- cell neighbors
    signal CellData : std_logic_vector((ROWSIZE * COLSIZE - 1) downto 0);   -- cell outputs
    signal CurDataIn : std_logic_vector(ROWSIZE * COLSIZE - 1 downto 0);    -- cell inputs
    begin

        -- rowsize x colsize mesh of cells
        rowGen: for r in 0 to ROWSIZE-1 generate
            colGen : for c in 0 to COLSIZE-1 generate
                -- current cell is number r * COLSIZE + c
                -- neighboring cells assigned; 0 if no neighbor
                CurNeighbors(r*COLSIZE + c)(0) <= '0' when (r-1) < 0 or (c-1) < 0 else -- edge case
                                    CellData((r-1)*COLSIZE + (c-1));

                CurNeighbors(r*COLSIZE + c)(1) <= '0' when (r-1) < 0 else -- edge case
                                    CellData((r-1)*COLSIZE + c);

                CurNeighbors(r*COLSIZE + c)(2) <= '0' when (r-1) < 0 or (c+1) >= COLSIZE else -- edge case
                                    CellData((r-1)*COLSIZE + (c+1));

                CurNeighbors(r*COLSIZE + c)(3) <= '0' when (c-1) < 0 else -- edge case
                                    CellData((r)*COLSIZE + (c-1));

                CurNeighbors(r*COLSIZE + c)(4) <= '0' when (c+1) >= COLSIZE else -- edge case
                                    CellData(r*COLSIZE + (c+1));

                CurNeighbors(r*COLSIZE + c)(5) <= '0' when (r+1) >= ROWSIZE or (c-1) < 0 else -- edge case
                                    CellData((r+1)*COLSIZE + (c-1));

                CurNeighbors(r*COLSIZE + c)(6) <= '0' when (r+1) >= ROWSIZE  else -- edge case
                                    CellData((r+1)*COLSIZE + c);

                CurNeighbors(r*COLSIZE + c)(7) <= '0' when (r+1) >= ROWSIZE or (c+1) >= COLSIZE else -- edge case
                                    CellData((r+1)*COLSIZE + (c+1));

                -- data input signal is DataIn for first cell; previous cell for others
                CurDataIn(r*COLSIZE + c) <=  DataIn when r + c = 0 else
                                CellData(r * COLSIZE + c - 1);
                Celli : Cell
                port map (
                    Clk         => Clk,
                    Neighbors   => CurNeighbors(r*COLSIZE + c),
                    Shift       => Shift,
                    CellDataIn      => CurDataIn(r*COLSIZE + c),
                    NextTimeTick    => NextTimeTick,
                    CellDataOut     => CellData(r*COLSIZE + c)
                );
            end generate colGen;
        end generate rowGen;
        -- last cell output is DataOut signal
        DataOut <= CellData(ROWSIZE * COLSIZE - 1);

end CellMeshArch;
