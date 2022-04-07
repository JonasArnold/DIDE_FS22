-------------------------------------------------------------------------------
-- Project: ECS Uebung 4.3
-- Entity : reak_test_rand
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- Erweiterung Reaktionstester aus Uebung 4.2 mit folgenden Features:
-- - Wird BTN_3 vor Aufleuchten von LED(3)} betätigt, blinken alle LEDs bis zum
-- nächsten Reset.
-- - Ist die Reaktionszeit grösser als 640 ms wird die Messung abgebrochen und alle
-- LEDs leuchten (Time out).
-- Nach Freigabe des Reset vergeht eine Zufallszeit im Bereich von 1...2 sec.
-- Notes:
-- * The signal initilization of rand_cnt is only relevant for simulation. It
-- is required for simulation since no reset is used for the random counter.
-- * Signal led_out is required, since VHDL does not allow reading of ports of
-- mode "out".
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reak_test_rand is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi  : in  std_logic; -- BTN_0
    clk_pi  : in  std_logic;
    stop_pi : in  std_logic; -- BTN_3
    led_po  : out std_logic_vector(7 downto 0)
    );
end reak_test_rand;

architecture rtl of reak_test_rand is

  -- constants
  -- 1 sec = 1 * CLK_FRQ 
  constant c_delay_time : unsigned(26 downto 0) := to_unsigned(1*CLK_FRQ-1,27); 
  -- 10 ms = CLK_FRQ / 100 
  constant c_tick_time : unsigned(20 downto 0) := to_unsigned(CLK_FRQ/100-1,21); 
  -- 5 ms = CLK_FRQ / 200 =  c_tick_time/2
  constant c_round_time : unsigned(20 downto 0) := to_unsigned(CLK_FRQ/200-1,21); 
  -- 250 ms = CLK_FRQ / 8
  constant c_blink_time : unsigned(23 downto 0) := to_unsigned(CLK_FRQ/8-1,24); 
  -- 640 ms in unit of 10 ms = 0x40 = 64
  constant c_time_out : unsigned(7 downto 0) := to_unsigned(64,8); 
  -- signals
  signal delay_done : std_logic;                    -- state type control signal 
  signal meas_done  : std_logic;                    -- state type control signal
  signal too_early  : std_logic;                    -- state type control signal
  signal time_out   : std_logic;                    -- state type control signal
  signal tick_cnt   : unsigned(20 downto 0);        -- 10 ms tick counter
  signal rand_time  : unsigned(27 downto 0);        -- random number (rand_cnt + c_delay_time)
  signal delay_cnt  : unsigned(27 downto 0);        -- delay counter (1...2 sec)
  signal meas_time  : unsigned( 7 downto 0);        -- measured time in 10 ms ticks
  signal blink_cnt  : unsigned(23 downto 0);        -- 250 ms blink counter
  signal led_out    : std_logic_vector(7 downto 0); -- internal led_po signal
  signal rand_cnt   : unsigned(26 downto 0) := to_unsigned(CLK_FRQ/2,27);
  
begin
  
  -- output assignment
  led_po <= led_out;

  -----------------------------------------------------------------------------
  -- sequential process: Delay
  -- # of FFs: 27 + 28 + 28 + 1 = 84
  P_del : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      -- no reset for rnd_cnt 
      rand_time  <= (others => '0');
      delay_cnt  <= (others => '0');
      delay_done <= '0';
    elsif rising_edge(clk_pi) then
      -- random counter without reset, always running...
      if rand_cnt < c_delay_time then
        rand_cnt <= rand_cnt + 1;
      else
        rand_cnt  <= (others => '0');
      end if;
      -- delay counter
      if delay_cnt < c_delay_time-1 then
        -- count up to one clock cycle before 1 sec
        delay_cnt <= delay_cnt + 1;
      elsif delay_cnt = c_delay_time-1 then
        -- get random delay number one clock cycle before 1 sec just in case
        -- rnd_cnt is zero
        rand_time <= ('0' & c_delay_time) + ('0' & rand_cnt);
        delay_cnt <= delay_cnt + 1;
      elsif delay_cnt < rand_time then
        -- count up to random time between 1 and 2 sec
        delay_cnt <= delay_cnt + 1;
      else
        delay_done <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Measure
  -- # of FFs: 21 + 8 + 1 + 1 + 1 = 32
  P_meas: process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      tick_cnt  <= (others => '0');
      meas_time <= (others => '0');
      meas_done <= '0';
      too_early <= '0';
      time_out  <= '0';
    elsif rising_edge(clk_pi) then
      -- state signal generation
      if stop_pi = '1' and delay_done = '0' then
        -- pressed button too early 
        too_early <= '1';
      elsif meas_time = c_time_out then
        -- time-out (button pressed not within 640 ms)
        time_out <= '1';
      elsif stop_pi = '1' then
        -- end of measurement (button pressed or time-out)
        meas_done <= '1';
      end if;
      -- maintain tick counter
      if delay_done = '0' then
        -- init to resolution/2 at start of measurement time
        tick_cnt <= c_round_time; 
      elsif tick_cnt < c_tick_time then
        -- count up to tick time
        tick_cnt <= tick_cnt + 1;
      else
        -- restart at tick time
        tick_cnt  <= (others => '0');
      end if;
      -- meas_time generation
      if delay_done = '1' and meas_done = '0' then
        -- measure time betwenn delay expiration and stop pressed
        if tick_cnt = c_tick_time then
          meas_time <= meas_time + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Display
  -- # of FFs: 24 + 8 = 32
  P_disp : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      blink_cnt <= (others => '0');
      led_out   <= (others => '0');
    elsif rising_edge(clk_pi) then
      if too_early = '1' then
        -- button pressed too early 
        if blink_cnt < c_blink_time then
          blink_cnt <= blink_cnt + 1;
        else 
          blink_cnt <= (others => '0');
          led_out   <= not led_out;
        end if;
      elsif delay_done = '1' and time_out = '1' then
        -- delay time expired and stop not pressed within 640 ms
        led_out <= (others => '1');
      elsif delay_done = '1' and meas_done = '0' then
        -- delay time expired and stop not pressed yet
        led_out(led_out'left) <= '1';
      elsif meas_done = '1' then
        -- stop pressed, display measured time
        led_out <= std_logic_vector(meas_time);
      end if;
    end if;
  end process;
  
end rtl;

