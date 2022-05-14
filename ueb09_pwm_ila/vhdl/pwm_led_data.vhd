-------------------------------------------------------------------------------
-- Entity: pwm_led_data
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: 
-- Data path unit instantiating 3 channels with pwm_dac component.
-- P = 125 Mz / (10 kHz * (2^N-1))
-- N_red   = 5 ==> P_red   = 4167
-- N_green = 4 ==> P_green = 1786
-- N_blue  = 3 ==> P_blue  = 833 
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pwm_led_data is
  generic(
    CLK_FRQ : integer ;  
    DAC_FRQ : integer ;  
    N_RED   : integer ;  
    N_GREEN : integer ;  
    N_BLUE  : integer    
    );
  port(
    rst_pi      : in  std_logic;          
    clk_pi      : in  std_logic;
    incr_evt_pi : in  std_logic;
    decr_evt_pi : in  std_logic;
    act_r_pi    : in  std_logic;
    act_g_pi    : in  std_logic;
    act_b_pi    : in  std_logic;
    pwm_r_po    : out std_logic;
    pwm_g_po    : out std_logic;
    pwm_b_po    : out std_logic
    );
end pwm_led_data;

architecture struct of pwm_led_data is

  -- component declarations
  component pwm_dac
    generic(
      N : integer := 8;
      R : integer := 0;
      P : integer := 500
      );
    port (
      rst_pi      : in std_logic;
      clk_pi      : in std_logic;
      incr_evt_pi : in  std_logic;
      decr_evt_pi : in  std_logic;
      active_pi   : in  std_logic;
      pwm_po      : out std_logic                       
      );
  end component;

begin
    
  -- instance pwm_dac (RED)
  u_pwm_dac_red: pwm_dac
    generic map (
      N => N_RED,                                                -- 2
      R => natural(0.0 * real(2**N_RED-1)/100.0),                -- 0%
      P => natural(real(CLK_FRQ)/real((DAC_FRQ*(2**N_RED-1))))   -- 4167
      )
    port map (
      rst_pi      => rst_pi,
      clk_pi      => clk_pi,
      incr_evt_pi => incr_evt_pi,
      decr_evt_pi => decr_evt_pi,
      active_pi   => act_r_pi,
      pwm_po      => pwm_r_po                      
      );

  -- instance pwm_dac (GREEN)
  u_pwm_dac_green: pwm_dac
    generic map (
      N => 1,  -- ToDo
      R => 1,  -- ToDo
      P => 1   -- ToDo
      )
    port map (
      rst_pi      => rst_pi,
      clk_pi      => clk_pi,
      incr_evt_pi => incr_evt_pi,
      decr_evt_pi => decr_evt_pi,
      active_pi   => act_g_pi,
      pwm_po      => pwm_g_po                      
      );

  -- instance pwm_dac (BLUE)
  u_pwm_dac_blue: pwm_dac
    generic map (
      N => 1,  -- ToDo
      R => 1,  -- ToDo
      P => 1   -- ToDo
      )
    port map (
      rst_pi      => rst_pi,
      clk_pi      => clk_pi,
      incr_evt_pi => incr_evt_pi,
      decr_evt_pi => decr_evt_pi,
      active_pi   => act_b_pi,
      pwm_po      => pwm_b_po                      
      );

end struct;
