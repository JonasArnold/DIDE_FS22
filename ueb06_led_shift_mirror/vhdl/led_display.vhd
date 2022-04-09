-------------------------------------------------------------------------------
-- Entity : led_display
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- Shifts and mirrows LED pattern according to input events.
-- Shifting stops, if exactly one LED is active in either the left- or right-
-- most position. If both shift and mirrow events appear in the same cc, first
-- shifting and then mirrowing is performed.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_display is
  port(
    rst_pi      : in  std_logic; 
    clk_pi      : in  std_logic;
    left_evt_pi : in  std_logic;
    rght_evt_pi : in  std_logic;
    mirr_evt_pi : in  std_logic;
    led_po      : out std_logic_vector(7 downto 0)
    );
end led_display;

architecture rtl of led_display is

begin

end rtl;


