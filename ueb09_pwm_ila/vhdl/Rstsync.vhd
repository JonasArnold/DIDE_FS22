-------------------------------------------------------------------------------
-- Entity: Rstsync
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 7)
-- Synchronizes the de-activating edge of a asynchronous active-high reset signal.
-------------------------------------------------------------------------------
-- Total # of FFs: RPL+1
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rstsync is
  generic(
    RPL : integer := 8 -- min. reset pulse length
    );
  port(
    rst_pi : in std_logic;
    clk_pi : in std_logic;
    rst_po : out std_logic
    );
end Rstsync;

architecture rtl of Rstsync is

  signal rst_sr   : std_logic_vector(RPL-1 downto 0);

begin

  sync_rst: process(clk_pi, rst_pi)
  begin
    if rst_pi = '1' then
      rst_sr <= (others => '1');
      rst_po <= '1';
   elsif rising_edge(clk_pi) then
      rst_sr(0)              <= '0';
      rst_sr(RPL-1 downto 1) <= rst_sr(RPL-2 downto 0);
      rst_po                 <= rst_sr(RPL-1);          
   end if;
  end process;

end rtl;
