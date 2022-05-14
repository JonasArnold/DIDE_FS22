-------------------------------------------------------------------------------
-- Entity: pwm_led_top
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: 
-- Top-level entity "LED-Farbmischung"
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_led_top is
  generic(
    CLK_FRQ : integer := 125_000_000;  -- 125 MHz
    DAC_FRQ : integer :=      10_000;  -- 10 kHz
    N_RED   : integer :=           2;  -- DAC Res Red
    N_GREEN : integer :=           3;  -- DAC Res Green
    N_BLUE  : integer :=           4   -- DAC Res Blue
    );
  port(
    rst_pi : in  std_logic;                     -- BTN_0
    clk_pi : in  std_logic;
    act_pi : in  std_logic_vector(2 downto 0);  -- SW(2:0)=R:G:B
    enc_pi : in  std_logic_vector(1 downto 0);  -- EncA:EncB                  
    led_po : out std_logic_vector(2 downto 0)   -- R:G:B
    );
end pwm_led_top;

architecture struct of pwm_led_top is

  -- component declarations
  component Rstsync
    generic(
      RPL : integer := 3
      );
    port (
      rst_pi : in  std_logic;
      clk_pi : in  std_logic;
      rst_po : out std_logic
      );
  end component;

  component pwm_led_ctrl
    generic(
      CLK_FRQ : integer := CLK_FRQ
      );
    port (
      rst_pi      : in  std_logic;          
      clk_pi      : in  std_logic;
      enc_pi      : in  std_logic_vector(1 downto 0);                
      act_pi      : in  std_logic_vector(2 downto 0);
      incr_evt_po : out std_logic;
      decr_evt_po : out std_logic;
      act_r_po    : out std_logic;
      act_g_po    : out std_logic;
      act_b_po    : out std_logic
      );
  end component;

  component pwm_led_data
    generic(
      CLK_FRQ : integer := CLK_FRQ;
      DAC_FRQ : integer := DAC_FRQ;
      N_RED   : integer := N_RED;
      N_GREEN : integer := N_GREEN;
      N_BLUE  : integer := N_BLUE
      );
    port (
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
  end component;

  -- signal declarations
  signal rst_loc             : std_logic;
  signal incr_evt, decr_evt  : std_logic;
  signal act_r, act_g, act_b : std_logic;

begin
  
  -- instance "Rstsync"
  u_Rstsync: Rstsync
    port map (
      rst_pi => rst_pi,
      clk_pi => clk_pi,
      rst_po => rst_loc
      );
  
  -- instance "pwm_led_ctrl"
  u_pwm_led_ctrl: pwm_led_ctrl
    port map (
      rst_pi      => rst_loc,
      clk_pi      => clk_pi,
      enc_pi      => enc_pi,         
      act_pi      => act_pi,         
      incr_evt_po => incr_evt,
      decr_evt_po => decr_evt,
      act_r_po    => act_r,
      act_g_po    => act_g,
      act_b_po    => act_b
      );

  -- instance "pwm_led_data"
  u_pwm_led_data: pwm_led_data
    port map (
      rst_pi      => rst_loc,
      clk_pi      => clk_pi,
      incr_evt_pi => incr_evt,
      decr_evt_pi => decr_evt,
      act_r_pi    => act_r,
      act_g_pi    => act_g,
      act_b_pi    => act_b,
      pwm_r_po    => led_po(2),
      pwm_g_po    => led_po(1),
      pwm_b_po    => led_po(0)
      );
  
end struct;
