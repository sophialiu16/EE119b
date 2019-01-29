----------------------------------------------------------------------------
-- 
-- 
-- Arithmetic Logic Unit  
--
-- ALU implementation for the AVR CPU, responsible for arithmetic and logic
-- operations, including boolean operations, shifts and rotates, bit functions,
-- addition, subtraction, and comparison. The operands may be registers or 
-- immediate values. 
-- The ALU consists of a functional block for logical operations, 
-- an adder/subtracter, and a shifter/rotator. It takes several control 
-- signals from the control unit as inputs, along with the operands A 
-- and B from the register array, or from an immediate value encoded in the 
-- instruction. It outputs the computed result and computed flags.
--
-- Ports:      
--  Inputs:  
--        ALUOp   - 4 bit operation control signal 
--        ALUSel  - 2 bit control signal for the final operation select 
--        RegA    - 8 bit operand A 
--        RegB    - 8 bit operand B         
--        FlagMask- 8 bit mask for writing to status flags
--
--  Outputs:
--        RegOut  - 8 bit output result        
--      StatusOut - 8 bit status flags to status register
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity ALU is
    port(
        -- from CU
        ALUOp   : in std_logic_vector(3 downto 0); -- operation control signals 
        ALUSel  : in std_logic_vector(1 downto 0); -- operation select 
        FlagMask: in std_logic_vector(7 downto 0); -- mask for writing to status flags
        
        -- from Regs 
        RegA    : in std_logic_vector(7 downto 0); -- operand A 
        RegB    : in std_logic_vector(7 downto 0); -- operand B 
        
        RegOut  : out std_logic_vector(7 downto 0); -- output result
        StatusOut    : out std_logic_vector(7 downto 0) -- status flags to status register
    );
end ALU;

----------------------------------------------------------------------------
-- 
-- 
-- Registers 
--
-- General purpose registers for the AVR CPU. There are 32 8-bit registers, 
-- R0 to R31. Registers 26 and 27 form the 16-bit X register, 28 and 29 
-- form the Y register, and 30 and 31 form the Z register. Registers 
-- 24 and 25 may be used as a 16-bit value for some operations, and registers 
-- 0 and 1 may be used for 16-bit results of some operations.
-- The register array consists of a 5:32 decoder, 32 DFFS, and a selecting 
-- interface. It takes as an input the system clock, input data, and enable 
-- and select control signals. It outputs 8 bit registers A and B to the ALU.
--
-- Ports:
--  Inputs:     
--        RegIn    - 8 bit input register bus
--        Clk      - system clock
--        RegWEn   - register write enable
--        RegWSel  - 5 bit register write select
--        RegSelA  - 5 bit register A select
--        RegSelB  - 5 bit register B select
--
--  Outputs:
--        RegAOut  - 8 bit register bus A output
--        RegBOut  - 8 bit register bus B output
--
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity Reg is
    port(
        RegIn    :  in  std_logic_vector(7 downto 0);       -- input register bus
        Clk      :  in  std_logic;                          -- system clock
        
        -- from CU 
        RegWEn  : in std_logic; -- register write enable 
        RegWSel : in std_logic_vector(4 downto 0); -- register write select
        RegSelA : in std_logic_vector(4 downto 0); -- register A select
        RegSelB : in std_logic_vector(4 downto 0); -- register B select
        
        RegAOut  :  out std_logic_vector(7 downto 0);       -- register bus A out
        RegBOut  :  out std_logic_vector(7 downto 0)        -- register bus B out
    );

end Reg;

----------------------------------------------------------------------------
-- 
-- 
-- I/O Registers 
--
-- I/O registers for the AVR CPU. There are 64 I/O ports that can be 
-- manipulated, located at addreses 32 to 95. The status registers 
-- are included in the I/O registers.
-- The inputs include the input data register, address values, 
-- and status register inputs. The output is the 8-bit data output.
-- 
--
-- Ports:
--  Inputs:
--        RegIn    - 8-bit input from the registers
--        StatusIn - 8-bit status flag input from ALU
--        Clk      - system clock
--        K        - 8-bit immediate value to use
--        SregInOut  - in/out control 
--        IOEn    - io register enable
--
--  Outputs:
--        RegOut  - 8-bit output register bus    
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity IOReg is
    port(
        RegIn    : in  std_logic_vector(7 downto 0);       -- input register bus
        StatusIn : in std_logic_vector(7 downto 0);        -- input status flags
        Clk      : in  std_logic;                          -- system clock
        K        : in std_logic_vector(7 downto 0);         -- immediate value 
        SRInOut : in std_logic;                             -- in/out control 
        IOEn    : in std_logic;                             -- io register enable
        RegOut  :  out std_logic_vector(7 downto 0)         -- output register bus
    );

end IOReg;

----------------------------------------------------------------------------
-- 
-- 
-- Program Memory Interface Unit
--
-- The program memory access unit generates the addresses for reading the  
-- program memory data. The program memory is addressed as 16-bit words 
-- with 16-bit addresses. The program counter, containing the currently 
-- executing instruction, is located inside this unit and is incremented 
-- or loaded as necessary for the next address.
--
-- Ports:
--  Inputs: 
--        ProgAddr - 16-bit program address source from CU
--        RegOut   - 16-bit immediate address source from registers
--        Load     - load select for PC, from CU
--        AddrSel  - address source select, from CU 
--
--  Outputs: 
--        ProgAB  : out std_logic_vector(15 downto 0) -- program address bus
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity ProgramMIU is 
    port(
        ProgAddr: in std_logic_vector(15 downto 0); -- program address source from CU
        RegOut  : in std_logic_vector(15 downto 0); -- immediate address source from registers
        Load    : in std_logic;                     -- load select for PC, from CU
        AddrSel : in std_logic_vector(1 downto 0);  -- address source select, from CU 
        ProgAB  : out std_logic_vector(15 downto 0) -- program address bus
     ); 
end ProgramMIU; 

----------------------------------------------------------------------------
-- 
-- 
-- Data Memory Interface Unit
--
-- The data memory access unit generates the addresses and reads/writes 
-- data for the data memory. The data is addressed as 8-bits with 16-bits 
-- of address. The address may come from the instruction, the X, Y, Z, or 
-- SP registers, and may be pre/post incremented/decremented or with 
-- a 6-bit unsigned offset. The CU handles this with select signals for 
-- the source, offset, and pre/post changes. 
--
-- Ports:
--  Input: 
--        DataAddr - 16-bit data address source from CU
--        XAddr    - 16-bit address source from register X
--        YAddr    - 16-bit address source from register Y
--        ZAddr    - 16-bit address source from register Z
--        AddrSel  - 2-bit address source select, from CU 
--        QOffset  - 6-bit unsigned address offset source from CU 
--        OffsetSel - 2-bit address offset source select from CU 
--        PreSel   - pre/post address select from CU 
--        DataRd   - indicates data memory is being read
--        DataWr   - indicates data memory is being 
--
--  Outputs:
--        DataReg - 16-bit data address register source 
--        DataAB  - 16-bit program address bus
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity DataMIU is 
    port(
        DataAddr: in std_logic_vector(15 downto 0); -- data address source from CU
        XAddr   : in std_logic_vector(15 downto 0); -- address source from register X
        YAddr   : in std_logic_vector(15 downto 0); -- address source from register Y
        ZAddr   : in std_logic_vector(15 downto 0); -- address source from register Z
        AddrSel : in std_logic_vector(1 downto 0);  -- address source select, from CU 
        
        QOffset : in std_logic_vector(5 downto 0);  -- unsigned address offset source from CU 
        OffsetSel : in std_logic_vector(1 downto 0);-- address offset source select from CU 
        
        PreSel : in std_logic; -- pre/post address select from CU 
        
        DataRd  : in std_logic; -- indicates data memory is being read
        DataWr  : in std_logic; -- indicates data memory is being written
        
        DataReg : out std_logic_vector(15 downto 0); -- data address register source 
        DataAB  : out std_logic_vector(15 downto 0) -- program address bus
     );
end DataMIU; 
 
----------------------------------------------------------------------------
-- 
-- 
-- Stack Pointer
--
-- The 8-bit stack pointer register stores the address at the top of the stack. 
-- It is incremented, decremented, or loaded as necessary depending on the 
-- instruction. An active low reset is used to initialize the pointer to 
-- all 1's. 
--
-- Ports:
--  Inputs:
--        StackEn     - stack enable signal from CU
--        StackPush   - stack push/pop from CU, used to inc/dec
--        Reset       - active low reset, sets SP to $FF
--        RegIn       - 8-bit stack load input from registers
--
--  Outputs:
--        SP          : out std_logic_vector(7 downto 0) -- stack pointer output 
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity SP is 
    port(
        StackEn     : in std_logic; -- stack enable signal from CU
        StackPush   : in std_logic; -- stack push/pop from CU, used to inc/dec
        Reset       : in std_logic; -- active low reset, sets SP to $FF
        RegIn       : in std_logic_vector(7 downto 0); -- stack load input from registers
        SP          : out std_logic_vector(7 downto 0) -- stack pointer output 
    ); 
end SP; 


 ----------------------------------------------------------------------------
-- 
-- 
-- Control Unit  
--
-- RISC Control Unit for the AVR CPU. This contains the 16-bit instruction 
-- register, logic for instruction decoding, and a finite state machine for 
-- instruction cycle counts. It outputs all the necessary control signals for 
-- executing instructions, including addressing, ALU operations, register 
-- operations, 
--
-- Ports:
--
-- Revision History:
-- 01/24/2019 Sophia Liu Initial revision
--
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes; 
use opcodes.opcodes.all; 

entity CU is
    port(
        ProgDB  : in std_logic_vector(15 downto 0); -- program memory data bus
        SReg    : in std_logic_vector(7 downto 0);  -- status flags
        
        -- to registers
        RegWEn  : out std_logic; -- register write enable 
        RegWSel : out std_logic_vector(4 downto 0); -- register write select
        RegSelA : out std_logic_vector(4 downto 0); -- register A select
        RegSelB : out std_logic_vector(4 downto 0); -- register B select

        -- to ALU and SReg
        ALUOp   : out std_logic_vector(4 downto 0); -- operation control signals 
        ALUSel  : out std_logic_vector(2 downto 0); -- operation select 
        FlagMask: out std_logic_vector(7 downto 0); -- mask for writing to flags
        
        -- I/O
        IOEn    : out std_logic; -- enable I/O port operations 
        K       : out std_logic_vector(7 downto 0); -- immediate value K 
        SRInOut : out std_logic; -- in/out control for I/O ports 
        
        -- Program memory access
        ProgAddr: out std_logic_vector(15 downto 0); -- address source for program memory unit
        ProgLoad: out std_logic;                    -- load select for PC
        ProgAddrSel : in std_logic_vector(1 downto 0);  -- program address source select 
        
        -- Data memory access       
        DataAddrSel : out std_logic_vector(1 downto 0);  -- data address source select
        DataOffsetSel : out std_logic_vector(1 downto 0);-- data address offset source select 
        PreSel  : out std_logic; -- data pre/post address select 
        DataRd  : out std_logic; -- indicates data memory is being read
        DataWr  : out std_logic; -- indicates data memory is being written
        DataAddr: out std_logic_vector(15 downto 0); -- address source for data memory unit
        AddrOffset: out std_logic_vector(5 downto 0); -- address offset for data memory unit 
        
        -- Stack
        StackEn     : out std_logic; -- stack enable signal 
        StackPush   : out std_logic; -- stack push/pop control
        Reset       : out std_logic -- active low reset signal
    );
end CU;