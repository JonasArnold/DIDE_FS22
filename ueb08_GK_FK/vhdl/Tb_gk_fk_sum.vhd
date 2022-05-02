-------------------------------------------------------------------------------
-- Entity: Tb_gk_fk_sum
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: (DIDE Uebung 8)
-- Testbench for "Gleitkomma-Summe"
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all ; 
library work;
use work.gk_pkg.all;


entity Tb_gk_fk_sum is
end Tb_gk_fk_sum;

architecture TB of Tb_gk_fk_sum is

  component gk_fk_sum is
  generic(
    W : natural := 20;  -- Output FK-Format W
    F : natural :=  8   -- Output FK-Format F
    );
  port(
    clk_pi : in  std_logic;
    a_pi   : in  t_gk_b16;            -- GK: binary16                 
    b_pi   : in  t_gk_b16;            -- GK: binary16 
    sum_po : out signed(19 downto 0)  -- FK: W=20, F=8
    );
  end component gk_fk_sum;

  -- constant definitions
  constant CLK_FRQ : integer := 125_000_000; -- 125 MHz

  signal clk     : std_logic := '0';
  signal a,b     : t_gk_b16 := ('0',to_unsigned(20,5),to_unsigned(0,10));
  signal exp_sum : real;
  signal exp_out : real;

  -- simulation control signals
  signal sim_done : boolean := false;
  
begin

  -- instantiate MUT
  MUT : gk_fk_sum
    port map(
      clk_pi => clk, 
      a_pi   => a,  
      b_pi   => b, 
      sum_po => open
      );

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

  -- stimuli and expected response generation 
  p_stim: process
    begin
    -- apply stimuli between active clock edges
    wait until rising_edge(clk);
    -- 1. stimuli set (underflow) --------------------------------------
    wait for 1*( 1 sec / CLK_FRQ);
    -- a = -(1+1/1024)*2^-14
    a.s <= '1';
    a.e <= to_unsigned(1,5);
    a.m <= to_unsigned(1,10);
    -- b = +(1+0/1024)*2^-14
    b.s <= '0';
    b.e <= to_unsigned(1,5);
    b.m <= to_unsigned(0,10);
    -- expected full-precision sum = -2^-24
    wait for 1*( 1 sec / CLK_FRQ);
    exp_sum <= (-1.0*(1.0+1.0/1024)*2.0**(-14)) + (+1.0*(1.0+0.0/1024)*2.0**(-14));
    -- expected output sum = 0 (underflow)
    wait for 1*( 1 sec / CLK_FRQ);
    exp_out <= 0.0;
    -- 2. stimuli set (pos. overflow) ---------------------------------
    wait for 1*( 1 sec / CLK_FRQ);
    -- a = +65504
    a.s <= '0';
    a.e <= to_unsigned(30,5);
    a.m <= to_unsigned(1023,10);
    -- b = -1025
    b.s <= '1';
    b.e <= to_unsigned(25,5);
    b.m <= to_unsigned(1,10);
    -- expected full-precision sum = 65504 - 1025 = 64479
    wait for 1*( 1 sec / CLK_FRQ);
    exp_sum <= (+1.0*(1.0+1023.0/1024)*2.0**(+15)) + (-1.0*(1.0+1.0/1024)*2.0**(+10));
    -- expected output sum = 2^11 - 2^-8 (pos. overflow)
    wait for 1*( 1 sec / CLK_FRQ);
    exp_out <= 2.0**11 - 2.0**(-8);
    -- 3. stimuli set (rounding) -------------------------------------
    wait for 1*( 1 sec / CLK_FRQ);
    -- a = +1
    a.s <= '0';
    a.e <= to_unsigned(15,5);
    a.m <= to_unsigned(0,10);
    -- b = -(1+3/1024)
    b.s <= '1';
    b.e <= to_unsigned(15,5);
    b.m <= to_unsigned(3,10);
    -- expected full-precision sum = - 3/1024 = -0.0029296875
    wait for 1*( 1 sec / CLK_FRQ);
    exp_sum <= (+1.0*(1.0+0.0/1024)*2.0**(+0)) + (-1.0*(1.0+3.0/1024)*2.0**(+0));
    -- expected output sum = -2^-8 = 0.00390625)
    wait for 1*( 1 sec / CLK_FRQ);
    exp_out <= - 2.0**(-8);
    -- signal end of simulation ---------------------------------------
    wait for 3*( 1 sec / CLK_FRQ);
    sim_done <= true;
    wait;
  end process;

end TB;
