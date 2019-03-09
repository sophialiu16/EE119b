----------------------------------------------------------------------------------
-- 
-- Test Bench for GCD Systolic Array 
-- 
-- Test Bench for GCDSys entity. Generates random numbers of size NBITS 
-- from the gcdConstants package. 
-- The array is first loaded with test cases, including several edge cases. 
-- Random cases are then generated, and the gcd output is checked every clock. 
--
--  Revision History:
--     03/06/19 Sophia Liu initial revision
--     03/08/19 Sophia Liu updated comments
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; 
use work.gcdConstants.all; 

entity gcdTB is
end gcdTB;

architecture TB_ARCH of gcdTB is
    
    -- test component
    component GCDSys is
        generic (
            NumBits : natural := 15;  -- number of bits in gcd inputs 
            NumBitsK : natural := 3;  -- number of bits in power of 2 counter
            NumBitsT : natural := 30  -- number of middle PEs
        );
        port(
            Clk   :  in  std_logic; -- system clock
            a     :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            b     :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            gcd   :  out std_logic_vector(NumBits downto 0) -- gcd of a and b
        );
    end component;

    -- Signal used to stop clock signal generators
    signal  END_SIM  :  BOOLEAN := FALSE;
    signal  Clk     : std_logic; -- system clock
    
    -- internal signals 
    signal a : std_logic_vector(NUMBITS_TEST downto 0);
    signal b : std_logic_vector(NUMBITS_TEST downto 0);
    signal gcd : std_logic_vector(NUMBITS_TEST downto 0);
    
    -- test signal type 
    type arrTest is array (SYSLENGTH downto 0) of std_logic_vector(NUMBITS_TEST downto 0); 
begin

    UUT : GCDSYS 
        generic map(
            NumBits => NUMBITS_TEST,
            NumBitsK => NUMBITSK_TEST,
            NumBitsT => NUMBITST_TEST
        )
        port map(
            clk   => clk,
            a     => a, 
            b     => b, 
            gcd   => gcd
        );
        
        -- randomly test GCD 
        process 
            variable  i  :  integer;        -- general loop indices
            variable  j  :  integer; 
            -- for random number generator 
            variable Seed1, Seed2: positive; 
            variable Rand : real; 				-- real number between (0, 1)
            variable RandRange : real := 2** (real(NUMBITS_TEST) + 1.0);  
            variable RandNum : std_logic_vector(NUMBITS_TEST downto 0); 
            
            -- test a, b, gcd
            variable aTest : arrTest;
            variable bTest : arrTest;
            variable gcdTest : arrTest;
            
            -- for calculating correct gcd
            variable r : integer; 
            variable m : integer; 
            variable n : integer;
            begin 
            
            -- have not yet started
            a <= (others => '0'); 
            b <= (others => '0'); 
            wait for CLK_PERIOD * 10; 
            
            -- begin testing 
            -- add some edge cases 
            aTest(1 downto 0) := ((others => '0'), (others => '1')); 
            bTest(1 downto 0) := ((others => '0'), (others => '1')); 
            gcdTest(1 downto 0) := ((others => '0'), (others => '1')); 
            
            aTest(2) := (0 => '0', others => '1'); 
            bTest(2) := (others => '1');
            gcdTest(2) := (0 => '1', others => '0'); 
            
            aTest(3) := (NUMBITS_TEST => '1', others => '0'); 
            bTest(3) := (NUMBITS_TEST => '1', others => '0');
            gcdTest(3) := (NUMBITS_TEST => '1', others => '0'); 
            
            aTest(4) := (NUMBITS_TEST => '1', others => '0'); 
            bTest(4) := (NUMBITS_TEST => '1', (NUMBITS_TEST - 1) => '1', others => '0');
            gcdTest(4) := ((NUMBITS_TEST - 1) => '1', others => '0'); 
            -- load in edge cases 
            for i in 0 to 4 loop 
                 a <= aTest(i); 
			     b <= bTest(i); 
			     wait for CLK_PERIOD;
			end loop; 
			
            -- randomized testing 
            for i in 5 to TEST_SIZE loop 
                -- can check gcd results once array is fully loaded 
                if(i >= SYSLENGTH) then 
			     assert (gcdTest(i mod SYSLENGTH) = gcd)
			         report  "GCD failure; a : " & integer'image(to_integer(unsigned(aTest(i mod SYSLENGTH)))) 
			         & "     b : "  &  integer'image(to_integer(unsigned(bTest(i mod SYSLENGTH)))) 
			         & "     correct GCD : " & integer'image(to_integer(unsigned(gcdTest(i mod SYSLENGTH)))) 
			         & "     test GCD : " & integer'image(to_integer(unsigned(gcd))) 
			         & "     test no : " & integer'image(i)
			         
			         severity  ERROR;
                end if; 
                -- generate next random a, b
			     uniform(Seed1, Seed2, Rand); 
			     RandNum := std_logic_vector(to_unsigned(integer(trunc(Rand * RandRange)), RandNum'length)); 
			     aTest(i mod SYSLENGTH) := RandNum; 
			     
			     uniform(Seed1, Seed2, Rand); 
			     RandNum := std_logic_vector(to_unsigned(integer(trunc(Rand * RandRange)), RandNum'length)); 
			     bTest(i mod SYSLENGTH) := RandNum;
			     
			     -- calculate test gcd result 
			     m := to_integer(unsigned(aTest(i mod SYSLENGTH))); 
			     n := to_integer(unsigned(bTest(i mod SYSLENGTH))); 
			     if (m = 0) then 
			         gcdTest(i mod SYSLENGTH) := (others => '0'); 
			     elsif (n = 0) then 
			         gcdTest(i mod SYSLENGTH) := aTest(i mod SYSLENGTH); --TODO 
			     else 
			         while (n /= 0) loop 
			             r := m mod n; 
			             m := n; 
			             n := r; 
			         end loop; 
			         gcdTest(i mod SYSLENGTH) := std_logic_vector(to_unsigned(m, NUMBITS_TEST + 1)); 
			     end if; 
			     
			     a <= aTest(i mod SYSLENGTH); 
			     b <= bTest(i mod SYSLENGTH); 
			     wait for CLK_PERIOD;
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

configuration TESTBENCH_FOR_GCD of gcdTB is
    for TB_ARCH
		  for UUT : GCDSys
            use entity work.GCDSys;
        end for;
    end for;
end TESTBENCH_FOR_GCD;