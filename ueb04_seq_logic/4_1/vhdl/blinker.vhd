-------------------------------------------------------------------------------
-- Project: ECS Uebung 4.1
-- Entity : blinker
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- A counter is used to toggle LEDs every 250 ms.
-- Notes:
-- * The local signal "led" is required, because VHDL does not allow reading of
-- port signals that are of mode "out".
-- * The counter signal cnt is defined as type "unsigned" to facilitate
-- incrementation and comparison with the constant c_max_cnt, which is also of
-- type "unsigned".
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinker is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi : in  std_logic;
    clk_pi : in  std_logic;
    led_po : out std_logic_vector(3 downto 0)
    );
end blinker;

architecture rtl of blinker is

  -- constants
  constant c_tog_per_s : integer := 8; -- # of LED toggles per second
  constant c_max_cnt   : unsigned(26 downto 0):= to_unsigned(CLK_FRQ/c_tog_per_s-1,27);
  -- signals
  signal cnt : unsigned(26 downto 0);
  signal led : std_logic_vector(3 downto 0); 
  
begin

  -- output assignments
  led_po <= led;

  -- sequential process with reset
  P1_seq: process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      led <= "1010";
      cnt <= (others => '0');
    elsif rising_edge(clk_pi) then
      if cnt < c_max_cnt then
        cnt <= cnt + 1;
      else
        cnt <= (others => '0');
        led <= not led;
      end if;
    end if;
  end process;
  
end RTL;
