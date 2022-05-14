-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : tb_mcu
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- Simple testbench for the MCU with clokc and reset generation only.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity tb_mcu is
end tb_mcu;

architecture TB of tb_mcu is

  signal rst    : std_logic;
  signal clk    : std_logic := '0';
  signal gpio_0 : std_logic_vector(c_gpio_port_ww-1 downto 0);
  signal gpio_1 : std_logic_vector(c_gpio_port_ww-1 downto 0);
   
begin

  -- instantiate MUT
  MUT : entity work.mcu
    port map(
      rst    => rst,
      clk    => clk,
      gpio_0 => gpio_0,
      gpio_1 => gpio_1
      );

  -- generate reset
  rst   <= '1', '0' after 5us;

  -- clock generation
  p_clk: process
  begin
    wait for 1 sec / CF/2;
    clk <= not clk;
  end process;

  -- mimic BTN/SW input values for GPIO_0
  gpio_0(0) <= '0' after 100 ns, '1' after 7 us;  -- SW_0
  gpio_0(1) <= '1' after 100 ns, '0' after 7 us;  -- SW_1
  gpio_0(2) <= '1' after 100 ns, '0' after 7 us;  -- SW_2
  gpio_0(3) <= '0' after 100 ns, '1' after 7 us;  -- SW_3
  gpio_0(4) <= '0';  -- not used
  gpio_0(5) <= '0' after 100 ns, '1' after 7 us;  -- BTN_1
  gpio_0(6) <= '1' after 100 ns, '0' after 7 us;  -- BTN_2
  gpio_0(7) <= '0' after 100 ns, '1' after 7 us;  -- BTN_3
 
end TB;
