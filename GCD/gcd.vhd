-- EE119b HW7 Sophia Liu

----------------------------------------------------------------------------
--
-- GCD PE 1
--
-- First PE for the GCD systolic array, which calculates the gcd of 
-- inputs a and b. 
-- This removes common factors of two from a and b. Each PE checks 
-- if a and b are even, and if so shifts a and b and increments a 
-- counter k for the power of 2. 
--
-- Generic: 
--      NumBits - number of bits in gcd inputs 
--      NumBitsK - number of bits in power of 2 counter (log2(size of input)) 
-- 
-- Inputs: 
--      clk   - system clock
--      ain   - NumBits sized input a 
--      bin   - NumBits sized input b
--      kin   - NumBitsK sized power of 2 counter 
-- 
-- Outputs: 
--      aout  - NumBits sized output a 
--      bout  - NumBits sized output b  
--      kout  - NumBitsK sized power of 2 counter  
--
-- Revision History:
-- 03/06/19 Sophia Liu Initial revision
-- 03/08/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity GCDPE1 is
        generic (
            NumBits : natural := 15; -- number of bits in gcd inputs
            NumBitsK : natural := 3  -- number of bits in power of 2 counter
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            bin   :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            bout  :  out std_logic_vector(NumBits downto 0); -- gcd input b
            kout  :  out std_logic_vector(NumBitsK downto 0) -- power of 2 counter 
        );
end GCDPE1;

architecture GCDPE1 of GCDPE1 is
	begin
	process(clk)
        begin
		if rising_edge(clk) then
            -- if a, b even then remove factor of 2
            if(ain(0) = '0' and bin(0) = '0') then
                kout <= std_logic_vector(unsigned(kin) + 1); -- increment k in 2^k
                aout <= '0' & ain(NumBits downto 1); -- shift to divide a by 2
                bout <= '0' & bin(NumBits downto 1); -- shift to divide b by 2
            else -- if no more factors of 2
                kout <= kin; -- pass signals through 
                aout <= ain; 
                bout <= bin; 
            end if; 
		end if;
	end process;
end GCDPE1;

----------------------------------------------------------------------------
--
-- GCD PE 2
--
-- Second PE for the GCD systolic array, which calculates the gcd of 
-- inputs a and b. 
-- This sets the initial intermediate signal t used in stein's algorithm 
-- based on inputs a and b. 
--
-- Generic: 
--      NumBits - number of bits in gcd inputs 
--      NumBitsK - number of bits in power of 2 counter (log2(size of input)) 
-- 
-- Inputs: 
--      clk   - system clock
--      ain   - NumBits sized input a 
--      bin   - NumBits sized input b
--      kin   - NumBitsK sized power of 2 counter 
-- 
-- Outputs: 
--      aout  - NumBits sized output a 
--      bout  - NumBits sized output b  
--      kout  - NumBitsK sized power of 2 counter  
--      tout  - NumBits sized intermediate signal t 
--      toutS - 1 bit flag for sign of t 
--
-- Revision History:
-- 03/06/19 Sophia Liu Initial revision
-- 03/08/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.gcdConstants.all;

entity GCDPE2 is
        generic (
            NumBits : natural := 15;-- number of bits in gcd inputs
            NumBitsK : natural := 3 -- number of bits in power of 2 counter
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            bin   :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            bout  :  out std_logic_vector(NumBits downto 0); -- gcd input b
            kout  :  out std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            tout  :  out std_logic_vector(NumBits downto 0); -- t output
            toutS :  out std_logic -- sign of t 
        );
end GCDPE2;

architecture GCDPE2 of GCDPE2 is
	begin
	process(clk)
        begin
		if rising_edge(clk) then
            if(ain(0) = '1') then   -- if a is odd, t = -b 
                tout <= bin;
                toutS <= TNEG; 
            else                    -- otherwise t = a
                tout <= ain;
                toutS <= TPOS; 
            end if;
            kout <= kin;            -- pass other signals through
            aout <= ain;
            bout <= bin;
		end if;
	end process;
end GCDPE2;

----------------------------------------------------------------------------
--
-- GCD PE 3
--
-- Third PE for the GCD systolic array, which calculates the gcd of 
-- inputs a and b. 
-- This follows stein's algorithm and shifts t to divide by two if t is even. 
-- It subtracts using inputs a, b, and t to set the next values of a, b, and t. 
--
-- Generic: 
--      NumBits - number of bits in gcd inputs 
--      NumBitsK - number of bits in power of 2 counter (log2(size of input)) 
-- 
-- Inputs: 
--      clk   - system clock
--      ain   - NumBits sized input a 
--      bin   - NumBits sized input b
--      kin   - NumBitsK sized power of 2 counter 
--      tin  - NumBits sized intermediate signal t 
--      tinS - 1 bit flag for sign of t 
-- 
-- Outputs: 
--      aout  - NumBits sized output a 
--      bout  - NumBits sized output b  
--      kout  - NumBitsK sized power of 2 counter  
--      tout  - NumBits sized intermediate signal t 
--      toutS - 1 bit flag for sign of t 
--
-- Revision History:
-- 03/06/19 Sophia Liu Initial revision
-- 03/08/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.gcdConstants.all;

entity GCDPE3 is
        generic (
            NumBits : natural := 15;-- number of bits in gcd inputs
            NumBitsK : natural := 3 -- number of bits in power of 2 counter 
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            bin   :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            tin   :  in  std_logic_vector(NumBits downto 0); -- t input 
            tinS  :  in  std_logic; -- sign of t
            
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            bout  :  out std_logic_vector(NumBits downto 0); -- gcd input b
            kout  :  out std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            tout  :  out std_logic_vector(NumBits downto 0); -- t output
            toutS :  out std_logic -- sign of t 
        );
end GCDPE3;

architecture GCDPE3 of GCDPE3 is
    begin
	process(clk)
        variable tint : std_logic_vector(NumBits downto 0); -- intermediate t variable
	   
        begin
		if rising_edge(clk) then
		    -- while t != 0; done if t = 0
            if (not (unsigned(tin) = 0)) then
                if (tin(0) = '0') then -- remove factors of 2 from t
                    tout <= '0' & tin(NumBits downto 1); -- shift t to divide by 2
                    aout <= ain; -- pass other signals through 
                    bout <= bin; 
                    toutS <= tinS; 
                else -- if t is not even, subtract for next outputs 
                    if (tinS = '0') then -- if t > 0 
                        aout <= tin;    -- a = t
                        bout <= bin; 
                        
                        -- t = a - b
                        if (unsigned(tin) >= unsigned(bin)) then 
                            tint := tin - bin; -- TODO subtractor
                            toutS <= '0'; 
                        else 
                            tint := bin - tin; 
                            toutS <= '1'; -- t is negative 
                        end if; 
                    else -- t < 0 
                        aout <= ain;
                        bout <= tin;    -- b = -t 
                        
                        -- t = a - b
                        if (unsigned(ain) >= unsigned(tin)) then 
                            tint := ain - tin; 
                            toutS <= '0'; 
                        else 
                            tint := tin - ain; 
                            toutS <= '1'; 
                        end if; 
                    end if;
                    -- shift if necessary 
                    if(tint(0) = '0') then 
                        tout <= '0' & tint(NumBits downto 1);
                    else 
                        tout <= tint; 
                    end if; 
                end if;
            else -- t == 0 
                aout <= ain; -- done with steins, pass signals through 
                bout <= bin; 
                tout <= tin; 
                toutS <= tinS; 
            end if;
            kout <= kin; -- pass k through 
		end if;
	end process;
end GCDPE3;

----------------------------------------------------------------------------
--
-- GCD PE 4
--
-- Fourth PE for the GCD systolic array, which calculates the gcd of 
-- inputs a and b. 
-- This puts back the factors of two into the final gcd result. 
-- For every k, it shifts the result a to multiply by 2.  
--
-- Generic: 
--      NumBits - number of bits in gcd inputs 
--      NumBitsK - number of bits in power of 2 counter (log2(size of input)) 
-- 
-- Inputs: 
--      clk   - system clock
--      ain   - NumBits sized input a 
--      kin   - NumBitsK sized power of 2 counter 
-- 
-- Outputs: 
--      aout  - NumBits sized output a 
--      kout  - NumBitsK sized power of 2 counter  
--
-- Revision History:
-- 03/06/19 Sophia Liu Initial revision
-- 03/08/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity GCDPE4 is
        generic (
            NumBits : natural := 15; -- number of bits in gcd inputs 
            NumBitsK : natural := 3 -- number of bits in power of 2 counter
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0);  -- gcd input a
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            kout  :  out std_logic_vector(NumBitsK downto 0) -- power of 2 counter 
        );
end GCDPE4;

architecture GCDPE4 of GCDPE4 is
	begin
	process(clk)
        begin
		if rising_edge(clk) then
            -- put factors of 2 back in
            if(unsigned(kin) > 0) then
                kout <= std_logic_vector(unsigned(kin) - 1); -- decrement k
                aout <= ain(NumBits - 1 downto 0) & '0'; -- multiply a by 2
            else 
                kout <= kin; -- done with gcd, pass signals through 
                aout <= ain; 
            end if; 
		end if;
	end process;
end GCDPE4;

----------------------------------------------------------------------------
--
-- GCD Semi-Systolic Array
--
-- Semi-systolic array for calculating the GCD of inputs a and b. 
-- Stein's algorithm is used to calculate the GCD. The first set of PEs 
-- removes common factors of 2, the middle sets of PEs shift and subtract 
-- according to Stein's, and the final set of PEs puts back the common 
-- factors of 2 into the gcd result.  
--
-- Generic: 
--      NumBits - number of bits in gcd inputs 
--      NumBitsK - number of bits in power of 2 counter (log2(size of input)) 
-- 
-- Inputs: 
--      clk   - system clock
--      a     - NumBits sized gcd input a 
--      b     - NumBits sized gcd input b
-- 
-- Outputs: 
--      gcd   - NumBits sized gcd of a and b
--
-- Revision History:
-- 03/06/19 Sophia Liu Initial revision
-- 03/08/19 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.gcdConstants.all;

entity GCDSys is
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
end GCDSys;

architecture GCDSys of GCDSys is
    -- internal signals
    type BusArr is array (natural range <>) of std_logic_vector(NumBits downto 0); 
    signal abus : BusArr(NumBits * 2 + NumBitsT + 4 downto 0); --TODO consts
    signal bbus : BusArr(NumBits + NumBitsT + 3 downto 0); 
    signal tbus : BusArr(NumBits + NumBitsT + 3 downto NumBits + 2);
    
    type KBusArr is array (natural range <>) of std_logic_vector(NumBitsK downto 0); 
    signal kbus : KBusArr(NumBits * 2 + NumBitsT + 4 + NumBits downto 0);
    
    type SBusArr is array (natural range <>) of std_logic; 
    signal tsbus : SBusArr(NumBits + NumBitsT + 3 downto NumBits + 2); 
    
    -- PE component declarations
    component GCDPE1 is
        generic (
            NumBits : natural := 15; -- number of bits in gcd inputs
            NumBitsK : natural := 3  -- number of bits in power of 2 counter
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            bin   :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            bout  :  out std_logic_vector(NumBits downto 0); -- gcd input b
            kout  :  out std_logic_vector(NumBitsK downto 0) -- power of 2 counter 
        );
    end component;

    component GCDPE2 is
        generic (
            NumBits : natural := 15;-- number of bits in gcd inputs
            NumBitsK : natural := 3 -- number of bits in power of 2 counter
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            bin   :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            bout  :  out std_logic_vector(NumBits downto 0); -- gcd input b
            kout  :  out std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            tout  :  out std_logic_vector(NumBits downto 0); -- t output
            toutS :  out std_logic -- sign of t 
        );
    end component;

    component GCDPE3 is
        generic (
            NumBits : natural := 15;-- number of bits in gcd inputs
            NumBitsK : natural := 3 -- number of bits in power of 2 counter 
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0); -- gcd input a
            bin   :  in  std_logic_vector(NumBits downto 0); -- gcd input b
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            tin   :  in  std_logic_vector(NumBits downto 0); -- t input 
            tinS  :  in  std_logic; -- sign of t
            
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            bout  :  out std_logic_vector(NumBits downto 0); -- gcd input b
            kout  :  out std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            tout  :  out std_logic_vector(NumBits downto 0); -- t output
            toutS :  out std_logic -- sign of t 
        );
    end component;

    component GCDPE4 is
            generic (
            NumBits : natural := 15; -- number of bits in gcd inputs 
            NumBitsK : natural := 3 -- number of bits in power of 2 counter
        );
        port(
            -- inputs 
            clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0);  -- gcd input a
            kin   :  in  std_logic_vector(NumBitsK downto 0); -- power of 2 counter 
            
            -- outputs 
            aout  :  out std_logic_vector(NumBits downto 0); -- gcd input a
            kout  :  out std_logic_vector(NumBitsK downto 0) -- power of 2 counter 
        );
    end component;

	begin
        kbus(0) <= (others => '0'); -- initialize k as 0
        abus(0) <= a;               -- initialize a, b
        bbus(0) <= b;

        -- need NumBits # of PE 1 to remove common power of 2 
        GCDPE1Gen : for i in 0 to NumBits generate
            GCDPE1i: GCDPE1
            generic map(
                NumBits => NumBits,
                NumBitsK => NumBitsK
            )
            port map(
                Clk   => Clk,
                ain   => abus(i),
                bin   => bbus(i),
                kin   => kbus(i),
                aout  => abus(i+1),
                bout  => bbus(i+1),
                kout  => kbus(i+1)
            );
        end generate GCDPE1Gen;
        
        -- need 1 of PE2 to set initial t
        GCDPE2i: GCDPE2
            generic map(
                NumBits => NumBits,
                NumBitsK => NumBitsK
            )
            port map(
                Clk   => Clk,
                ain   => abus(NumBits + 1),
                bin   => bbus(NumBits + 1),
                kin   => kbus(NumBits + 1),
                aout  => abus(NumBits + 2),
                bout  => bbus(NumBits + 2),
                kout  => kbus(NumBits + 2),
                tout  => tbus(NumBits + 2),
                toutS => tsbus(NumBits + 2)
            );

        -- need NumBitsT # of PE3 to perform stein's algorithm
        GCDPE3Gen : for i in 0 to NumBitsT generate
            GCDPE3i: GCDPE3
                generic map(
                    NumBits => NumBits,
                    NumBitsK => NumBitsK
                )
                port map(
                    Clk   => Clk,
                    ain   => abus(i + NumBits + 2),
                    bin   => bbus(i + NumBits + 2),
                    kin   => kbus(i + NumBits + 2),
                    tin   => tbus(i + NumBits + 2),
                    tinS  => tsbus(i + NumBits + 2),
                    aout  => abus(i + NumBits + 3),
                    bout  => bbus(i + NumBits + 3),
                    kout  => kbus(i + NumBits + 3),
                    tout  => tbus(i + NumBits + 3),
                    toutS => tsbus(i + NumBits + 3)
                );
        end generate GCDPE3Gen;

        -- need NumBits # of PE4 to put common power of 2 back into final result
        GCDPE4Gen : for i in 0 to NumBits generate
            GCDPE4i: GCDPE4
                generic map(
                    NumBits => NumBits,
                    NumBitsK => NumBitsK
                )
                port map(
                    Clk   => Clk,
                    ain   => abus(i + NumBitsT + NumBits + 3),
                    kin   => kbus(i + NumBitsT + NumBits + 3),
                    aout  => abus(i + NumBitsT + NumBits + 4),
                    kout  => kbus(i + NumBitsT + NumBits + 4)
                );
        end generate GCDPE4Gen;
        -- gcd is final a output 
        gcd <= abus(NumBits * 2 + NumBitsT + 4);

end GCDSys;
