library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
  port(
    sw_pi  : in  std_logic_vector(1 downto 0);
    led_po : out std_logic_vector(3 downto 0)
    );
end decoder;

architecture RTL of decoder is
begin
  
  process(sw_pi)
  begin
    led_po                              <= (others => '0');
    led_po(to_integer(unsigned(sw_pi))) <= '1';
  end process;
  
end RTL;
