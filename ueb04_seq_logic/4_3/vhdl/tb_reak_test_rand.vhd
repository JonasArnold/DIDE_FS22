-------------------------------------------------------------------------------
-- Project: ECS Uebung 4.3
-- Entity : tb_reak_test_rand
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- A reaction time of reac_time ms is simulated by asserting stop after this time.
-- The displayed reaction time in units of 40 ms is automatically checked by
-- the testbench.
-- Notes:
-- * 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reak_test_rand is
  generic(
    CLK_FRQ : integer := 125_000 -- use 125 kHz instead of 125 MHz for simulation
                                 -- in order to cut simulation time (only
                                 -- 1/1000 clock events are generated per second)
    );
end tb_reak_test_rand;

architecture TB of tb_reak_test_rand is

  component reak_test_rand is
    generic(
      CLK_FRQ : integer := CLK_FRQ
      );
    port(
      rst_pi  : in  std_logic;
      clk_pi  : in  std_logic;
      stop_pi : in  std_logic;
      led_po  : out std_logic_vector(7 downto 0)
      );
  end component reak_test_rand;

  signal rst  : std_logic;
  signal clk  : std_logic := '0';
  signal stop : std_logic := '0';
  signal led  : std_logic_vector(7 downto 0);
  
  signal sim_done : boolean := false;

  constant fix_time  : time := 1.0 sec;
  constant rand_real : real := 500.0;       -- random time (used in MUT)
  constant rand_time : time := rand_real * ms; 
  constant reac_real : real := 570.0;       -- simulated reaction time
  constant reac_time : time := reac_real * ms; 
 
begin

  -- instantiate MUT
  MUT : reak_test_rand
    port map(
      rst_pi  => rst,
      clk_pi  => clk,
      stop_pi => stop,
      led_po  => led
      );

  -- apply stimuli
  rst  <= '1', '0' after 5us;
  stop <= '0', '1' after fix_time + rand_time + reac_time,
               '0' after fix_time + rand_time + reac_time + 1 ms;

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
    wait for 3*fix_time;
    if integer(reac_real/10.0) > 64 and to_integer(unsigned(led)) = 255 then
      report "TIME_OUT detected OK" severity note;
      sim_done <= true;
      wait;
    elsif integer((reac_real)/10.0) = to_integer(unsigned(led)) then
      report "Reaction Time displayed OK" severity note;
      sim_done <= true;
      wait;
    else	 
      report "!!!SIMULATION FAILED!!!" severity failure;
    end if;
  end process;
  
end TB;
