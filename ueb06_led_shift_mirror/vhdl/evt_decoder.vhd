-------------------------------------------------------------------------------
-- Entity : evt_decoder
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- Decode debounced rotary encoder signals into left/right-click event signals.
-- Generate button-pressed event signal from debounced button input (active-low).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity evt_decoder is
  port(
    rst_pi      : in  std_logic;
    clk_pi      : in  std_logic;
    enca_deb_pi : in  std_logic;
    encb_deb_pi : in  std_logic;
    butt_deb_pi : in  std_logic; 
    left_evt_po : out std_logic;
    rght_evt_po : out std_logic;
    mirr_evt_po : out std_logic
    );
end evt_decoder;

architecture rtl of evt_decoder is

begin  

end rtl;


