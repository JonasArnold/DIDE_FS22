-------------------------------------------------------------------------------
-- Entity : sync_deb
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (DIDE Uebung 6)
-- Synchroniration and debouncing (blanking) of asynchronous single-bit signal.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_deb is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi   : in  std_logic;
    clk_pi   : in  std_logic;
    async_pi : in  std_logic;
    deb_po   : out std_logic
    );
end sync_deb;

architecture rtl of sync_deb is

begin
  
end rtl;


