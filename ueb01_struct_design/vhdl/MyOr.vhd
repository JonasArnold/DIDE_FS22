library ieee;
use ieee.std_logic_1164.all;

entity MyOr is
  port(
    x_pi : in  std_logic;
    y_pi : in  std_logic;
    z_po : out std_logic
    );
end MyOr;

architecture rtl of MyOr is
  
begin
  
  z_po <= x_pi or y_pi;
  
end rtl;
