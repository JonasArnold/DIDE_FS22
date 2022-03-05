library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BarrelShifter is
  port(
    dataIn  : in  std_logic_vector(7 downto 0);  -- 8-bit input
    shift   : in  std_logic_vector(3 downto 0);  -- 2sC shift value 
    dataOut : out std_logic_vector(7 downto 0)   -- 8-bit output
    );
end BarrelShifter;

architecture rtl of BarrelShifter is
 
begin

end rtl;





      




