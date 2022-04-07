-------------------------------------------------------------------------------
-- Project: ECS Uebung 5
-- Entity : reak_test_rand_fsm
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- Erweiterter Reaktionstester aus Uebung 4.3 mit FSM (Mealy-Type)
-- Notes:
-- * 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reak_test_rand_fsm is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi  : in  std_logic; -- BTN_0
    clk_pi  : in  std_logic;
    stop_pi : in  std_logic; -- BTN_3
    led_po  : out std_logic_vector(7 downto 0)
    );
end reak_test_rand_fsm;

architecture rtl of reak_test_rand_fsm is

  -- constants
  -- 1 sec = 1 * CLK_FRQ 
  constant c_delay_time : unsigned(26 downto 0) := to_unsigned(1*CLK_FRQ-1,27); 
  -- 10 ms = CLK_FRQ / 100
  constant c_tick_time : unsigned(26 downto 0) := to_unsigned(CLK_FRQ/100-1,27); 
  -- 5 ms = CLK_FRQ / 200 =  c_tick_time/2
  constant c_round_time : unsigned(26 downto 0) := to_unsigned(CLK_FRQ/200-1,27); 
  -- 250 ms = CLK_FRQ / 8
  constant c_blink_time : unsigned(26 downto 0) := to_unsigned(CLK_FRQ/8-1,27); 
  -- 640 ms in unit of 10 ms = 0x40 = 64
  constant c_time_out : unsigned(7 downto 0) := to_unsigned(64,8); 
  -- FSM state
  type state is (s_del_1s, s_del_rand, s_measure, s_done, s_cheat, s_timeout);
  signal c_st, n_st : state;
  -- signals
  signal cnt_done    : std_logic;                    -- event signal 
  signal time_out    : std_logic;                    -- event signal 
  signal meas_done   : std_logic;                    -- event signal 
  signal start_rand  : std_logic;                    -- event signal 
  signal start_meas  : std_logic;                    -- event signal 
  signal start_blink : std_logic;                    -- event signal
  signal com_cnt     : unsigned(26 downto 0);        -- common counter
  signal end_tme     : unsigned(26 downto 0);        -- end time for common counter
  signal meas_time   : unsigned( 7 downto 0);        -- measured time in 10 ms ticks
  signal led_out     : std_logic_vector(7 downto 0); -- internal led_po signal
  signal rand_cnt    : unsigned(26 downto 0) := to_unsigned(CLK_FRQ/2,27);

begin
  
  -- output assignment
  led_po <= led_out;

  -----------------------------------------------------------------------------
  -- sequential process: Common and random Counter
  -- # of FFs: 27 + 27 + 27 + 8 + 1 + 1 = 91
  P_cnt: process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      -- NOTE: no reset for rnd_cnt 
     end_tme   <= c_delay_time;
     com_cnt   <= (others => '0');
     meas_time <= (others => '0');
     cnt_done  <= '0';
     time_out  <= '0';
    elsif rising_edge(clk_pi) then
      -- random counter without reset, always running... --
      if rand_cnt < c_delay_time then
        rand_cnt <= rand_cnt + 1;
      else
        rand_cnt <= (others => '0');
      end if;
      -- common counter -----------------------------------
      cnt_done <= '0'; -- default for event signal
      time_out <= '0'; -- default for event signal
      com_cnt  <= (others => '0');
      if com_cnt < end_tme then
        -- count up
        com_cnt <= com_cnt + 1;
      elsif com_cnt = end_tme then
        -- end value reached
        cnt_done  <= '1';
      end if;
      -- meas_time counter ----------------------------------
      if start_meas = '1' then
        meas_time <= (others => '0');
      elsif cnt_done = '1' then
        meas_time <= meas_time + 1;
        if meas_time = c_time_out then
          -- time out: set meas_time to max
          meas_time <= (others => '1');
          time_out <= '1';
        end if;
      end if;
      -- store end value for counter ------------------------
      if start_rand = '1' then
        end_tme <= rand_cnt;
      elsif start_meas = '1' then
        com_cnt <= c_round_time; -- init to resolution/2 
        end_tme <= c_tick_time;
      elsif start_blink = '1' then
        end_tme <= c_blink_time;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: LED Control
  -- # of FFs: 8
  P_LED_ctrl: process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      led_out <= (others => '0');
    elsif rising_edge(clk_pi) then
      if start_meas = '1' then
        led_out <= ('1', others => '0');
      elsif start_blink = '1' then
        led_out <= not led_out;
      elsif meas_done = '1' then
        led_out <= std_logic_vector(meas_time);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : cnt_done, stop_pi, time_out
  -- Outputs: meas_done, start_rand, start_meas, start_blink
  -- States : s_del_1s, s_del_rand, s_measure, s_done, s_cheat, s_timeout
  -----------------------------------------------------------------------------
  -- memoryless process
  P_MemoryLess: process (c_st, cnt_done, stop_pi, time_out)
  begin
    -- default assignments
    n_st <= c_st;  -- remain in current state
    meas_done <= '0';
    start_rand <= '0';
    start_meas <= '0';
    start_blink <= '0';
    
    -- specific assignments
    case c_st is
      when s_del_1s =>
        -- prio 2: random time start
        if cnt_done = '1' and not stop_pi = '1' then
          start_rand <= '1';
          n_st <= s_del_rand;
        -- prio 1: cheated
        elsif stop_pi = '1' then
          start_blink <= '1';
          n_st <= s_cheat;
        end if;
        
      when s_del_rand =>
         -- prio 2: measurement start
        if cnt_done = '1' and not stop_pi = '1' then
          start_meas <= '1';
          n_st <= s_measure;
        -- prio 1: cheated
        elsif stop_pi = '1' then
          start_blink <= '1';
          n_st <= s_cheat;
        end if;
        
      when s_measure =>
        -- prio 2: timeout
        if time_out = '1' and not stop_pi = '1' then
          meas_done <= '1';
          n_st <= s_timeout;
        -- prio 1: done
        elsif stop_pi = '1' then
          meas_done <= '1';
          n_st <= s_done;
        end if;
        
      when s_cheat => 
        if cnt_done = '1' then
          start_blink <= '1';
        end if;
        
      when s_done =>
        -- wait for reset after normal measurement
        null;
        
      when s_timeout =>
        -- wait for reset after timeout
        null;
        
      when others =>
        n_st <= s_cheat; -- handle parasitic state
    end case;
  end process;
  
  
  ----------------------------------------------------------------------------- 
  -- sequential process
  p_seq: process (rst_pi, clk_pi)
  begin
    -- reset state when reset button is pressed
    if rst_pi = '1' then
      c_st <= s_del_1s;
    -- update state on rising edge
    elsif rising_edge(clk_pi) then
      c_st <= n_st;   
    end if;
  end process;
 
end rtl;
