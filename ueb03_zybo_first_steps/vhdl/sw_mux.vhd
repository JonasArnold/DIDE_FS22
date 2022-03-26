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

  process(btn_pi, sw_pi)
    variable v_idx_led : natural range 6 downto 0;                  -- natueral?
    variable v_led_val : std_logic;
    constant c_offset  : unsigned(1 downto 0) := to_unsigned(2,2);  -- offset
  begin
    -- encode current input into helper variables to simplify code below
    -- note that modulo-arithmetic requires the use of type unsigned
    v_idx_led := to_integer(unsigned(sw_pi))*2;
    v_led_val := not btn_pi(to_integer(unsigned(sw_pi) + c_offset));
    
    -- default assignment: all 8 LEDs on
    led_po                      <= (others => '1');
    -- switch the 2 selected LEDs off if selected button is pressed
    led_po(v_idx_led)           <= v_led_val;
    led_po(v_idx_led + 1)       <= v_led_val;
  end process;
    
end rtl;
  