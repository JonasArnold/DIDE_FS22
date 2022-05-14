-------------------------------------------------------------------------------
-- Entity: tb_pwm_dac
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- Testbench for PWM DAC unit
-- NOTE:
-- The testbench assumes the following:
--  1) The blank time used for debouncing the encoder signals is shorter than 100 ms.
--  2) The blank time definition is made dependent upon generic CLK_FRQ.
--  3) The prescaler P is chosen for each channel such that f_DAC is closest to 10 kHz.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all ; 

entity tb_pwm_led_top is
end tb_pwm_led_top;

architecture TB of tb_pwm_led_top is

  component pwm_led_top is
  generic(
    CLK_FRQ : integer;  
    DAC_FRQ : integer;  
    N_RED   : integer;  
    N_GREEN : integer;  
    N_BLUE  : integer 
    );
   port(
    rst_pi : in  std_logic;         
    clk_pi : in  std_logic;
    act_pi : in  std_logic_vector(2 downto 0);  -- SW(2:0)=R:G:B
    enc_pi : in  std_logic_vector(1 downto 0);  -- EncA:EncB                  
    led_po : out std_logic_vector(2 downto 0)   -- R:G:B
      );
  end component pwm_led_top;

  -- DAC resolution
  constant N_R     : integer := 2;
  constant N_G     : integer := 3;
  constant N_B     : integer := 4;
  constant CLK_FRQ : integer := 125_000; -- 125 MHz/1000
  constant DAC_FRQ : integer :=      10; --  20 kHz/1000
  
  -- testbench signals
  signal rst       : std_logic := '1';
  signal clk       : std_logic := '0';
  signal act_r     : std_logic := '1'; -- active
  signal act_g     : std_logic := '0'; -- non-active
  signal act_b     : std_logic := '1'; -- active
  signal enc_a     : std_logic := '0';
  signal enc_b     : std_logic := '0';
  signal led_r     : std_logic;
  signal led_g     : std_logic;
  signal led_b     : std_logic;
  signal led_po    : std_logic_vector(2 downto 0);

  -- encoder input events
  type t_enc_evt_rec is record
    t  : time;
    tc : time;
    a  : std_logic;
    b  : std_logic;
  end record;
  type t_enc_evt_ar is array (0 to 11) of t_enc_evt_rec;
  constant enc_evt : t_enc_evt_ar := (
    --    time      cummal.  a   b
    0 => ( 100 ms,  100 ms, '0','1'),
    1 => ( 100 ms,  200 ms, '1','1'),
    2 => ( 100 ms,  300 ms, '1','0'),
    3 => ( 100 ms,  400 ms, '0','0'), -- left click
    4 => ( 300 ms,  500 ms, '1','0'),
    5 => ( 100 ms , 600 ms, '1','1'),
    6 => ( 100 ms,  700 ms, '0','1'),
    7 => ( 100 ms,  800 ms, '0','0'),  -- right click
    8 => ( 100 ms,  900 ms, '0','1'),
    9 => ( 100 ms, 1000 ms, '1','1'),
   10 => ( 100 ms, 1100 ms, '1','0'),
   11 => ( 100 ms, 1200 ms, '0','0') -- left click
    );
  -- PWM high-/low-times
  constant c_r_res  : time := natural(round(real(CLK_FRQ)/real((DAC_FRQ*(2**N_R-1)))))* (1 sec/CLK_FRQ); -- Resolution of PWM-Red signal
  constant c_g_res  : time := natural(round(real(CLK_FRQ)/real((DAC_FRQ*(2**N_G-1)))))* (1 sec/CLK_FRQ); -- Resolution of PWM-Green signal
  constant c_b_res  : time := natural(round(real(CLK_FRQ)/real((DAC_FRQ*(2**N_B-1)))))* (1 sec/CLK_FRQ); -- Resolution of PWM-Blue signal

  -- error messages
  constant c_R_LF : string := ("(RED)"   & LF);
  constant c_G_LF : string := ("(GREEN)" & LF);
  constant c_B_LF : string := ("(BLUE)"  & LF);
  constant c_RST  : string := ("==> ERROR: PWM not ok after reset!  ");
  constant c_HS   : string := ("==> ERROR: PWM High-Time too short!  ");
  constant c_HL   : string := ("==> ERROR: PWM High-Time too long!   ");
  constant c_LS   : string := ("==> ERROR: PWM Low-Time too short!   ");
  constant c_LL   : string := ("==> ERROR: PWM Low-Time too long!    ");
  constant c_ER1  : string := ("==> ERROR: No PWM signal generated!  ");
  constant c_ER2  : string := ("==> ERROR: Deactivation not working! ");
  constant c_ER3  : string := ("==> ERROR: Decr from 0 to 100 failed! ");
  constant c_ER4  : string := ("==> ERROR: Incr above 100 not allowed! ");

  -- simulation control signals
  signal sim_done      : boolean := false;
  signal pwm_red_act   : boolean := false;
  signal pwm_green_act : boolean := false;
  signal pwm_blue_act  : boolean := false;
  
begin

  -- instantiate DAC, channel BLUE
  mut :  pwm_led_top
    generic map(
      CLK_FRQ => CLK_FRQ,
      DAC_FRQ => DAC_FRQ,  
      N_RED   => N_R,  
      N_GREEN => N_G,  
      N_BLUE  => N_B
      )
    port map(
      rst_pi => rst,
      clk_pi => clk,
      act_pi => (act_r & act_g & act_b),
      enc_pi => (enc_a & enc_b),             
      led_po => led_po
      );
      led_r <= led_po(2);
      led_g <= led_po(1);
      led_b <= led_po(0);

  -- generate reset
  rst <= '1', '0' after 3 sec / CLK_FRQ;

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

  -- stop simulation after fixed time
  sim_done <= false, true after 1900 ms;
  p_stop: process
  begin
    wait until sim_done;
    -- check red active
    if not pwm_red_act then
      write(std.textio.OUTPUT, (c_ER1 & c_R_LF));
    end if;
    -- check blue active
    if not pwm_blue_act then
      write(std.textio.OUTPUT, (c_ER1 & c_B_LF));
    end if;
    -- check green inactive
    -- end of simulation
    write(std.textio.OUTPUT, ("######## End of Simulation #######" & LF));
  end process;

  -- encoder input generation
  p_enc: process
  begin
    for k in 0 to enc_evt'length-1 loop
      wait for enc_evt(k).t;
      enc_a <= enc_evt(k).a;
      enc_b <= enc_evt(k).b;
      if k=7 then
        -- activate GREEN channel with increment click
        act_g <= '1';
      end if;
    end loop;
    wait;
  end process;

  -- check PWM generated on RED channel (activated)
  p_check_red: process
  begin
    -- check PWM off after reset, but later active
    wait until led_r = '0';
    wait until led_r = '1';
    if now < enc_evt(3).t then
      write(std.textio.OUTPUT, (c_RST & c_R_LF));
    end if;    
    pwm_red_act <= true;
    -- check decrement from 0 to 100%
    wait until led_r = '0';
    if now < enc_evt(7).tc then
      write(std.textio.OUTPUT, (c_ER3 & c_R_LF));
    end if;    
    -- check for no increment above 100%
    if now < enc_evt(11).tc then
      write(std.textio.OUTPUT, (c_ER4 & c_R_LF));
    end if;
    -- start of T_DAC interval
    wait until led_r = '1';
    -- check high-time
    wait for 2*c_r_res; -- 66% high
    if led_r = '0' then
      write(std.textio.OUTPUT, (c_HS & c_R_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_r = '1' then
      write(std.textio.OUTPUT, (c_HL & c_R_LF));
    end if;
    -- check low-time
    wait until led_r = '0';
    wait for 1*c_r_res; -- 33% low
    if led_r = '1' then
      write(std.textio.OUTPUT, (c_LS & c_R_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_r = '0' then
      write(std.textio.OUTPUT, (c_LL & c_R_LF));
    end if;
    wait;
  end process;
  
  -- check PWM generated on GREEN channel (deactivated after reset)
  p_check_green: process
  begin
    -- check PWM on 100% after reset
    wait for enc_evt(0).tc;
    if led_g = '0' or led_g = 'U' then
      write(std.textio.OUTPUT, (c_RST & c_G_LF));
    else
      pwm_green_act <= true;     
    end if;
    -- start of T_DAC interval after increment
    wait for enc_evt(11).tc;
    wait until led_g = '1';
    -- check high-time
    wait for 6*c_g_res; -- 6/7% high
    if led_g = '0' then
      write(std.textio.OUTPUT, (c_HS & c_G_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_g = '1' then
      write(std.textio.OUTPUT, (c_HL & c_G_LF));
    end if;
    -- check low-time
    wait until led_g = '0';
    wait for 1*c_g_res; -- 1/7% low
    if led_g = '1' then
      write(std.textio.OUTPUT, (c_LS & c_G_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_g = '0' then
      write(std.textio.OUTPUT, (c_LL & c_G_LF));
    end if;
    wait;
  end process;
 
  -- check PWM generated on BLUE channel (activated)
  p_check_blue: process
  begin
    -- check PWM off after reset, but later active
    wait until led_b = '0';
    wait until led_b = '1';
    if now > enc_evt(0).t  then
      write(std.textio.OUTPUT, (c_RST & c_B_LF));
    end if;    
    pwm_blue_act <= true;
    -- start of T_DAC interval after reset
    -- check high-time
    wait for 3*c_b_res; -- 20% high
    if led_b = '0' then
      write(std.textio.OUTPUT, (c_HS & c_B_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_b = '1' then
      write(std.textio.OUTPUT, (c_HL & c_B_LF));
    end if;
    -- check low-time
    wait until led_b = '0';
    wait for 12*c_b_res; -- 80% low
    if led_b = '1' then
      write(std.textio.OUTPUT, (c_LS & c_B_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_b = '0' then
      write(std.textio.OUTPUT, (c_LL & c_B_LF));
    end if;
    -- start of T_DAC interval after decrement
    wait for enc_evt(4).tc;
    wait until led_b = '1';
    -- check high-time
    wait for 2*c_b_res; -- 2/15% high
    if led_b = '0' then
      write(std.textio.OUTPUT, (c_HS & c_B_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_b = '1' then
      write(std.textio.OUTPUT, (c_HL & c_B_LF));
    end if;
    -- check low-time
    wait until led_b = '0';
    wait for 13*c_b_res; -- 13/15% low
    if led_b = '1' then
      write(std.textio.OUTPUT, (c_LS & c_B_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_b = '0' then
      write(std.textio.OUTPUT, (c_LL & c_B_LF));
    end if;
    -- start of T_DAC interval after increment
    wait for enc_evt(8).tc;
    wait until led_b = '1';
    -- check high-time
    wait for 3*c_b_res; -- 20% high
    if led_b = '0' then
      write(std.textio.OUTPUT, (c_HS & c_B_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_b = '1' then
      write(std.textio.OUTPUT, (c_HL & c_B_LF));
    end if;
    -- check low-time
    wait until led_b = '0';
    wait for 12*c_b_res; -- 80% low
    if led_b = '1' then
      write(std.textio.OUTPUT, (c_LS & c_B_LF));
    end if;
    wait for 1 sec / CLK_FRQ;
    if led_b = '0' then
      write(std.textio.OUTPUT, (c_LL & c_B_LF));
    end if;
    wait;
  end process;

end TB;
