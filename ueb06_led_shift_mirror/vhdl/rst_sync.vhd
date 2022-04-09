-------------------------------------------------------------------------------
-- Entity : rst_sync
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- Synchronize de-activating edge of async active-high reset with min. of 4 cc
-- active-time of local reset.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rst_sync is
  port(
    rst_pi : in  std_logic; 
    clk_pi : in  std_logic;
    rst_po : out std_logic
    );
end rst_sync;

architecture rtl of rst_sync is

begin
  
end rtl;


