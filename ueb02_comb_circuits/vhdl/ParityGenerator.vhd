-------------------------------------------------------------------------------
-- Odd-Parity Generator
-- Output parity complements input data such that the total number of '1' in
-- data and parity is an odd number.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ParityGenerator is
  port(
    data   : in  std_logic_vector(3 downto 0);
    parity : out std_logic
    );
end ParityGenerator;

architecture xor_chain of ParityGenerator is
    
    signal X : std_logic;    -- Result uf first xor
    signal Y : std_logic;    -- Result uf first xor

begin

    X <= data(0) xor data(1);
    Y <= data(2) xor data(3);
    parity <= not (X xor Y);

end xor_chain;
