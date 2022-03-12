library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sw_mux is
  port(
    btn_pi : in  std_logic_vector(3 downto 0);
    sw_pi  : in  std_logic_vector(1 downto 0);
    led_po : out std_logic_vector(7 downto 0)
    );
end sw_mux;

architecture rtl of sw_mux is
  
begin
    
end rtl;

