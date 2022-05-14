-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : ram
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: 
-- Data memory for simple von-Neumann MCU with registered read data output.
-------------------------------------------------------------------------------
-- Total # of FFs: (2**AW)*DW + DW (or equivalent BRAM/distr. memory)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity ram is
  port(clk     : in    std_logic;
       -- RAM bus signals
       bus_in  : in  t_bus2ram;
       bus_out : out t_ram2bus
       );
end ram;

architecture rtl of ram is

  -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!
  -- type t_ram is array (0 to ........) of std_logic_vector(..... downto 0);
  -- signal ram_array : t_ram;
  
begin

  -----------------------------------------------------------------------------
  -- sequential process: RAM (read before write)
  ----------------------------------------------------------------------------- 
  P_ram: process(clk)
  begin
    if rising_edge(clk) then
    
      -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      -- bus_in.wr_enb, bus_in.addr, bus_in.data, bus_out.data
      
    end if;
  end process;
  
end rtl;

