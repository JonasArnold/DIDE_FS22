library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_blinker is
  generic(
    CLK_FRQ : integer := 125_000 -- use 125 kHz instead of 125 MHz for simulation
                                 -- in order to cut simulation time (only
                                 -- 1/1000 clock events are generated per second)
    );
end tb_blinker;

architecture TB of tb_blinker is

  component blinker is
    generic(
      CLK_FRQ : integer := CLK_FRQ
      );
    port(
      rst_pi : in  std_logic;
      clk_pi : in  std_logic;
      led_po : out std_logic_vector(3 downto 0)
      );
  end component blinker;

  signal rst : std_logic;
  signal clk : std_logic := '0';
  signal led : std_logic_vector(3 downto 0);
  
  signal sim_done : boolean := false;

begin

  -- instantiate MUT
  MUT : blinker
    port map(
      rst_pi => rst,
      clk_pi => clk,
      led_po => led
      );

  -- apply stimuli (reset only)
  rst <= '1', '0' after 5us;

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

  -- no automatic response checking
  process
  begin
    wait for 5sec;
    report "Simulation done." severity note;
    sim_done <= true;
    wait;
  end process;
  
end TB;
