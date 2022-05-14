-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : fmc_top
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: 
-- Top-level of Floppy-Music Controller peripheral module in MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity fmc_top is
  generic(CF : natural := CF
          ); 
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- FMC bus signals
       bus_in  : in  t_bus2rws;
       bus_out : out t_rws2bus;
       -- FMC pin signals
       fmc_enable : out  std_logic_vector(c_fmc_num_chn-1 downto 0);
       fmc_direct : out  std_logic_vector(c_fmc_num_chn-1 downto 0);
       fmc_step   : out  std_logic_vector(c_fmc_num_chn-1 downto 0)
       );
end fmc_top;

architecture rtl of fmc_top is

begin

  -- ToDo!!!!!!!!!!!!!!!!!!!!!
  fmc_enable <= (others => '0');
  fmc_direct <= (others => '0');
  fmc_step <= (others => '0');
  
end rtl;
