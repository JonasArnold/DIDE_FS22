library ieee;
use ieee.std_logic_1164.all;

entity MyXor is
  port(
    x_pi : in  std_logic;
    y_pi : in  std_logic;
    z_po : out std_logic
    );
end MyXor;

architecture rtl of MyXor is
  
begin
  
    z_po <= x_pi xor y_pi;
  
end rtl;
