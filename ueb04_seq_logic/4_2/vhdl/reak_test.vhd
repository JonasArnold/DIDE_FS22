-------------------------------------------------------------------------------
-- Project: ECS Uebung 4.2
-- Entity : reak_test
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- Nach Freigabe des Reset (BTN_0) vergeht eine feste Zeit (2 sec).
-- Nach Ablauf dieser Zeit wird LED(7) eingeschaltet.
-- Die Reaktionszeit zwischen Einschalten von LED(7) und Betätigung von
-- Druckknopf BTN_3 wird mit 10 ms Auflösung gemessen.
-- Die Reaktionszeit wird bis zum nächsten Reset als Binärzahl auf
-- LED(7:0) angezeigt.
-- Notes:
-- * The signal tick_cnt, which counts the number of cc in one tick of 10 ms,
-- is reset to half the tick duration (5 ms) in order to ensure a symmetric
-- measurement error of -tick/2 <= error < + tick/2. 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reak_test is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi  : in  std_logic; -- BTN_0
    clk_pi  : in  std_logic;
    stop_pi : in  std_logic; -- BTN_3
    led_po  : out std_logic_vector(7 downto 0)
    );
end reak_test;

architecture rtl of reak_test is

  -- constants
  -- 2 sec = 2 * CLK_FRQ 
  constant c_delay_time : unsigned(27 downto 0) := to_unsigned(2*CLK_FRQ-1,28); 
  -- 10 ms = CLK_FRQ / 100 
  constant c_tick_time : unsigned(20 downto 0) := to_unsigned(CLK_FRQ/100-1,21); 
  -- 5 ms = CLK_FRQ / 200 =  c_tick_time/2
  constant c_round_time : unsigned(20 downto 0) := to_unsigned(CLK_FRQ/200-1,21); 
  -- signals
  signal delay_done : std_logic;              -- state type control signal 
  signal meas_done  : std_logic;              -- state type control signal
  signal delay_cnt  : unsigned(27 downto 0);  -- delay counter
  signal tick_cnt   : unsigned(20 downto 0);  -- 10 ms counter
  signal meas_time  : unsigned( 7 downto 0);  -- measured time in 10 ms ticks
  
begin

  -----------------------------------------------------------------------------
  -- sequential process: Delay
  -- # of FFs: ???
  P_del : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      delay_cnt  <= (others => '0');
      delay_done <= '0';
    elsif rising_edge(clk_pi) then
      
      -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if delay_cnt < c_delay_time then
        delay_cnt <= delay_cnt + 1;
      else
        delay_done <= '1';
      end if;      
      
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Measurement
  -- # of FFs: ???
  P_meas: process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      tick_cnt  <= c_round_time; -- init to resolution/2 
      meas_time <= (others => '0');
      meas_done <= '0';
    elsif rising_edge(clk_pi) then
      
      -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      -- stop button pressed
      if stop_pi = '1' then
        meas_done <= '1';
      end if; 
      -- measurement time
      if delay_done = '1' and meas_done = '0' then
        if tick_cnt < c_tick_time then  -- measurement ongoing
          tick_cnt <= tick_cnt + 1;
        else  -- measurement done
          tick_cnt <= (others => '0');
          if meas_time < 2**(meas_time'left+1)-1 then
            meas_time <= meas_time + 1;
          end if;
        end if;
      end if;
      
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Display
  -- # of FFs: ???
  P_disp : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      led_po <= (others => '0');
    elsif rising_edge(clk_pi) then
      
      -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if delay_done = '1' and meas_done = '0' then
        -- delay time expired, but stop not pressed yet
        led_po(led_po'left) <= '1';
      elsif meas_done = '1' then
        -- stop pressed, display measured time
        led_po <= std_logic_vector(meas_time);
      end if;
      
    end if;
  end process;
  
end rtl;







