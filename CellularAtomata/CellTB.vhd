----------------------------------------------------------------------------------
--
-- Test Bench for Cell Mesh
--
-- Test Bench for CellMesh entity. Tests several different sized meshes, using
-- all possible 3x3 cases and random cases for 7x7 and 6x9 meshes. 
-- The test data is shifted in, the cells are left for a number of cycles,
-- and the test data is shifted out and checked.
--
--  Revision History:
--     03/13/19 Sophia Liu initial revision
--     03/14/19 Sophia Liu updated comments
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.CellConstants.all;

entity CellTB is
end CellTB;

architecture TB_ARCH of CellTB is

    -- test component
    component CellMesh is
        generic(
            RowSize : natural := 3; -- number of rows in mesh
            ColSize : natural := 3  -- number of columns in mesh
        );
        port(
            Clk     : in std_logic;     -- system clock
            Shift   : in std_logic;     -- control signal to shift data in and out
            DataIn  : in std_logic;     -- data to shift in serially
            NextTimeTick    : in std_logic;     -- control signal to enable cell change
            DataOut : out std_logic     -- serial data output from cells
        );
    end component;

    -- Signal used to stop clock signal generators
    signal  END_SIM  :  BOOLEAN := FALSE;
    signal  Clk     : std_logic; -- system clock

    -- internal signals
    signal Shift : std_logic;
    signal DataIn : std_logic;
    signal NextTimeTick : std_logic;
    signal DataOut : std_logic;
    signal DataOut7 : std_logic;
    signal DataOut69 : std_logic;

begin
    -- test components
    UUT : CellMesh
        generic map(
            RowSize => 3,
            ColSize => 3
        )
        port map(
            Clk     => Clk,
            Shift   => Shift,
            DataIn  => DataIn,
            NextTimeTick    => NextTimeTick,
            DataOut => DataOut
        );

   UUT7 : CellMesh
        generic map(
            RowSize => 7,
            ColSize => 7
        )
        port map(
            Clk     => Clk,
            Shift   => Shift,
            DataIn  => DataIn,
            NextTimeTick    => NextTimeTick,
            DataOut => DataOut7
        );

        UUT69 : CellMesh
             generic map(
                 RowSize => 6,
                 ColSize => 9
             )
             port map(
                 Clk     => Clk,
                 Shift   => Shift,
                 DataIn  => DataIn,
                 NextTimeTick    => NextTimeTick,
                 DataOut => DataOut69
             );

        process
            variable  i  :  integer;        -- general loop indices
            variable  j  :  integer;

            -- test dataout vectors
            variable DataOutTest33 : std_logic_vector(0 to 8);
            variable DataOutTest77 : std_logic_vector(0 to 48);
            variable DataOutTest69 : std_logic_vector(0 to 53);
            begin

            -- have not yet started
            DataIn <= '0';
            Shift  <= '0';
            NextTimeTick <= '0';
            wait for CLK_PERIOD * 10;

            -- 3x3 testing
            -- 1 cycle
            for i in 0 to 511 loop
                -- shift in data
                Shift <= '1';
                for j in 0 to 8 loop
                    DataIn <= InitialState33(i)(j);
                    wait for CLK_PERIOD;
                end loop;
                Shift <= '0';

                -- wait for one cycle
                NextTimeTick <= '1';
                wait for CLK_PERIOD;
                NextTimeTick <= '0';

                -- shift out data and check
                DataIn <= '0'; -- shift in something
                Shift <= '1';
                wait for CLK_PERIOD;
                for j in 0 to 8 loop
                    DataOutTest33(j) := DataOut;
                    wait for CLK_PERIOD;
                end loop;
                -- check output data
			    assert (DataOutTest33 = Cycle133(i))
			         report  "Cycle 1 failure; Initial : " & integer'image(to_integer(unsigned(InitialState33(i))))
			         & "     Final : "  &  integer'image(to_integer(unsigned(DataOutTest33)))
			         & "     Correct : " & integer'image(to_integer(unsigned(Cycle133(i))))
                     & "     Test Number : " & integer'image(i)
			         severity  ERROR;
            end loop;

            -- 3x3 testing
            -- 10 cycles
            for i in 0 to 511 loop
                -- shift in data
                Shift <= '1';
                for j in 0 to 8 loop
                    DataIn <= InitialState33(i)(j);
                    wait for CLK_PERIOD;
                end loop;
                Shift <= '0';

                -- wait for 10 cycles
                NextTimeTick <= '1';
                wait for CLK_PERIOD*10;
                NextTimeTick <= '0';

                -- shift out data and check
                DataIn <= '0'; -- shift in something
                Shift <= '1';
                wait for CLK_PERIOD;
                for j in 0 to 8 loop
                    DataOutTest33(j) := DataOut;
                    wait for CLK_PERIOD;
                end loop;
                -- check output data
			    assert (DataOutTest33 = Cycle1033(i))
			         report  "Cycle 10 failure; Initial : " & integer'image(to_integer(unsigned(InitialState33(i))))
			         & "     Final : "  &  integer'image(to_integer(unsigned(DataOutTest33)))
			         & "     Correct : " & integer'image(to_integer(unsigned(Cycle133(i))))
                     & "     Test Number : " & integer'image(i)
			         severity  ERROR;
            end loop;

            -- 7x7 testing
            -- 5 cycles
            for i in 0 to 22 loop
                -- shift in data
                Shift <= '1';
                for j in 0 to 48 loop
                    DataIn <= TestCycle577(i*2)(j);
                    wait for CLK_PERIOD;
                end loop;
                Shift <= '0';

                -- wait for 5 cycles
                NextTimeTick <= '1';
                wait for CLK_PERIOD*5;
                NextTimeTick <= '0';

                -- shift out data and check
                DataIn <= '0'; -- shift in something
                Shift <= '1';
                wait for CLK_PERIOD;
                for j in 0 to 48 loop
                    DataOutTest77(j) := DataOut7;
                    wait for CLK_PERIOD;
                end loop;
                -- check output data
                assert (DataOutTest77 = TestCycle577(i*2 + 1))
                     report  "Mesh 7x7 failure; Initial : " & integer'image(to_integer(unsigned(TestCycle577(i*2))))
                     & "     Final : "  &  integer'image(to_integer(unsigned(DataOutTest77)))
                     & "     Correct : " & integer'image(to_integer(unsigned(TestCycle577(i*2 + 1))))
                     & "     Test Number : " & integer'image(i)
                     severity  ERROR;
            end loop;

            -- 6x9 testing
            -- 5 cycles
            for i in 0 to 22 loop
                -- shift in data
                Shift <= '1';
                for j in 0 to 53 loop
                    DataIn <= TestCycle569(i*2)(j);
                    wait for CLK_PERIOD;
                end loop;
                Shift <= '0';

                -- wait for 5 cycles
                NextTimeTick <= '1';
                wait for CLK_PERIOD*5;
                NextTimeTick <= '0';

                -- shift out data and check
                DataIn <= '0'; -- shift in something
                Shift <= '1';
                wait for CLK_PERIOD;
                for j in 0 to 53 loop
                    DataOutTest69(j) := DataOut69;
                    wait for CLK_PERIOD;
                end loop;
                -- check output data
                assert (DataOutTest69 = TestCycle569(i*2 + 1))
                     report  "Mesh 6x9 failure; Initial : " & integer'image(to_integer(unsigned(TestCycle569(i*2))))
                     & "     Final : "  &  integer'image(to_integer(unsigned(DataOutTest69)))
                     & "     Correct : " & integer'image(to_integer(unsigned(TestCycle569(i*2 + 1))))
                     & "     Test Number : " & integer'image(i)
                     severity  ERROR;
            end loop;

            END_SIM <= true;
            wait;
        end process;

        -- process for generating system clock
        CLOCK_CLK : process
        begin
            -- this process generates a CLK_PERIOD ns 50% duty cycle clock
            -- stop the clock when the end of the simulation is reached
            if END_SIM = FALSE then
                CLK <= '0';
                wait for CLK_PERIOD/2;
            else
                wait;
            end if;

            if END_SIM = FALSE then
                CLK <= '1';
                wait for CLK_PERIOD/2;
            else
                wait;
            end if;
        end process;

end TB_ARCH;

configuration TESTBENCH_FOR_CELL of CellTB is
    for TB_ARCH
		  for UUT : CellMesh
            use entity work.CellMesh;
        end for;
        for UUT7 : CellMesh
            use entity work.CellMesh;
        end for;
        for UUT69 : CellMesh
            use entity work.CellMesh;
        end for;
    end for;
end TESTBENCH_FOR_CELL;
