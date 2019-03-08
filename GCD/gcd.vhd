
----------------------------------------------------------------------------
--
-- EE119b HW7 Sophia Liu
--
-- GCD PE 1
--
-- Description
--
-- Ports:
--
-- Revision History:
-- 11/14/18 Sophia Liu Initial revision
-- 11/16/18 Sophia Liu Updated comments
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity GCDPE1 is
        generic (
            NumBits : natural := 31
            --NumBitsK : natural := 4 --TODO make k smaler
        );
        port(
            Clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0);
            bin   :  in  std_logic_vector(NumBits downto 0);
            kin   :  in  std_logic_vector(NumBits downto 0);
            aout  :  out std_logic_vector(NumBits downto 0);
            bout  :  out std_logic_vector(NumBits downto 0);
            kout  :  out std_logic_vector(NumBits downto 0)
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
                aout <= '0' & ain(NumBits downto 1); -- divide a by 2
                bout <= '0' & bin(NumBits downto 1); -- divide b by 2
            else 
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
-- Name
--
-- Description
--
-- Ports:
--
-- Revision History:
-- 11/14/18 Sophia Liu Initial revision
-- 11/16/18 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity GCDPE2 is
        generic (
            NumBits : natural := 31
        );
        port(
            Clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0);
            bin   :  in  std_logic_vector(NumBits downto 0);
            kin   :  in  std_logic_vector(NumBits downto 0);
            aout  :  out std_logic_vector(NumBits downto 0);
            bout  :  out std_logic_vector(NumBits downto 0);
            kout  :  out std_logic_vector(NumBits downto 0);
            tout  :  out std_logic_vector(NumBits downto 0); -- TODO size
            toutS :  out std_logic
        );
end GCDPE2;

architecture GCDPE2 of GCDPE2 is
	begin
	process(clk)
        begin
		if rising_edge(clk) then
            -- if a is odd, t = -b
            if(ain(0) = '1') then
                tout <= bin;--std_logic_vector(unsigned(not(bin)) + 1); -- twos complement
                toutS <= '1'; 
            else
                tout <= ain;
                toutS <= '0'; 
            end if;
            kout <= kin; -- pass other signals through
            aout <= ain;
            bout <= bin;
		end if;
	end process;
end GCDPE2;

----------------------------------------------------------------------------
--
-- EE119b HW7 Sophia Liu
--
-- GCD PE 3
--
-- Description
--
-- Ports:
--
-- Revision History:
-- 11/14/18 Sophia Liu Initial revision
-- 11/16/18 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity GCDPE3 is
        generic (
            NumBits : natural := 31
        );
        port(
            Clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0);
            bin   :  in  std_logic_vector(NumBits downto 0);
            kin   :  in  std_logic_vector(NumBits downto 0);
            tin   :  in  std_logic_vector(NumBits downto 0);
            tinS  :  in  std_logic; 
            aout  :  out std_logic_vector(NumBits downto 0);
            bout  :  out std_logic_vector(NumBits downto 0);
            kout  :  out std_logic_vector(NumBits downto 0);
            tout  :  out std_logic_vector(NumBits downto 0);
            toutS :  out std_logic
        );
end GCDPE3;

architecture GCDPE3 of GCDPE3 is
    begin
	process(clk)
        begin
		if rising_edge(clk) then
            if (not (unsigned(tin) = 0)) then
                if (tin(0) = '0') then -- remove factors of 2 from t
                    tout <= '0' & tin(NumBits downto 1); -- t/2
                    aout <= ain; 
                    bout <= bin; 
                    toutS <= tinS; 
                else -- if t is not even 
                    if (tinS = '0') then -- if t > 0 --------------------------------
                        aout <= tin;    
                        bout <= bin;
                        
                        if (unsigned(tin) >= unsigned(bin)) then 
                            tout <= tin - bin; -- TODO subtractor
                            toutS <= '0'; 
                        else 
                            tout <= bin - tin; 
                            toutS <= '1'; -- t is negative 
                        end if; 
                    else -- t < 0 
                        aout <= ain;
                        bout <= tin;
                        
                        if (unsigned(ain) >= unsigned(tin)) then 
                            tout <= ain - tin; 
                            toutS <= '0'; 
                        else 
                            tout <= tin - ain; 
                            toutS <= '1'; 
                        end if; 
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
-- EE119b HW7 Sophia Liu
--
-- GCD PE 4
--
-- Description
--
-- Ports:
--
-- Revision History:
-- 11/14/18 Sophia Liu Initial revision
-- 11/16/18 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity GCDPE4 is
        generic (
            NumBits : natural := 31
        );
        port(
            Clk   :  in  std_logic; -- system clock
            ain   :  in  std_logic_vector(NumBits downto 0);
            kin   :  in  std_logic_vector(NumBits downto 0);
            aout  :  out std_logic_vector(NumBits downto 0);
            kout  :  out std_logic_vector(NumBits downto 0)
        );
end GCDPE4;

architecture GCDPE4 of GCDPE4 is
	begin
	process(clk)
        begin
		if rising_edge(clk) then
            -- put factor of 2 back in
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
-- EE119b HW7 Sophia Liu
--
-- GCD Semi-Systolic Array
--
-- Description
--
-- Ports:
--
-- Revision History:
-- 11/14/18 Sophia Liu Initial revision
-- 11/16/18 Sophia Liu Updated comments
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.gcdConstants.all;

entity GCDSys is
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
end GCDSys;

architecture GCDSys of GCDSys is
    -- internal signals
    type BusArr is array (natural range <>) of std_logic_vector(NumBits downto 0); 
    signal abus : BusArr(NumBits * 2 + NumBitsT + 4 downto 0); --TODO size
    signal bbus : BusArr(NumBits + NumBitsT + 3 downto 0); -- TODO consts
    signal kbus : BusArr(NumBits * 2 + NumBitsT + 4 + NumBits downto 0);
    signal tbus : BusArr(NumBits + NumBitsT + 3 downto NumBits + 2);

    type SBusArr is array (natural range <>) of std_logic; 
    signal tsbus : SBusArr(NumBits + NumBitsT + 3 downto NumBits + 2); 
    
    -- PE component declarations
    component GCDPE1 is
            generic (
                NumBits : natural := 31
            );
            port(
                Clk   :  in  std_logic; -- system clock
                ain   :  in  std_logic_vector(NumBits downto 0);
                bin   :  in  std_logic_vector(NumBits downto 0);
                kin   :  in  std_logic_vector(NumBits downto 0);
                aout  :  out std_logic_vector(NumBits downto 0);
                bout  :  out std_logic_vector(NumBits downto 0);
                kout  :  out std_logic_vector(NumBits downto 0)
            );
    end component;

    component GCDPE2 is
            generic (
                NumBits : natural := 31
            );
            port(
                Clk   :  in  std_logic; -- system clock
                ain   :  in  std_logic_vector(NumBits downto 0);
                bin   :  in  std_logic_vector(NumBits downto 0);
                kin   :  in  std_logic_vector(NumBits downto 0);
                aout  :  out std_logic_vector(NumBits downto 0);
                bout  :  out std_logic_vector(NumBits downto 0);
                kout  :  out std_logic_vector(NumBits downto 0);
                tout   :  out std_logic_vector(NumBits downto 0);
                toutS  :  out std_logic
            );
    end component;

    component GCDPE3 is
            generic (
                NumBits : natural := 31
            );
            port(
                Clk   :  in  std_logic; -- system clock
                ain   :  in  std_logic_vector(NumBits downto 0);
                bin   :  in  std_logic_vector(NumBits downto 0);
                kin   :  in  std_logic_vector(NumBits downto 0);
                tin   :  in  std_logic_vector(NumBits downto 0);
                tinS  :  in  std_logic;
                aout  :  out std_logic_vector(NumBits downto 0);
                bout  :  out std_logic_vector(NumBits downto 0);
                kout  :  out std_logic_vector(NumBits downto 0);
                tout  :  out std_logic_vector(NumBits downto 0);
                toutS :  out std_logic
            );
    end component;

    component GCDPE4 is
            generic (
                NumBits : natural := 31
            );
            port(
                Clk   :  in  std_logic; -- system clock
                ain   :  in  std_logic_vector(NumBits downto 0);
                kin   :  in  std_logic_vector(NumBits downto 0);
                aout  :  out std_logic_vector(NumBits downto 0);
                kout  :  out std_logic_vector(NumBits downto 0)
            );
    end component;

	begin
        kbus(0) <= (others => '0'); -- initialize k as 0
        abus(0) <= a; -- initialize a, b
        bbus(0) <= b;

        GCDPE1Gen : for i in 0 to NumBits generate
            GCDPE1i: GCDPE1
            generic map(
                NumBits => NumBits
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

        GCDPE2i: GCDPE2
            generic map(
                NumBits => NumBits
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

        GCDPE3Gen : for i in 0 to NumBitsT generate
            GCDPE3i: GCDPE3
                generic map(
                    NumBits => NumBits
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

        GCDPE4Gen : for i in 0 to NumBits generate
            GCDPE4i: GCDPE4
                generic map(
                    NumBits => NumBits
                )
                port map(
                    Clk   => Clk,
                    ain   => abus(i + NumBitsT + NumBits + 3),
                    kin   => kbus(i + NumBitsT + NumBits + 3),
                    aout  => abus(i + NumBitsT + NumBits + 4),
                    kout  => kbus(i + NumBitsT + NumBits + 4)
                );
        end generate GCDPE4Gen;
        gcd <= abus(NumBits * 2 + NumBitsT + 4);

end GCDSys;
