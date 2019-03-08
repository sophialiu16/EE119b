----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2019 09:48:28 PM
-- Design Name: 
-- Module Name: gcdTB - Behavioral
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
            NumBits : natural := 31;
            NumBitsT : natural := 45
        );
        port(
            Clk   :  in  std_logic; -- system clock
            a     :  in  std_logic_vector(NumBits downto 0);
            b     :  in  std_logic_vector(NumBits downto 0);
            gcd   :  out std_logic_vector(NumBits downto 0)
        );
    end component;

    -- Signal used to stop clock signal generators
    signal  END_SIM  :  BOOLEAN := FALSE;
    signal  Clk     : std_logic; -- system clock
    
    -- internal signals 
    signal a : std_logic_vector(NUMBITS_TEST downto 0);
    signal b : std_logic_vector(NUMBITS_TEST downto 0);
    signal gcd : std_logic_vector(NUMBITS_TEST downto 0);
    
    -- test signals 
    signal aTest : std_logic_vector(NUMBITS_TEST downto 0);
    signal bTest : std_logic_vector(NUMBITS_TEST downto 0);
    signal gcdTest : std_logic_vector(NUMBITS_TEST downto 0);
begin

    UUT : GCDSYS 
        generic map(
            NumBits => NUMBITS_TEST,
            NumBitsT => NUMBITST_TEST
        )
        port map(
            Clk   => Clk,
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
            variable aTest : std_logic_vector(NUMBITS_TEST downto 0);
            variable bTest : std_logic_vector(NUMBITS_TEST downto 0);
            variable gcdTest : std_logic_vector(NUMBITS_TEST downto 0);
            
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
            for i in 0 to TEST_SIZE loop 
                -- generate random a, b
			     uniform(Seed1, Seed2, Rand); 
			     RandNum := std_logic_vector(to_unsigned(integer(trunc(Rand * RandRange)), RandNum'length)); 
			     aTest := RandNum; 
			     wait for CLK_PERIOD; 
			     
			     uniform(Seed1, Seed2, Rand); 
			     RandNum := std_logic_vector(to_unsigned(integer(trunc(Rand * RandRange)), RandNum'length)); 
			     bTest := RandNum;
			     wait for CLK_PERIOD;
			     
			     -- calculate test gcd result 
			     m := to_integer(unsigned(aTest)); 
			     n := to_integer(unsigned(bTest)); 
			     if (m = 0) then 
			         gcdTest := (others => '0'); 
			     elsif (n = 0) then 
			         gcdTest := aTest; --TODO 
			     else 
			         while (n /= 0) loop 
			             r := m mod n; 
			             m := n; 
			             n := r; 
			         end loop; 
			         gcdTest := std_logic_vector(to_unsigned(m, gcdTest'length)); 
			     end if; 
			     
			     a <= aTest; 
			     b <= bTest; 
			     wait for CLK_PERIOD * (NUMBITS_TEST * 2 + NUMBITST_TEST + 4); -- pipeline TODO 
			     
			     -- check array output 
			     assert (gcdTest = gcd)
			         report  "GCD failure; a : " & integer'image(to_integer(unsigned(aTest))) 
			         & "     b : "  &  integer'image(to_integer(unsigned(bTest))) 
			         & "     correct GCD : " & integer'image(to_integer(unsigned(gcdTest))) 
			         & "     test GCD : " & integer'image(to_integer(unsigned(gcd))) 
			         & "     test no : " & integer'image(TEST_SIZE-i)
			         
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

configuration TESTBENCH_FOR_GCD of gcdTB is
    for TB_ARCH
		  for UUT : GCDSys
            use entity work.GCDSys;
        end for;
    end for;
end TESTBENCH_FOR_GCD;