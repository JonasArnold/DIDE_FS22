-------------------------------------------------------------------------------
-- Entity : led_sfift_mirror
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (DIDE Uebung 6)
-- LED pattern shift left/right with rotary encoder and mirror with button.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_shift_mirror is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi  : in  std_logic; -- BTN_0
    clk_pi  : in  std_logic;
    enca_pi : in  std_logic;
    encb_pi : in  std_logic;
    mirr_pi : in  std_logic; -- ENC_SW
    led_po  : out std_logic_vector(7 downto 0)
    );
end led_shift_mirror;

architecture rtl of led_shift_mirror is

  -- local reset signal
  signal rst_loc : std_logic;
  -- sync/debounced signals
  signal enca_deb : std_logic;  
  signal encb_deb : std_logic;
  signal butt_deb : std_logic;
  -- event signals
  signal left_evt : std_logic;  
  signal rght_evt : std_logic;  
  signal mirr_evt : std_logic;  
  
begin

end rtl;


