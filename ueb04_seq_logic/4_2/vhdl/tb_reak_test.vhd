-------------------------------------------------------------------------------
-- Project: ECS Uebung 4.2
-- Entity : reak_test_tb
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- A reaction time of r_time ms is simulated by asserting stop after this time.
-- The displayed reaction time in units of 40 ms is automatically checked by
-- the testbench.
-- Notes:
-- * 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reak_test is
  generic(
    CLK_FRQ : integer := 125_000 -- use 125 kHz instead of 125 MHz for simulation
                                 -- in order to cut simulation time (only
                                 -- 1/1000 clock events are generated per second)
    );
end tb_reak_test;

architecture TB of tb_reak_test is

  component reak_test is
    generic(
      CLK_FRQ : integer := CLK_FRQ
      );
    port(
      rst_pi  : in  std_logic;
      clk_pi  : in  std_logic;
      stop_pi : in  std_logic;
      led_po  : out std_logic_vector(7 downto 0)
      );
  end component reak_test;

  signal rst  : std_logic;
  signal clk  : std_logic := '0';
  signal stop : std_logic := '0';
  signal led  : std_logic_vector(7 downto 0);
  
  signal sim_done : boolean := false;
  
  constant d_time : time := 2.0 sec; 
  constant r_real : real := 345.01;
  constant r_time : time := r_real * ms; -- reaction time in ms
  
begin

  -- instantiate MUT
  MUT : reak_test
    port map(
      rst_pi  => rst,
      clk_pi  => clk,
      stop_pi => stop,
      led_po  => led
      );

  -- apply stimuli
  rst  <= '1', '0' after 5us;
  stop <= '0', '1' after d_time + r_time, '0' after d_time + r_time + 1 ms;

  -- clock generation
  p_clk: process
  begin
    if not sim_done then
      wait for 1 sec / CLK_FRQ/2;
      clk <= not clk;
    else
      wait;
    end if;
  end process;

  -- response checking
  process
  begin
    wait for d_time + r_time + 1 ms;
    if to_integer(unsigned(led)) /= integer(r_real/10.0) then
      report "SIMULATION FAILED" severity failure;
    else
      report "simulation o.k." severity note;
      sim_done <= true;
      wait;
    end if;
  end process;
  
end TB;
