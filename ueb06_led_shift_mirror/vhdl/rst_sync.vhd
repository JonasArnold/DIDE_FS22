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

    signal sync : std_logic_vector(3 downto 0) := "0000"; -- internal sync array
    
begin
    --- memorizing process for synchronization 
    process (rst_pi, clk_pi)
    begin
      -- default: set synchronized reset output
      rst_po <= sync(3);
    
      -- always take rst_pi if it is '1'
      if rst_pi = '1' then
        sync <= "1111";
      elsif rising_edge(clk_pi) then
        sync(0) <= rst_pi;
        sync(1) <= sync(0);
        sync(2) <= sync(1);
        sync(3) <= sync(2);
      end if;
      
    end process;
    

    
end rtl;


